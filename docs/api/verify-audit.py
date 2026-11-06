#!/usr/bin/env python3
"""Validate the pinned denominator and documentary traces; optionally probe examples."""
import argparse
import collections
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tempfile

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
    for file in sorted((ROOT / 'Sources/TMDBKit/Networking/APIClient').glob('*.swift')):
        for signature in re.findall(r'public func [^\n{]+', file.read_text()):
            if not any('func ' + name + '(' in signature for name in
                       ['updateAuthenticator', 'cacheDiskStorageSize', 'clearCaches']):
                all_signatures.append(signature.strip())
    assert collections.Counter(all_signatures) == collections.Counter(p['signature'] for p in public)
    for method in public:
        assert method['signature'] in (ROOT / method['file']).read_text()
        for group in ['public_tests', 'endpoint_tests']:
            for test in method[group]:
                assert 'func ' + test['name'].split('.')[-1] + '(' in (ROOT / test['file']).read_text()
        for model in method['models']:
            assert 'struct ' + model['name'].split('.')[-1] in (ROOT / model['file']).read_text()
        mapped = [r for r in rows if r['public_symbol'] == method['symbol']]
        assert {r['operation_id'] for r in mapped} == set(method['operation_ids'])
    assert sum(r['public_present'] for r in rows) == 85
    counts = dict(sorted(collections.Counter(r['status'] for r in rows).items()))
    print('PASS: pinned SHA-256; 148 paths; 152 unique operations; 82 public methods; 85 intended operation mappings')
    print('Statuses: ' + ', '.join(f'{k}={v}' for k, v in counts.items()))
    print('PASS: signatures, source models, named existing tests, schema denominator, repair references')
    return spec, audit


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
    sources = [str(p) for p in sorted((ROOT / 'Sources/TMDBKit').rglob('*.swift'))]
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
    parser.add_argument('--probe-examples', action='store_true', help='compile baseline sources and decode pinned successful examples')
    args = parser.parse_args()
    result = validate()
    if args.probe_examples:
        probe_examples(*result)
