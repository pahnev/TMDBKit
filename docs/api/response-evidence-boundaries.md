# Response evidence and compatibility boundaries

Stage-one repairs preserve the pinned v3 contract's limits. This document does
not claim a complete upstream response schema or full API alignment. The baseline
[audit](implemented-api-audit.md) and its [machine-readable companion](implemented-api-audit.json)
retain the operation inventory and source pointers; no endpoint families were added.

- Movie recommendations: the pinned `movie-recommendations` response schema and
  example are `{}`. Response completeness is unknown. `PopularMoviesResponse`
  continues requiring page, results, total_pages and total_results. The empty
  example is used only as a labeled negative fixture by
  `testMovieRecommendationsRejectsMissingPagination`.
- Required fields and nullability: omitted schema `required` lists and `{}`
  sub-schemas mean unknown. They do not authorize permissive defaults, identity
  coercion, or swallowed wrong present types. `testRequiredIDsRemainStrict`
  decodes complete pinned objects and tests missing/wrong identity types across
  the changed typed models. The historical string/integer list-ID union remains
  a separately tested compatibility decision. Appended containers intentionally
  omit standalone root IDs while retaining strict child identities.
- Recommendation-specific image nullability (Task 7D) remains unresolved. Current
  string-only recommendation image fields are retained; the examples do not prove
  these assumptions and no nullable-image success claim is made.
- The explicit `/account/{account_id}` details path is supported. Current-session
  `/account` lookup and the meaning of legacy default ID `0` (Task 7I) remain
  unverified server conventions. Existing calls retain their local routing;
  tests of those routes are non-contract compatibility coverage. Authoritative
  evidence or a separately approved migration is required before claiming
  default account calls conform. No credentialed requests were used to guess.

The [tagged-images reference](https://developer.themoviedb.org/reference/person-tagged-images)
and [keyword-movies reference](https://developer.themoviedb.org/reference/keyword-movies)
mark their operations deprecated, while the pinned snapshot records
`deprecated: false` for both. Both sources remain recorded in the audit: status
stays `deprecated`, with public presence `true` for tagged images and `false` for
keyword movies. Existing tagged-images routing is preserved; no keyword wrapper
or other missing family is introduced.

The unresolved recommendation image/nullability and account conventions block
full-alignment signoff. They do not block stage-two behavioral coverage once
confirmed implementation mismatches are repaired.

## Append source compatibility

`DetailsAppendable` adds `.movieCredits`, `.tvCredits`, and `.combinedCredits` for
person resources. Clients with exhaustive switches must handle these cases;
this joins Task 7F's documented Media/MediaType enum migrations. Original cases
remain available. Person `.credits` selects `combined_credits`; unsupported person
reviews/videos/similar/recommendations are deprecated selections and are omitted.
The new person credit cases are omitted from movie/TV requests. A details request
has one shared language value: explicit language wins, otherwise the first
supported nonnil appended language wins. Image-language filters merge uniquely
in input order.

Canonical `PersonDetailsResponse.profileImages` and `personTranslations` decode
profiles and person biography/name data from the wire `images` and `translations`
keys. Original `images: AppendedImages?` and `translations: AppendedTranslations?`
accessors remain source compatible but return nil, with deprecation guidance;
those movie-shaped projections are unavailable for person-shaped data. No
homepage or overview values are fabricated. `credits` aliases `combinedCredits`.
