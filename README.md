# TMDBKit

Swift wrapper for [TMDB v3 API](https://developers.themoviedb.org/3) with cache handling

![Build&Test](https://github.com/pahnev/TMDBKit/workflows/Build&Test/badge.svg?branch=main)
[![codecov](https://codecov.io/gh/pahnev/TMDBKit/branch/main/graph/badge.svg?token=38DDSS4RNN)](https://codecov.io/gh/pahnev/TMDBKit)
[![Maintainability](https://api.codeclimate.com/v1/badges/40c87869aa1402a9f206/maintainability)](https://codeclimate.com/github/pahnev/TMDBKit/maintainability)
[![codebeat badge](https://codebeat.co/badges/72b080e9-8858-45d2-a4de-b0bb97d1c0f8)](https://codebeat.co/projects/github-com-pahnev-tmdbkit-main)

## Endpoints covered

Against the [pinned TMDB v3 contract](docs/api/spec/README.md): **85 public operations**, including one deprecated tagged-images operation; **67 operations lack public APIs**, including one deprecated keyword listing. `complete` describes supported operation exposure and offline coverage, not full schema alignment. See [remaining evidence limits](docs/api/response-evidence-boundaries.md).

| Family | Exposure | Supported public / supported total | Details |
| --- | --- | --- | --- |
| Account | complete | 11 / 11 | [Inventory](docs/api/test-coverage.md) |
| Authentication | partial | 3 / 7 | [Inventory](docs/api/missing-implementations.md#authentication) |
| Certifications | not exposed | 0 / 2 | [Inventory](docs/api/missing-implementations.md#certifications) |
| Changes | not exposed | 0 / 3 | [Inventory](docs/api/missing-implementations.md#changes) |
| Collections | not exposed | 0 / 3 | [Inventory](docs/api/missing-implementations.md#collections) |
| Companies | not exposed | 0 / 3 | [Inventory](docs/api/missing-implementations.md#companies) |
| Configuration | not exposed | 0 / 6 | [Inventory](docs/api/missing-implementations.md#configuration) |
| Credits | not exposed | 0 / 1 | [Inventory](docs/api/missing-implementations.md#credits) |
| Discover | not exposed | 0 / 2 | [Inventory](docs/api/missing-implementations.md#discover) |
| Find | not exposed | 0 / 1 | [Inventory](docs/api/missing-implementations.md#find) |
| Genres | not exposed | 0 / 2 | [Inventory](docs/api/missing-implementations.md#genres) |
| Guest Sessions | not exposed | 0 / 3 | [Inventory](docs/api/missing-implementations.md#guest-sessions) |
| Keywords | not exposed | 0 / 1 | [Inventory](docs/api/missing-implementations.md#keywords) |
| Lists | complete | 7 / 7 | [Inventory](docs/api/test-coverage.md) |
| Movies | complete | 23 / 23 | [Inventory](docs/api/test-coverage.md) |
| Networks | not exposed | 0 / 3 | [Inventory](docs/api/missing-implementations.md#networks) |
| Trending | complete | 4 / 4 | [Inventory](docs/api/test-coverage.md) |
| People | complete | 10 / 10 | [Inventory](docs/api/test-coverage.md) |
| Reviews | not exposed | 0 / 1 | [Inventory](docs/api/missing-implementations.md#reviews) |
| Search | partial | 1 / 7 | [Inventory](docs/api/missing-implementations.md#search) |
| TV | partial | 25 / 26 | [Inventory](docs/api/missing-implementations.md#tv) |
| TV Seasons | not exposed | 0 / 10 | [Inventory](docs/api/missing-implementations.md#tv-seasons) |
| TV Episodes | not exposed | 0 / 10 | [Inventory](docs/api/missing-implementations.md#tv-episodes) |
| TV Episode Groups | not exposed | 0 / 1 | [Inventory](docs/api/missing-implementations.md#tv-episode-groups) |
| Watch Providers | not exposed | 0 / 3 | [Inventory](docs/api/missing-implementations.md#watch-providers) |

People additionally exposes deprecated tagged images; Keywords additionally has one deprecated, unexposed movie listing. [Final inventory](docs/api/final-api-inventory.json) records all 152 operation statuses, assets and test references. [Migration notes](docs/api/implementation-decisions.md#migration-notes) describe enum additions and compatibility accessors.
