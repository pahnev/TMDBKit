# TMDB v3 API Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Align existing TMDB v3 APIs with the official contract, verify their behavior comprehensively, and publish the missing-implementation map.

**Architecture:** Preserve endpoint enums, public client groups, Codable models, and URLSession transport. Start with an evidence-backed operation inventory; repair existing functionality with regression tests, then cover the public surface systematically. Finish with a documentation backlog rather than adding missing API families.

**Tech Stack:** Swift tools 5.1, SwiftPM, Foundation/URLSession/URLCache, XCTest, MockURLProtocol, llvm-cov; no new package dependencies.

**Spec:** `docs/superpowers/specs/2026-11-06-api-refresh-design.md` (approved for subagent-driven execution on 2026-11-06).

## Global Constraints

- Scope is TMDB v3 at `https://api.themoviedb.org/3/`; v4 is excluded.
- Retain `// swift-tools-version:5.1` and add no package dependencies.
- Retain the callback-based public API and existing `TMDBResult<T>` completion style.
- Preserve existing public call sites through defaults, overloads, or deprecated compatibility accessors; document any unavoidable source break before implementing it.
- Use deterministic offline XCTest tests; no real credentials or live API mutations.
- Treat endpoint declarations, fixtures, and README checkboxes as evidence, not proof of a usable public implementation.
- Do not implement missing endpoint families in this update; catalog them with proposed follow-up order.
- Do not change branches, push, merge, or change global settings as part of planning.

## Review Focus

- Distinct series ID/rating inputs must serialize the rating, not the ID: Task 3.
- Missing or replaced credentials must not send stale sessions or cross-account cache data: Tasks 4 and 9.
- Search text containing `&`, `+`, `?`, `/`, and non-ASCII characters must survive query encoding: Tasks 6 and 8.
- Documented null/absent fields and union-shaped values must preserve valid data without swallowing malformed required values: Task 7.
- Expired cache entries, conditional responses, and repeated mutations must not return stale or cached mutation results: Task 9.

---

## Execution boundaries and file map

This is an **audit-led plan**, not a claim that a complete contract audit has already happened. Task 1 must enumerate the full existing public surface and expand Task 7 / insert additional repair tasks for discoveries before executing those repairs. Each inserted task must contain exact files, public/internal signatures, source evidence, a failing assertion, and a verification command. Stage two cannot begin while known stage-one discrepancies remain unaddressed. Do not guess model changes from the preliminary findings.

The three stages are sequential. Within each stage, commit independently reviewable deliverables. Commands below assume a normal local checkout; respect existing branch/worktree permissions before execution. Planning has changed documentation only.

| Files | Responsibility |
| --- | --- |
| `docs/api/spec/tmdb-v3.json`, `docs/api/spec/README.md` (new) | Pinned official source, retrieval date/hash, documentation conflicts |
| `docs/api/implemented-api-audit.md` (new) | Full operation-to-code contract inventory and discrepancy ledger |
| Existing `Networking/Endpoints/*.swift`, `Networking/APIClient/TMDB*.swift` | Correct only existing functionality and expose missing options on existing public operations |
| Existing `Model/*.swift`, `Responses/**/*.swift` | Audit-backed response fixes; no general model rewrite |
| `Tests/TMDBKitTests/Helpers/RequestAssertions.swift` (new) | Independent wire-contract assertions shared by endpoint suites |
| Existing endpoint test files; `SearchEndpointTests.swift`, `NetworkClientTests.swift`, `NetworkCacheTests.swift`, `ResponseContractTests.swift` (new) | Public requests, model boundaries, errors, authentication, caching |
| `docs/api/test-coverage.md`, `docs/api/missing-implementations.md` (new) | Operation coverage matrix, measured coverage summary, missing-public-API backlog |
| `README.md` (modify last) | Accurate family summary with links to detailed inventories |

## Verification convention

Run tests through `xcsift` as required by the local command hook. The verified sandbox-compatible command is:

```bash
set -o pipefail
CLANG_MODULE_CACHE_PATH=/tmp/tmdbkit-clang-cache SWIFTPM_MODULECACHE_OVERRIDE=/tmp/tmdbkit-swift-cache swift test --disable-sandbox --enable-code-coverage 2>&1 | xcsift -f toon -w
```

For focused checks, add `--filter <SuiteName>` before `2>&1`. A pass means exit 0, zero failed tests, and the named suite actually ran. Compilation/tool failures do not count as the expected failing test. Baseline at `f12ce06810f602fce08c048476c9a522c862c83e`: 120 tests passed, with SwiftPM user-cache warnings.

## Stage 1 — Audit and update existing APIs

### Task 1: Pin the official contract and inventory the implemented public surface

**Files:** Create `docs/api/spec/tmdb-v3.json`, `docs/api/spec/README.md`, `docs/api/implemented-api-audit.md`; update this plan with audit-discovered repair tasks.

**Interfaces:** Consumes the official v3 OpenAPI JSON and actual repository state. Produces operation keys `METHOD /3/path/{parameter}`, public signatures, model paths, named tests, and the six statuses defined in the spec; later tasks use this inventory as their coverage denominator.

- [x] **Step 1:** Run `git status --short`, `git rev-parse HEAD`, and the full verification command; record revision, changes, test count, and failures. Do not discard unrelated work. Recheck the transient files mentioned in the spec.
- [x] **Step 2:** Save the complete JSON from `https://developer.themoviedb.org/openapi/tmdb-api.json`, validate that `openapi`, `paths`, and v3 operations exist, and record `shasum -a 256 docs/api/spec/tmdb-v3.json`. If shell networking is unavailable, use an available fetch tool; never save a truncated search excerpt as the specification.
- [x] **Step 3:** Enumerate every documented method/path and trace existing endpoints through public methods, response types, authentication, and tests. List local-only/obsolete routes separately. Read linked guides for session requirements and append behavior. Record exact source links for discrepancies.
- [x] **Step 4:** For every public operation compare path/method, required and optional parameters, defaults, JSON body/headers, user/guest auth, response keys/types/nullability, pagination, and supported appended resources. Add missing concrete repair tasks to this plan, including the exact model/signature/test decisions; record incompatible public-model choices before implementing them.
- [x] **Step 5:** Validate inventory completeness: one row per documented HTTP operation, no duplicate method/path keys, every current public network method traced, and every known discrepancy assigned to a task. Document counts and evidence, not guessed completeness percentages.
- [x] **Step 6:** Commit the contract snapshot, audit, and expanded plan: `docs: audit existing APIs against pinned TMDB v3 contract`.

### Task 1A: Stabilize existing JSON object-body assertions

**Files:** `Tests/TMDBKitTests/AccountEndpointTests.swift`, `ListEndpointTests.swift`, `MovieEndpointTests.swift`, `TVEndpointTests.swift`, `AuthenticationEndpointTests.swift`. No production edits.

The Task 1 baseline was 118 passed / 2 failed because raw encoded JSON `Data` equality assumes dictionary key order. Treat this as a test defect, not a TMDB regression.

- [ ] Replace byte equality in `AccountEndpointTests.test_markFavorite_httpBody`, `test_addToWatchList_httpBody`; `ListEndpointTests.test_createListHTTPBody`, `test_addMovie_HTTPBody`, `test_removeMovie_HTTPBody`; `MovieEndpointTests.test_rateMovie_httpBody`; `TVEndpointTests.test_rateShow_httpBody`; `AuthenticationEndpointTests.test_createSession_HTTPBody`, `test_deleteSession_HTTPBody` with semantic JSON object assertions. Decode the actual body, assert exact key set and independent expected literal values/types. Preserve nil-body assertions in the existing `test_httpBody` tables. No sorting or production encoder change is needed.
- [ ] Use distinct ID/rating values in later Task 3 regressions; this stabilization alone must not silently implement that runtime repair.
- [ ] Run the full verification command with `pipefail` and xcsift; expect 120 tests passing before Task 2. Commit separately: `test: compare request JSON bodies semantically`.

### Task 2: Correct the movie similarity route

**Files:** Modify `Sources/TMDBKit/Networking/Endpoints/Movies.swift`, `Tests/TMDBKitTests/MovieEndpointTests.swift`, `Tests/TMDBKitTests/StubHelper.swift` only if needed; create `Tests/TMDBKitTests/Fixtures/Movie/v3_movie_284054_similar.json` from the existing similarity payload.

**Interfaces:** Preserve `MovieEndpoints.similarMovies(for:pageNumber:language:completion:) -> Void` and `TMDBResult<PopularMoviesResponse>`. `Movies.similarMovies` must build `/3/movie/{movie_id}/similar`.

- [ ] **Step 1:** Add `testSimilarMoviesUsesCurrentRoute` with independent assertions:

```swift
let url = Movies.similarMovies(movieId: 284054, pageNumber: 2, language: "fi-FI").url
XCTAssertEqual(url.path, "/3/movie/284054/similar")
let query = URLComponents(url: url, resolvingAgainstBaseURL: false)!.queryItems!
XCTAssertTrue(query.contains(URLQueryItem(name: "page", value: "2")))
XCTAssertTrue(query.contains(URLQueryItem(name: "language", value: "fi-FI")))
```

- [ ] **Step 2:** Run `MovieEndpointTests`; expect the new literal path assertion to fail.
- [ ] **Step 3:** Change only the route component to `similar`; add the correctly named fixture and update old literal URL assertions. Keep old fixture files unless explicit deletion is authorized. Do not make the stub accept both paths, which would conceal the bug.
- [ ] **Step 4:** Run `MovieEndpointTests`; expect all tests to pass, including public response parsing.
- [ ] **Step 5:** Commit the exact changed files: `fix: use current movie similarity endpoint`.

### Task 3: Correct rating serialization and list-clear confirmation

**Files:** Modify `Sources/TMDBKit/Networking/Endpoints/TV.swift`, `Sources/TMDBKit/Networking/Endpoints/Lists.swift`, `Tests/TMDBKitTests/TVEndpointTests.swift`, `Tests/TMDBKitTests/ListEndpointTests.swift`.

**Interfaces:** Preserve `TV.rateShow(tvId: Int, rating: Double)` and `Lists.clearList(listId: String)`. Existing public `rateShow` and `clear` calls remain unchanged; invoking `clear` means confirming that explicit operation.

- [ ] **Step 1:** Replace the equal-input rating test with these assertions, and add `testClearListIncludesConfirmation`:

```swift
let data = try XCTUnwrap(TV.rateShow(tvId: 1399, rating: 8.5).httpBody)
let body = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Double])
XCTAssertEqual(body, ["value": 8.5])
XCTAssertEqual(TV.rateShow(tvId: 1399, rating: 8.5).url.path, "/3/tv/1399/rating")
let query = URLComponents(url: Lists.clearList(listId: "1").url, resolvingAgainstBaseURL: false)!.queryItems!
XCTAssertEqual(query.filter { $0.name == "confirm" }, [URLQueryItem(name: "confirm", value: "true")])
```

- [ ] **Step 2:** Run `TVEndpointTests` and `ListEndpointTests`; expect rating-body and confirmation assertions to fail.
- [ ] **Step 3:** Bind the second TV associated value as the rating and append exactly one `confirm=true` query item for clearing; update existing URL expectations.
- [ ] **Step 4:** Run both suites; expect pass. Include `0.5` and `10.0` as serialized boundary ratings with an unrelated ID.
- [ ] **Step 5:** Commit: `fix: serialize TV ratings and confirm list clearing`.

### Task 4: Repair session propagation for existing APIs

**Files:** Modify `Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift`, `Sources/TMDBKit/Networking/APIClient/TMDB.swift`, `Sources/TMDBKit/Networking/NetworkClient.swift`, `Sources/TMDBKit/Networking/Endpoints/Authentication.swift`; test in `Tests/TMDBKitTests/AuthenticationEndpointTests.swift` and `Tests/TMDBKitTests/TVEndpointTests.swift`.

**Interfaces:** Preserve `TVEndpoints.accountStates(for:language:completion:)`, `TMDB.updateAuthenticator(_:)`, and `TMDB.createSession(requestToken:completion:)`. Add internal `NetworkClient.updateAuthenticator(_ authenticator: Authenticator) -> Void`; `TMDB.updateAuthenticator` updates both consumers. Preserve public `Authenticator` requirements.

- [ ] **Step 1:** Add `testTVAccountStatesSendsConfiguredSession` using a captured URLRequest and a valid account-state payload; assert one `session_id=456`. Add `testTVAccountStatesWithoutSessionDoesNotRequest`: completion carries `sessionIdMissing` (allow the existing transport error wrapper), request count is zero. Confirm the reference's auth contract in Task 1 before changing it.
- [ ] **Step 2:** Add `testUpdatedAuthenticatorIsUsedByTransport`: initialize with API key/session A, call `updateAuthenticator` with B, request account states, and assert the outgoing query contains B exactly once and never A. Add `testCreateSessionTokenOnlyInJSONBody`: POST path `/3/authentication/session/new`, body `request_token=token-123`, no query token.
- [ ] **Step 3:** Run both suites; expect failures for omitted TV session, stale credentials, and duplicated token.
- [ ] **Step 4:** Route TV account states through the authenticated parser; make the transport authenticator replaceable through the internal method; update both authenticator references; remove the create-session URL token. Preserve JSON encoding and update the query-derived session fixture lookup to use a correctly named fixture copy.
- [ ] **Step 5:** Run both suites and the full suite; expect pass, including no-session requests completing once without network access.
- [ ] **Step 6:** Commit: `fix: propagate current authentication to existing requests`.

### Task 5: Add documented date and pagination filters to existing change APIs

**Files:** Modify `Sources/TMDBKit/Networking/Endpoints/Movies.swift`, `TV.swift`, `People.swift` and corresponding `Networking/APIClient/TMDB+Movies.swift`, `TMDB+TV.swift`, `TMDB+People.swift`; test in existing family suites.

**Interfaces:** Extend each family's existing `changes(for:...)` with `startDate: String? = nil`, `endDate: String? = nil`; add `pageNumber: PageNumber = 1` to movie changes and retain the existing TV/people page labels/defaults. Completion types stay `ChangesResponse` / `TVChangesResponse`. Extend internal cases to carry these optional strings. Strings use the documented date representation; no new Date formatter abstraction.

- [ ] **Step 1:** Add `testChangesForwardsDateRangeAndPage` in all three suites, capturing public requests: ID `550` (movie), `1399` (TV), `1` (person), page `2`, `start_date=2026-11-01`, `end_date=2026-11-06`, each exactly once. Add `testChangesOmitsUnspecifiedDates`; existing call sites compile unchanged.
- [ ] **Step 2:** Run the three suites; expect compilation failure until the new options exist, then failing request assertions if forwarding is missing.
- [ ] **Step 3:** Add the signatures and forward values into URLQueryItem construction, omitting nil dates. Use Task 1's endpoint-specific parameter evidence; do not add filters to operations that do not support them.
- [ ] **Step 4:** Run the three suites; expect all tests to pass, retaining page defaults and date spelling.
- [ ] **Step 5:** Commit: `feat: support documented filters on existing change APIs`.

### Task 6: Add documented movie-search options without expanding the search family

**Files:** Modify `Sources/TMDBKit/Networking/APIClient/TMDB+Search.swift`, `Sources/TMDBKit/Networking/Endpoints/Search.swift`; create `Tests/TMDBKitTests/SearchEndpointTests.swift`.

**Interfaces:** Preserve `searchForMovies(_:page:completion:)`. Add an overload `searchForMovies(_ movies: String, page: Int, language: String?, includeAdult: Bool?, region: String?, year: String?, primaryReleaseYear: String?, completion: @escaping TMDBResult<PopularMoviesResponse>) -> Void`; old calls delegate with nil options. New option parameters intentionally have no defaults to avoid ambiguous overloads. Extend only the internal movie-search case or add a dedicated options value; preserve other cases for the inventory.

- [ ] **Step 1:** Add `testMovieSearchForwardsAllDocumentedOptions` with query `Amélie & C++?/`, page `2`, language `fi-FI`, adult `true`, region `FI`, year `2001`, primary release year `2001`; capture the request and assert decoded query values, exact `/3/search/movie` path, and one occurrence per parameter. Add `testLegacyMovieSearchOmitsUnspecifiedOptions` asserting no new query keys and a decoded empty results response.
- [ ] **Step 2:** Run `SearchEndpointTests`; expect missing overload failure before implementation.
- [ ] **Step 3:** Implement the overload using `URLQueryItem`; map `includeAdult` to `include_adult` and `primaryReleaseYear` to `primary_release_year`. Preserve nil omission and the old method's behavior.
- [ ] **Step 4:** Run `SearchEndpointTests`; expect pass for both the legacy call and special-character query.
- [ ] **Step 5:** Commit: `feat: expose current movie search filters`.

### Task 7: Complete all audit-discovered request and response repairs

**Files:** Exact production files and test fixtures are selected and recorded in Task 1; create `Tests/TMDBKitTests/ResponseContractTests.swift` and `Fixtures/Contract/` for focused decoding regressions. Update `docs/api/implemented-api-audit.md` with fix/test references.

**Interfaces:** The completed Task 1 repair entries define exact signatures and compatibility decisions. Retain existing `CodableEquatable` contracts; do not turn every field optional or replace typed APIs with unstructured dictionaries to make examples decode.

- [ ] **Step 1:** Before coding, finish the concrete repair entries for every discrepancy not covered by Tasks 2–6. Audit all currently public families, including account, movie, TV, people, trending, lists, and movie search. Explicitly decide model contracts for TV changes' top-level key, heterogeneous change values, provider regions/monetization, rated results, and nullable recommendation images from source evidence. Also check supported image/video language filters, timezone, append parameters, and guest-session options on existing operations.
- [ ] **Step 2:** For each repair entry, add its named failing test with exact source-backed input/assertions; run the owning suite and verify that the failure demonstrates the discrepancy. Tests must cover documented valid null/absent fields and heterogeneous values, plus rejection of missing required IDs and wrong required-field types. Preserve newly supported values through Codable round trips where encoding is public behavior.
- [ ] **Step 3:** Implement that entry's exact signatures/keys/types and compatibility adapter; run the focused suite to pass. Commit each independently reviewable repair with its regression fixtures and audit link before starting the next.
- [ ] **Step 4:** Reconcile all `public-needs-update` rows. Run the full suite; stage one passes only with every public operation audited and no unresolved confirmed mismatch. If a source conflict or source-breaking model decision remains, report it and do not claim full alignment.

#### Audit repair ledger (Task 1, 2026-11-06)

These entries are implementation requirements, not completed fixes. Operation IDs and JSON pointers resolve against `docs/api/spec/tmdb-v3.json`; the exhaustive method/field/test crosswalk is `docs/api/implemented-api-audit.md` and its JSON companion. All verification commands below use `CLANG_MODULE_CACHE_PATH=/tmp/tmdbkit-clang-cache SWIFTPM_MODULECACHE_OVERRIDE=/tmp/tmdbkit-swift-cache swift test --disable-sandbox --enable-code-coverage --filter <Suite> 2>&1 | xcsift -f toon -w`; substitute the named suite, inspect failures and the command status (enable shell `pipefail`). Run the full command without `--filter` after each repair group. Do not implement missing endpoint families.

#### Task 7A: Existing request options and unsupported query cleanup

- [ ] Files: `Networking/APIClient/TMDB+Movies.swift`, `TMDB+TV.swift`, `TMDB+People.swift`, `TMDB+Trending.swift`, `TMDB+Lists.swift`; corresponding `Networking/Endpoints/*.swift`, `DetailsAppendable.swift`, `Extensions/URL+QueryItem.swift`; family test suites. Add defaulted `includeImageLanguages: [String]? = nil` before completion to movie/TV `images`; add `includeVideoLanguages: [String]? = nil` to TV `videos`; add `timezone: String? = nil` to TV `airingToday` and `onTheAir`; add `language: String? = nil` to `TrendingEndpoints.trending`. Keep movie `videos` limited to the documented `language` parameter (the pinned movie operation lacks `include_video_language`). List `details` gains `pageNumber: PageNumber? = nil` before completion; `itemStatus` gains `language: String? = nil`. Delete-session retains its existing missing-user-session guard and JSON session_id body, but dispatches with application authentication to omit the undocumented duplicated session_id query; add `testDeleteSessionUsesBodyWithoutSessionQuery` asserting exactly api_key in query and one body session_id. Existing default/nil calls omit new options; nonnil arrays join with commas, including literal `null`. Keep legacy language/sort labels compiling, but stop sending undocumented `language` and `sort_by` for Account.createdLists; stop sending `language` for TV account states/alternative titles/content ratings/episode groups/external IDs/latest, People external IDs/tagged images/translations/latest, and Movies.latest. These parameters are absent from the pinned operation; document ignored compatibility arguments. `testImageLanguageFallbackQuery`, `testTVVideoLanguageFallbackQuery`, `testTVListTimezoneQuery`, `testTrendingLanguageQuery`, `testListReadOptions`, `testLegacyUndocumentedQueriesAreOmitted` must invoke public methods and assert exact decoded key/value multiplicity, no body, GET, default omission and `page=2`, `timezone=Europe/Helsinki`, `language=fi-FI`, `include_image_language=en,null`, `include_video_language=fi,en`. Verify MovieEndpointTests, TVEndpointTests, PeopleEnpointTests, TrendingEndpointTests, ListEndpointTests, AccountEndpointTests. Evidence: each affected operation's parameter array; image-language and append guides linked in audit.

#### Task 7B: Lossless change values and canonical TV key

- [ ] Files: `Model/Change.swift`, `Responses/ChangesResponse.swift`, new `Model/ChangeValue.swift`, `ResponseContractTests.swift`, `Fixtures/Contract/changes-*.json`. Movie schema/example contains an object `value.poster.file_path` and no `original_value`; person example contains a string and no `original_value`; TV example uses top-level `changes`, not `items`; TV guide also describes season/episode IDs. Define `public indirect enum ChangeValue: CodableEquatable { case string(String), integer(Int), number(Double), bool(Bool), object([String: ChangeValue]), array([ChangeValue]), null }`. Preserve the existing `Change.Item.value: String` and `originalValue: String` as deprecated computed compatibility projections (string payload or empty string); add canonical `valueData: ChangeValue?`, `originalValueData: ChangeValue?`, `iso31661: String?`, and make missing locale data optional only in new canonical properties. Keep `id`, `action`, `time`, change `key`, and item arrays typed/strict. `TVChange.Item.Value` remains public, holds `rawValue: ChangeValue`, adds `posterValue: Poster?`, and retains deprecated `poster: Poster` as a documented compatibility projection with empty `filePath`/nil locale when no poster exists; canonical data must never be replaced with that projection. `TVChange.Item` gains optional `valueData`/`originalValueData`; retain legacy nonoptional `value`/`originalValue` wrappers around `.null` when absent and retain locale string projections with empty fallback. Add `TVChangesResponse.changes: [TVChange]?`; retain `items` as deprecated alias. Decode/encode canonical wire `changes`, `value`, `original_value`; distinguish absent and explicit null using `.null`. `testMovieChangesAcceptPosterObjectAndMissingOriginalValue`, `testPersonChangesAllowMissingOriginalValue`, `testTVChangesDecodeCanonicalChanges`, `testChangeValuesRoundTripAllJSONKinds`, `testChangeRequiredFieldsRejectMalformedData`: use pinned examples plus explicitly labeled synthetic union boundaries; assert poster path, text, numeric series/episode IDs (decode integral numbers as Int before Double), null versus absent, and malformed/missing required ID rejection. Verify ResponseContractTests; no blanket `try?` for required values. Compatibility sentinels are API migration behavior, not claims that TMDB returned those strings.

#### Task 7C: Dynamic provider regions and monetization

- [ ] Files: `Model/WatchProvider.swift`, ResponseContractTests, `Fixtures/Contract/providers-*.json`. Replace fixed-region storage internally with `Results.regions: [String: ProviderResult]` and public `subscript(region: String) -> ProviderResult?`; preserve every existing lower-case accessor, including `iN`, as computed lookups by uppercase wire key. Custom keyed Codable must preserve arbitrary region keys through the package's snake-case strategy. Add `ProviderResult.ads: [WatchProvider]?` and `free: [WatchProvider]?`; keep existing buy/rent/flatrate/link types. Pinned movie example contains AE and ads, pinned TV example contains free; arrays contain typed provider IDs/names/priorities/logo paths. `testProviderRegionsPreserveAEAndUnknownRegion`, `testProviderFreeAndAdsRoundTrip`, `testLegacyProviderRegionAccessors`: assert AE, synthetic ZZ, old US/iN properties, exact provider ID, free/ads, round-trip arbitrary keys, and rejection of wrong provider-ID type. Verify ResponseContractTests, MovieEndpointTests, TVEndpointTests.

#### Task 7D: TV recommendation structure and image evidence boundary

- [ ] Files: `Responses/TV/RecommendationsResponse.swift`, ResponseContractTests, `Fixtures/Contract/tv-recommendations.json`. Pinned `tv-series-recommendations` example omits `networks`; preserve public `networks: [RecommendationNetwork]` with default empty array on absence, but reject wrong non-array types. Add optional `adult: Bool?`, `mediaType: String?` to expose documented fields. `testTVRecommendationsWithoutNetworks` decodes the pinned example and asserts first result ID 1396/name Breaking Bad, pagination, and empty networks. `testTVRecommendationsRejectMalformedIDAndNetworks` asserts missing/wrong ID and wrong networks fail. **Image nullability remains an evidence gap:** this snapshot says string and its recommendation example contains no null image paths; no authoritative recommendation-specific nullability guarantee was found. Do not silently claim those paths are required from the example, and do not change String public properties to optionals speculatively. Before a nullable-path repair, obtain authoritative provenance and choose additive optional canonical image accessors with deprecated string projections, or explicitly document an unavoidable break. `testTVRecommendationNullableImages` is reserved pending that evidence; it must not be represented as source-backed or passing yet. This unresolved item blocks a claim of full alignment, not execution of the demonstrated networks fix or stage-two coverage after confirmed mismatches are repaired. Verify ResponseContractTests and TVEndpointTests.

#### Task 7E: Existing identity/credit key repairs

- [ ] Files: `Model/List.swift`, `Responses/People/PersonDetailsResponse.swift`, `Responses/People/PersonCreditsResponse.swift`; ResponseContractTests. `list-check-item-status` schema/example uses numeric ID. Keep `ListItemStatus.id: String`, decode Int or String and normalize an Int to decimal text; encode its canonical numeric ID when numeric, preserving accepted string wire IDs for legacy compatibility; reject Bool/object IDs. Add `numericId: Int?`. Person `deathday` is a single lower-case word and is lost by `deathDay`; add canonical `deathday: String?` and retain computed `deathDay` alias. Credits `credit_id`/`genre_ids` become `creditId`/`genreIds` with convertFromSnakeCase, so explicitly map the existing `creditID`/`genreIDS` properties using coding keys whose raw values match the decoder's transformed names; add lower-camel aliases, preserving existing callers and snake-case encoding. Add `CreditsCast.order: Int?`, `mediaType: String?`. `testListItemStatusAcceptsNumericAndLegacyStringID`, `testPersonDeathdayIsPreserved`, `testPersonCreditsPreserveIDsGenresAndOrder` must assert official example ID 1, synthetic non-null deathday labeled as a key regression, actual credit ID and genre array from all three pinned credits payloads, and Codable round trips. Missing required numeric media IDs remain failures. Verify ResponseContractTests, PeopleEnpointTests, ListEndpointTests.

#### Task 7F: Typed episode media and tagged-image data

- [ ] Files: `Model/Media.swift`, `Responses/People/TaggedImageResponse.swift`, ResponseContractTests. Pinned `person-tagged-images` response result index 10 has outer `media_type=episode`, inner `media_type=tv_episode`, episode ID 1196876 and show ID 66623. Add `Media.episode(LastEpisodeToAir)` (existing model already represents every required episode field); add `TaggedImageResponse.Result.MediaType.episode`; add optional `id: String?`, `imageType: String?`. Decode Media by explicit discriminator when present (`movie`, `tv`, `person`, `tv_episode`, accepting `episode` at the tagged boundary), preserving shape fallback only for historical payloads lacking a discriminator; reject unknown explicit discriminators and malformed IDs rather than trying unrelated shapes. Encode the discriminator for round-trip stability. `testTaggedImagesDecodeEpisodeMedia`, `testMediaDiscriminatorIsRespected`, `testMediaRoundTripsAllSupportedCases` assert the exact IDs and case. **Approved unavoidable source-compatibility exception, documented before implementation:** new public enum cases require downstream exhaustive `switch` statements over Media/TaggedImageResponse.Result.MediaType to add `.episode` handling; existing taggedImages method/result signatures remain. No parallel API or false TV-show mapping. Human reference marks this operation deprecated even though snapshot `deprecated=false`; retain wrapper and document deprecation rather than remove it. Verify ResponseContractTests and PeopleEnpointTests.

#### Task 7G: Expose every audited dropped response field without widening unrelated requirements

- [ ] Files and exact additions below; add `test<Model>PreservesDocumentedFields` to ResponseContractTests for each row, extracting the corresponding operation's pinned example. New properties are optional because the source does not declare response `required`; existing IDs/typed arrays stay strict. Unknown-property tolerance is not an assertion of complete contract support. Optional arrays must reject wrong present types. Never infer element types for empty schema arrays.

  | File under Sources/TMDBKit | Exact additive fields/types | Named tests / evidence |
  | --- | --- | --- |
  | `Model/AccountDetails.swift` | `AccountDetails.Avatar.tmdb: TMDBAvatar?`; nested `TMDBAvatar.avatarPath: String?` | `testAccountAvatarPreservesTMDBPath`; account-details |
  | `Model/Movie.swift`, `Model/Language.swift`, `Model/MovieFragment.swift` | `Movie.originCountry: [String]?`; `Language.englishName: String?`; `MovieFragment.mediaType: String?` | `testMoviePreservesCountryLanguageAndMediaType`; movie-details, list-details and trending examples |
  | `Model/Cast.swift`, `Model/Crew.swift`, `Responses/CreditsResponse.swift` | `Cast.castId: Int?`; Crew and AggregateCrew `adult: Bool?`, `knownForDepartment: String?`, `originalName: String?`, `popularity: Double?`; `AggregateCast.roles: [Role]?`, `AggregateCrew.jobs: [Job]?` | `testCreditsPreserveCastIDAndCrewMetadata`, `testAggregateCreditsPreserveRolesAndJobs`; movie-credits, tv-series-credits, tv-series-aggregate-credits |
  | `Model/ExternalIds.swift` | `wikidataId`, `freebaseMid`, `freebaseId`, `tiktokId`: `String?`; `tvdbId`, `tvrageId`: `Int?`. `youtube_id` has unspecified schema and only a null example; its public type remains unresolved, excluded from this repair until authoritative evidence establishes it | `testExternalIDsPreserveAllDocumentedSources`; movie/person/TV external IDs |
  | `Responses/ImagesResponse.swift` | `ImagesResponse.logos: [Image]?`, `AppendedImages.logos: [Image]?` | `testImagesPreserveLogos`; movie/TV images |
  | `Model/Review.swift`, `Model/Video.swift`, `Model/Translation.swift` | AuthorDetails `username: String?`; Video `official: Bool?`, `publishedAt: String?`; TranslationData `runtime: Int?`, `tagline: String?`; PersonTranslation.TranslationData `name: String?` | `testReviewsPreserveUsername`, `testVideosPreserveOfficialAndPublishedAt`, `testTranslationsPreserveRuntimeTaglineAndPersonName`; movie/TV reviews/videos/translations, translations |
  | `Model/TVDetails.swift` | TVDetails `adult: Bool?`, `productionCountries: [ProductionCountry]?`, `spokenLanguages: [Language]?`, `tagline: String?`; LastEpisodeToAir `runtime: Int?`, `rating: Double?`; Season `voteAverage: Double?` | `testTVDetailsPreserveAdditionalFields`, `testRatedEpisodesPreserveRatingAndNullableRuntime`; TV details/latest and account-rated-tv-episodes (latest episode runtime is null) |
  | `Responses/TV/SimilarShowsResponse.swift`, `Model/Media.swift` | TVShowFragment `adult: Bool?`, `rating: Double?`; TVMedia `adult: Bool?`, `mediaType: String?`; PopularPerson `originalName: String?`, `mediaType: String?` | `testRatedTVPreservesRating`, `testTVMediaPreservesAdultAndType`, `testPopularPersonPreservesOriginalNameAndType`; account-rated-tv, tv-series-similar, trending-tv |
  | `Model/ReleaseDate.swift`, `Model/Rating.swift` | `descriptors: [ChangeValue]?` until an authoritative element schema exists (snapshot supplies only empty arrays) | `testCertificationDescriptorsRoundTrip`; movie-release-dates and tv-series-content-ratings; synthetic mixed values explicitly labeled synthetic, preserving rather than asserting an undocumented element type |

  Verify ResponseContractTests and owning family suites. Every added field needs a value assertion and at least one round-trip assertion; fields absent in one family remain nil rather than requiring a new endpoint/model family.

#### Task 7H: Guest alternatives and unnecessary read-session gates

- [ ] Files: `Networking/NetworkClient.swift`, `Networking/APIClient/TMDB.swift`, `TMDB+Movies.swift`, `TMDB+TV.swift`, `TMDB+Lists.swift`; MovieEndpointTests, TVEndpointTests, ListEndpointTests, NetworkClientTests. Add defaulted `guestSessionId: String? = nil` to the two public accountStates and four movie/TV rate/delete methods immediately before completion. Existing nil uses configured user session; nonnil selects guest_session_id and omits session_id. Add an internal authenticated request helper accepting an explicit session-query kind/value, with exactly one selected key and unchanged missing-user-session error for nil/nil; do not add guest-session creation wrappers (missing operation). List details/itemStatus should use application authentication rather than unconditional user-session guard; use configured user session optionally when available to retain private-list behavior. `testGuestAccountStatesAndRatingsUseGuestSessionOnly`, `testDefaultUserSessionRemainsCompatible`, `testListReadsWorkWithoutUserSession` assert method/path, one credential query key, exact JSON rating and API key presence. Account/list mutations stay user-only. Account-state `rated` decoder must accept false and object-with-numeric-value only; true/wrong string/malformed object fails rather than being swallowed by `try?`. `testAccountStateRejectsMalformedRatedUnion` covers false, object, and invalid inputs; preserve public rated: Rating?. Evidence: operation parameter lists, user/guest guides; no new auth protocol requirement. Verify those suites plus full suite.

#### Task 7I: Account path and legacy default-ID decisions

- [ ] Files: `Networking/Endpoints/Account.swift`, `Networking/APIClient/TMDB+Account.swift`, `Extensions/URL+QueryItem.swift`, AccountEndpointTests. Pinned account-details is GET `/3/account/{account_id}`; existing public details uses `/3/account` and optional account methods substitute `0`, neither behavior is documented by this snapshot. Add `details(for accountId: Int, completion: @escaping TMDBResult<AccountDetails>)` and matching endpoint case for the official path, using application authentication with an optional configured user session rather than requiring a session for public explicit-ID details; preserve existing `details(completion:)` as an explicitly documented legacy compatibility call. Preserve default nil/0 behavior for old call sites, but label it an unverified server convention; explicit IDs must serialize exactly, and no newly written API may claim 0 means current user. `testAccountDetailsExplicitIDUsesDocumentedPath` asserts `/3/account/548`; `testLegacyAccountDefaultsRemainDocumentedCompatibility` asserts local legacy route/default behavior independently and labels it non-contract coverage. **Unresolved official-evidence boundary:** the current-session account lookup and ID 0 convention need authoritative confirmation or a separately approved migration before claiming all default account calls conform to the pinned contract. Do not make live credentialed requests to guess. Verify AccountEndpointTests. This evidence limit does not block stage-two coverage after confirmed path mismatches are repaired. This is not permission to remove old signatures or make up an account ID.

#### Task 7J: Append resources must match namespaces and survive decoding

- [ ] Files: `Networking/Endpoints/DetailsAppendable.swift`, movie/TV/people Endpoint files; `Model/TVDetails.swift`, `Responses/People/PersonDetailsResponse.swift`, `Responses/CreditsResponse.swift`, `Responses/ImagesResponse.swift`; owning family suites and ResponseContractTests. Preserve DetailsAppendable cases. Add cases `.movieCredits`, `.tvCredits`, `.combinedCredits` for valid person resources (new enum-case exhaustive-switch migration must be documented with 7F). Movie and TV support all seven existing cases; person supports images/translations and the three new credit cases; legacy `.credits` maps to combined_credits on person, since `/person/{id}/credits` does not exist; legacy person reviews/videos/similar/recommendations are ignored with documented deprecation rather than dispatched to nonexistent resources. Person appended images decode profiles with new `AppendedPersonImages { profiles: [Image] }`; because changing existing `images: AppendedImages?` would break call sites, add canonical `profileImages: AppendedPersonImages?` and retain legacy images nil compatibility field, both mapped from the same wire `images` via custom coding. Add canonical `personTranslations: [PersonTranslation]?` from `translations.translations`, preserving old `translations: AppendedTranslations?` compatibility projection without forcing movie translation data. Add person `movieCredits`, `tvCredits`, `combinedCredits`: AppendedPersonCredits? and legacy `credits` alias to combinedCredits. Add TV `credits: AppendedTVCredits?` with new `AppendedTVCredits {cast:[TVCast], crew:[Crew]}` (appended id may be absent, so do not require a standalone root ID), `similar: SimilarShowsResponse?`, `recommendations: RecommendationsResponse?`, `translations: AppendedTranslations?`. Normalize duplicate append names and query keys: explicit top-level language wins, else first nonnil appended language wins; one language key only, merge image-language values uniquely preserving input order. Do not invent per-resource independent language query semantics. `testPersonAppendResourcesUseDocumentedNamespaces`, `testPersonAppendImagesAndTranslationsDecode`, `testTVAllSupportedAppendsDecode`, `testAppendLanguageHasSingleDeterministicValue`, `testAppendUnsupportedPersonResourcesAreOmitted` use pinned standalone subresponses nested under their wire resource names, remove standalone-only IDs only where appended models omit IDs, and assert values rather than nonnil objects. Verify MovieEndpointTests, TVEndpointTests, PeopleEnpointTests, ResponseContractTests.

#### Task 7K: Source conflicts and unspecified nullability remain explicit

- [ ] No production relaxation to make `{}` decode. `movie-recommendations` has an empty schema and `{}` example: retain strict PopularMoviesResponse pagination/results and record unknown response completeness. `testMovieRecommendationsRejectsMissingPagination` should assert malformed `{}` fails, with fixture labeled a negative boundary and upstream schema gap, not proof that TMDB's useful response is empty. Reference tagged-images and keyword-movies pages say deprecated while snapshot false; keep status `deprecated` with both sources and public-presence flag, do not remove routes. For all response properties, omitted schema required lists and `{}` sub-schemas mean unknown; maintain existing required IDs, reject wrong present types, and track recommendation image nullability (7D) and account conventions (7I) as unresolved evidence before full-alignment signoff. `testRequiredIDsRemainStrict` iterates changed typed models with missing/string ID inputs, independent of permissive example defaults. Verify ResponseContractTests. Report these boundaries at stage-one signoff rather than claiming a complete upstream schema.


## Stage 2 — Systematic behavioral coverage for existing APIs

### Task 8: Verify every public operation through the request boundary

**Files:** Create `Tests/TMDBKitTests/Helpers/RequestAssertions.swift`, `docs/api/test-coverage.md`; modify `TMDBTestCase.swift`, `StubHelper.swift`, and all existing family suites; retain `PeopleEnpointTests.swift`'s existing spelling. Use `SearchEndpointTests.swift` from Task 6.

**Interfaces:** Add test-only `assertQuery(_ request: URLRequest, equals expected: [String: String], file: StaticString = #file, line: UInt = #line) -> Void` (assert duplicate keys separately before dictionary conversion) and `requestBodyJSON(_ request: URLRequest) throws -> [String: Any]` (support `httpBodyStream`). Expected methods/paths/body values are independent literals derived from the contract, never from the production endpoint being tested.

- [ ] **Step 1:** Build a coverage matrix keyed by every public operation from Task 1. Columns: public invocation, method/path, query/default/omission, body/header, auth, response assertions, errors, test names, not-applicable reason. Shared transport tests may satisfy an error column by link.
- [ ] **Step 2:** Add request expectations to fixture-driven stubs and verify the harness catches a deliberately wrong path in a temporary local assertion. Add per-test isolated URLCache instances and reset MockURLProtocol handlers in teardown. Keep these tests serial while their handler is global.
- [ ] **Step 3:** For each uncovered public operation add a named test invoking the public method and asserting the independently specified request plus representative returned field values and pagination. Cover GET without body, mutation JSON/header content, optional omission, nondefault page/language/region/sort, and append queries according to its row. Do not add wrappers for internal-only cases to improve the count.
- [ ] **Step 4:** Add `testSearchQueryEncodingRoundTripsSpecialCharacters` using `Amélie & C++?/` and `testAppendQueriesPreserveLanguageAndPage` for existing supported append combinations. Assert decoded query values and multiplicity rather than serialized query order. Invalid combinations follow the documented supported surface, not a newly invented API.
- [ ] **Step 5:** Run each affected family suite, then the full suite with coverage; expect pass and no public-operation row without a named request/response test. Tests added for previously untested correct behavior may pass immediately; do not manufacture production changes merely to get red tests.
- [ ] **Step 6:** Commit family-sized groups: `test: verify <family> public API contracts`; commit the reconciled coverage matrix with the last group.

### Task 9: Cover transport errors, authentication isolation, and cache behavior

**Files:** Create `Tests/TMDBKitTests/NetworkClientTests.swift`, `Tests/TMDBKitTests/NetworkCacheTests.swift`; modify `TMDBTestCase.swift` / helpers as needed. Production repairs, if demonstrated: `NetworkClient.swift`, `TMDB.swift`, `HTTPResponseHeaders.swift`, `TMDBError.swift` only as required by failing assertions.

**Interfaces:** Consume the internal update method from Task 4 and existing injected `NetworkClient(authenticator:urlSession:cache:)`. Retain current public error cases. For nested legacy error wrappers, assert the underlying error category rather than changing public error semantics incidentally.

- [ ] **Step 1:** Add `testHTTPFailuresCompleteOnce` for `401`, `403`, `404`, `422`, `429`, `500`; assert failure contains that HTTP code, no success object, and one completion. Add `testTransportFailureCompletesOnce` with `URLError(.timedOut)` and `testMalformedJSONReturnsDecodingError` through a public client method.
- [ ] **Step 2:** Add `testFreshCacheAvoidsRequest`, `testExpiredCacheRevalidatesWithETag`, `testNotModifiedReturnsCachedPayload`, and `testNotModifiedWithoutCacheFails`. Seed isolated URLCache entries with explicit old/current Date, Cache-Control, and ETag headers. Assert request counts, `If-None-Match`, returned payload, and status wrapper where used. A cached response dated one hour ago with `max-age=1` must not be treated as fresh.
- [ ] **Step 3:** Add `testMutationsNeverReadOrPopulateCache` for representative POST and DELETE operations with two invocations and two outgoing requests. Add `testAuthenticationResponsesAreNotCached` for request-token/session creation and deletion. Add `testCredentialReplacementDoesNotReusePreviousAccountResponse`, and `testClearCachesRemovesStoredResponses`.
- [ ] **Step 4:** Run the two suites; record actual red assertions. Insert exact repair steps/signatures for demonstrated defects before modifying production code, then repair freshness calculation, authentication cache policy, or response handling at their owning boundary. Do not implement retry/backoff or a new error architecture.
- [ ] **Step 5:** Run both suites and the full suite with coverage; expect every named behavioral assertion to pass without timing sleeps or shared cache interference. Record measured line/function coverage and still-unexercised branches with explanations in `docs/api/test-coverage.md`.
- [ ] **Step 6:** Commit test groups and any regression-backed fixes separately: `test: cover transport failures and cache lifecycle` / `fix: <demonstrated transport defect>`.

#### Task 9 discovered repairs (recorded before production edits)

- [ ] `NetworkClient.init(authenticator:urlSession:cache:)`: preserve an explicitly injected URLCache's memory/disk capacities. Focused `testInjectedCacheRetainsCallerCapacities` RED reports 104857600 versus requested 1048576 memory / 0 disk. Change the internal cache argument to optional with a nil default; configure the existing shared cache to 100 MB only when no cache is supplied. Existing explicit URLCache calls remain compatible. This removes unintended shared disk storage from deterministic tests. The first cache-wide RED was polluted by the capacity override and sandbox Cache.db failures; repeat it after this repair before drawing further conclusions.

## Stage 3 — Map missing implementations

### Task 10: Publish the complete missing-public-API backlog

**Files:** Create `docs/api/missing-implementations.md`; update `docs/api/implemented-api-audit.md`, `docs/api/test-coverage.md`, and `README.md`.

**Interfaces:** Consume the pinned operation inventory and final test matrix. Produce one backlog entry per documented operation without a current usable public implementation, including internal-only and declaration-only operations. No new runtime methods.

- [ ] **Step 1:** Reconcile every pinned HTTP operation with the final code state. Keep deprecated/removed operations separate from supported missing operations, and explain preexisting local routes absent from the spec.
- [ ] **Step 2:** For every missing operation record method/path, operation ID, official link, status, existing enum/model/fixture assets, required response models, application/user/guest auth, proposed public endpoint group, dependencies, and next implementation/test work. A fixture or enum alone never counts as implemented.
- [ ] **Step 3:** Group entries by official family; use the audit to establish the full list. Explicitly inspect authentication, certifications, change lists, collections, companies, configuration, credits, discover, find, genres, guest sessions, keywords, networks, review details, remaining search variants, TV hierarchy/groups, provider catalog/regions, and missing operations within otherwise implemented families. This checklist is a seed, not the denominator.
- [ ] **Step 4:** Propose follow-up order: shared configuration/genres and response prerequisites; search/discover/find/provider catalog; TV hierarchy; remaining metadata and auth-dependent operations. Mark this as an implementation recommendation, with dependencies and estimated relative size, rather than a user-approved schedule. Give each family a separate future implementation plan instead of expanding this project.
- [ ] **Step 5:** Replace ambiguous README family checkboxes with `complete`, `partial`, or `not exposed` summaries supported by the detailed inventory. Validate operation counts reconcile, all source/model/test links exist, and no supported public operation lacks its audit/test reference.
- [ ] **Step 6:** Run the full verification command and `git diff --check`; record results and remaining limitations. Commit the documentation: `docs: map missing TMDB v3 public APIs`.

## Completion and self-review

- [ ] User's sequence is preserved: existing contracts repaired, broad coverage completed, missing implementations mapped.
- [ ] Contract snapshot and audit distinguish initial findings from exhaustively checked operations.
- [ ] Every discovered repair has concrete files/signatures/assertions before implementation; no unknown discovery is treated as an already specified code change.
- [ ] Every Review Focus condition maps to named tests in its owning task.
- [ ] Existing call sites compile; any incompatible model decision was reviewed before coding.
- [ ] Full tests pass; coverage report and operation matrix agree with the final code; documentation links and diff checks pass.
- [ ] No missing endpoint families were implemented as incidental scope expansion.

## Handoff

The user selected **Subagent-driven** execution and approved the isolated branch/worktree on 2026-11-06. Execute all stages continuously with task review and a final broad review; no push or merge is authorized.
