# Implementation decisions and migration notes

These controller rulings were made during the approved three-stage refresh (2026-11-06–07). They are copied from the execution ledger so the rationale and costs remain reviewable with the source. The original ledger is retained. This records decisions actually applied; it is not a new approval schedule. See [final operation inventory](final-api-inventory.json), [coverage evidence](test-coverage.md) and [source limitations](response-evidence-boundaries.md).

## Controller rulings (chronological)

1. User selection of subagents plus explicit continuation approves the proposed scope — direct user instruction supersedes stale pending-review wording — cost if wrong is reversible implementation work.

2. Task 1 must expand Task 7 into exact, reviewed repair tasks before dispatch — audit-led plan deliberately does not invent undiscovered model changes — cost is additional planning within the authorized audit.

3. Baseline SwiftPM user-cache warnings are environmental evidence to retain, not a reason to modify global configuration — existing sandbox lacks those write paths — cost is warning noise only.

4. Preserve source compatibility using additive APIs/accessors; if a model type correction cannot be additive, document and adjudicate the exact choice before implementation — scope requires public call-site preservation — cost is compatibility scaffolding.

5. Add Task 1A before runtime repairs to compare JSON request bodies semantically — baseline rerun found nondeterministic key-order failures in existing raw Data equality assertions — cost if wrong is only test representation changes; all body fields must still be asserted.

6. Add typed Media.episode for documented tagged-image episode payloads, documenting exhaustive-switch migration before implementation — preserves current method/result signatures while representing valid API data truthfully — cost if wrong: downstream exhaustive Media switches require a new case. Reject a parallel API that leaves the current decoder broken.

7. Do not weaken required pagination to accept upstream movie-recommendations empty-object example/schema — source itself is incomplete — cost if wrong: that invalid upstream example remains an explicit audit gap rather than a misleading success.

8. Upstream empty schemas, unconfirmed recommendation nullability, and legacy account-default conventions are explicit evidence limitations rather than permission to invent behavior — fix every confirmed mismatch and continue coverage/mapping, but do not claim full alignment — cost if wrong is a documented compatibility limitation needing future provenance.

9. Adding person-credit DetailsAppendable cases shares the documented exhaustive-switch migration exception with Media.episode — existing append behavior needs namespace-correct expressiveness — cost if wrong is downstream switch migration.

10. preserve this as an explicit evidence gap — unsupported type would invent a public contract — cost if wrong is delaying one field until authoritative evidence exists.

11. **Superseded by decision 12:** Media historical shape fallback normalizes absent mediaType to known enum-case discriminator while standalone models preserve nil — necessary for wrapper encode/decode equality without suppressing fields — cost if wrong: inferred wrapper metadata replaces absent wire metadata; explicit discriminators stay authoritative.

12. revise earlier inferred-normalization policy to preserve nil fallback metadata and omit discriminator for nil movie/TV/person payloads while explicit-tag input stays strict/canonical and episode stays tagged — manual public enum construction exposes previously missed equality gap — cost if wrong is historical fallback wire output retaining omission rather than always adding tag. No custom Equatable suppression.

13. person canonical translations preserve actual biography/name; legacy movie-shaped translations projection is nil for person-shaped input rather than invented homepage or biography->overview mapping — avoids falsely modeled values — cost if wrong is old optional projection unavailable, with canonical migration accessor provided. Historical truly movie-shaped payload may retain actual projection.

14. counting URLCache delegates to real Foundation storage; mutation seed rejections are harness mistakes, so mutation no-read/no-write is proved by boundary counters plus repeated wire calls. Costs if wrong: system URLSession behavior remains separately limited to outgoing cache directives and offline URLProtocol evidence.

15. Whole-valued ChangeValue.number(Double) may canonicalize to.integer on JSON roundtrip — required integer-first decoding and JSON numeric tokens do not preserve manual enum-case choice — cost if wrong: callers needing exact numeric enum-case roundtrips must normalize; preserve exact Int/fractional Double and do not suppress equality or redesign decoder.

Signed commits were required by the user after the initial audit. Signing was preserved; signing was never bypassed. No push or merge is part of this refresh.

## Final media metadata policy

The initial inferred-discriminator normalization ruling above was superseded after review exposed manually constructed public enum values that failed exact Codable round trips. Final behavior (`fdf2577`): absent discriminator metadata stays nil for historical movie/TV/person shape fallbacks, and encoding omits it. Explicit discriminators are authoritative and unknown/malformed values fail; episode media remains explicitly tagged. Equality does not suppress metadata differences. Evidence: [ResponseContractTests](../../Tests/TMDBKitTests/ResponseContractTests.swift), `testMediaDiscriminatorIsRespected`, `testMediaRoundTripsAllSupportedCases`, `testMediaManualConstructionPreservesMissingType`, and `testTaggedImageOptionalMetadataBoundaries`.

## Migration notes

| Surface | Migration / compatibility behavior | Implementation and verification |
| --- | --- | --- |
| Public enum additions | Exhaustive switches over `Media` and `TaggedImageResponse.Result.MediaType` need `.episode`; switches over `DetailsAppendable` need `.movieCredits`, `.tvCredits`, `.combinedCredits`. Existing method/result signatures remain. | [Media](../../Sources/TMDBKit/Model/Media.swift), [tagged images](../../Sources/TMDBKit/Responses/People/TaggedImageResponse.swift), [append selections](../../Sources/TMDBKit/Networking/Endpoints/DetailsAppendable.swift); `443801e`, `d3d4fec`; ResponseContractTests and person append tests |
| Full method references | Existing full parameter-label/arity signatures have 17 forwarding overloads; new options use additive APIs. Default arguments alone did not preserve method references. | [Compatibility overloads](../../Sources/TMDBKit/Networking/APIClient/TMDB+Compatibility.swift); `15eb37a`, `3e7f9e9`; [compatibility tests](../../Tests/TMDBKitTests/PublicMethodCompatibilityTests.swift) |
| Changes | Whole-valued `.number(1.0)` can encode as `1` and canonicalize to `.integer(1)`; exact enum-case preservation is not guaranteed for whole-valued Doubles. Use `valueData` / `originalValueData` (`ChangeValue?`) and canonical locale fields. Nil is absent; `.null` is explicit null. Old String projections use empty strings for nonstring/absent values; old TV wrappers use `.null` and poster fallback uses empty path/nil locale. `TVChangesResponse.items` aliases `changes`. These sentinels are compatibility projections, not server values. | [Change](../../Sources/TMDBKit/Model/Change.swift), [ChangeValue](../../Sources/TMDBKit/Model/ChangeValue.swift), [envelopes](../../Sources/TMDBKit/Responses/ChangesResponse.swift); `634040f`; ResponseContractTests |
| Provider regions | Use `Results.regions` or `subscript(region:)` for arbitrary ISO region keys. Existing lowercase accessors, including `iN`, still look up uppercase keys. `free` and `ads` join existing categories. | [WatchProvider](../../Sources/TMDBKit/Model/WatchProvider.swift); `66ef663`; provider round-trip/boundary tests |
| Person keys / list identities | `deathday` is canonical; `deathDay` aliases it. Lower-camel `creditId` / `genreIds` alias retained `creditID` / `genreIDS`. `ListItemStatus.id` remains String, normalizing accepted numeric wire IDs; use `numericId` when needed. | [Person details](../../Sources/TMDBKit/Responses/People/PersonDetailsResponse.swift), [credits](../../Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift), [List](../../Sources/TMDBKit/Model/List.swift); `7669955`; ResponseContractTests |
| Person appended data | Use `profileImages`, `personTranslations`, and `movieCredits` / `tvCredits` / `combinedCredits`. Old movie-shaped `images` and `translations` projections are nil; old `credits` aliases combined credits. Person `.credits` requests combined_credits; unsupported person review/video/similar/recommendation selections are omitted. | [Person details](../../Sources/TMDBKit/Responses/People/PersonDetailsResponse.swift), [append rules](response-evidence-boundaries.md#append-source-compatibility); `d3d4fec`; person append tests |
| Recommendation networks | Absent networks becomes `[]`; present malformed/null networks still fails. Existing required recommendation image Strings remain because nullability evidence is unknown. | [RecommendationsResponse](../../Sources/TMDBKit/Responses/TV/RecommendationsResponse.swift); `9670417`; `testTVRecommendationsWithoutNetworks` / `testTVRecommendationsRejectMalformedIDAndNetworks` |
| Account defaults | Prefer explicit `details(for:)` and explicit IDs. Legacy `/account` and nil-to-0 routes remain local compatibility behavior, not verified server conventions. | [Account client](../../Sources/TMDBKit/Networking/APIClient/TMDB+Account.swift); `f9ec35a`; AccountEndpointTests |
| Legacy query arguments | Existing language/sort labels compile but undocumented parameters are omitted on the operations listed in Task 7A and [wire matrix](test-coverage.md). Details has one language: explicit top-level value, otherwise first supported appended value. | [request options plan](../superpowers/plans/2026-11-06-api-refresh.md#task-7a-existing-request-options-and-unsupported-query-cleanup); `beff9dc`, `d3d4fec`; `testLegacyUndocumentedQueriesAreOmitted` in owning suites |
| Authentication / cache | Configured credentials update the transport; explicit guest selection sends only guest_session_id; existing nil guest uses user session. List reads use optional user session. Cache keeps legacy callback/error wrappers; freshness/never-cache fixes are regression-backed. | [TMDB](../../Sources/TMDBKit/Networking/APIClient/TMDB.swift), [NetworkClient](../../Sources/TMDBKit/Networking/NetworkClient.swift); `2c10a65`, `3e7f9e9`, `d6403dc`, `54544ad`; [coverage](test-coverage.md) |

## Review-focus evidence

| Requirement | Named evidence |
| --- | --- |
| Distinct TV ID and rating; list confirmation | `TVEndpointTests.testRateShowSerializesBoundaryRatings`; `ListEndpointTests.testClearListIncludesConfirmation`; owning [tests](test-coverage.md) |
| Missing/replaced sessions; cache isolation | `NetworkClientTests.testMissingUserSessionRetainsErrorWithoutRequest`; `NetworkCacheTests.testCredentialReplacementDoesNotReusePreviousAccountResponse`; authentication/movie/TV matrix rows |
| Search special characters | `SearchEndpointTests.testSearchQueryEncodingRoundTripsSpecialCharacters` |
| Null/absent/union and malformed identities | `ResponseContractTests.testChangeValuesRoundTripAllJSONKinds`, `testRequiredIDsRemainStrict`, `testAccountStateRejectsMalformedRatedUnion`; source boundaries above |
| Freshness/304/mutations | `NetworkCacheTests.testExpiredCacheRevalidatesWithETag`, `testNotModifiedReturnsCachedPayload`, `testMutationsNeverReadOrPopulateCache` |

[Response evidence boundaries](response-evidence-boundaries.md) remain explicit UNKNOWNs: movie-recommendations empty schema/example, recommendation-specific image nullability, untyped response subfields such as youtube_id, and legacy account conventions. They prevent full-alignment signoff; confirmed repairs and the mapping deliverables are complete independently of those upstream gaps.
