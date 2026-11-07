#!/usr/bin/env python3
"""Validate the pinned denominator and documentary traces; optionally probe examples."""
import argparse
import collections
import hashlib
from functools import lru_cache
import json
from pathlib import Path
import re
import subprocess
import tempfile

BASELINE = "f12ce06810f602fce08c048476c9a522c862c83e"

@lru_cache(maxsize=None)
def historical_text(file):
    return subprocess.check_output(["git", "show", BASELINE + ":" + str(file)], cwd=ROOT, text=True)

def historical_files(directory):
    return subprocess.check_output(["git", "ls-tree", "-r", "--name-only", BASELINE, directory], cwd=ROOT, text=True).splitlines()

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'docs/api/spec/tmdb-v3.json'
AUDIT = ROOT / 'docs/api/implemented-api-audit.json'
METHODS = {'get', 'post', 'put', 'patch', 'delete', 'head', 'options', 'trace'}
EXPECTED_HASH = '1c709375fe994e58c5a35aba7c9abfa7f28aa7103ed6c2052ea5ab0b62af081b'


def validate():
    raw = SPEC.read_bytes()
    spec = json.loads(raw)
    audit = json.loads(AUDIT.read_text())
    assert hashlib.sha256(raw).hexdigest() == EXPECTED_HASH == audit['contract_sha256']
    assert len(raw) == 3054059 and spec['openapi'] == '3.1.0'
    official = {method.upper() + ' ' + path: (path, method, op)
                for path, item in spec['paths'].items()
                for method, op in item.items() if method in METHODS}
    rows = audit['operations']
    assert len(official) == len(rows) == 152 and len(spec['paths']) == 148
    assert len({r['key'] for r in rows}) == len(rows)
    assert set(official) == {r['key'] for r in rows}
    statuses = {'public-current', 'public-needs-update', 'internal-only',
                'declaration-only', 'absent', 'deprecated'}
    plan = (ROOT / 'docs/superpowers/plans/2026-11-06-api-refresh.md').read_text()
    for row in rows:
        path, method, original = official[row['key']]
        assert path.startswith('/3/') and row['operation_id'] == original['operationId']
        assert row['status'] in statuses
        assert row['parameters'] == original.get('parameters', [])
        assert row['request_body'] == original.get('requestBody')
        assert set(row['response_fields']) == set(original['responses'])
        for task in row['repair_tasks']:
            assert re.search(r'^#{3,4} Task ' + re.escape(task) + ':', plan, re.M), task
        expected_fields = {}
        def flatten(schema, path='$', required=None):
            fields = [dict(path=path, type=schema.get('type', 'unspecified'), required=required,
                           nullable=schema.get('nullable', 'unspecified'), enum=schema.get('enum'))]
            for name, value in schema.get('properties', {}).items():
                req = name in schema['required'] if 'required' in schema else 'unspecified'
                fields += flatten(value, path + '.' + name, req)
            if isinstance(schema.get('items'), dict):
                fields += flatten(schema['items'], path + '[]', None)
            return fields
        for status, response in original['responses'].items():
            schema = response.get('content', {}).get('application/json', {}).get('schema', {})
            expected_fields[status] = flatten(schema)
        assert row['response_fields'] == expected_fields, row['key']
        if row.get('model_gaps'):
            assert row['repair_tasks'], row['key']
    for finding in audit['manual_model_findings']:
        assert finding['repair_tasks']
        for task in finding['repair_tasks']:
            assert re.search(r'^#{3,4} Task ' + re.escape(task) + ':', plan, re.M)
    public = audit['public_methods']
    assert len(public) == 82 and len({p['symbol'] for p in public}) == 82
    # Exclude three local cache/authenticator utilities; all other public funcs dispatch.
    all_signatures = []
    for file in historical_files('Sources/TMDBKit/Networking/APIClient'):
        for signature in re.findall(r'public func [^\n{]+', historical_text(file)):
            if not any('func ' + name + '(' in signature for name in
                       ['updateAuthenticator', 'cacheDiskStorageSize', 'clearCaches']):
                all_signatures.append(signature.strip())
    assert collections.Counter(all_signatures) == collections.Counter(p['signature'] for p in public)
    for method in public:
        assert method['signature'] in historical_text(method['file'])
        for group in ['public_tests', 'endpoint_tests']:
            for test in method[group]:
                assert 'func ' + test['name'].split('.')[-1] + '(' in historical_text(test['file'])
        for model in method['models']:
            assert 'struct ' + model['name'].split('.')[-1] in historical_text(model['file'])
        mapped = [r for r in rows if r['public_symbol'] == method['symbol']]
        assert {r['operation_id'] for r in mapped} == set(method['operation_ids'])
    assert sum(r['public_present'] for r in rows) == 85
    counts = dict(sorted(collections.Counter(r['status'] for r in rows).items()))
    print('PASS: pinned SHA-256; 148 paths; 152 unique operations; 82 public methods; 85 intended operation mappings')
    print('Statuses: ' + ', '.join(f'{k}={v}' for k, v in counts.items()))
    print('PASS: HISTORICAL baseline signatures/models/tests via git show ' + BASELINE + '; schema denominator and repair references')
    validate_final(official, audit)
    return spec, audit



def validate_final(official, baseline):
    final = json.loads((ROOT / 'docs/api/final-api-inventory.json').read_text())
    assert final['baseline_revision'] == BASELINE
    subprocess.run(['git', 'diff', '--exit-code', final['source_revision'], '--', 'Sources/TMDBKit', 'Tests/TMDBKitTests', 'Package.swift'], cwd=ROOT, check=True, stdout=subprocess.DEVNULL)
    assert final['contract_sha256'] == EXPECTED_HASH
    rows = final['operations']
    assert len(rows) == len({r['key'] for r in rows}) == 152
    assert {r['key'] for r in rows} == set(official)
    old = {r['key']: r for r in baseline['operations']}
    missing = []
    coverage = (ROOT / 'docs/api/test-coverage.md').read_text()
    backlog = (ROOT / 'docs/api/missing-implementations.md').read_text()
    for row in rows:
        prior = old[row['key']]
        assert row['baseline_status'] == prior['status']
        assert row['public_present'] == prior['public_present']
        assert row['snapshot_deprecated'] == prior['snapshot_deprecated']
        assert row['reference_deprecated'] == prior['reference_deprecated']
        assert row['operation_id'] == prior['operation_id']
        assert row['final_status'] == ('deprecated' if prior['status'] == 'deprecated' else
                                       'public-current' if prior['public_present'] else prior['status'])
        if row['public_present']:
            assert row['tests'] and '| `' + row['key'] + '` |' in coverage
            source = (ROOT / row['source_file']).read_text()
            invocation = re.search(r'\.([A-Za-z]+)\(', row['public_invocation'])
            assert invocation and 'func ' + invocation[1] + '(' in source, row['key']
            for test in row['tests']:
                assert 'func ' + test['name'].split('.')[-1] + '(' in (ROOT / test['file']).read_text(), test
            for file in row['model_files']:
                assert (ROOT / file).is_file()
        else:
            missing.append(row)
            # One detailed heading for each missing key, including the deprecated entry.
            assert len(re.findall(r'^#{3,4} `' + re.escape(row['key']) + '`$', backlog, re.M)) == 1, row['key']
            for key in ['auth', 'response_requirement', 'proposed_group', 'dependencies', 'next_work', 'priority', 'relative_size']:
                assert row[key], (row['key'], key)
            for file in row['fixture_assets'] + row['model_candidates']:
                assert (ROOT / file).is_file(), file
            if row['endpoint_file']:
                source = (ROOT / row['endpoint_file']).read_text()
                assert 'case ' + row['endpoint_symbol'].split('.')[-1] in source
    declarations = []
    for file in sorted((ROOT / 'Sources/TMDBKit/Networking/APIClient').glob('*.swift')):
        for number, line in enumerate(file.read_text().splitlines(), 1):
            if ('public func ' in line or (file.name == 'TMDB+Compatibility.swift' and line.strip().startswith('func '))) and not any(
                    'func ' + name + '(' in line for name in ['updateAuthenticator', 'cacheDiskStorageSize', 'clearCaches']):
                declarations.append(dict(file=str(file.relative_to(ROOT)), line=number, signature=line.strip().removesuffix(' {')))
    assert declarations == final['public_method_declarations'] and len(declarations) == 101
    assert len(missing) == 67 and sum(r['public_present'] for r in rows) == 85
    assert sum(r['final_status'] == 'public-current' for r in rows) == 84
    assert sum(r['final_status'] == 'deprecated' for r in missing) == 1
    assert collections.Counter(r['final_status'] for r in missing) == dict(absent=40, **{'declaration-only':18, 'internal-only':8, 'deprecated':1})
    expected = dict(operations=152, paths=148, public_operations=85, supported_public_operations=84,
                    missing_public_operations=67, supported_missing_operations=66,
                    deprecated_public_operations=1, deprecated_missing_operations=1, public_method_declarations=101)
    assert final['counts'] == expected
    readme = (ROOT / 'README.md').read_text()
    for family in {r['family'] for r in rows}:
        supported = [r for r in rows if r['family'] == family and r['final_status'] != 'deprecated']
        exposed = sum(r['public_present'] for r in supported)
        state = 'complete' if exposed == len(supported) else 'partial' if exposed else 'not exposed'
        assert f'| {family} | {state} | {exposed} / {len(supported)} |' in readme
    decisions = (ROOT / 'docs/api/implementation-decisions.md').read_text()
    tests = '\n'.join(p.read_text() for p in (ROOT / 'Tests/TMDBKitTests').glob('*.swift'))
    for name in re.findall(r'`(?:[A-Za-z]+Tests\.)?(test[A-Za-z0-9_]+)`', decisions):
        assert 'func ' + name + '(' in tests, name
    # Relative Markdown destinations only; external source pages are pinned documentary references.
    documents = [ROOT / 'README.md', ROOT / 'docs/superpowers/plans/2026-11-06-api-refresh.md', ROOT / 'docs/superpowers/specs/2026-11-06-api-refresh-design.md'] + list((ROOT / 'docs/api').glob('*.md'))
    links = 0
    for document in documents:
        for target in re.findall(r'\]\((<[^>]+>|[^)]+)\)', document.read_text()):
            target = target.strip('<>')
            if re.match(r'[a-z]+:', target) or target.startswith('#'):
                continue
            path = target.split('#')[0]
            assert (document.parent / path).is_file(), (document, target)
            links += 1
    print('PASS: FINAL 152 operation statuses; 85 public with source/model/test references; 67 unique missing entries (66 supported + 1 deprecated)')
    print('PASS: FINAL 101 current public declarations; missing assets/auth/dependencies/work; ' + str(links) + ' relative documentation links')

def probe_examples(spec, audit):
    work = Path(tempfile.mkdtemp(prefix='tmdb-contract-probe-', dir='/tmp'))
    methods = {oid: method for method in audit['public_methods'] for oid in method['operation_ids']}
    swift = ['import Foundation', 'let decoder = JSONDecoder()',
             'decoder.keyDecodingStrategy = .convertFromSnakeCase']
    count = 0
    for row in audit['operations']:
        if not row['public_present']:
            continue
        method, path = row['key'].split(' ', 1)
        operation = spec['paths'][path][method.lower()]
        typ = methods[row['operation_id']]['response'].replace('HTTPResponseContaining<', '').rstrip('>')
        for status, response in operation['responses'].items():
            if not status.startswith('2'):
                continue
            examples = response.get('content', {}).get('application/json', {}).get('examples', {})
            for name, example in examples.items():
                value = example['value']
                if isinstance(value, str):
                    value = json.loads(value)
                payload = work / f'example-{count}.json'
                payload.write_text(json.dumps(value))
                label = row['operation_id'] + ':' + status + ':' + name
                swift.append('do { let data = try Data(contentsOf: URL(fileURLWithPath: ' + json.dumps(str(payload)) +
                             ')); _ = try decoder.decode(' + typ + '.self, from: data); print(' + json.dumps(label + ' PASS') +
                             ') } catch { print(' + json.dumps(label + ' FAIL ') + ' + String(describing: error)) }')
                count += 1
    source = work / 'main.swift'
    source.write_text('\n'.join(swift))
    binary = work / 'probe'
    sources = []
    for file in historical_files('Sources/TMDBKit'):
        if file.endswith('.swift'):
            target = work / file
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(historical_text(file))
            sources.append(str(target))
    subprocess.run(['swiftc', '-module-cache-path', '/tmp/tmdbkit-swift-cache', *sources,
                    str(source), '-o', str(binary)], check=True, cwd=ROOT)
    result = subprocess.run([str(binary)], check=True, capture_output=True, text=True)
    (work / 'results.txt').write_text(result.stdout)
    passed = sum(line.endswith(' PASS') for line in result.stdout.splitlines())
    failures = [line for line in result.stdout.splitlines() if ' FAIL ' in line]
    assert count == 85 and passed == 79 and len(failures) == 6
    print(f'Baseline example probe: {passed}/{count} decoded; {len(failures)} failures (5 actionable, 1 empty upstream example)')
    for failure in failures:
        print(failure)
    print(f'Probe evidence: {work}/results.txt')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--probe-examples', action='store_true', help='materialize and compile git baseline sources and decode pinned successful examples')
    args = parser.parse_args()
    result = validate()
    if args.probe_examples:
        probe_examples(*result)
