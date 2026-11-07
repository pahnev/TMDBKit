# TMDB v3 API refresh: proposed scope

This document records the scope based on the user's three-stage request. The user approved implementation using subagents and an isolated worktree on 2026-11-06.

## Intent and deliverables

1. Review existing implementations against the current TMDB v3 reference and correct their request and response contracts.
2. Expand tests for those APIs beyond successful fixture parsing, including requests sent through the public client, meaningful model assertions, and failure behavior.
3. Produce a complete map of documented operations that the library does not expose as working public APIs. Implementing that backlog is a separate project.

Stage one includes regression tests for each fix. Stage two adds systematic coverage after the corrected behavior is established. Stage three publishes the missing-operation backlog after the audit and coverage results have settled.

## Proposed constraints

- Scope is TMDB v3 at `https://api.themoviedb.org/3/`; v4 is excluded.
- Retain `// swift-tools-version:5.1` and add no package dependencies.
- Retain the callback-based public API and existing `TMDBResult<T>` completion style.
- Preserve existing public call sites through defaults, overloads, or deprecated compatibility accessors; document any unavoidable source break before implementing it.
- Use deterministic offline XCTest tests; no real credentials or live API mutations.
- Treat endpoint declarations, fixtures, and README checkboxes as evidence, not proof of a usable public implementation.
- Do not implement missing endpoint families in this update; catalog them with proposed follow-up order.
- Do not change branches, push, merge, or change global settings as part of planning.

The Swift and dependency constraints preserve the current package. The v3 boundary follows the README and supplied reference. These are proposed decisions, not additional requirements supplied by the user.

## Sources and precedence

- [TMDB v3 reference](https://developer.themoviedb.org/reference/getting-started)
- [Official v3 OpenAPI document](https://developer.themoviedb.org/openapi/tmdb-api.json)
- Individual endpoint reference pages and linked authentication/append-response guides.

At execution, capture the official OpenAPI file, its SHA-256, retrieval date, and the repository revision being audited. Enumerate operations by `(HTTP method, normalized path)`, retaining `operationId` for traceability. Inspect the human reference for authentication and behavior that the schema does not capture. If the two disagree, record the exact disagreement and evidence; do not silently invent a contract. Examples are test inputs, not a complete nullability specification. Never infer required response fields solely from an example.

## Existing structure and baseline

Inspected revision: `f12ce06810f602fce08c048476c9a522c862c83e`.

- `Sources/TMDBKit/Networking/Endpoints/`: internal routing, methods, bodies, headers, and default cache policy.
- `Sources/TMDBKit/Networking/APIClient/`: public endpoint groups and response dispatch.
- `Sources/TMDBKit/Model/` and `Sources/TMDBKit/Responses/`: Codable response types.
- `NetworkClient.swift`, `TMDB.swift`, and `Authenticator.swift`: URLSession transport, caching, authentication, and decoding.
- `Tests/TMDBKitTests/`: XCTest suites, URLProtocol interception, and historical JSON fixtures.
- `Package.swift` is the active SwiftPM package. `project.yml` contains older source/dependency settings; do not modernize it incidentally.

Baseline verification on 2026-11-06: **120 tests passed** with coverage enabled. The sandbox required writable module-cache paths; the successful command is in the plan. The initial working tree contained untracked additions that disappeared during inspection. The final baseline was clean; recheck at execution rather than relying on the earlier transient files.

Tests already cover some endpoint URLs, methods, bodies, and headers. The largest weakness is that tests can assert the implementation's own assumptions: fixture selection comes from endpoint URLs, most successful calls assert only a non-nil result, and the TV rating test uses equal ID/rating inputs.

## Preliminary findings, not an exhaustive audit

| Finding | Repository evidence | Official evidence / next check |
| --- | --- | --- |
| Movie similarity uses an obsolete path | `Movies.similarMovies` builds `similar_movies` | [Current path is `/movie/{movie_id}/similar`](https://developer.themoviedb.org/reference/movie-similar) |
| TV rating serializes the first associated value, the series ID | `TV.httpBody` matches `.rateShow(let rating, _)` while the declaration orders `tvId` first | [TV add rating](https://developer.themoviedb.org/reference/tv-series-add-rating); use distinct ID/rating values |
| List clear omits confirmation | `Lists.clearList` builds only the path | [Clear requires `confirm`](https://developer.themoviedb.org/reference/list-clear) |
| TV account states omit the configured user session | Public method calls `fetchObject`, unlike movie account states | Verify user/guest authentication choices against the current account-states reference |
| Create-session token is duplicated in URL and JSON | `Authentication.createSession` appends a query token and encodes a body token | [Create session documents the JSON body](https://developer.themoviedb.org/reference/authentication-create-session) |
| Existing APIs omit documented filters | Movie changes has a TODO; movie search accepts only query/page | [Movie changes](https://developer.themoviedb.org/reference/movie-changes), [Movie search](https://developer.themoviedb.org/reference/search-movie) |
| Some internal declarations have no usable public surface | TV seasons/episodes/groups lack Endpoint conformance; six Search cases have no public method; Reviews has no public wrapper | Classify separately as declaration-only/internal-only; verify operation existence in the snapshot |
| Response shapes require detailed review | TV changes exposes `items`; change values are narrowly typed; provider regions are fixed properties; recommendation images are nonoptional | Audit with documented responses and provenance-backed boundary fixtures before selecting exact model changes |

## Approaches considered

**Proposed: audit existing behavior, repair it, strengthen coverage, then publish the gap map.** This follows the user's sequence and avoids making a misleading completeness claim from filenames or fixtures. The initial inventory supports the later gap map but is not its final deliverable.

**Alternative: add all missing APIs while refreshing existing ones.** Much larger scope, entangles new public interface decisions with repairs, and exceeds the requested third-stage mapping deliverable.

**Alternative: replace the client with generated OpenAPI code.** Could improve repeatability, but changes the public surface and transport architecture and is unnecessary for the requested update.

## Audit and acceptance rules

The inventory has one row per documented v3 HTTP operation plus a separate table of obsolete/local-only routes. Each row records method/path, operation ID, reference URL, deprecation, auth, parameters/body, response types, endpoint symbol, public method signature, models, test names, discrepancies, and status.

Statuses: `public-current`, `public-needs-update`, `internal-only`, `declaration-only`, `absent`, `deprecated`. A deprecated row also records whether it has a public implementation. Presence of a fixture never promotes a status.

Stage one is complete only when every currently public operation has an audited contract and every confirmed discrepancy is fixed or explicitly recorded as an unresolved decision. Unresolved decisions block a claim of full alignment. Newly discovered fixes receive concrete tasks, signatures, and regression assertions before coding; the preliminary findings do not bound the audit.

Stage two is complete when every public operation has request/response tests and every relevant failure dimension is either tested or explicitly justified as not applicable. Shared transport cases can be tested once at that boundary. Record line/function coverage as supporting evidence, not a substitute for operation coverage or an arbitrary percentage target.

Stage three is complete when every documented operation maps to a final status and each missing public operation has an actionable backlog entry. Include partial families, internal-only implementations, deprecated operations, required models/auth, dependencies, and suggested priority. No missing-family implementation is required.

## Remaining decisions

The exhaustive audit will establish additional contract discrepancies and any public-model compatibility problems. It must settle those with evidence before their implementation tasks are executed. The user reviews this scope and the accompanying plan before implementation begins.

## Audit compatibility decisions (2026-11-06)

Task 1 captured 152 official operations and traced 82 existing public network methods. The [audit](../../api/implemented-api-audit.md) and expanded Task 7 ledger define exact repairs before runtime implementation. Model additions retain callback APIs, Swift tools 5.1 and existing call sites through additive fields and documented compatibility projections wherever possible.

One unavoidable source exception is approved before implementation: `Media.episode(LastEpisodeToAir)` and `TaggedImageResponse.Result.MediaType.episode` represent the official tagged-image episode payload. Downstream exhaustive switches over those public enums must add an episode case. Task 7J adds namespace-valid `DetailsAppendable.movieCredits`, `.tvCredits`, `.combinedCredits`; downstream exhaustive switches over that enum also need those cases. Existing public method signatures/result types remain. Mapping an episode to a TV series or adding a second tagged-image method would conceal the actual contract and is not the chosen design.

The snapshot lacks sufficient evidence to settle recommendation-specific image nullability and legacy `/3/account`/default account ID `0` semantics; the movie-recommendations response schema/example is also empty. Record these limits without weakening required IDs/pagination or guessing a server convention. Preserve legacy account entry points with explicit compatibility documentation and add an explicit-ID details overload for the documented route. These evidence gaps prevent a claim of full alignment; stage-two deterministic coverage may proceed once all confirmed mismatches have been repaired. Human-reference deprecation markers for tagged images and keyword movies conflict with the snapshot flags and remain visible in the inventory.


## Execution outcome (2026-11-07)

The approved three stages are complete: confirmed existing-contract repairs, 85-operation public wire/model coverage, then the [67-operation missing-public map](../../api/missing-implementations.md). [Final reconciliation](../../api/implemented-api-audit.md#final-reconciliation-2026-11-07) distinguishes 152 final statuses from the unchanged Task 1 baseline. The fresh final serial run passed 265 tests. [Implementation decisions](../../api/implementation-decisions.md) retain controller rulings, costs and migrations, including the superseded metadata policy and final media round-trip behavior. [Response evidence boundaries](../../api/response-evidence-boundaries.md) remain UNKNOWN where the pinned source is incomplete; completion does not claim full upstream-schema alignment or new missing-family APIs.
