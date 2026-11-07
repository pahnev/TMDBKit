# Response contract fixtures

These are complete `responses["200"].content["application/json"].examples[example name].value`
objects extracted by operation ID from `docs/api/spec/tmdb-v3.json`, pinned on
2026-11-06 (SHA-256 `1c709375fe994e58c5a35aba7c9abfa7f28aa7103ed6c2052ea5ab0b62af081b`).
Only JSON formatting changed. No live API requests or credentials are needed.

| Fixture | Operation ID |
| --- | --- |
| changes-movie.json | movie-changes |
| changes-person.json | person-changes |
| changes-tv.json | tv-series-changes |
| providers-movie.json | movie-watch-providers |
| providers-tv.json | tv-series-watch-providers |
| tv-recommendations.json | tv-series-recommendations |
| list-item-status.json | list-check-item-status |
| person-details.json | person-details |
| person-tagged-images.json | person-tagged-images |
| person-movie-credits.json | person-movie-credits |
| person-tv-credits.json | person-tv-credits |
| person-combined-credits.json | person-combined-credits |

Inline test payloads are explicitly labeled synthetic boundaries or regressions;
they are not represented as official API examples.

Recommendation image nullability remains an evidence gap; these string example
paths do not establish a recommendation-specific nullable-path contract. The
reserved nullable-images test is not implemented or counted as passing.

Task 7G complete examples (all use `Result` except `movie-details`, which uses `OK`):

| Fixture / operation ID | Example |
| --- | --- |
| account-details.json / account-details | Result |
| account-rated-tv-episodes.json / account-rated-tv-episodes | Result |
| account-rated-tv.json / account-rated-tv | Result |
| list-details.json / list-details | Result |
| movie-credits.json / movie-credits | Result |
| movie-details.json / movie-details | OK |
| movie-external-ids.json / movie-external-ids | Result |
| movie-images.json / movie-images | Result |
| movie-release-dates.json / movie-release-dates | Result |
| movie-reviews.json / movie-reviews | Result |
| movie-translations.json / movie-translations | Result |
| movie-videos.json / movie-videos | Result |
| person-external-ids.json / person-external-ids | Result |
| translations.json / translations | Result |
| trending-all.json / trending-all | Result |
| trending-people.json / trending-people | Result |
| trending-tv.json / trending-tv | Result |
| tv-series-aggregate-credits.json / tv-series-aggregate-credits | Result |
| tv-series-content-ratings.json / tv-series-content-ratings | Result |
| tv-series-credits.json / tv-series-credits | Result |
| tv-series-details.json / tv-series-details | Result |
| tv-series-external-ids.json / tv-series-external-ids | Result |
| tv-series-images.json / tv-series-images | Result |
| tv-series-latest-id.json / tv-series-latest-id | Result |
| tv-series-reviews.json / tv-series-reviews | Result |
| tv-series-similar.json / tv-series-similar | Result |
| tv-series-translations.json / tv-series-translations | Result |
| tv-series-videos.json / tv-series-videos | Result |

Task 7J adds `person-images.json` from the pinned `person-images` operation's
`Result` example, unchanged except formatting. Append tests nest complete
standalone examples under their wire names and remove only standalone root IDs
for appended containers whose models deliberately omit those IDs. This composition
is a deterministic nesting test, not a new upstream details example.

Person compatibility accessors `images: AppendedImages?` and
`translations: AppendedTranslations?` remain available and return nil. Canonical
`profileImages` and `personTranslations` decode the actual person wire shapes;
no movie overview/homepage values are fabricated from person biography data.

`DetailsAppendable` adds person-only `.movieCredits`, `.tvCredits`, and
`.combinedCredits`: external exhaustive switches must handle these new cases.
This enum migration joins the Media/MediaType migrations documented in Task 7F.
Existing `.credits` maps to `combined_credits` for person requests. Unsupported
person reviews/videos/similar/recommendations selections are deprecated and omitted;
they remain valid movie/TV selections. Language applies once to the whole request.

`movie-recommendations-negative-boundary.json` preserves the pinned
`movie-recommendations` empty `{}` example. It is a **negative boundary fixture**
and an **upstream schema gap**, not a useful successful response contract. Strict
pagination/results decoding remains in place; missing schema required lists and
empty sub-schemas are treated as unknown, never as permission to supply IDs.
