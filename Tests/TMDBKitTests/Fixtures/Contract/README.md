# Response contract fixtures

These are complete `responses["200"].content["application/json"].examples.Result.value`
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
