# Implemented TMDB v3 API contract audit

Audited 2026-11-06 at `f12ce06810f602fce08c048476c9a522c862c83e`. Snapshot provenance and caveats: [spec README](spec/README.md). This is the Task 1 pre-repair inventory, not a claim of stage-one alignment. No production code changed. A second verification with pipefail produced 117 passed / 3 failed: the same two ordering defects plus AccountEndpointTests.test_addToWatchList_httpBody; Task 1A covers all three and all nine object-body assertions.

The complete contract contains **152 operations on 148 paths**. Every operation has one row below. There are **82 existing public network methods**, conceptually mapped to **85 official operations**, because trending covers four literal paths. Account.details is an intended mapping only: its current route is local `/3/account`. There are 8 internal-only operation mappings and 18 declaration-only mappings. Fixtures do not change a status.

Initial working tree: `?? docs/` (restored design and plan, preserved and included in documentation commit); HEAD matched the required base. No previously transient runtime/test files were present. Baseline command in spec README produced **118 passed / 2 failed**, both JSON byte-order test defects, assigned Task 1A.

Status counts: absent=40, declaration-only=18, deprecated=2, internal-only=8, public-current=17, public-needs-update=67.

Statuses are `public-current`, `public-needs-update`, `internal-only`, `declaration-only`, `absent`, `deprecated`. Deprecated includes a separate public-presence flag. `public-current` means no confirmed discrepancy in the inspected contract, not verified production behavior. All methods still need Task 8/9 systematic request/failure coverage.

The [machine-readable companion](implemented-api-audit.json) contains exact public signatures, source locations, named existing tests, model fields, request parameter defaults/requirements, response leaf schemas, repair assignments, and unambiguous JSON pointers into the pinned contract. Field `required=unspecified` and `{}`/unspecified types mean the upstream source gives no guarantee. Never infer required/nullability from an example. Human references are supplemental; each operation link below is its retained operationId slug, including awkward upstream IDs such as `lists-copy`.

## Authoritative guides and source conflicts

- [Application authentication](https://developer.themoviedb.org/docs/authentication-application): API key query remains supported alongside Bearer credentials. The snapshot declares only global Bearer security; retain API-key authentication.
- [User authentication](https://developer.themoviedb.org/docs/authentication-user) and [guest sessions](https://developer.themoviedb.org/docs/authentication-guest-sessions): user session is a query parameter; guests have limited rating permissions. Operation parameter arrays separately document guest account-state alternatives.
- [Append-to-response](https://developer.themoviedb.org/docs/append-to-response) and [image languages](https://developer.themoviedb.org/docs/image-languages): append resources use their parent namespace and retain child query behavior. One top-level language query cannot represent independent child languages.
- [Tagged images](https://developer.themoviedb.org/reference/person-tagged-images) and [keyword movies](https://developer.themoviedb.org/reference/keyword-movies) are marked deprecated by the human reference, but both pinned operations say `deprecated: false`. Inventory uses deprecated with both facts retained; neither route is inferred absent.
- [Movie recommendations](https://developer.themoviedb.org/reference/movie-recommendations) supplies no additional usable response schema; pinned schema and example are `{}`. Keep strict pagination pending better evidence (7K).
- Recommendation-specific image nullability is not established by this snapshot or linked guides (7D). Existing public required-image assumptions are unverified, not proven correct. Account current-user `/account` and default ID `0` conventions are also undocumented in this snapshot (7I). These unresolved evidence boundaries block full-alignment signoff; they do not block stage-two coverage after confirmed mismatches are repaired.

## Approved compatibility exception

Before implementation: Task 7F adds `Media.episode(LastEpisodeToAir)` and tagged-image `MediaType.episode` to preserve the official episode payload. Downstream exhaustive switches must add an episode case. This unavoidable source exception was explicitly accepted by the controller; the existing public method/result type remains. Task 7J also documents exhaustive-switch additions for the three namespace-valid DetailsAppendable credit cases. Existing properties otherwise retain their declared types via canonical additive fields, aliases or documented legacy projections.

## Complete official operation inventory

| Operation key | operationId / source | Status | Public? / endpoint | Repair tasks |
| --- | --- | --- | --- | --- |
| `GET /3/authentication` | [authentication-validate-key](https://developer.themoviedb.org/reference/authentication-validate-key) | absent | no; `none` | — |
| `GET /3/account/{account_id}` | [account-details](https://developer.themoviedb.org/reference/account-details) | public-needs-update | yes; `Account.details` | 7G, 7I |
| `POST /3/account/{account_id}/favorite` | [account-add-favorite](https://developer.themoviedb.org/reference/account-add-favorite) | public-needs-update | yes; `Account.markFavorite` | 7I |
| `POST /3/account/{account_id}/watchlist` | [account-add-to-watchlist](https://developer.themoviedb.org/reference/account-add-to-watchlist) | public-needs-update | yes; `Account.addToWatchlist` | 7I |
| `GET /3/account/{account_id}/favorite/movies` | [account-get-favorites](https://developer.themoviedb.org/reference/account-get-favorites) | public-needs-update | yes; `Account.favoriteMovies` | 7I |
| `GET /3/account/{account_id}/favorite/tv` | [account-favorite-tv](https://developer.themoviedb.org/reference/account-favorite-tv) | public-needs-update | yes; `Account.favoriteTVShows` | 7G, 7I |
| `GET /3/account/{account_id}/lists` | [account-lists](https://developer.themoviedb.org/reference/account-lists) | public-needs-update | yes; `Account.createdLists` | 7A, 7I |
| `GET /3/account/{account_id}/rated/movies` | [account-rated-movies](https://developer.themoviedb.org/reference/account-rated-movies) | public-needs-update | yes; `Account.ratedMovies` | 7I |
| `GET /3/account/{account_id}/rated/tv` | [account-rated-tv](https://developer.themoviedb.org/reference/account-rated-tv) | public-needs-update | yes; `Account.ratedTVShows` | 7G, 7I |
| `GET /3/account/{account_id}/rated/tv/episodes` | [account-rated-tv-episodes](https://developer.themoviedb.org/reference/account-rated-tv-episodes) | public-needs-update | yes; `Account.ratedTVEpisodes` | 7G, 7I |
| `GET /3/account/{account_id}/watchlist/movies` | [account-watchlist-movies](https://developer.themoviedb.org/reference/account-watchlist-movies) | public-needs-update | yes; `Account.movieWatchlist` | 7I |
| `GET /3/account/{account_id}/watchlist/tv` | [account-watchlist-tv](https://developer.themoviedb.org/reference/account-watchlist-tv) | public-needs-update | yes; `Account.tvShowWatchlist` | 7G, 7I |
| `GET /3/authentication/guest_session/new` | [authentication-create-guest-session](https://developer.themoviedb.org/reference/authentication-create-guest-session) | internal-only | no; `Authentication.createQuestSession` | — |
| `GET /3/authentication/token/new` | [authentication-create-request-token](https://developer.themoviedb.org/reference/authentication-create-request-token) | public-current | yes; `Authentication.requestToken` | — |
| `POST /3/authentication/session/new` | [authentication-create-session](https://developer.themoviedb.org/reference/authentication-create-session) | public-needs-update | yes; `Authentication.createSession` | 4 |
| `POST /3/authentication/session/convert/4` | [authentication-create-session-from-v4-token](https://developer.themoviedb.org/reference/authentication-create-session-from-v4-token) | absent | no; `none` | — |
| `POST /3/authentication/token/validate_with_login` | [authentication-create-session-from-login](https://developer.themoviedb.org/reference/authentication-create-session-from-login) | absent | no; `none` | — |
| `DELETE /3/authentication/session` | [authentication-delete-session](https://developer.themoviedb.org/reference/authentication-delete-session) | public-needs-update | yes; `Authentication.deleteSession` | 7A |
| `GET /3/certification/movie/list` | [certification-movie-list](https://developer.themoviedb.org/reference/certification-movie-list) | absent | no; `none` | — |
| `GET /3/certification/tv/list` | [certifications-tv-list](https://developer.themoviedb.org/reference/certifications-tv-list) | absent | no; `none` | — |
| `GET /3/movie/changes` | [changes-movie-list](https://developer.themoviedb.org/reference/changes-movie-list) | absent | no; `none` | — |
| `GET /3/person/changes` | [changes-people-list](https://developer.themoviedb.org/reference/changes-people-list) | absent | no; `none` | — |
| `GET /3/tv/changes` | [changes-tv-list](https://developer.themoviedb.org/reference/changes-tv-list) | absent | no; `none` | — |
| `GET /3/collection/{collection_id}` | [collection-details](https://developer.themoviedb.org/reference/collection-details) | absent | no; `none` | — |
| `GET /3/collection/{collection_id}/images` | [collection-images](https://developer.themoviedb.org/reference/collection-images) | absent | no; `none` | — |
| `GET /3/collection/{collection_id}/translations` | [collection-translations](https://developer.themoviedb.org/reference/collection-translations) | absent | no; `none` | — |
| `GET /3/company/{company_id}` | [company-details](https://developer.themoviedb.org/reference/company-details) | absent | no; `none` | — |
| `GET /3/company/{company_id}/alternative_names` | [company-alternative-names](https://developer.themoviedb.org/reference/company-alternative-names) | absent | no; `none` | — |
| `GET /3/company/{company_id}/images` | [company-images](https://developer.themoviedb.org/reference/company-images) | absent | no; `none` | — |
| `GET /3/configuration` | [configuration-details](https://developer.themoviedb.org/reference/configuration-details) | absent | no; `none` | — |
| `GET /3/configuration/countries` | [configuration-countries](https://developer.themoviedb.org/reference/configuration-countries) | absent | no; `none` | — |
| `GET /3/configuration/jobs` | [configuration-jobs](https://developer.themoviedb.org/reference/configuration-jobs) | absent | no; `none` | — |
| `GET /3/configuration/languages` | [configuration-languages](https://developer.themoviedb.org/reference/configuration-languages) | absent | no; `none` | — |
| `GET /3/configuration/primary_translations` | [configuration-primary-translations](https://developer.themoviedb.org/reference/configuration-primary-translations) | absent | no; `none` | — |
| `GET /3/configuration/timezones` | [configuration-timezones](https://developer.themoviedb.org/reference/configuration-timezones) | absent | no; `none` | — |
| `GET /3/credit/{credit_id}` | [credit-details](https://developer.themoviedb.org/reference/credit-details) | absent | no; `none` | — |
| `GET /3/discover/movie` | [discover-movie](https://developer.themoviedb.org/reference/discover-movie) | absent | no; `none` | — |
| `GET /3/discover/tv` | [discover-tv](https://developer.themoviedb.org/reference/discover-tv) | absent | no; `none` | — |
| `GET /3/find/{external_id}` | [find-by-id](https://developer.themoviedb.org/reference/find-by-id) | absent | no; `none` | — |
| `GET /3/genre/movie/list` | [genre-movie-list](https://developer.themoviedb.org/reference/genre-movie-list) | absent | no; `none` | — |
| `GET /3/genre/tv/list` | [genre-tv-list](https://developer.themoviedb.org/reference/genre-tv-list) | absent | no; `none` | — |
| `GET /3/guest_session/{guest_session_id}/rated/movies` | [guest-session-rated-movies](https://developer.themoviedb.org/reference/guest-session-rated-movies) | absent | no; `none` | — |
| `GET /3/guest_session/{guest_session_id}/rated/tv` | [guest-session-rated-tv](https://developer.themoviedb.org/reference/guest-session-rated-tv) | absent | no; `none` | — |
| `GET /3/guest_session/{guest_session_id}/rated/tv/episodes` | [guest-session-rated-tv-episodes](https://developer.themoviedb.org/reference/guest-session-rated-tv-episodes) | absent | no; `none` | — |
| `GET /3/keyword/{keyword_id}` | [keyword-details](https://developer.themoviedb.org/reference/keyword-details) | absent | no; `none` | — |
| `GET /3/keyword/{keyword_id}/movies` | [keyword-movies](https://developer.themoviedb.org/reference/keyword-movies) | deprecated | no; `none` | 7K |
| `POST /3/list/{list_id}/add_item` | [list-add-movie](https://developer.themoviedb.org/reference/list-add-movie) | public-current | yes; `Lists.addMovie` | — |
| `GET /3/list/{list_id}/item_status` | [list-check-item-status](https://developer.themoviedb.org/reference/list-check-item-status) | public-needs-update | yes; `Lists.itemStatus` | 7A, 7E, 7H |
| `POST /3/list/{list_id}/clear` | [list-clear](https://developer.themoviedb.org/reference/list-clear) | public-needs-update | yes; `Lists.clearList` | 3 |
| `POST /3/list` | [list-create](https://developer.themoviedb.org/reference/list-create) | public-current | yes; `Lists.createList` | — |
| `DELETE /3/list/{list_id}` | [list-delete](https://developer.themoviedb.org/reference/list-delete) | public-current | yes; `Lists.deleteList` | — |
| `GET /3/list/{list_id}` | [list-details](https://developer.themoviedb.org/reference/list-details) | public-needs-update | yes; `Lists.details` | 7A, 7G, 7H |
| `POST /3/list/{list_id}/remove_item` | [list-remove-movie](https://developer.themoviedb.org/reference/list-remove-movie) | public-current | yes; `Lists.removeMovie` | — |
| `GET /3/movie/now_playing` | [movie-now-playing-list](https://developer.themoviedb.org/reference/movie-now-playing-list) | public-current | yes; `Movies.nowPlaying` | — |
| `GET /3/movie/popular` | [movie-popular-list](https://developer.themoviedb.org/reference/movie-popular-list) | public-current | yes; `Movies.popular` | — |
| `GET /3/movie/top_rated` | [movie-top-rated-list](https://developer.themoviedb.org/reference/movie-top-rated-list) | public-current | yes; `Movies.topRated` | — |
| `GET /3/movie/upcoming` | [movie-upcoming-list](https://developer.themoviedb.org/reference/movie-upcoming-list) | public-current | yes; `Movies.upcoming` | — |
| `GET /3/movie/{movie_id}` | [movie-details](https://developer.themoviedb.org/reference/movie-details) | public-needs-update | yes; `Movies.details` | 7G, 7J |
| `GET /3/movie/{movie_id}/account_states` | [movie-account-states](https://developer.themoviedb.org/reference/movie-account-states) | public-needs-update | yes; `Movies.accountStates` | 7H |
| `GET /3/movie/{movie_id}/alternative_titles` | [movie-alternative-titles](https://developer.themoviedb.org/reference/movie-alternative-titles) | public-current | yes; `Movies.alternativeTitles` | — |
| `GET /3/movie/{movie_id}/changes` | [movie-changes](https://developer.themoviedb.org/reference/movie-changes) | public-needs-update | yes; `Movies.changes` | 5, 7B |
| `GET /3/movie/{movie_id}/credits` | [movie-credits](https://developer.themoviedb.org/reference/movie-credits) | public-needs-update | yes; `Movies.credits` | 7G |
| `GET /3/movie/{movie_id}/external_ids` | [movie-external-ids](https://developer.themoviedb.org/reference/movie-external-ids) | public-needs-update | yes; `Movies.externalIds` | 7G |
| `GET /3/movie/{movie_id}/images` | [movie-images](https://developer.themoviedb.org/reference/movie-images) | public-needs-update | yes; `Movies.images` | 7A, 7G |
| `GET /3/movie/{movie_id}/keywords` | [movie-keywords](https://developer.themoviedb.org/reference/movie-keywords) | public-current | yes; `Movies.keywords` | — |
| `GET /3/movie/latest` | [movie-latest-id](https://developer.themoviedb.org/reference/movie-latest-id) | public-needs-update | yes; `Movies.latest` | 7A |
| `GET /3/movie/{movie_id}/lists` | [movie-lists](https://developer.themoviedb.org/reference/movie-lists) | public-current | yes; `Movies.lists` | — |
| `GET /3/movie/{movie_id}/recommendations` | [movie-recommendations](https://developer.themoviedb.org/reference/movie-recommendations) | public-needs-update | yes; `Movies.recommendations` | 7K |
| `GET /3/movie/{movie_id}/release_dates` | [movie-release-dates](https://developer.themoviedb.org/reference/movie-release-dates) | public-needs-update | yes; `Movies.releaseDates` | 7G |
| `GET /3/movie/{movie_id}/reviews` | [movie-reviews](https://developer.themoviedb.org/reference/movie-reviews) | public-needs-update | yes; `Movies.reviews` | 7G |
| `GET /3/movie/{movie_id}/similar` | [movie-similar](https://developer.themoviedb.org/reference/movie-similar) | public-needs-update | yes; `Movies.similarMovies` | 2 |
| `GET /3/movie/{movie_id}/translations` | [movie-translations](https://developer.themoviedb.org/reference/movie-translations) | public-needs-update | yes; `Movies.translations` | 7G |
| `GET /3/movie/{movie_id}/videos` | [movie-videos](https://developer.themoviedb.org/reference/movie-videos) | public-needs-update | yes; `Movies.videos` | 7G |
| `GET /3/movie/{movie_id}/watch/providers` | [movie-watch-providers](https://developer.themoviedb.org/reference/movie-watch-providers) | public-needs-update | yes; `Movies.watchProviders` | 7C |
| `POST /3/movie/{movie_id}/rating` | [movie-add-rating](https://developer.themoviedb.org/reference/movie-add-rating) | public-needs-update | yes; `Movies.rateMovie` | 7H |
| `DELETE /3/movie/{movie_id}/rating` | [movie-delete-rating](https://developer.themoviedb.org/reference/movie-delete-rating) | public-needs-update | yes; `Movies.deleteRating` | 7H |
| `GET /3/network/{network_id}` | [network-details](https://developer.themoviedb.org/reference/network-details) | absent | no; `none` | — |
| `GET /3/network/{network_id}/alternative_names` | [details-copy](https://developer.themoviedb.org/reference/details-copy) | absent | no; `none` | — |
| `GET /3/network/{network_id}/images` | [alternative-names-copy](https://developer.themoviedb.org/reference/alternative-names-copy) | absent | no; `none` | — |
| `GET /3/person/popular` | [person-popular-list](https://developer.themoviedb.org/reference/person-popular-list) | public-needs-update | yes; `People.popular` | 7F, 7G |
| `GET /3/person/{person_id}` | [person-details](https://developer.themoviedb.org/reference/person-details) | public-needs-update | yes; `People.details` | 7E, 7J |
| `GET /3/person/{person_id}/changes` | [person-changes](https://developer.themoviedb.org/reference/person-changes) | public-needs-update | yes; `People.changes` | 5, 7B |
| `GET /3/person/{person_id}/combined_credits` | [person-combined-credits](https://developer.themoviedb.org/reference/person-combined-credits) | public-needs-update | yes; `People.combinedCredits` | 7E |
| `GET /3/person/{person_id}/external_ids` | [person-external-ids](https://developer.themoviedb.org/reference/person-external-ids) | public-needs-update | yes; `People.externalIds` | 7A, 7G |
| `GET /3/person/{person_id}/images` | [person-images](https://developer.themoviedb.org/reference/person-images) | public-current | yes; `People.images` | — |
| `GET /3/person/latest` | [person-latest-id](https://developer.themoviedb.org/reference/person-latest-id) | public-needs-update | yes; `People.latest` | 7A, 7E |
| `GET /3/person/{person_id}/movie_credits` | [person-movie-credits](https://developer.themoviedb.org/reference/person-movie-credits) | public-needs-update | yes; `People.movieCredits` | 7E |
| `GET /3/person/{person_id}/tv_credits` | [person-tv-credits](https://developer.themoviedb.org/reference/person-tv-credits) | public-needs-update | yes; `People.tvCredits` | 7E |
| `GET /3/person/{person_id}/tagged_images` | [person-tagged-images](https://developer.themoviedb.org/reference/person-tagged-images) | deprecated | yes; `People.taggedImages` | 7A, 7F, 7K |
| `GET /3/person/{person_id}/translations` | [translations](https://developer.themoviedb.org/reference/translations) | public-needs-update | yes; `People.translations` | 7A, 7G |
| `GET /3/review/{review_id}` | [review-details](https://developer.themoviedb.org/reference/review-details) | internal-only | no; `Reviews.details` | — |
| `GET /3/search/collection` | [search-collection](https://developer.themoviedb.org/reference/search-collection) | internal-only | no; `Search.collections` | — |
| `GET /3/search/company` | [search-company](https://developer.themoviedb.org/reference/search-company) | internal-only | no; `Search.companies` | — |
| `GET /3/search/keyword` | [search-keyword](https://developer.themoviedb.org/reference/search-keyword) | internal-only | no; `Search.keywords` | — |
| `GET /3/search/movie` | [search-movie](https://developer.themoviedb.org/reference/search-movie) | public-needs-update | yes; `Search.movies` | 6 |
| `GET /3/search/multi` | [search-multi](https://developer.themoviedb.org/reference/search-multi) | internal-only | no; `Search.multiSearch` | — |
| `GET /3/search/person` | [search-person](https://developer.themoviedb.org/reference/search-person) | internal-only | no; `Search.people` | — |
| `GET /3/search/tv` | [search-tv](https://developer.themoviedb.org/reference/search-tv) | internal-only | no; `Search.tvShows` | — |
| `GET /3/trending/all/{time_window}` | [trending-all](https://developer.themoviedb.org/reference/trending-all) | public-needs-update | yes; `Trending.trending` | 7A, 7F, 7G |
| `GET /3/trending/movie/{time_window}` | [trending-movies](https://developer.themoviedb.org/reference/trending-movies) | public-needs-update | yes; `Trending.trending` | 7A, 7F, 7G |
| `GET /3/trending/person/{time_window}` | [trending-people](https://developer.themoviedb.org/reference/trending-people) | public-needs-update | yes; `Trending.trending` | 7A, 7F, 7G |
| `GET /3/trending/tv/{time_window}` | [trending-tv](https://developer.themoviedb.org/reference/trending-tv) | public-needs-update | yes; `Trending.trending` | 7A, 7F, 7G |
| `GET /3/tv/airing_today` | [tv-series-airing-today-list](https://developer.themoviedb.org/reference/tv-series-airing-today-list) | public-needs-update | yes; `TV.airingToday` | 7A |
| `GET /3/tv/on_the_air` | [tv-series-on-the-air-list](https://developer.themoviedb.org/reference/tv-series-on-the-air-list) | public-needs-update | yes; `TV.onTheAir` | 7A |
| `GET /3/tv/popular` | [tv-series-popular-list](https://developer.themoviedb.org/reference/tv-series-popular-list) | public-current | yes; `TV.popular` | — |
| `GET /3/tv/top_rated` | [tv-series-top-rated-list](https://developer.themoviedb.org/reference/tv-series-top-rated-list) | public-current | yes; `TV.topRated` | — |
| `GET /3/tv/{series_id}` | [tv-series-details](https://developer.themoviedb.org/reference/tv-series-details) | public-needs-update | yes; `TV.details` | 7G, 7J |
| `GET /3/tv/{series_id}/account_states` | [tv-series-account-states](https://developer.themoviedb.org/reference/tv-series-account-states) | public-needs-update | yes; `TV.accountStates` | 4, 7A, 7H |
| `GET /3/tv/{series_id}/aggregate_credits` | [tv-series-aggregate-credits](https://developer.themoviedb.org/reference/tv-series-aggregate-credits) | public-needs-update | yes; `TV.aggregateCredits` | 7G |
| `GET /3/tv/{series_id}/alternative_titles` | [tv-series-alternative-titles](https://developer.themoviedb.org/reference/tv-series-alternative-titles) | public-needs-update | yes; `TV.alternativeTitles` | 7A |
| `GET /3/tv/{series_id}/changes` | [tv-series-changes](https://developer.themoviedb.org/reference/tv-series-changes) | public-needs-update | yes; `TV.changes` | 5, 7B |
| `GET /3/tv/{series_id}/content_ratings` | [tv-series-content-ratings](https://developer.themoviedb.org/reference/tv-series-content-ratings) | public-needs-update | yes; `TV.contentRatings` | 7A, 7G |
| `GET /3/tv/{series_id}/credits` | [tv-series-credits](https://developer.themoviedb.org/reference/tv-series-credits) | public-needs-update | yes; `TV.credits` | 7G |
| `GET /3/tv/{series_id}/episode_groups` | [tv-series-episode-groups](https://developer.themoviedb.org/reference/tv-series-episode-groups) | public-needs-update | yes; `TV.episodeGroups` | 7A |
| `GET /3/tv/{series_id}/external_ids` | [tv-series-external-ids](https://developer.themoviedb.org/reference/tv-series-external-ids) | public-needs-update | yes; `TV.externalIds` | 7A, 7G |
| `GET /3/tv/{series_id}/images` | [tv-series-images](https://developer.themoviedb.org/reference/tv-series-images) | public-needs-update | yes; `TV.images` | 7A, 7G |
| `GET /3/tv/{series_id}/keywords` | [tv-series-keywords](https://developer.themoviedb.org/reference/tv-series-keywords) | public-current | yes; `TV.keywords` | — |
| `GET /3/tv/latest` | [tv-series-latest-id](https://developer.themoviedb.org/reference/tv-series-latest-id) | public-needs-update | yes; `TV.latest` | 7A, 7G |
| `GET /3/tv/{series_id}/lists` | [lists-copy](https://developer.themoviedb.org/reference/lists-copy) | absent | no; `none` | — |
| `GET /3/tv/{series_id}/recommendations` | [tv-series-recommendations](https://developer.themoviedb.org/reference/tv-series-recommendations) | public-needs-update | yes; `TV.recommendations` | 7D |
| `GET /3/tv/{series_id}/reviews` | [tv-series-reviews](https://developer.themoviedb.org/reference/tv-series-reviews) | public-needs-update | yes; `TV.reviews` | 7G |
| `GET /3/tv/{series_id}/screened_theatrically` | [tv-series-screened-theatrically](https://developer.themoviedb.org/reference/tv-series-screened-theatrically) | public-current | yes; `TV.screenedTheatrically` | — |
| `GET /3/tv/{series_id}/similar` | [tv-series-similar](https://developer.themoviedb.org/reference/tv-series-similar) | public-needs-update | yes; `TV.similarShows` | 7G |
| `GET /3/tv/{series_id}/translations` | [tv-series-translations](https://developer.themoviedb.org/reference/tv-series-translations) | public-needs-update | yes; `TV.translations` | 7G |
| `GET /3/tv/{series_id}/videos` | [tv-series-videos](https://developer.themoviedb.org/reference/tv-series-videos) | public-needs-update | yes; `TV.videos` | 7A, 7G |
| `GET /3/tv/{series_id}/watch/providers` | [tv-series-watch-providers](https://developer.themoviedb.org/reference/tv-series-watch-providers) | public-needs-update | yes; `TV.watchProviders` | 7C |
| `POST /3/tv/{series_id}/rating` | [tv-series-add-rating](https://developer.themoviedb.org/reference/tv-series-add-rating) | public-needs-update | yes; `TV.rateShow` | 3, 7H |
| `DELETE /3/tv/{series_id}/rating` | [tv-series-delete-rating](https://developer.themoviedb.org/reference/tv-series-delete-rating) | public-needs-update | yes; `TV.deleteRating` | 7H |
| `GET /3/tv/{series_id}/season/{season_number}` | [tv-season-details](https://developer.themoviedb.org/reference/tv-season-details) | declaration-only | no; `TVSeasons.details` | — |
| `GET /3/tv/{series_id}/season/{season_number}/account_states` | [tv-season-account-states](https://developer.themoviedb.org/reference/tv-season-account-states) | declaration-only | no; `TVSeasons.accountStates` | — |
| `GET /3/tv/{series_id}/season/{season_number}/aggregate_credits` | [tv-season-aggregate-credits](https://developer.themoviedb.org/reference/tv-season-aggregate-credits) | absent | no; `none` | — |
| `GET /3/tv/season/{season_id}/changes` | [tv-season-changes-by-id](https://developer.themoviedb.org/reference/tv-season-changes-by-id) | declaration-only | no; `TVSeasons.changes` | — |
| `GET /3/tv/{series_id}/season/{season_number}/credits` | [tv-season-credits](https://developer.themoviedb.org/reference/tv-season-credits) | declaration-only | no; `TVSeasons.credits` | — |
| `GET /3/tv/{series_id}/season/{season_number}/external_ids` | [tv-season-external-ids](https://developer.themoviedb.org/reference/tv-season-external-ids) | declaration-only | no; `TVSeasons.externalIds` | — |
| `GET /3/tv/{series_id}/season/{season_number}/images` | [tv-season-images](https://developer.themoviedb.org/reference/tv-season-images) | declaration-only | no; `TVSeasons.images` | — |
| `GET /3/tv/{series_id}/season/{season_number}/translations` | [tv-season-translations](https://developer.themoviedb.org/reference/tv-season-translations) | absent | no; `none` | — |
| `GET /3/tv/{series_id}/season/{season_number}/videos` | [tv-season-videos](https://developer.themoviedb.org/reference/tv-season-videos) | declaration-only | no; `TVSeasons.videos` | — |
| `GET /3/tv/{series_id}/season/{season_number}/watch/providers` | [tv-season-watch-providers](https://developer.themoviedb.org/reference/tv-season-watch-providers) | absent | no; `none` | — |
| `GET /3/tv/{series_id}/season/{season_number}/episode/{episode_number}` | [tv-episode-details](https://developer.themoviedb.org/reference/tv-episode-details) | declaration-only | no; `TVEpisodes.details` | — |
| `GET /3/tv/{series_id}/season/{season_number}/episode/{episode_number}/account_states` | [tv-episode-account-states](https://developer.themoviedb.org/reference/tv-episode-account-states) | declaration-only | no; `TVEpisodes.accountStates` | — |
| `GET /3/tv/episode/{episode_id}/changes` | [tv-episode-changes-by-id](https://developer.themoviedb.org/reference/tv-episode-changes-by-id) | declaration-only | no; `TVEpisodes.changes` | — |
| `GET /3/tv/{series_id}/season/{season_number}/episode/{episode_number}/credits` | [tv-episode-credits](https://developer.themoviedb.org/reference/tv-episode-credits) | declaration-only | no; `TVEpisodes.credits` | — |
| `GET /3/tv/{series_id}/season/{season_number}/episode/{episode_number}/external_ids` | [tv-episode-external-ids](https://developer.themoviedb.org/reference/tv-episode-external-ids) | declaration-only | no; `TVEpisodes.externalIds` | — |
| `GET /3/tv/{series_id}/season/{season_number}/episode/{episode_number}/images` | [tv-episode-images](https://developer.themoviedb.org/reference/tv-episode-images) | declaration-only | no; `TVEpisodes.images` | — |
| `GET /3/tv/{series_id}/season/{season_number}/episode/{episode_number}/translations` | [tv-episode-translations](https://developer.themoviedb.org/reference/tv-episode-translations) | declaration-only | no; `TVEpisodes.translations` | — |
| `GET /3/tv/{series_id}/season/{season_number}/episode/{episode_number}/videos` | [tv-episode-videos](https://developer.themoviedb.org/reference/tv-episode-videos) | declaration-only | no; `TVEpisodes.videos` | — |
| `POST /3/tv/{series_id}/season/{season_number}/episode/{episode_number}/rating` | [tv-episode-add-rating](https://developer.themoviedb.org/reference/tv-episode-add-rating) | declaration-only | no; `TVEpisodes.rateEpisode` | — |
| `DELETE /3/tv/{series_id}/season/{season_number}/episode/{episode_number}/rating` | [tv-episode-delete-rating](https://developer.themoviedb.org/reference/tv-episode-delete-rating) | declaration-only | no; `TVEpisodes.deleteRating` | — |
| `GET /3/tv/episode_group/{tv_episode_group_id}` | [tv-episode-group-details](https://developer.themoviedb.org/reference/tv-episode-group-details) | declaration-only | no; `TVEpisodeGroups.details` | — |
| `GET /3/watch/providers/regions` | [watch-providers-available-regions](https://developer.themoviedb.org/reference/watch-providers-available-regions) | absent | no; `none` | — |
| `GET /3/watch/providers/movie` | [watch-providers-movie-list](https://developer.themoviedb.org/reference/watch-providers-movie-list) | absent | no; `none` | — |
| `GET /3/watch/providers/tv` | [watch-provider-tv-list](https://developer.themoviedb.org/reference/watch-provider-tv-list) | absent | no; `none` | — |

## Local-only routes and expansions

| Key | Symbol | Finding |
| --- | --- | --- |
| `GET /3/account` | `Account.details` | Existing public current-user compatibility call; absent from pinned paths. Preserve with explicit label; add official explicit-ID overload (7I). |
| `GET /3/movie/{movie_id}/similar_movies` | `Movies.similarMovies` | Existing public obsolete similarity path; map to pinned /similar in Task 2. |
| `GET /3/review{reviewId}` | `Reviews.details` | Internal URL is missing slash and accepts Int rather than official string review ID; official row remains internal-only, broken. Missing-family repair deferred. |
| `GET /3/trending/{mediaType}/{timeWindow}` | `Trending.trending` | Internal generic template expands four official literal namespaces; this is not a fifth official operation. |

Additional internal limitations: Reviews.details does not expose a public wrapper and builds the malformed route above. Search has six internal routed cases without public methods. Authentication.createQuestSession is internal-only. TVSeasons, TVEpisodes and TVEpisodeGroups lack Endpoint conformance and usable public wrappers; declarations with wrong/incomplete parameter types remain declaration-only. TV seasons aggregate credits/translations/providers, TV series lists, and all other rows marked absent have no current usable public implementation; do not implement these missing families during this refresh.

## Per-operation official request/response contract

Every row records all parameters (including path/header and defaults). Body links are exact JSON pointers to request schema and examples. Success fields include root field types; **all nested field types, schema presence/required/null markers are in response_fields in the JSON companion**, and the complete source is pinned. Response schemas here mostly omit required lists; defaults in response schemas are schema artifacts, not client fill-in instructions.

| OperationId | Auth | Parameters | Body / success response keys |
| --- | --- | --- | --- |
| `authentication-validate-key` | application API key (api_key supported by application guide; snapshot global Bearer sec0) |  | body none; 200: success:boolean, status_code:integer, status_message:string; 401: status_code:integer, status_message:string, success:boolean |
| `account-details` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user | path account_id:integer required default=null format=int32; query session_id:string optional | body none; 200: avatar:object, id:integer, iso_639_1:string, iso_3166_1:string, name:string, include_adult:boolean, username:string |
| `account-add-favorite` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user | path account_id:integer required default=null format=int32; query session_id:string optional | body `/paths/~13~1account~1{account_id}~1favorite/post/requestBody` (RAW_BODY schema; see examples for actual JSON); 200: status_code:integer, status_message:string |
| `account-add-to-watchlist` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user | path account_id:integer required default=null format=int32; query session_id:string optional | body `/paths/~13~1account~1{account_id}~1watchlist/post/requestBody` (RAW_BODY schema; see examples for actual JSON); 200: status_code:integer, status_message:string |
| `account-get-favorites` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user | path account_id:integer required default=null format=int32; query language:string optional default="en-US"; query page:integer optional default=1 format=int32; query session_id:string optional; query sort_by:string optional default="created_at.asc" enum=["created_at.asc", "created_at.desc"] | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `account-favorite-tv` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user | path account_id:integer required default=null format=int32; query language:string optional default="en-US"; query page:integer optional default=1 format=int32; query session_id:string optional; query sort_by:string optional default="created_at.asc" enum=["created_at.asc", "created_at.desc"] | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `account-lists` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user | path account_id:integer required default=null format=int32; query page:integer optional default=1 format=int32; query session_id:string optional | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `account-rated-movies` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user | path account_id:integer required default=null format=int32; query language:string optional default="en-US"; query page:integer optional default=1 format=int32; query session_id:string optional; query sort_by:string optional default="created_at.asc" enum=["created_at.asc", "created_at.desc"] | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `account-rated-tv` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user | path account_id:integer required default=null format=int32; query language:string optional default="en-US"; query page:integer optional default=1 format=int32; query session_id:string optional; query sort_by:string optional default="created_at.asc" enum=["created_at.asc", "created_at.desc"] | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `account-rated-tv-episodes` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user | path account_id:integer required default=null format=int32; query language:string optional default="en-US"; query page:integer optional default=1 format=int32; query session_id:string optional; query sort_by:string optional default="created_at.asc" enum=["created_at.asc", "created_at.desc"] | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `account-watchlist-movies` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user | path account_id:integer required default=null format=int32; query language:string optional default="en-US"; query page:integer optional default=1 format=int32; query session_id:string optional; query sort_by:string optional default="created_at.asc" enum=["created_at.asc", "created_at.desc"] | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `account-watchlist-tv` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user | path account_id:integer required default=null format=int32; query language:string optional default="en-US"; query page:integer optional default=1 format=int32; query session_id:string optional; query sort_by:string optional default="created_at.asc" enum=["created_at.asc", "created_at.desc"] | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `authentication-create-guest-session` | application API key (api_key supported by application guide; snapshot global Bearer sec0) |  | body none; 200: success:boolean, guest_session_id:string, expires_at:string |
| `authentication-create-request-token` | application API key (api_key supported by application guide; snapshot global Bearer sec0) |  | body none; 200: success:boolean, expires_at:string, request_token:string |
| `authentication-create-session` | application API key (api_key supported by application guide; snapshot global Bearer sec0) |  | body `/paths/~13~1authentication~1session~1new/post/requestBody` (RAW_BODY schema; see examples for actual JSON); 200: success:boolean, session_id:string |
| `authentication-create-session-from-v4-token` | application API key (api_key supported by application guide; snapshot global Bearer sec0) |  | body `/paths/~13~1authentication~1session~1convert~14/post/requestBody` (RAW_BODY schema; see examples for actual JSON); 200: success:boolean, session_id:string |
| `authentication-create-session-from-login` | application API key (api_key supported by application guide; snapshot global Bearer sec0) |  | body `/paths/~13~1authentication~1token~1validate_with_login/post/requestBody` (RAW_BODY schema; see examples for actual JSON); 200: success:boolean, expires_at:string, request_token:string |
| `authentication-delete-session` | application API key (api_key supported by application guide; snapshot global Bearer sec0) |  | body `/paths/~13~1authentication~1session/delete/requestBody` (RAW_BODY schema; see examples for actual JSON); 200: success:boolean |
| `certification-movie-list` | application API key (api_key supported by application guide; snapshot global Bearer sec0) |  | body none; 200: certifications:object |
| `certifications-tv-list` | application API key (api_key supported by application guide; snapshot global Bearer sec0) |  | body none; 200: certifications:object |
| `changes-movie-list` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query end_date:string optional format=date; query page:integer optional default=1 format=int32; query start_date:string optional format=date | body none; 200: results:array, page:integer, total_pages:integer, total_results:integer |
| `changes-people-list` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query end_date:string optional format=date; query page:integer optional default=1 format=int32; query start_date:string optional format=date | body none; 200: results:array, page:integer, total_pages:integer, total_results:integer |
| `changes-tv-list` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query end_date:string optional format=date; query page:integer optional default=1 format=int32; query start_date:string optional format=date | body none; 200: results:array, page:integer, total_pages:integer, total_results:integer |
| `collection-details` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path collection_id:integer required format=int32; query language:string optional default="en-US" | body none; 200: id:integer, name:string, original_language:string, original_name:string, overview:string, poster_path:string, backdrop_path:string, parts:array |
| `collection-images` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path collection_id:integer required format=int32; query include_image_language:string optional; query language:string optional | body none; 200: id:integer, backdrops:array, posters:array |
| `collection-translations` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path collection_id:integer required format=int32 | body none; 200: id:integer, translations:array |
| `company-details` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path company_id:integer required format=int32 | body none; 200: description:string, headquarters:string, homepage:string, id:integer, logo_path:string, name:string, origin_country:string, parent_company:unspecified |
| `company-alternative-names` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path company_id:integer required format=int32 | body none; 200: id:integer, results:array |
| `company-images` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path company_id:integer required format=int32 | body none; 200: id:integer, logos:array |
| `configuration-details` | application API key (api_key supported by application guide; snapshot global Bearer sec0) |  | body none; 200: images:object, change_keys:array |
| `configuration-countries` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query language:string optional default="en-US" | body none; 200: array (no declared fields) |
| `configuration-jobs` | application API key (api_key supported by application guide; snapshot global Bearer sec0) |  | body none; 200: array (no declared fields) |
| `configuration-languages` | application API key (api_key supported by application guide; snapshot global Bearer sec0) |  | body none; 200: array (no declared fields) |
| `configuration-primary-translations` | application API key (api_key supported by application guide; snapshot global Bearer sec0) |  | body none; 200: array (no declared fields) |
| `configuration-timezones` | application API key (api_key supported by application guide; snapshot global Bearer sec0) |  | body none; 200: array (no declared fields) |
| `credit-details` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path credit_id:string required; query language:string optional default="en-US" | body none; 200: credit_type:string, department:string, job:string, media:object, media_type:string, id:string, person:object |
| `discover-movie` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query certification:string optional; query certification.gte:string optional; query certification.lte:string optional; query certification_country:string optional; query include_adult:boolean optional default=false; query include_video:boolean optional default=false; query language:string optional default="en-US"; query page:integer optional default=1 format=int32; query primary_release_year:integer optional format=int32; query primary_release_date.gte:string optional format=date; query primary_release_date.lte:string optional format=date; query region:string optional; query release_date.gte:string optional format=date; query release_date.lte:string optional format=date; query sort_by:string optional default="popularity.desc" enum=["original_title.asc", "original_title.desc", "popularity.asc", "popularity.desc", "revenue.asc", "revenue.desc", "primary_release_date.asc", "title.asc", "title.desc", "primary_release_date.desc", "vote_average.asc", "vote_average.desc", "vote_count.asc", "vote_count.desc"]; query vote_average.gte:number optional format=float; query vote_average.lte:number optional format=float; query vote_count.gte:number optional format=float; query vote_count.lte:number optional format=float; query watch_region:string optional; query with_cast:string optional; query with_companies:string optional; query with_crew:string optional; query with_genres:string optional; query with_keywords:string optional; query with_origin_country:string optional; query with_original_language:string optional; query with_people:string optional; query with_release_type:integer optional format=int32; query with_runtime.gte:integer optional format=int32; query with_runtime.lte:integer optional format=int32; query with_watch_monetization_types:string optional; query with_watch_providers:string optional; query without_companies:string optional; query without_genres:string optional; query without_keywords:string optional; query without_watch_providers:string optional; query year:integer optional format=int32 | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `discover-tv` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query air_date.gte:string optional format=date; query air_date.lte:string optional format=date; query first_air_date_year:integer optional format=int32; query first_air_date.gte:string optional format=date; query first_air_date.lte:string optional format=date; query include_adult:boolean optional default=false; query include_null_first_air_dates:boolean optional default=false; query language:string optional default="en-US"; query page:integer optional default=1 format=int32; query screened_theatrically:boolean optional; query sort_by:string optional default="popularity.desc" enum=["first_air_date.asc", "first_air_date.desc", "name.asc", "name.desc", "original_name.asc", "original_name.desc", "popularity.asc", "popularity.desc", "vote_average.asc", "vote_average.desc", "vote_count.asc", "vote_count.desc"]; query timezone:string optional; query vote_average.gte:number optional format=float; query vote_average.lte:number optional format=float; query vote_count.gte:number optional format=float; query vote_count.lte:number optional format=float; query watch_region:string optional; query with_companies:string optional; query with_genres:string optional; query with_keywords:string optional; query with_networks:integer optional format=int32; query with_origin_country:string optional; query with_original_language:string optional; query with_runtime.gte:integer optional format=int32; query with_runtime.lte:integer optional format=int32; query with_status:string optional; query with_watch_monetization_types:string optional; query with_watch_providers:string optional; query without_companies:string optional; query without_genres:string optional; query without_keywords:string optional; query without_watch_providers:string optional; query with_type:string optional | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `find-by-id` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path external_id:string required; query external_source:string required enum=["imdb_id", "facebook_id", "instagram_id", "tvdb_id", "tiktok_id", "twitter_id", "wikidata_id", "youtube_id"]; query language:string optional default="en-US" | body none; 200: movie_results:array, person_results:array, tv_results:array, tv_episode_results:array, tv_season_results:array |
| `genre-movie-list` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query language:string optional default="en" | body none; 200: genres:array |
| `genre-tv-list` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query language:string optional default="en" | body none; 200: genres:array |
| `guest-session-rated-movies` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user or guest_session_id alternative | path guest_session_id:string required; query language:string optional default="en-US"; query page:integer optional default=1 format=int32; query sort_by:string optional default="created_at.asc" enum=["created_at.asc", "created_at.desc"] | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `guest-session-rated-tv` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user or guest_session_id alternative | path guest_session_id:string required; query language:string optional default="en-US"; query page:integer optional default=1 format=int32; query sort_by:string optional default="created_at.asc" enum=["created_at.asc", "created_at.desc"] | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `guest-session-rated-tv-episodes` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user or guest_session_id alternative | path guest_session_id:string required; query language:string optional default="en-US"; query page:integer optional default=1 format=int32; query sort_by:string optional default="created_at.asc" enum=["created_at.asc", "created_at.desc"] | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `keyword-details` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path keyword_id:integer required format=int32 | body none; 200: id:integer, name:string |
| `keyword-movies` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path keyword_id:string required; query include_adult:boolean optional default=false; query language:string optional default="en-US"; query page:integer optional default=1 format=int32 | body none; 200: id:integer, page:integer, results:array, total_pages:integer, total_results:integer |
| `list-add-movie` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user | path list_id:integer required format=int32; query session_id:string required | body `/paths/~13~1list~1{list_id}~1add_item/post/requestBody` (RAW_BODY schema; see examples for actual JSON); 200: status_code:integer, status_message:string |
| `list-check-item-status` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path list_id:integer required format=int32; query language:string optional default="en-US"; query movie_id:integer optional format=int32 | body none; 200: id:integer, item_present:boolean |
| `list-clear` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user | path list_id:integer required format=int32; query session_id:string required; query confirm:boolean required default=false | body none; 200: status_code:integer, status_message:string |
| `list-create` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user | query session_id:string required | body `/paths/~13~1list/post/requestBody` (RAW_BODY schema; see examples for actual JSON); 200: status_message:string, success:boolean, status_code:integer, list_id:integer |
| `list-delete` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user | path list_id:integer required format=int32; query session_id:string required | body none; 200: status_code:integer, status_message:string |
| `list-details` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path list_id:integer required format=int32; query language:string optional default="en-US"; query page:integer optional default=1 format=int32 | body none; 200: created_by:string, description:string, favorite_count:integer, id:string, items:array, item_count:integer, iso_639_1:string, name:string, poster_path:string |
| `list-remove-movie` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user | path list_id:integer required format=int32; query session_id:string required | body `/paths/~13~1list~1{list_id}~1remove_item/post/requestBody` (RAW_BODY schema; see examples for actual JSON); 200: status_code:integer, status_message:string |
| `movie-now-playing-list` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query language:string optional default="en-US"; query page:integer optional default=1 format=int32; query region:string optional | body none; 200: dates:object, page:integer, results:array, total_pages:integer, total_results:integer |
| `movie-popular-list` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query language:string optional default="en-US"; query page:integer optional default=1 format=int32; query region:string optional | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `movie-top-rated-list` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query language:string optional default="en-US"; query page:integer optional default=1 format=int32; query region:string optional | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `movie-upcoming-list` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query language:string optional default="en-US"; query page:integer optional default=1 format=int32; query region:string optional | body none; 200: dates:object, page:integer, results:array, total_pages:integer, total_results:integer |
| `movie-details` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path movie_id:integer required format=int32; query append_to_response:string optional; query language:string optional default="en-US" | body none; 200: adult:boolean, backdrop_path:string, belongs_to_collection:object, budget:integer, genres:array, homepage:string, id:integer, imdb_id:string, origin_country:array, original_language:string, original_title:string, overview:string, popularity:number, poster_path:string, production_companies:array, production_countries:array, release_date:string, revenue:integer, runtime:integer, spoken_languages:array, status:string, tagline:string, title:string, video:boolean, vote_average:number, vote_count:integer |
| `movie-account-states` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user or guest_session_id alternative | path movie_id:integer required format=int32; query session_id:string optional; query guest_session_id:string optional | body none; 200: id:integer, favorite:boolean, rated:object, watchlist:boolean |
| `movie-alternative-titles` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path movie_id:integer required format=int32; query country:string optional | body none; 200: id:integer, titles:array |
| `movie-changes` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path movie_id:integer required format=int32; query end_date:string optional format=date; query page:integer optional default=1 format=int32; query start_date:string optional format=date | body none; 200: changes:array |
| `movie-credits` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path movie_id:integer required format=int32; query language:string optional default="en-US" | body none; 200: id:integer, cast:array, crew:array |
| `movie-external-ids` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path movie_id:integer required format=int32 | body none; 200: id:integer, imdb_id:string, wikidata_id:unspecified, facebook_id:string, instagram_id:unspecified, twitter_id:unspecified |
| `movie-images` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path movie_id:integer required format=int32; query include_image_language:string optional; query language:string optional | body none; 200: backdrops:array, id:integer, logos:array, posters:array |
| `movie-keywords` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path movie_id:string required | body none; 200: id:integer, keywords:array |
| `movie-latest-id` | application API key (api_key supported by application guide; snapshot global Bearer sec0) |  | body none; 200: adult:boolean, backdrop_path:unspecified, belongs_to_collection:unspecified, budget:integer, genres:array, homepage:string, id:integer, imdb_id:unspecified, original_language:string, original_title:string, overview:string, popularity:integer, poster_path:unspecified, production_companies:array, production_countries:array, release_date:string, revenue:integer, runtime:integer, spoken_languages:array, status:string, tagline:string, title:string, video:boolean, vote_average:integer, vote_count:integer |
| `movie-lists` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path movie_id:integer required format=int32; query language:string optional default="en-US"; query page:integer optional default=1 format=int32 | body none; 200: id:integer, page:integer, results:array, total_pages:integer, total_results:integer |
| `movie-recommendations` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path movie_id:integer required format=int32; query language:string optional default="en-US"; query page:integer optional default=1 format=int32 | body none; 200: object (no declared fields) |
| `movie-release-dates` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path movie_id:integer required format=int32 | body none; 200: id:integer, results:array |
| `movie-reviews` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path movie_id:integer required format=int32; query language:string optional default="en-US"; query page:integer optional default=1 format=int32 | body none; 200: id:integer, page:integer, results:array, total_pages:integer, total_results:integer |
| `movie-similar` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path movie_id:integer required format=int32; query language:string optional default="en-US"; query page:integer optional default=1 format=int32 | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `movie-translations` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path movie_id:integer required format=int32 | body none; 200: id:integer, translations:array |
| `movie-videos` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path movie_id:integer required format=int32; query language:string optional default="en-US" | body none; 200: id:integer, results:array |
| `movie-watch-providers` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path movie_id:integer required format=int32 | body none; 200: id:integer, results:object |
| `movie-add-rating` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user or guest_session_id alternative | path movie_id:integer required format=int32; query guest_session_id:string optional; query session_id:string optional; header Content-Type:string required default="application/json;charset=utf-8" | body `/paths/~13~1movie~1{movie_id}~1rating/post/requestBody` (RAW_BODY schema; see examples for actual JSON); 200: status_code:integer, status_message:string |
| `movie-delete-rating` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user or guest_session_id alternative | path movie_id:integer required format=int32; header Content-Type:string optional default="application/json;charset=utf-8"; query guest_session_id:string optional; query session_id:string optional | body none; 200: status_code:integer, status_message:string |
| `network-details` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path network_id:integer required format=int32 | body none; 200: headquarters:string, homepage:string, id:integer, logo_path:string, name:string, origin_country:string |
| `details-copy` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path network_id:integer required format=int32 | body none; 200: id:integer, results:array |
| `alternative-names-copy` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path network_id:integer required format=int32 | body none; 200: id:integer, logos:array |
| `person-popular-list` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query language:string optional default="en-US"; query page:integer optional default=1 format=int32 | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `person-details` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path person_id:integer required format=int32; query append_to_response:string optional; query language:string optional default="en-US" | body none; 200: adult:boolean, also_known_as:array, biography:string, birthday:string, deathday:unspecified, gender:integer, homepage:unspecified, id:integer, imdb_id:string, known_for_department:string, name:string, place_of_birth:string, popularity:number, profile_path:string |
| `person-changes` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path person_id:integer required format=int32; query end_date:string optional format=date; query page:integer optional default=1 format=int32; query start_date:string optional format=date | body none; 200: changes:array |
| `person-combined-credits` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path person_id:string required; query language:string optional default="en-US" | body none; 200: cast:array, crew:array, id:integer |
| `person-external-ids` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path person_id:integer required format=int32 | body none; 200: id:integer, freebase_mid:string, freebase_id:string, imdb_id:string, tvrage_id:integer, wikidata_id:string, facebook_id:string, instagram_id:string, tiktok_id:string, twitter_id:string, youtube_id:unspecified |
| `person-images` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path person_id:integer required format=int32 | body none; 200: id:integer, profiles:array |
| `person-latest-id` | application API key (api_key supported by application guide; snapshot global Bearer sec0) |  | body none; 200: adult:boolean, also_known_as:array, biography:string, birthday:unspecified, deathday:unspecified, gender:integer, homepage:unspecified, id:integer, imdb_id:unspecified, known_for_department:unspecified, name:string, place_of_birth:unspecified, popularity:integer, profile_path:unspecified |
| `person-movie-credits` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path person_id:integer required format=int32; query language:string optional default="en-US" | body none; 200: cast:array, crew:array, id:integer |
| `person-tv-credits` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path person_id:integer required format=int32; query language:string optional default="en-US" | body none; 200: cast:array, crew:array, id:integer |
| `person-tagged-images` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path person_id:integer required format=int32; query page:integer optional default=1 format=int32 | body none; 200: id:integer, page:integer, results:array, total_pages:integer, total_results:integer |
| `translations` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path person_id:integer required format=int32 | body none; 200: id:integer, translations:array |
| `review-details` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path review_id:string required | body none; 200: id:string, author:string, author_details:object, content:string, created_at:string, iso_639_1:string, media_id:integer, media_title:string, media_type:string, updated_at:string, url:string |
| `search-collection` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query query:string required; query include_adult:boolean optional default=false; query language:string optional default="en-US"; query page:integer optional default=1 format=int32; query region:string optional | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `search-company` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query query:string required; query page:integer optional default=1 format=int32 | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `search-keyword` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query query:string required; query page:integer optional default=1 format=int32 | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `search-movie` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query query:string required; query include_adult:boolean optional default=false; query language:string optional default="en-US"; query primary_release_year:string optional; query page:integer optional default=1 format=int32; query region:string optional; query year:string optional | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `search-multi` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query query:string required; query include_adult:boolean optional default=false; query language:string optional default="en-US"; query page:integer optional default=1 format=int32 | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `search-person` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query query:string required; query include_adult:boolean optional default=false; query language:string optional default="en-US"; query page:integer optional default=1 format=int32 | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `search-tv` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query query:string required; query first_air_date_year:integer optional format=int32; query include_adult:boolean optional default=false; query language:string optional default="en-US"; query page:integer optional default=1 format=int32; query year:integer optional format=int32 | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `trending-all` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path time_window:string required default="day" enum=["day", "week"]; query language:string optional default="en-US" | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `trending-movies` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path time_window:string required default="day" enum=["day", "week"]; query language:string optional default="en-US" | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `trending-people` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path time_window:string required default="day" enum=["day", "week"]; query language:string optional default="en-US" | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `trending-tv` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path time_window:string required default="day" enum=["day", "week"]; query language:string optional default="en-US" | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `tv-series-airing-today-list` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query language:string optional default="en-US"; query page:integer optional default=1 format=int32; query timezone:string optional | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `tv-series-on-the-air-list` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query language:string optional default="en-US"; query page:integer optional default=1 format=int32; query timezone:string optional | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `tv-series-popular-list` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query language:string optional default="en-US"; query page:integer optional default=1 format=int32 | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `tv-series-top-rated-list` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query language:string optional default="en-US"; query page:integer optional default=1 format=int32 | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `tv-series-details` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32; query append_to_response:string optional; query language:string optional default="en-US" | body none; 200: adult:boolean, backdrop_path:string, created_by:array, episode_run_time:array, first_air_date:string, genres:array, homepage:string, id:integer, in_production:boolean, languages:array, last_air_date:string, last_episode_to_air:object, name:string, next_episode_to_air:unspecified, networks:array, number_of_episodes:integer, number_of_seasons:integer, origin_country:array, original_language:string, original_name:string, overview:string, popularity:number, poster_path:string, production_companies:array, production_countries:array, seasons:array, spoken_languages:array, status:string, tagline:string, type:string, vote_average:number, vote_count:integer |
| `tv-series-account-states` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user or guest_session_id alternative | path series_id:integer required format=int32; query session_id:string optional; query guest_session_id:string optional | body none; 200: id:integer, favorite:boolean, rated:object, watchlist:boolean |
| `tv-series-aggregate-credits` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32; query language:string optional default="en-US" | body none; 200: cast:array, crew:array, id:integer |
| `tv-series-alternative-titles` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32 | body none; 200: id:integer, results:array |
| `tv-series-changes` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32; query end_date:string optional; query page:integer optional default=1 format=int32; query start_date:string optional | body none; 200: changes:array |
| `tv-series-content-ratings` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32 | body none; 200: results:array, id:integer |
| `tv-series-credits` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32; query language:string optional default="en-US" | body none; 200: cast:array, crew:array, id:integer |
| `tv-series-episode-groups` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32 | body none; 200: results:array, id:integer |
| `tv-series-external-ids` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32 | body none; 200: id:integer, imdb_id:string, freebase_mid:string, freebase_id:string, tvdb_id:integer, tvrage_id:integer, wikidata_id:string, facebook_id:string, instagram_id:string, twitter_id:string |
| `tv-series-images` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32; query include_image_language:string optional; query language:string optional | body none; 200: backdrops:array, id:integer, logos:array, posters:array |
| `tv-series-keywords` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32 | body none; 200: id:integer, results:array |
| `tv-series-latest-id` | application API key (api_key supported by application guide; snapshot global Bearer sec0) |  | body none; 200: adult:boolean, backdrop_path:unspecified, created_by:array, episode_run_time:array, first_air_date:string, genres:array, homepage:string, id:integer, in_production:boolean, languages:array, last_air_date:string, last_episode_to_air:object, name:string, next_episode_to_air:unspecified, networks:array, number_of_episodes:integer, number_of_seasons:integer, origin_country:array, original_language:string, original_name:string, overview:string, popularity:integer, poster_path:unspecified, production_companies:array, production_countries:array, seasons:array, spoken_languages:array, status:string, tagline:string, type:string, vote_average:integer, vote_count:integer |
| `lists-copy` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32; query language:string optional default="en-US"; query page:integer optional default=1 format=int32 | body none; 200: id:integer, page:integer, results:array, total_pages:integer, total_results:integer |
| `tv-series-recommendations` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32; query language:string optional default="en-US"; query page:integer optional default=1 format=int32 | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `tv-series-reviews` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32; query language:string optional default="en-US"; query page:integer optional default=1 format=int32 | body none; 200: id:integer, page:integer, results:array, total_pages:integer, total_results:integer |
| `tv-series-screened-theatrically` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32 | body none; 200: id:integer, results:array |
| `tv-series-similar` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:string required; query language:string optional default="en-US"; query page:integer optional default=1 format=int32 | body none; 200: page:integer, results:array, total_pages:integer, total_results:integer |
| `tv-series-translations` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32 | body none; 200: id:integer, translations:array |
| `tv-series-videos` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32; query include_video_language:string optional; query language:string optional default="en-US" | body none; 200: id:integer, results:array |
| `tv-series-watch-providers` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32 | body none; 200: id:integer, results:object |
| `tv-series-add-rating` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user or guest_session_id alternative | path series_id:integer required format=int32; query guest_session_id:string optional; query session_id:string optional; header Content-Type:string required default="application/json;charset=utf-8" | body `/paths/~13~1tv~1{series_id}~1rating/post/requestBody` (RAW_BODY schema; see examples for actual JSON); 200: status_code:integer, status_message:string |
| `tv-series-delete-rating` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user or guest_session_id alternative | path series_id:integer required format=int32; header Content-Type:string optional default="application/json;charset=utf-8"; query guest_session_id:string optional; query session_id:string optional | body none; 200: status_code:integer, status_message:string |
| `tv-season-details` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32; path season_number:integer required format=int32; query append_to_response:string optional; query language:string optional default="en-US" | body none; 200: _id:string, air_date:string, episodes:array, name:string, networks:array, overview:string, id:integer, poster_path:string, season_number:integer, vote_average:number |
| `tv-season-account-states` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user or guest_session_id alternative | path series_id:integer required format=int32; query session_id:string optional; query guest_session_id:string optional; path season_number:integer required format=int32 | body none; 200: id:integer, results:array |
| `tv-season-aggregate-credits` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32; query language:string optional default="en-US"; path season_number:integer required format=int32 | body none; 200: cast:array, crew:array, id:integer |
| `tv-season-changes-by-id` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query end_date:string optional; query page:integer optional default=1 format=int32; query start_date:string optional; path season_id:integer required format=int32 | body none; 200: changes:array |
| `tv-season-credits` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32; path season_number:integer required format=int32; query language:string optional default="en-US" | body none; 200: cast:array, crew:array, id:integer |
| `tv-season-external-ids` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32; path season_number:integer required format=int32 | body none; 200: id:integer, freebase_mid:string, freebase_id:string, tvdb_id:integer, tvrage_id:unspecified, wikidata_id:string |
| `tv-season-images` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32; query include_image_language:string optional; query language:string optional; path season_number:integer required format=int32 | body none; 200: id:integer, posters:array |
| `tv-season-translations` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32; path season_number:integer required format=int32 | body none; 200: id:integer, translations:array |
| `tv-season-videos` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32; query include_video_language:string optional; query language:string optional default="en-US"; path season_number:integer required format=int32 | body none; 200: id:integer, results:array |
| `tv-season-watch-providers` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32; query language:string optional default="en-US"; path season_number:integer required format=int32 | body none; 200: id:integer, results:object |
| `tv-episode-details` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32; path season_number:integer required format=int32; path episode_number:integer required format=int32; query append_to_response:string optional; query language:string optional default="en-US" | body none; 200: air_date:string, crew:array, episode_number:integer, guest_stars:array, name:string, overview:string, id:integer, production_code:string, runtime:integer, season_number:integer, still_path:string, vote_average:number, vote_count:integer |
| `tv-episode-account-states` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user or guest_session_id alternative | path series_id:integer required format=int32; query session_id:string optional; path season_number:integer required format=int32; path episode_number:integer required format=int32; query guest_session_id:string optional | body none; 200: id:integer, favorite:boolean, rated:object, watchlist:boolean |
| `tv-episode-changes-by-id` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path episode_id:integer required format=int32 | body none; 200: changes:array |
| `tv-episode-credits` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32; path season_number:integer required format=int32; query language:string optional default="en-US"; path episode_number:integer required format=int32 | body none; 200: cast:array, crew:array, guest_stars:array, id:integer |
| `tv-episode-external-ids` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32; path season_number:integer required format=int32; path episode_number:string required | body none; 200: id:integer, imdb_id:string, freebase_mid:string, freebase_id:string, tvdb_id:integer, tvrage_id:integer, wikidata_id:string |
| `tv-episode-images` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32; query include_image_language:string optional; query language:string optional; path season_number:integer required format=int32; path episode_number:integer required format=int32 | body none; 200: id:integer, stills:array |
| `tv-episode-translations` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32; path season_number:integer required format=int32; path episode_number:integer required format=int32 | body none; 200: id:integer, translations:array |
| `tv-episode-videos` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path series_id:integer required format=int32; query include_video_language:string optional; query language:string optional default="en-US"; path season_number:integer required format=int32; path episode_number:integer required format=int32 | body none; 200: id:integer, results:array |
| `tv-episode-add-rating` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user or guest_session_id alternative | path series_id:integer required format=int32; query guest_session_id:string optional; query session_id:string optional; header Content-Type:string required default="application/json;charset=utf-8"; path season_number:integer required format=int32; path episode_number:integer required format=int32 | body `/paths/~13~1tv~1{series_id}~1season~1{season_number}~1episode~1{episode_number}~1rating/post/requestBody` (RAW_BODY schema; see examples for actual JSON); 200: status_code:integer, status_message:string |
| `tv-episode-delete-rating` | application API key (api_key supported by application guide; snapshot global Bearer sec0); session_id user or guest_session_id alternative | path series_id:integer required format=int32; header Content-Type:string optional default="application/json;charset=utf-8"; query guest_session_id:string optional; query session_id:string optional; path season_number:integer required format=int32; path episode_number:integer required format=int32 | body none; 200: status_code:integer, status_message:string |
| `tv-episode-group-details` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | path tv_episode_group_id:string required | body none; 200: description:string, episode_count:integer, group_count:integer, groups:array, id:string, name:string, network:object, type:integer |
| `watch-providers-available-regions` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query language:string optional default="en-US" | body none; 200: results:array |
| `watch-providers-movie-list` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query language:string optional default="en-US"; query watch_region:string optional | body none; 200: results:array |
| `watch-provider-tv-list` | application API key (api_key supported by application guide; snapshot global Bearer sec0) | query language:string optional default="en-US"; query watch_region:string optional | body none; 200: results:array |

## Every current public network method

Each method below supplies the signature, actual dispatch/request and all named existing tests. Endpoints-only tests are listed separately because they do not prove a public call works. A blank public-test list is a measured coverage gap. Query nils are omitted, Int PageNumber is serialized as decimal without validation, language/region are passed unchanged. Session/API-key insertion is at NetworkClient; all callbacks retain TMDBResult semantics. Pagination keys and response types are exact in the operation contract above/JSON companion.

### Account.details

`public func details(completion: @escaping TMDBResult<AccountDetails>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Account.swift:18](../../Sources/TMDBKit/Networking/APIClient/TMDB+Account.swift#L18). Official operationId(s): `account-details`.

Actual request: GET; no body; no endpoint headers. Query: `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `AccountDetails`. Models: `AccountDetails` ([Sources/TMDBKit/Model/AccountDetails.swift:11](../../Sources/TMDBKit/Model/AccountDetails.swift#L11)), `AccountDetails.Avatar` ([Sources/TMDBKit/Model/AccountDetails.swift:12](../../Sources/TMDBKit/Model/AccountDetails.swift#L12)), `AccountDetails.Avatar.Gravatar` ([Sources/TMDBKit/Model/AccountDetails.swift:13](../../Sources/TMDBKit/Model/AccountDetails.swift#L13)).

Existing public-call tests: `AccountEndpointTests.testDetailsRequest` ([Tests/TMDBKitTests/AccountEndpointTests.swift:13](../../Tests/TMDBKitTests/AccountEndpointTests.swift#L13)).

Existing endpoint/fixture-associated tests: `AccountEndpointTests.testDetailsRequest`; `AccountEndpointTests.test_httpMethod`; `AccountEndpointTests.test_httpBody`; `AccountEndpointTests.test_requestHeaders`; `AccountEndpointTests.test_urlConstruction`.

Discrepancies / decisions: Public details calls GET /3/account, not documented /3/account/{account_id}; official operation has only an intended mapping until explicit-ID overload exists. Repair tasks: 7G, 7I.

Field crosswalk for `account-details`:

- `avatar.tmdb` → `AccountDetails.Avatar`: not exposed.

### Account.createdLists

`public func createdListsFor(accountId: Int? = nil, pageNumber: PageNumber?, language: String? = nil, sortBy: Sort? = nil, completion: @escaping TMDBResult<HTTPResponseContaining<ListsResponse>>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Account.swift:30](../../Sources/TMDBKit/Networking/APIClient/TMDB+Account.swift#L30). Official operationId(s): `account-lists`.

Actual request: GET; no body; no endpoint headers. Query: `sort_by`, `page`, `language`, `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `HTTPResponseContaining<ListsResponse>`. Models: `List` ([Sources/TMDBKit/Model/List.swift:10](../../Sources/TMDBKit/Model/List.swift#L10)), `ListsResponse` ([Sources/TMDBKit/Responses/ListsResponse.swift:11](../../Sources/TMDBKit/Responses/ListsResponse.swift#L11)).

Existing public-call tests: `AccountEndpointTests.testCreatedListsRequest` ([Tests/TMDBKitTests/AccountEndpointTests.swift:21](../../Tests/TMDBKitTests/AccountEndpointTests.swift#L21)).

Existing endpoint/fixture-associated tests: `AccountEndpointTests.testCreatedListsRequest`; `AccountEndpointTests.test_httpMethod`; `AccountEndpointTests.test_httpBody`; `AccountEndpointTests.test_requestHeaders`; `AccountEndpointTests.test_urlConstruction`.

Discrepancies / decisions: Sends undocumented language/sort_by; nil account ID uses undocumented 0 convention. Repair tasks: 7A, 7I.

All optional nil account IDs currently become literal `0` via URL.appendingAccountId; no pinned operation documents that current-user convention. Task 7I retains explicit compatibility evidence boundaries.

### Account.favoriteMovies

`public func favoriteMoviesFor(accountId: Int? = nil, pageNumber: PageNumber?, language: String? = nil, sortBy: Sort? = nil, completion: @escaping TMDBResult<HTTPResponseContaining<PopularMoviesResponse>>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Account.swift:45](../../Sources/TMDBKit/Networking/APIClient/TMDB+Account.swift#L45). Official operationId(s): `account-get-favorites`.

Actual request: GET; no body; no endpoint headers. Query: `sort_by`, `page`, `language`, `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `HTTPResponseContaining<PopularMoviesResponse>`. Models: `MovieFragment` ([Sources/TMDBKit/Model/MovieFragment.swift:11](../../Sources/TMDBKit/Model/MovieFragment.swift#L11)), `PopularMoviesResponse` ([Sources/TMDBKit/Responses/PopularMoviesResponse.swift:11](../../Sources/TMDBKit/Responses/PopularMoviesResponse.swift#L11)).

Existing public-call tests: `AccountEndpointTests.testFavoriteMoviesRequest` ([Tests/TMDBKitTests/AccountEndpointTests.swift:29](../../Tests/TMDBKitTests/AccountEndpointTests.swift#L29)).

Existing endpoint/fixture-associated tests: `AccountEndpointTests.testFavoriteMoviesRequest`; `AccountEndpointTests.test_httpMethod`; `AccountEndpointTests.test_httpBody`; `AccountEndpointTests.test_requestHeaders`; `AccountEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7I.

All optional nil account IDs currently become literal `0` via URL.appendingAccountId; no pinned operation documents that current-user convention. Task 7I retains explicit compatibility evidence boundaries.

### Account.favoriteTVShows

`public func favoriteTVShowsFor(accountId: Int? = nil, pageNumber: PageNumber?, language: String? = nil, sortBy: Sort? = nil, completion: @escaping TMDBResult<HTTPResponseContaining<SimilarShowsResponse>>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Account.swift:60](../../Sources/TMDBKit/Networking/APIClient/TMDB+Account.swift#L60). Official operationId(s): `account-favorite-tv`.

Actual request: GET; no body; no endpoint headers. Query: `sort_by`, `page`, `language`, `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `HTTPResponseContaining<SimilarShowsResponse>`. Models: `SimilarShowsResponse` ([Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift:10](../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift#L10)), `TVShowFragment` ([Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift:17](../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift#L17)).

Existing public-call tests: `AccountEndpointTests.testFavoriteTVShowsRequest` ([Tests/TMDBKitTests/AccountEndpointTests.swift:37](../../Tests/TMDBKitTests/AccountEndpointTests.swift#L37)).

Existing endpoint/fixture-associated tests: `AccountEndpointTests.testFavoriteTVShowsRequest`; `AccountEndpointTests.test_httpMethod`; `AccountEndpointTests.test_httpBody`; `AccountEndpointTests.test_requestHeaders`; `AccountEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7G, 7I.

Field crosswalk for `account-favorite-tv`:

- `results.[]adult` → `TVShowFragment`: not exposed.

All optional nil account IDs currently become literal `0` via URL.appendingAccountId; no pinned operation documents that current-user convention. Task 7I retains explicit compatibility evidence boundaries.

### Account.ratedMovies

`public func ratedMoviesFor(accountId: Int? = nil, pageNumber: PageNumber?, language: String? = nil, sortBy: Sort? = nil, completion: @escaping TMDBResult<HTTPResponseContaining<PopularMoviesResponse>>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Account.swift:75](../../Sources/TMDBKit/Networking/APIClient/TMDB+Account.swift#L75). Official operationId(s): `account-rated-movies`.

Actual request: GET; no body; no endpoint headers. Query: `sort_by`, `page`, `language`, `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `HTTPResponseContaining<PopularMoviesResponse>`. Models: `MovieFragment` ([Sources/TMDBKit/Model/MovieFragment.swift:11](../../Sources/TMDBKit/Model/MovieFragment.swift#L11)), `PopularMoviesResponse` ([Sources/TMDBKit/Responses/PopularMoviesResponse.swift:11](../../Sources/TMDBKit/Responses/PopularMoviesResponse.swift#L11)).

Existing public-call tests: `AccountEndpointTests.testRatedMoviesRequest` ([Tests/TMDBKitTests/AccountEndpointTests.swift:45](../../Tests/TMDBKitTests/AccountEndpointTests.swift#L45)).

Existing endpoint/fixture-associated tests: `AccountEndpointTests.testRatedMoviesRequest`; `AccountEndpointTests.test_httpMethod`; `AccountEndpointTests.test_httpBody`; `AccountEndpointTests.test_requestHeaders`; `AccountEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7I.

All optional nil account IDs currently become literal `0` via URL.appendingAccountId; no pinned operation documents that current-user convention. Task 7I retains explicit compatibility evidence boundaries.

### Account.ratedTVShows

`public func ratedTVShowsFor(accountId: Int? = nil, pageNumber: PageNumber?, language: String? = nil, sortBy: Sort? = nil, completion: @escaping TMDBResult<HTTPResponseContaining<SimilarShowsResponse>>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Account.swift:90](../../Sources/TMDBKit/Networking/APIClient/TMDB+Account.swift#L90). Official operationId(s): `account-rated-tv`.

Actual request: GET; no body; no endpoint headers. Query: `sort_by`, `page`, `language`, `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `HTTPResponseContaining<SimilarShowsResponse>`. Models: `SimilarShowsResponse` ([Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift:10](../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift#L10)), `TVShowFragment` ([Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift:17](../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift#L17)).

Existing public-call tests: `AccountEndpointTests.testRatedTVShowsRequest` ([Tests/TMDBKitTests/AccountEndpointTests.swift:53](../../Tests/TMDBKitTests/AccountEndpointTests.swift#L53)).

Existing endpoint/fixture-associated tests: `AccountEndpointTests.testRatedTVShowsRequest`; `AccountEndpointTests.test_httpMethod`; `AccountEndpointTests.test_httpBody`; `AccountEndpointTests.test_requestHeaders`; `AccountEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7G, 7I.

Field crosswalk for `account-rated-tv`:

- `results.[]adult` → `TVShowFragment`: not exposed.
- `results.[]rating` → `TVShowFragment`: not exposed.

All optional nil account IDs currently become literal `0` via URL.appendingAccountId; no pinned operation documents that current-user convention. Task 7I retains explicit compatibility evidence boundaries.

### Account.ratedTVEpisodes

`public func ratedTVEpisodesFor(accountId: Int? = nil, pageNumber: PageNumber?, language: String? = nil, sortBy: Sort? = nil, completion: @escaping TMDBResult<HTTPResponseContaining<EpisodeListResponse>>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Account.swift:105](../../Sources/TMDBKit/Networking/APIClient/TMDB+Account.swift#L105). Official operationId(s): `account-rated-tv-episodes`.

Actual request: GET; no body; no endpoint headers. Query: `sort_by`, `page`, `language`, `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `HTTPResponseContaining<EpisodeListResponse>`. Models: `EpisodeListResponse` ([Sources/TMDBKit/Responses/EpisodeListResponse.swift:11](../../Sources/TMDBKit/Responses/EpisodeListResponse.swift#L11)), `LastEpisodeToAir` ([Sources/TMDBKit/Model/TVDetails.swift:57](../../Sources/TMDBKit/Model/TVDetails.swift#L57)).

Existing public-call tests: `AccountEndpointTests.testRatedTVEpisodesRequest` ([Tests/TMDBKitTests/AccountEndpointTests.swift:61](../../Tests/TMDBKitTests/AccountEndpointTests.swift#L61)).

Existing endpoint/fixture-associated tests: `AccountEndpointTests.testRatedTVEpisodesRequest`; `AccountEndpointTests.test_httpMethod`; `AccountEndpointTests.test_httpBody`; `AccountEndpointTests.test_requestHeaders`; `AccountEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7G, 7I.

Field crosswalk for `account-rated-tv-episodes`:

- `results.[]runtime` → `LastEpisodeToAir`: not exposed.
- `results.[]rating` → `LastEpisodeToAir`: not exposed.

All optional nil account IDs currently become literal `0` via URL.appendingAccountId; no pinned operation documents that current-user convention. Task 7I retains explicit compatibility evidence boundaries.

### Account.movieWatchlist

`public func movieWatchlist(accountId: Int? = nil, pageNumber: PageNumber?, language: String? = nil, sortBy: Sort? = nil, completion: @escaping TMDBResult<HTTPResponseContaining<PopularMoviesResponse>>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Account.swift:120](../../Sources/TMDBKit/Networking/APIClient/TMDB+Account.swift#L120). Official operationId(s): `account-watchlist-movies`.

Actual request: GET; no body; no endpoint headers. Query: `sort_by`, `page`, `language`, `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `HTTPResponseContaining<PopularMoviesResponse>`. Models: `MovieFragment` ([Sources/TMDBKit/Model/MovieFragment.swift:11](../../Sources/TMDBKit/Model/MovieFragment.swift#L11)), `PopularMoviesResponse` ([Sources/TMDBKit/Responses/PopularMoviesResponse.swift:11](../../Sources/TMDBKit/Responses/PopularMoviesResponse.swift#L11)).

Existing public-call tests: `AccountEndpointTests.testMovieWatchlistRequest` ([Tests/TMDBKitTests/AccountEndpointTests.swift:69](../../Tests/TMDBKitTests/AccountEndpointTests.swift#L69)).

Existing endpoint/fixture-associated tests: `AccountEndpointTests.testMovieWatchlistRequest`; `AccountEndpointTests.test_httpMethod`; `AccountEndpointTests.test_httpBody`; `AccountEndpointTests.test_requestHeaders`; `AccountEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7I.

All optional nil account IDs currently become literal `0` via URL.appendingAccountId; no pinned operation documents that current-user convention. Task 7I retains explicit compatibility evidence boundaries.

### Account.tvShowWatchlist

`public func tvShowWatchlist(accountId: Int? = nil, pageNumber: PageNumber?, language: String? = nil, sortBy: Sort? = nil, completion: @escaping TMDBResult<HTTPResponseContaining<SimilarShowsResponse>>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Account.swift:135](../../Sources/TMDBKit/Networking/APIClient/TMDB+Account.swift#L135). Official operationId(s): `account-watchlist-tv`.

Actual request: GET; no body; no endpoint headers. Query: `sort_by`, `page`, `language`, `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `HTTPResponseContaining<SimilarShowsResponse>`. Models: `SimilarShowsResponse` ([Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift:10](../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift#L10)), `TVShowFragment` ([Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift:17](../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift#L17)).

Existing public-call tests: `AccountEndpointTests.testTVShowWatchlistRequest` ([Tests/TMDBKitTests/AccountEndpointTests.swift:77](../../Tests/TMDBKitTests/AccountEndpointTests.swift#L77)).

Existing endpoint/fixture-associated tests: `AccountEndpointTests.testTVShowWatchlistRequest`; `AccountEndpointTests.test_httpMethod`; `AccountEndpointTests.test_httpBody`; `AccountEndpointTests.test_requestHeaders`; `AccountEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7G, 7I.

Field crosswalk for `account-watchlist-tv`:

- `results.[]adult` → `TVShowFragment`: not exposed.

All optional nil account IDs currently become literal `0` via URL.appendingAccountId; no pinned operation documents that current-user convention. Task 7I retains explicit compatibility evidence boundaries.

### Account.markFavorite

`public func markAsFavorite(_ isFavorite: Bool, media: ListableMedia, for accountId: Int? = nil, completion: @escaping TMDBResult<StatusResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Account.swift:152](../../Sources/TMDBKit/Networking/APIClient/TMDB+Account.swift#L152). Official operationId(s): `account-add-favorite`.

Actual request: POST JSON {media_type, media_id, favorite}; application/json;charset=utf-8. Query: `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `StatusResponse`. Models: `StatusResponse` ([Sources/TMDBKit/Networking/APIClient/TMDB.swift:36](../../Sources/TMDBKit/Networking/APIClient/TMDB.swift#L36)).

Existing public-call tests: **none**.

Existing endpoint/fixture-associated tests: `AccountEndpointTests.test_httpMethod`; `AccountEndpointTests.test_httpBody`; `AccountEndpointTests.test_markFavorite_httpBody`; `AccountEndpointTests.test_requestHeaders`; `AccountEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7I.

All optional nil account IDs currently become literal `0` via URL.appendingAccountId; no pinned operation documents that current-user convention. Task 7I retains explicit compatibility evidence boundaries.

### Account.addToWatchlist

`public func addToWatchlist(_ toWatchlist: Bool, media: ListableMedia, for accountId: Int? = nil, completion: @escaping TMDBResult<StatusResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Account.swift:164](../../Sources/TMDBKit/Networking/APIClient/TMDB+Account.swift#L164). Official operationId(s): `account-add-to-watchlist`.

Actual request: POST JSON {media_type, media_id, watchlist}; application/json;charset=utf-8. Query: `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `StatusResponse`. Models: `StatusResponse` ([Sources/TMDBKit/Networking/APIClient/TMDB.swift:36](../../Sources/TMDBKit/Networking/APIClient/TMDB.swift#L36)).

Existing public-call tests: **none**.

Existing endpoint/fixture-associated tests: `AccountEndpointTests.test_httpMethod`; `AccountEndpointTests.test_httpBody`; `AccountEndpointTests.test_addToWatchList_httpBody`; `AccountEndpointTests.test_requestHeaders`; `AccountEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7I.

All optional nil account IDs currently become literal `0` via URL.appendingAccountId; no pinned operation documents that current-user convention. Task 7I retains explicit compatibility evidence boundaries.

### Lists.details

`public func details(for listId: String, language: String? = nil, completion: @escaping TMDBResult<ListDetails>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Lists.swift:20](../../Sources/TMDBKit/Networking/APIClient/TMDB+Lists.swift#L20). Official operationId(s): `list-details`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `ListDetails`. Models: `ListDetails` ([Sources/TMDBKit/Model/List.swift:21](../../Sources/TMDBKit/Model/List.swift#L21)), `MovieFragment` ([Sources/TMDBKit/Model/MovieFragment.swift:11](../../Sources/TMDBKit/Model/MovieFragment.swift#L11)).

Existing public-call tests: `ListEndpointTests.test_details` ([Tests/TMDBKitTests/ListEndpointTests.swift:12](../../Tests/TMDBKitTests/ListEndpointTests.swift#L12)).

Existing endpoint/fixture-associated tests: `ListEndpointTests.test_details`; `ListEndpointTests.test_httpMethod`; `ListEndpointTests.test_httpBody`; `ListEndpointTests.test_requestHeaders`; `ListEndpointTests.test_urlConstruction`.

Discrepancies / decisions: Requires user session unnecessarily; omits page; response uses string ID (retain). Repair tasks: 7A, 7G, 7H.

Field crosswalk for `list-details`:

- `items.[]media_type` → `MovieFragment`: not exposed.

### Lists.itemStatus

`public func itemStatus(itemId: Int, listId: String, completion: @escaping TMDBResult<ListItemStatus>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Lists.swift:29](../../Sources/TMDBKit/Networking/APIClient/TMDB+Lists.swift#L29). Official operationId(s): `list-check-item-status`.

Actual request: GET; no body; no endpoint headers. Query: `movie_id`, `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `ListItemStatus`. Models: `ListItemStatus` ([Sources/TMDBKit/Model/List.swift:34](../../Sources/TMDBKit/Model/List.swift#L34)).

Existing public-call tests: `ListEndpointTests.test_itemStatus` ([Tests/TMDBKitTests/ListEndpointTests.swift:28](../../Tests/TMDBKitTests/ListEndpointTests.swift#L28)).

Existing endpoint/fixture-associated tests: `ListEndpointTests.test_itemStatus`; `ListEndpointTests.test_httpMethod`; `ListEndpointTests.test_httpBody`; `ListEndpointTests.test_requestHeaders`; `ListEndpointTests.test_urlConstruction`.

Discrepancies / decisions: Requires user session unnecessarily; omits language; pinned numeric ID fails String decoder. Repair tasks: 7A, 7E, 7H.

Field crosswalk for `list-check-item-status`:

- `id` → `ListItemStatus`: type integer vs String.

### Lists.createList

`public func createWith(name: String, description: String?, language: String?, completion: @escaping TMDBResult<ListCreateResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Lists.swift:39](../../Sources/TMDBKit/Networking/APIClient/TMDB+Lists.swift#L39). Official operationId(s): `list-create`.

Actual request: POST JSON {name, description: supplied or empty string, language: supplied or empty string}; application/json;charset=utf-8. Query: `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `ListCreateResponse`. Models: `ListCreateResponse` ([Sources/TMDBKit/Model/List.swift:39](../../Sources/TMDBKit/Model/List.swift#L39)).

Existing public-call tests: `ListEndpointTests.test_createWith` ([Tests/TMDBKitTests/ListEndpointTests.swift:35](../../Tests/TMDBKitTests/ListEndpointTests.swift#L35)).

Existing endpoint/fixture-associated tests: `ListEndpointTests.test_createWith`; `ListEndpointTests.test_httpMethod`; `ListEndpointTests.test_httpBody`; `ListEndpointTests.test_createListHTTPBody`; `ListEndpointTests.test_requestHeaders`; `ListEndpointTests.test_urlConstruction`.

Discrepancies / decisions: No confirmed discrepancy in inspected request/represented response fields; systematic failure/request coverage remains Task 8/9. Repair tasks: none confirmed.

### Lists.addMovie

`public func addMovie(movieId: Int, to listId: String, completion: @escaping TMDBResult<ListModificationResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Lists.swift:49](../../Sources/TMDBKit/Networking/APIClient/TMDB+Lists.swift#L49). Official operationId(s): `list-add-movie`.

Actual request: POST JSON {media_id}; application/json;charset=utf-8. Query: `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `ListModificationResponse`. Models: `ListModificationResponse` ([Sources/TMDBKit/Model/List.swift:46](../../Sources/TMDBKit/Model/List.swift#L46)).

Existing public-call tests: `ListEndpointTests.test_addMovie` ([Tests/TMDBKitTests/ListEndpointTests.swift:44](../../Tests/TMDBKitTests/ListEndpointTests.swift#L44)).

Existing endpoint/fixture-associated tests: `ListEndpointTests.test_addMovie`; `ListEndpointTests.test_httpMethod`; `ListEndpointTests.test_httpBody`; `ListEndpointTests.test_addMovie_HTTPBody`; `ListEndpointTests.test_requestHeaders`; `ListEndpointTests.test_urlConstruction`.

Discrepancies / decisions: No confirmed discrepancy in inspected request/represented response fields; systematic failure/request coverage remains Task 8/9. Repair tasks: none confirmed.

### Lists.removeMovie

`public func removeMovie(movieId: Int, from listId: String, completion: @escaping TMDBResult<ListModificationResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Lists.swift:58](../../Sources/TMDBKit/Networking/APIClient/TMDB+Lists.swift#L58). Official operationId(s): `list-remove-movie`.

Actual request: POST JSON {media_id}; application/json;charset=utf-8. Query: `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `ListModificationResponse`. Models: `ListModificationResponse` ([Sources/TMDBKit/Model/List.swift:46](../../Sources/TMDBKit/Model/List.swift#L46)).

Existing public-call tests: `ListEndpointTests.test_removeMovie` ([Tests/TMDBKitTests/ListEndpointTests.swift:51](../../Tests/TMDBKitTests/ListEndpointTests.swift#L51)).

Existing endpoint/fixture-associated tests: `ListEndpointTests.test_removeMovie`; `ListEndpointTests.test_httpMethod`; `ListEndpointTests.test_httpBody`; `ListEndpointTests.test_removeMovie_HTTPBody`; `ListEndpointTests.test_requestHeaders`; `ListEndpointTests.test_urlConstruction`.

Discrepancies / decisions: No confirmed discrepancy in inspected request/represented response fields; systematic failure/request coverage remains Task 8/9. Repair tasks: none confirmed.

### Lists.clearList

`public func clear(listId: String, completion: @escaping TMDBResult<ListModificationResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Lists.swift:66](../../Sources/TMDBKit/Networking/APIClient/TMDB+Lists.swift#L66). Official operationId(s): `list-clear`.

Actual request: POST no body; application/json;charset=utf-8; missing confirm query. Query: `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `ListModificationResponse`. Models: `ListModificationResponse` ([Sources/TMDBKit/Model/List.swift:46](../../Sources/TMDBKit/Model/List.swift#L46)).

Existing public-call tests: `ListEndpointTests.test_clearList` ([Tests/TMDBKitTests/ListEndpointTests.swift:58](../../Tests/TMDBKitTests/ListEndpointTests.swift#L58)).

Existing endpoint/fixture-associated tests: `ListEndpointTests.test_clearList`; `ListEndpointTests.test_httpMethod`; `ListEndpointTests.test_httpBody`; `ListEndpointTests.test_requestHeaders`; `ListEndpointTests.test_urlConstruction`.

Discrepancies / decisions: Required confirm Boolean query absent; explicit clear API must send confirm=true. Repair tasks: 3.

### Lists.deleteList

`public func delete(listId: String, completion: @escaping TMDBResult<ListModificationResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Lists.swift:74](../../Sources/TMDBKit/Networking/APIClient/TMDB+Lists.swift#L74). Official operationId(s): `list-delete`.

Actual request: DELETE no body; no endpoint headers. Query: `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `ListModificationResponse`. Models: `ListModificationResponse` ([Sources/TMDBKit/Model/List.swift:46](../../Sources/TMDBKit/Model/List.swift#L46)).

Existing public-call tests: `ListEndpointTests.test_deleteList` ([Tests/TMDBKitTests/ListEndpointTests.swift:65](../../Tests/TMDBKitTests/ListEndpointTests.swift#L65)).

Existing endpoint/fixture-associated tests: `ListEndpointTests.test_deleteList`; `ListEndpointTests.test_httpMethod`; `ListEndpointTests.test_httpBody`; `ListEndpointTests.test_requestHeaders`; `ListEndpointTests.test_urlConstruction`.

Discrepancies / decisions: No confirmed discrepancy in inspected request/represented response fields; systematic failure/request coverage remains Task 8/9. Repair tasks: none confirmed.

### Movies.details

`public func details(for movieId: Int, appending details: [DetailsAppendable]?, language: String? = nil, completion: @escaping TMDBResult<Movie>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift:23](../../Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift#L23). Official operationId(s): `movie-details`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `append_to_response`, `append-derived language/include_image_language (may duplicate language)`, `api_key`. Dispatch: application.

Response: `Movie`. Models: `AppendedCredits` ([Sources/TMDBKit/Responses/CreditsResponse.swift:25](../../Sources/TMDBKit/Responses/CreditsResponse.swift#L25)), `AppendedImages` ([Sources/TMDBKit/Responses/ImagesResponse.swift:19](../../Sources/TMDBKit/Responses/ImagesResponse.swift#L19)), `AppendedRecommendations` ([Sources/TMDBKit/Responses/TV/RecommendationsResponse.swift:34](../../Sources/TMDBKit/Responses/TV/RecommendationsResponse.swift#L34)), `AppendedReviews` ([Sources/TMDBKit/Responses/ReviewsResponse.swift:21](../../Sources/TMDBKit/Responses/ReviewsResponse.swift#L21)), `AppendedTranslations` ([Sources/TMDBKit/Responses/TranslationsResponse.swift:21](../../Sources/TMDBKit/Responses/TranslationsResponse.swift#L21)), `AppendedVideos` ([Sources/TMDBKit/Responses/VideosResponse.swift:18](../../Sources/TMDBKit/Responses/VideosResponse.swift#L18)), `Cast` ([Sources/TMDBKit/Model/Cast.swift:10](../../Sources/TMDBKit/Model/Cast.swift#L10)), `Crew` ([Sources/TMDBKit/Model/Crew.swift:10](../../Sources/TMDBKit/Model/Crew.swift#L10)), `Genre` ([Sources/TMDBKit/Model/Genre.swift:10](../../Sources/TMDBKit/Model/Genre.swift#L10)), `Image` ([Sources/TMDBKit/Model/Poster.swift:10](../../Sources/TMDBKit/Model/Poster.swift#L10)), `Language` ([Sources/TMDBKit/Model/Language.swift:10](../../Sources/TMDBKit/Model/Language.swift#L10)), `Movie` ([Sources/TMDBKit/Model/Movie.swift:11](../../Sources/TMDBKit/Model/Movie.swift#L11)), `MovieCollection` ([Sources/TMDBKit/Model/MovieCollection.swift:10](../../Sources/TMDBKit/Model/MovieCollection.swift#L10)), `MovieFragment` ([Sources/TMDBKit/Model/MovieFragment.swift:11](../../Sources/TMDBKit/Model/MovieFragment.swift#L11)), `PopularMoviesResponse` ([Sources/TMDBKit/Responses/PopularMoviesResponse.swift:11](../../Sources/TMDBKit/Responses/PopularMoviesResponse.swift#L11)), `ProductionCompany` ([Sources/TMDBKit/Model/ProductionCompany.swift:10](../../Sources/TMDBKit/Model/ProductionCompany.swift#L10)), `ProductionCountry` ([Sources/TMDBKit/Model/ProductionCountry.swift:10](../../Sources/TMDBKit/Model/ProductionCountry.swift#L10)), `Review` ([Sources/TMDBKit/Model/Review.swift:10](../../Sources/TMDBKit/Model/Review.swift#L10)), `Review.AuthorDetails` ([Sources/TMDBKit/Model/Review.swift:11](../../Sources/TMDBKit/Model/Review.swift#L11)), `Translation` ([Sources/TMDBKit/Model/Translation.swift:10](../../Sources/TMDBKit/Model/Translation.swift#L10)), `Translation.TranslationData` ([Sources/TMDBKit/Model/Translation.swift:11](../../Sources/TMDBKit/Model/Translation.swift#L11)), `Video` ([Sources/TMDBKit/Model/Video.swift:10](../../Sources/TMDBKit/Model/Video.swift#L10)).

Existing public-call tests: `MovieEndpointTests.testReturnsMovieDetails` ([Tests/TMDBKitTests/MovieEndpointTests.swift:16](../../Tests/TMDBKitTests/MovieEndpointTests.swift#L16)); `MovieEndpointTests.testReturnsMovieDetailsWithAllExtraDetails` ([Tests/TMDBKitTests/MovieEndpointTests.swift:24](../../Tests/TMDBKitTests/MovieEndpointTests.swift#L24)).

Existing endpoint/fixture-associated tests: `MovieEndpointTests.testReturnsMovieDetails`; `MovieEndpointTests.testReturnsMovieDetailsWithAllExtraDetails`; `MovieEndpointTests.testDetailsEndpointURLAppendsDetails`; `MovieEndpointTests.test_httpMethod`; `MovieEndpointTests.test_httpBody`; `MovieEndpointTests.test_requestHeaders`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7G, 7J.

Field crosswalk for `movie-details`:

- `origin_country` → `Movie`: not exposed.
- `spoken_languages.[]english_name` → `Language`: not exposed.

### Movies.accountStates

`public func accountStates(for movieId: Int, completion: @escaping TMDBResult<AccountState>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift:35](../../Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift#L35). Official operationId(s): `movie-account-states`.

Actual request: GET; no body; no endpoint headers. Query: `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `AccountState`. Models: `AccountState` ([Sources/TMDBKit/Model/AccountState.swift:11](../../Sources/TMDBKit/Model/AccountState.swift#L11)), `AccountState.Rating` ([Sources/TMDBKit/Model/AccountState.swift:12](../../Sources/TMDBKit/Model/AccountState.swift#L12)).

Existing public-call tests: `MovieEndpointTests.testReturnsAccountsStatesForMovie` ([Tests/TMDBKitTests/MovieEndpointTests.swift:37](../../Tests/TMDBKitTests/MovieEndpointTests.swift#L37)); `MovieEndpointTests.testReturnsAccountsStatesForMovieWithRating` ([Tests/TMDBKitTests/MovieEndpointTests.swift:47](../../Tests/TMDBKitTests/MovieEndpointTests.swift#L47)).

Existing endpoint/fixture-associated tests: `MovieEndpointTests.testReturnsAccountsStatesForMovie`; `MovieEndpointTests.testReturnsAccountsStatesForMovieWithRating`; `MovieEndpointTests.test_httpMethod`; `MovieEndpointTests.test_httpBody`; `MovieEndpointTests.test_requestHeaders`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7H.

AccountState.rated currently uses try? and silently converts malformed payloads to nil, not just false. Task 7H requires strict false/object discrimination.

### Movies.alternativeTitles

`public func alternativeTitles(for movieId: Int, country: String? = nil, completion: @escaping TMDBResult<AlternativeTitlesResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift:45](../../Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift#L45). Official operationId(s): `movie-alternative-titles`.

Actual request: GET; no body; no endpoint headers. Query: `country`, `api_key`. Dispatch: application.

Response: `AlternativeTitlesResponse`. Models: `AlternativeTitle` ([Sources/TMDBKit/Model/AlternativeTitle.swift:10](../../Sources/TMDBKit/Model/AlternativeTitle.swift#L10)), `AlternativeTitlesResponse` ([Sources/TMDBKit/Responses/AlternativeTitlesResponse.swift:13](../../Sources/TMDBKit/Responses/AlternativeTitlesResponse.swift#L13)).

Existing public-call tests: `MovieEndpointTests.testReturnsAlternativeTitlesForMovie` ([Tests/TMDBKitTests/MovieEndpointTests.swift:56](../../Tests/TMDBKitTests/MovieEndpointTests.swift#L56)).

Existing endpoint/fixture-associated tests: `MovieEndpointTests.testReturnsAlternativeTitlesForMovie`; `MovieEndpointTests.test_httpMethod`; `MovieEndpointTests.test_httpBody`; `MovieEndpointTests.test_requestHeaders`.

Discrepancies / decisions: No confirmed discrepancy in inspected request/represented response fields; systematic failure/request coverage remains Task 8/9. Repair tasks: none confirmed.

### Movies.changes

`public func changes(for movieId: Int, completion: @escaping TMDBResult<ChangesResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift:55](../../Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift#L55). Official operationId(s): `movie-changes`.

Actual request: GET; no body; no endpoint headers. Query: `api_key`. Dispatch: application.

Response: `ChangesResponse`. Models: `Change` ([Sources/TMDBKit/Model/Change.swift:10](../../Sources/TMDBKit/Model/Change.swift#L10)), `Change.Item` ([Sources/TMDBKit/Model/Change.swift:11](../../Sources/TMDBKit/Model/Change.swift#L11)), `ChangesResponse` ([Sources/TMDBKit/Responses/ChangesResponse.swift:13](../../Sources/TMDBKit/Responses/ChangesResponse.swift#L13)).

Existing public-call tests: `MovieEndpointTests.testReturnsChanges` ([Tests/TMDBKitTests/MovieEndpointTests.swift:64](../../Tests/TMDBKitTests/MovieEndpointTests.swift#L64)).

Existing endpoint/fixture-associated tests: `MovieEndpointTests.testReturnsChanges`; `MovieEndpointTests.test_httpMethod`; `MovieEndpointTests.test_httpBody`; `MovieEndpointTests.test_requestHeaders`.

Discrepancies / decisions: Missing page/start_date/end_date and change object union support. Repair tasks: 5, 7B.

Field crosswalk for `movie-changes`:

- `changes.[]items.[]iso_3166_1` → `Change.Item`: not exposed.
- `changes.[]items.[]value` → `Change.Item`: type object vs String.
- `changes.[]items.[]originalValue` → `Change.Item`: local required field absent from schema.

### Movies.credits

`public func credits(for movieId: Int, language: String? = nil, completion: @escaping TMDBResult<CreditsResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift:66](../../Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift#L66). Official operationId(s): `movie-credits`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `api_key`. Dispatch: application.

Response: `CreditsResponse`. Models: `Cast` ([Sources/TMDBKit/Model/Cast.swift:10](../../Sources/TMDBKit/Model/Cast.swift#L10)), `CreditsResponse` ([Sources/TMDBKit/Responses/CreditsResponse.swift:13](../../Sources/TMDBKit/Responses/CreditsResponse.swift#L13)), `Crew` ([Sources/TMDBKit/Model/Crew.swift:10](../../Sources/TMDBKit/Model/Crew.swift#L10)).

Existing public-call tests: `MovieEndpointTests.testReturnsCredits` ([Tests/TMDBKitTests/MovieEndpointTests.swift:72](../../Tests/TMDBKitTests/MovieEndpointTests.swift#L72)).

Existing endpoint/fixture-associated tests: `MovieEndpointTests.testReturnsCredits`; `MovieEndpointTests.test_httpMethod`; `MovieEndpointTests.test_httpBody`; `MovieEndpointTests.test_requestHeaders`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7G.

Field crosswalk for `movie-credits`:

- `cast.[]cast_id` → `Cast`: not exposed.
- `crew.[]adult` → `Crew`: not exposed.
- `crew.[]known_for_department` → `Crew`: not exposed.
- `crew.[]original_name` → `Crew`: not exposed.
- `crew.[]popularity` → `Crew`: not exposed.

### Movies.externalIds

`public func externalIds(for movieId: Int, completion: @escaping TMDBResult<ExternalIds>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift:78](../../Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift#L78). Official operationId(s): `movie-external-ids`.

Actual request: GET; no body; no endpoint headers. Query: `api_key`. Dispatch: application.

Response: `ExternalIds`. Models: `ExternalIds` ([Sources/TMDBKit/Model/ExternalIds.swift:11](../../Sources/TMDBKit/Model/ExternalIds.swift#L11)).

Existing public-call tests: `MovieEndpointTests.testReturnsExternalIds` ([Tests/TMDBKitTests/MovieEndpointTests.swift:80](../../Tests/TMDBKitTests/MovieEndpointTests.swift#L80)).

Existing endpoint/fixture-associated tests: `MovieEndpointTests.testReturnsExternalIds`; `MovieEndpointTests.test_httpMethod`; `MovieEndpointTests.test_httpBody`; `MovieEndpointTests.test_requestHeaders`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7G.

Field crosswalk for `movie-external-ids`:

- `wikidata_id` → `ExternalIds`: not exposed.

### Movies.images

`public func images(for movieId: Int, language: String? = nil, completion: @escaping TMDBResult<ImagesResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift:93](../../Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift#L93). Official operationId(s): `movie-images`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `api_key`. Dispatch: application.

Response: `ImagesResponse`. Models: `Image` ([Sources/TMDBKit/Model/Poster.swift:10](../../Sources/TMDBKit/Model/Poster.swift#L10)), `ImagesResponse` ([Sources/TMDBKit/Responses/ImagesResponse.swift:13](../../Sources/TMDBKit/Responses/ImagesResponse.swift#L13)).

Existing public-call tests: `MovieEndpointTests.testReturnsMovieImages` ([Tests/TMDBKitTests/MovieEndpointTests.swift:88](../../Tests/TMDBKitTests/MovieEndpointTests.swift#L88)).

Existing endpoint/fixture-associated tests: `MovieEndpointTests.testReturnsMovieImages`; `MovieEndpointTests.test_httpMethod`; `MovieEndpointTests.test_httpBody`; `MovieEndpointTests.test_requestHeaders`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7A, 7G.

Field crosswalk for `movie-images`:

- `logos` → `ImagesResponse`: not exposed.

### Movies.keywords

`public func keywords(for movieId: Int, completion: @escaping TMDBResult<KeywordsResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift:101](../../Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift#L101). Official operationId(s): `movie-keywords`.

Actual request: GET; no body; no endpoint headers. Query: `api_key`. Dispatch: application.

Response: `KeywordsResponse`. Models: `Keyword` ([Sources/TMDBKit/Model/Keyword.swift:10](../../Sources/TMDBKit/Model/Keyword.swift#L10)), `KeywordsResponse` ([Sources/TMDBKit/Responses/KeywordsResponse.swift:13](../../Sources/TMDBKit/Responses/KeywordsResponse.swift#L13)).

Existing public-call tests: `MovieEndpointTests.testReturnsKeywords` ([Tests/TMDBKitTests/MovieEndpointTests.swift:96](../../Tests/TMDBKitTests/MovieEndpointTests.swift#L96)).

Existing endpoint/fixture-associated tests: `MovieEndpointTests.testReturnsKeywords`; `MovieEndpointTests.test_httpMethod`; `MovieEndpointTests.test_httpBody`; `MovieEndpointTests.test_requestHeaders`.

Discrepancies / decisions: No confirmed discrepancy in inspected request/represented response fields; systematic failure/request coverage remains Task 8/9. Repair tasks: none confirmed.

### Movies.lists

`public func lists(for movieId: Int, pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<ListsResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift:112](../../Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift#L112). Official operationId(s): `movie-lists`.

Actual request: GET; no body; no endpoint headers. Query: `page`, `language`, `api_key`. Dispatch: application.

Response: `ListsResponse`. Models: `List` ([Sources/TMDBKit/Model/List.swift:10](../../Sources/TMDBKit/Model/List.swift#L10)), `ListsResponse` ([Sources/TMDBKit/Responses/ListsResponse.swift:11](../../Sources/TMDBKit/Responses/ListsResponse.swift#L11)).

Existing public-call tests: `MovieEndpointTests.testReturnsLists` ([Tests/TMDBKitTests/MovieEndpointTests.swift:165](../../Tests/TMDBKitTests/MovieEndpointTests.swift#L165)).

Existing endpoint/fixture-associated tests: `MovieEndpointTests.testReturnsLists`; `MovieEndpointTests.test_httpMethod`; `MovieEndpointTests.test_httpBody`; `MovieEndpointTests.test_requestHeaders`.

Discrepancies / decisions: No confirmed discrepancy in inspected request/represented response fields; systematic failure/request coverage remains Task 8/9. Repair tasks: none confirmed.

### Movies.recommendations

`public func recommendations(for movieId: Int, pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<PopularMoviesResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift:125](../../Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift#L125). Official operationId(s): `movie-recommendations`.

Actual request: GET; no body; no endpoint headers. Query: `page`, `language`, `api_key`. Dispatch: application.

Response: `PopularMoviesResponse`. Models: `MovieFragment` ([Sources/TMDBKit/Model/MovieFragment.swift:11](../../Sources/TMDBKit/Model/MovieFragment.swift#L11)), `PopularMoviesResponse` ([Sources/TMDBKit/Responses/PopularMoviesResponse.swift:11](../../Sources/TMDBKit/Responses/PopularMoviesResponse.swift#L11)).

Existing public-call tests: `MovieEndpointTests.testReturnsRecommendations` ([Tests/TMDBKitTests/MovieEndpointTests.swift:141](../../Tests/TMDBKitTests/MovieEndpointTests.swift#L141)).

Existing endpoint/fixture-associated tests: `MovieEndpointTests.testReturnsRecommendations`; `MovieEndpointTests.test_httpMethod`; `MovieEndpointTests.test_httpBody`; `MovieEndpointTests.test_requestHeaders`.

Discrepancies / decisions: Pinned response schema properties and example are empty {}. This is an upstream evidence gap, not proof to make pagination optional. Repair tasks: 7K.

### Movies.releaseDates

`public func releaseDates(for movieId: Int, completion: @escaping TMDBResult<ReleaseDatesResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift:143](../../Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift#L143). Official operationId(s): `movie-release-dates`.

Actual request: GET; no body; no endpoint headers. Query: `api_key`. Dispatch: application.

Response: `ReleaseDatesResponse`. Models: `ReleaseDate` ([Sources/TMDBKit/Model/ReleaseDate.swift:10](../../Sources/TMDBKit/Model/ReleaseDate.swift#L10)), `ReleaseDateResult` ([Sources/TMDBKit/Model/ReleaseDateResult.swift:10](../../Sources/TMDBKit/Model/ReleaseDateResult.swift#L10)), `ReleaseDatesResponse` ([Sources/TMDBKit/Responses/ReleaseDatesResponse.swift:11](../../Sources/TMDBKit/Responses/ReleaseDatesResponse.swift#L11)).

Existing public-call tests: `MovieEndpointTests.testReturnsReleaseDates` ([Tests/TMDBKitTests/MovieEndpointTests.swift:104](../../Tests/TMDBKitTests/MovieEndpointTests.swift#L104)).

Existing endpoint/fixture-associated tests: `MovieEndpointTests.testReturnsReleaseDates`; `MovieEndpointTests.test_httpMethod`; `MovieEndpointTests.test_httpBody`; `MovieEndpointTests.test_requestHeaders`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7G.

Field crosswalk for `movie-release-dates`:

- `results.[]release_dates.[]descriptors` → `ReleaseDate`: not exposed.

### Movies.reviews

`public func reviews(for movieId: Int, pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<ReviewsResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift:154](../../Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift#L154). Official operationId(s): `movie-reviews`.

Actual request: GET; no body; no endpoint headers. Query: `page`, `language`, `api_key`. Dispatch: application.

Response: `ReviewsResponse`. Models: `Review` ([Sources/TMDBKit/Model/Review.swift:10](../../Sources/TMDBKit/Model/Review.swift#L10)), `Review.AuthorDetails` ([Sources/TMDBKit/Model/Review.swift:11](../../Sources/TMDBKit/Model/Review.swift#L11)), `ReviewsResponse` ([Sources/TMDBKit/Responses/ReviewsResponse.swift:13](../../Sources/TMDBKit/Responses/ReviewsResponse.swift#L13)).

Existing public-call tests: `MovieEndpointTests.testReturnsReviews` ([Tests/TMDBKitTests/MovieEndpointTests.swift:157](../../Tests/TMDBKitTests/MovieEndpointTests.swift#L157)).

Existing endpoint/fixture-associated tests: `MovieEndpointTests.testReturnsReviews`; `MovieEndpointTests.test_httpMethod`; `MovieEndpointTests.test_httpBody`; `MovieEndpointTests.test_requestHeaders`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7G.

Field crosswalk for `movie-reviews`:

- `results.[]author_details.username` → `Review.AuthorDetails`: not exposed.

### Movies.similarMovies

`public func similarMovies(for movieId: Int, pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<PopularMoviesResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift:168](../../Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift#L168). Official operationId(s): `movie-similar`.

Actual request: GET; no body; no endpoint headers. Query: `page`, `language`, `api_key`. Dispatch: application.

Response: `PopularMoviesResponse`. Models: `MovieFragment` ([Sources/TMDBKit/Model/MovieFragment.swift:11](../../Sources/TMDBKit/Model/MovieFragment.swift#L11)), `PopularMoviesResponse` ([Sources/TMDBKit/Responses/PopularMoviesResponse.swift:11](../../Sources/TMDBKit/Responses/PopularMoviesResponse.swift#L11)).

Existing public-call tests: `MovieEndpointTests.testReturnsSimilarMovies` ([Tests/TMDBKitTests/MovieEndpointTests.swift:149](../../Tests/TMDBKitTests/MovieEndpointTests.swift#L149)).

Existing endpoint/fixture-associated tests: `MovieEndpointTests.testReturnsSimilarMovies`; `MovieEndpointTests.test_httpMethod`; `MovieEndpointTests.test_httpBody`; `MovieEndpointTests.test_requestHeaders`.

Discrepancies / decisions: Actual route /3/movie/{movie_id}/similar_movies is obsolete/local-only; pinned route ends /similar. Repair tasks: 2.

### Movies.translations

`public func translations(for movieId: Int, completion: @escaping TMDBResult<TranslationsResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift:178](../../Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift#L178). Official operationId(s): `movie-translations`.

Actual request: GET; no body; no endpoint headers. Query: `api_key`. Dispatch: application.

Response: `TranslationsResponse`. Models: `Translation` ([Sources/TMDBKit/Model/Translation.swift:10](../../Sources/TMDBKit/Model/Translation.swift#L10)), `Translation.TranslationData` ([Sources/TMDBKit/Model/Translation.swift:11](../../Sources/TMDBKit/Model/Translation.swift#L11)), `TranslationsResponse` ([Sources/TMDBKit/Responses/TranslationsResponse.swift:11](../../Sources/TMDBKit/Responses/TranslationsResponse.swift#L11)).

Existing public-call tests: `MovieEndpointTests.testReturnsTranslations` ([Tests/TMDBKitTests/MovieEndpointTests.swift:133](../../Tests/TMDBKitTests/MovieEndpointTests.swift#L133)).

Existing endpoint/fixture-associated tests: `MovieEndpointTests.testReturnsTranslations`; `MovieEndpointTests.test_httpMethod`; `MovieEndpointTests.test_httpBody`; `MovieEndpointTests.test_requestHeaders`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7G.

Field crosswalk for `movie-translations`:

- `translations.[]data.runtime` → `Translation.TranslationData`: not exposed.
- `translations.[]data.tagline` → `Translation.TranslationData`: not exposed.

### Movies.videos

`public func videos(for movieId: Int, language: String? = nil, completion: @escaping TMDBResult<VideosResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift:190](../../Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift#L190). Official operationId(s): `movie-videos`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `api_key`. Dispatch: application.

Response: `VideosResponse`. Models: `Video` ([Sources/TMDBKit/Model/Video.swift:10](../../Sources/TMDBKit/Model/Video.swift#L10)), `VideosResponse` ([Sources/TMDBKit/Responses/VideosResponse.swift:13](../../Sources/TMDBKit/Responses/VideosResponse.swift#L13)).

Existing public-call tests: `MovieEndpointTests.testReturnsVideos` ([Tests/TMDBKitTests/MovieEndpointTests.swift:112](../../Tests/TMDBKitTests/MovieEndpointTests.swift#L112)).

Existing endpoint/fixture-associated tests: `MovieEndpointTests.testReturnsVideos`; `MovieEndpointTests.test_httpMethod`; `MovieEndpointTests.test_httpBody`; `MovieEndpointTests.test_requestHeaders`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7G.

Field crosswalk for `movie-videos`:

- `results.[]official` → `Video`: not exposed.
- `results.[]published_at` → `Video`: not exposed.

### Movies.watchProviders

`public func watchProviders(for movieId: Int, completion: @escaping TMDBResult<WatchProviderResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift:206](../../Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift#L206). Official operationId(s): `movie-watch-providers`.

Actual request: GET; no body; no endpoint headers. Query: `api_key`. Dispatch: application.

Response: `WatchProviderResponse`. Models: `ProviderResult` ([Sources/TMDBKit/Model/WatchProvider.swift:22](../../Sources/TMDBKit/Model/WatchProvider.swift#L22)), `Results` ([Sources/TMDBKit/Model/WatchProvider.swift:29](../../Sources/TMDBKit/Model/WatchProvider.swift#L29)), `WatchProvider` ([Sources/TMDBKit/Model/WatchProvider.swift:15](../../Sources/TMDBKit/Model/WatchProvider.swift#L15)), `WatchProviderResponse` ([Sources/TMDBKit/Model/WatchProvider.swift:10](../../Sources/TMDBKit/Model/WatchProvider.swift#L10)).

Existing public-call tests: `MovieEndpointTests.testReturnsWatchProviders` ([Tests/TMDBKitTests/MovieEndpointTests.swift:120](../../Tests/TMDBKitTests/MovieEndpointTests.swift#L120)).

Existing endpoint/fixture-associated tests: `MovieEndpointTests.testReturnsWatchProviders`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7C.

Field crosswalk for `movie-watch-providers`:

- `results.{region}` → `Results`: dynamic region map required; legacy fixed accessors omit documented regions.

### Movies.latest

`public func latest(language: String? = nil, completion: @escaping TMDBResult<Movie>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift:214](../../Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift#L214). Official operationId(s): `movie-latest-id`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `api_key`. Dispatch: application.

Response: `Movie`. Models: `AppendedCredits` ([Sources/TMDBKit/Responses/CreditsResponse.swift:25](../../Sources/TMDBKit/Responses/CreditsResponse.swift#L25)), `AppendedImages` ([Sources/TMDBKit/Responses/ImagesResponse.swift:19](../../Sources/TMDBKit/Responses/ImagesResponse.swift#L19)), `AppendedRecommendations` ([Sources/TMDBKit/Responses/TV/RecommendationsResponse.swift:34](../../Sources/TMDBKit/Responses/TV/RecommendationsResponse.swift#L34)), `AppendedReviews` ([Sources/TMDBKit/Responses/ReviewsResponse.swift:21](../../Sources/TMDBKit/Responses/ReviewsResponse.swift#L21)), `AppendedTranslations` ([Sources/TMDBKit/Responses/TranslationsResponse.swift:21](../../Sources/TMDBKit/Responses/TranslationsResponse.swift#L21)), `AppendedVideos` ([Sources/TMDBKit/Responses/VideosResponse.swift:18](../../Sources/TMDBKit/Responses/VideosResponse.swift#L18)), `Cast` ([Sources/TMDBKit/Model/Cast.swift:10](../../Sources/TMDBKit/Model/Cast.swift#L10)), `Crew` ([Sources/TMDBKit/Model/Crew.swift:10](../../Sources/TMDBKit/Model/Crew.swift#L10)), `Genre` ([Sources/TMDBKit/Model/Genre.swift:10](../../Sources/TMDBKit/Model/Genre.swift#L10)), `Image` ([Sources/TMDBKit/Model/Poster.swift:10](../../Sources/TMDBKit/Model/Poster.swift#L10)), `Language` ([Sources/TMDBKit/Model/Language.swift:10](../../Sources/TMDBKit/Model/Language.swift#L10)), `Movie` ([Sources/TMDBKit/Model/Movie.swift:11](../../Sources/TMDBKit/Model/Movie.swift#L11)), `MovieCollection` ([Sources/TMDBKit/Model/MovieCollection.swift:10](../../Sources/TMDBKit/Model/MovieCollection.swift#L10)), `MovieFragment` ([Sources/TMDBKit/Model/MovieFragment.swift:11](../../Sources/TMDBKit/Model/MovieFragment.swift#L11)), `PopularMoviesResponse` ([Sources/TMDBKit/Responses/PopularMoviesResponse.swift:11](../../Sources/TMDBKit/Responses/PopularMoviesResponse.swift#L11)), `ProductionCompany` ([Sources/TMDBKit/Model/ProductionCompany.swift:10](../../Sources/TMDBKit/Model/ProductionCompany.swift#L10)), `ProductionCountry` ([Sources/TMDBKit/Model/ProductionCountry.swift:10](../../Sources/TMDBKit/Model/ProductionCountry.swift#L10)), `Review` ([Sources/TMDBKit/Model/Review.swift:10](../../Sources/TMDBKit/Model/Review.swift#L10)), `Review.AuthorDetails` ([Sources/TMDBKit/Model/Review.swift:11](../../Sources/TMDBKit/Model/Review.swift#L11)), `Translation` ([Sources/TMDBKit/Model/Translation.swift:10](../../Sources/TMDBKit/Model/Translation.swift#L10)), `Translation.TranslationData` ([Sources/TMDBKit/Model/Translation.swift:11](../../Sources/TMDBKit/Model/Translation.swift#L11)), `Video` ([Sources/TMDBKit/Model/Video.swift:10](../../Sources/TMDBKit/Model/Video.swift#L10)).

Existing public-call tests: `MovieEndpointTests.testReturnsLatestMovie` ([Tests/TMDBKitTests/MovieEndpointTests.swift:181](../../Tests/TMDBKitTests/MovieEndpointTests.swift#L181)).

Existing endpoint/fixture-associated tests: `MovieEndpointTests.testReturnsLatestMovie`; `MovieEndpointTests.test_httpMethod`; `MovieEndpointTests.test_httpBody`; `MovieEndpointTests.test_requestHeaders`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7A.

### Movies.nowPlaying

`public func nowPlaying(pageNumber: PageNumber, language: String? = nil, region: String? = nil, completion: @escaping TMDBResult<NowPlayingMoviesResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift:226](../../Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift#L226). Official operationId(s): `movie-now-playing-list`.

Actual request: GET; no body; no endpoint headers. Query: `page`, `language`, `region`, `api_key`. Dispatch: application.

Response: `NowPlayingMoviesResponse`. Models: `MovieFragment` ([Sources/TMDBKit/Model/MovieFragment.swift:11](../../Sources/TMDBKit/Model/MovieFragment.swift#L11)), `NowPlayingMoviesResponse` ([Sources/TMDBKit/Responses/NowPlayingMoviesResponse.swift:11](../../Sources/TMDBKit/Responses/NowPlayingMoviesResponse.swift#L11)), `TMDBDate` ([Sources/TMDBKit/Model/TMDBDate.swift:10](../../Sources/TMDBKit/Model/TMDBDate.swift#L10)).

Existing public-call tests: `MovieEndpointTests.testReturnsNowPlayingMovies` ([Tests/TMDBKitTests/MovieEndpointTests.swift:173](../../Tests/TMDBKitTests/MovieEndpointTests.swift#L173)).

Existing endpoint/fixture-associated tests: `MovieEndpointTests.testReturnsNowPlayingMovies`; `MovieEndpointTests.test_httpMethod`; `MovieEndpointTests.test_httpBody`; `MovieEndpointTests.test_requestHeaders`.

Discrepancies / decisions: No confirmed discrepancy in inspected request/represented response fields; systematic failure/request coverage remains Task 8/9. Repair tasks: none confirmed.

### Movies.popular

`public func popular(pageNumber: PageNumber, language: String? = nil, region: String? = nil, completion: @escaping TMDBResult<PopularMoviesResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift:237](../../Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift#L237). Official operationId(s): `movie-popular-list`.

Actual request: GET; no body; no endpoint headers. Query: `page`, `language`, `region`, `api_key`. Dispatch: application.

Response: `PopularMoviesResponse`. Models: `MovieFragment` ([Sources/TMDBKit/Model/MovieFragment.swift:11](../../Sources/TMDBKit/Model/MovieFragment.swift#L11)), `PopularMoviesResponse` ([Sources/TMDBKit/Responses/PopularMoviesResponse.swift:11](../../Sources/TMDBKit/Responses/PopularMoviesResponse.swift#L11)).

Existing public-call tests: `MovieEndpointTests.testReturnsPopularMovies` ([Tests/TMDBKitTests/MovieEndpointTests.swift:189](../../Tests/TMDBKitTests/MovieEndpointTests.swift#L189)).

Existing endpoint/fixture-associated tests: `MovieEndpointTests.testReturnsPopularMovies`; `MovieEndpointTests.test_httpMethod`; `MovieEndpointTests.test_httpBody`; `MovieEndpointTests.test_requestHeaders`.

Discrepancies / decisions: No confirmed discrepancy in inspected request/represented response fields; systematic failure/request coverage remains Task 8/9. Repair tasks: none confirmed.

### Movies.topRated

`public func topRated(pageNumber: PageNumber, language: String? = nil, region: String? = nil, completion: @escaping TMDBResult<PopularMoviesResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift:248](../../Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift#L248). Official operationId(s): `movie-top-rated-list`.

Actual request: GET; no body; no endpoint headers. Query: `page`, `language`, `region`, `api_key`. Dispatch: application.

Response: `PopularMoviesResponse`. Models: `MovieFragment` ([Sources/TMDBKit/Model/MovieFragment.swift:11](../../Sources/TMDBKit/Model/MovieFragment.swift#L11)), `PopularMoviesResponse` ([Sources/TMDBKit/Responses/PopularMoviesResponse.swift:11](../../Sources/TMDBKit/Responses/PopularMoviesResponse.swift#L11)).

Existing public-call tests: `MovieEndpointTests.testReturnsTopRatedMovies` ([Tests/TMDBKitTests/MovieEndpointTests.swift:197](../../Tests/TMDBKitTests/MovieEndpointTests.swift#L197)).

Existing endpoint/fixture-associated tests: `MovieEndpointTests.testReturnsTopRatedMovies`; `MovieEndpointTests.test_httpMethod`; `MovieEndpointTests.test_httpBody`; `MovieEndpointTests.test_requestHeaders`.

Discrepancies / decisions: No confirmed discrepancy in inspected request/represented response fields; systematic failure/request coverage remains Task 8/9. Repair tasks: none confirmed.

### Movies.upcoming

`public func upcoming(pageNumber: PageNumber, language: String? = nil, region: String? = nil, completion: @escaping TMDBResult<NowPlayingMoviesResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift:260](../../Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift#L260). Official operationId(s): `movie-upcoming-list`.

Actual request: GET; no body; no endpoint headers. Query: `page`, `language`, `region`, `api_key`. Dispatch: application.

Response: `NowPlayingMoviesResponse`. Models: `MovieFragment` ([Sources/TMDBKit/Model/MovieFragment.swift:11](../../Sources/TMDBKit/Model/MovieFragment.swift#L11)), `NowPlayingMoviesResponse` ([Sources/TMDBKit/Responses/NowPlayingMoviesResponse.swift:11](../../Sources/TMDBKit/Responses/NowPlayingMoviesResponse.swift#L11)), `TMDBDate` ([Sources/TMDBKit/Model/TMDBDate.swift:10](../../Sources/TMDBKit/Model/TMDBDate.swift#L10)).

Existing public-call tests: `MovieEndpointTests.testReturnsUpcomingMovies` ([Tests/TMDBKitTests/MovieEndpointTests.swift:205](../../Tests/TMDBKitTests/MovieEndpointTests.swift#L205)).

Existing endpoint/fixture-associated tests: `MovieEndpointTests.testReturnsUpcomingMovies`; `MovieEndpointTests.test_httpMethod`; `MovieEndpointTests.test_httpBody`; `MovieEndpointTests.test_requestHeaders`.

Discrepancies / decisions: No confirmed discrepancy in inspected request/represented response fields; systematic failure/request coverage remains Task 8/9. Repair tasks: none confirmed.

### Movies.rateMovie

`public func rateMovie(_ movieId: Int, rating: Double, completion: @escaping TMDBResult<StatusResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift:273](../../Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift#L273). Official operationId(s): `movie-add-rating`.

Actual request: POST JSON {value: rating}; application/json;charset=utf-8. Query: `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `StatusResponse`. Models: `StatusResponse` ([Sources/TMDBKit/Networking/APIClient/TMDB.swift:36](../../Sources/TMDBKit/Networking/APIClient/TMDB.swift#L36)).

Existing public-call tests: **none**.

Existing endpoint/fixture-associated tests: `MovieEndpointTests.test_httpMethod`; `MovieEndpointTests.test_rateMovie_httpBody`; `MovieEndpointTests.test_requestHeaders`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7H.

### Movies.deleteRating

`public func deleteRating(of movieId: Int, completion: @escaping TMDBResult<StatusResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift:285](../../Sources/TMDBKit/Networking/APIClient/TMDB+Movies.swift#L285). Official operationId(s): `movie-delete-rating`.

Actual request: DELETE no body; application/json;charset=utf-8. Query: `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `StatusResponse`. Models: `StatusResponse` ([Sources/TMDBKit/Networking/APIClient/TMDB.swift:36](../../Sources/TMDBKit/Networking/APIClient/TMDB.swift#L36)).

Existing public-call tests: **none**.

Existing endpoint/fixture-associated tests: `MovieEndpointTests.test_httpMethod`; `MovieEndpointTests.test_httpBody`; `MovieEndpointTests.test_requestHeaders`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7H.

### People.details

`public func details(for personId: Int, language: String? = nil, appending details: [DetailsAppendable]?, completion: @escaping TMDBResult<PersonDetailsResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+People.swift:21](../../Sources/TMDBKit/Networking/APIClient/TMDB+People.swift#L21). Official operationId(s): `person-details`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `append_to_response`, `append-derived language/include_image_language (may duplicate language)`, `api_key`. Dispatch: application.

Response: `PersonDetailsResponse`. Models: `AppendedImages` ([Sources/TMDBKit/Responses/ImagesResponse.swift:19](../../Sources/TMDBKit/Responses/ImagesResponse.swift#L19)), `AppendedPersonCredits` ([Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift:48](../../Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift#L48)), `AppendedRecommendations` ([Sources/TMDBKit/Responses/TV/RecommendationsResponse.swift:34](../../Sources/TMDBKit/Responses/TV/RecommendationsResponse.swift#L34)), `AppendedReviews` ([Sources/TMDBKit/Responses/ReviewsResponse.swift:21](../../Sources/TMDBKit/Responses/ReviewsResponse.swift#L21)), `AppendedTranslations` ([Sources/TMDBKit/Responses/TranslationsResponse.swift:21](../../Sources/TMDBKit/Responses/TranslationsResponse.swift#L21)), `AppendedVideos` ([Sources/TMDBKit/Responses/VideosResponse.swift:18](../../Sources/TMDBKit/Responses/VideosResponse.swift#L18)), `CreditsCast` ([Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift:18](../../Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift#L18)), `Image` ([Sources/TMDBKit/Model/Poster.swift:10](../../Sources/TMDBKit/Model/Poster.swift#L10)), `MovieFragment` ([Sources/TMDBKit/Model/MovieFragment.swift:11](../../Sources/TMDBKit/Model/MovieFragment.swift#L11)), `PersonDetailsResponse` ([Sources/TMDBKit/Responses/People/PersonDetailsResponse.swift:10](../../Sources/TMDBKit/Responses/People/PersonDetailsResponse.swift#L10)), `PopularMoviesResponse` ([Sources/TMDBKit/Responses/PopularMoviesResponse.swift:11](../../Sources/TMDBKit/Responses/PopularMoviesResponse.swift#L11)), `Review` ([Sources/TMDBKit/Model/Review.swift:10](../../Sources/TMDBKit/Model/Review.swift#L10)), `Review.AuthorDetails` ([Sources/TMDBKit/Model/Review.swift:11](../../Sources/TMDBKit/Model/Review.swift#L11)), `Translation` ([Sources/TMDBKit/Model/Translation.swift:10](../../Sources/TMDBKit/Model/Translation.swift#L10)), `Translation.TranslationData` ([Sources/TMDBKit/Model/Translation.swift:11](../../Sources/TMDBKit/Model/Translation.swift#L11)), `Video` ([Sources/TMDBKit/Model/Video.swift:10](../../Sources/TMDBKit/Model/Video.swift#L10)).

Existing public-call tests: `PeopleEndpointTests.testReturnsPersonDetails` ([Tests/TMDBKitTests/PeopleEnpointTests.swift:14](../../Tests/TMDBKitTests/PeopleEnpointTests.swift#L14)).

Existing endpoint/fixture-associated tests: `PeopleEndpointTests.testReturnsPersonDetails`; `PeopleEndpointTests.test_httpMethod`; `PeopleEndpointTests.test_httpBody`; `PeopleEndpointTests.test_endpointHeaders`; `PeopleEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7E, 7J.

Field crosswalk for `person-details`:

- `deathday` → `PersonDetailsResponse`: not exposed.

### People.changes

`public func changes(for personId: Int, pageNumber: PageNumber = 1, completion: @escaping TMDBResult<ChangesResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+People.swift:36](../../Sources/TMDBKit/Networking/APIClient/TMDB+People.swift#L36). Official operationId(s): `person-changes`.

Actual request: GET; no body; no endpoint headers. Query: `page`, `api_key`. Dispatch: application.

Response: `ChangesResponse`. Models: `Change` ([Sources/TMDBKit/Model/Change.swift:10](../../Sources/TMDBKit/Model/Change.swift#L10)), `Change.Item` ([Sources/TMDBKit/Model/Change.swift:11](../../Sources/TMDBKit/Model/Change.swift#L11)), `ChangesResponse` ([Sources/TMDBKit/Responses/ChangesResponse.swift:13](../../Sources/TMDBKit/Responses/ChangesResponse.swift#L13)).

Existing public-call tests: `PeopleEndpointTests.testReturnsPersonChanges` ([Tests/TMDBKitTests/PeopleEnpointTests.swift:23](../../Tests/TMDBKitTests/PeopleEnpointTests.swift#L23)).

Existing endpoint/fixture-associated tests: `PeopleEndpointTests.testReturnsPersonChanges`; `PeopleEndpointTests.test_httpMethod`; `PeopleEndpointTests.test_httpBody`; `PeopleEndpointTests.test_endpointHeaders`; `PeopleEndpointTests.test_urlConstruction`.

Discrepancies / decisions: Missing start_date/end_date; original_value incorrectly required. Repair tasks: 5, 7B.

Field crosswalk for `person-changes`:

- `changes.[]items.[]iso_3166_1` → `Change.Item`: not exposed.
- `changes.[]items.[]originalValue` → `Change.Item`: local required field absent from schema.

### People.movieCredits

`public func movieCredits(for personId: Int, language: String? = nil, completion: @escaping TMDBResult<PersonCreditsResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+People.swift:48](../../Sources/TMDBKit/Networking/APIClient/TMDB+People.swift#L48). Official operationId(s): `person-movie-credits`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `api_key`. Dispatch: application.

Response: `PersonCreditsResponse`. Models: `CreditsCast` ([Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift:18](../../Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift#L18)), `PersonCreditsResponse` ([Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift:10](../../Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift#L10)).

Existing public-call tests: `PeopleEndpointTests.testReturnsMovieCredits` ([Tests/TMDBKitTests/PeopleEnpointTests.swift:31](../../Tests/TMDBKitTests/PeopleEnpointTests.swift#L31)).

Existing endpoint/fixture-associated tests: `PeopleEndpointTests.testReturnsMovieCredits`; `PeopleEndpointTests.test_httpMethod`; `PeopleEndpointTests.test_httpBody`; `PeopleEndpointTests.test_endpointHeaders`; `PeopleEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7E.

Field crosswalk for `person-movie-credits`:

- `cast.[]genre_ids` → `CreditsCast`: not exposed.
- `cast.[]credit_id` → `CreditsCast`: not exposed.
- `cast.[]order` → `CreditsCast`: not exposed.
- `crew.[]genre_ids` → `CreditsCast`: not exposed.
- `crew.[]credit_id` → `CreditsCast`: not exposed.

### People.tvCredits

`public func tvCredits(for personId: Int, language: String? = nil, completion: @escaping TMDBResult<PersonCreditsResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+People.swift:60](../../Sources/TMDBKit/Networking/APIClient/TMDB+People.swift#L60). Official operationId(s): `person-tv-credits`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `api_key`. Dispatch: application.

Response: `PersonCreditsResponse`. Models: `CreditsCast` ([Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift:18](../../Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift#L18)), `PersonCreditsResponse` ([Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift:10](../../Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift#L10)).

Existing public-call tests: `PeopleEndpointTests.testReturnsTVCredits` ([Tests/TMDBKitTests/PeopleEnpointTests.swift:39](../../Tests/TMDBKitTests/PeopleEnpointTests.swift#L39)).

Existing endpoint/fixture-associated tests: `PeopleEndpointTests.testReturnsTVCredits`; `PeopleEndpointTests.test_httpMethod`; `PeopleEndpointTests.test_httpBody`; `PeopleEndpointTests.test_endpointHeaders`; `PeopleEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7E.

Field crosswalk for `person-tv-credits`:

- `cast.[]genre_ids` → `CreditsCast`: not exposed.
- `cast.[]credit_id` → `CreditsCast`: not exposed.
- `crew.[]genre_ids` → `CreditsCast`: not exposed.
- `crew.[]credit_id` → `CreditsCast`: not exposed.

### People.combinedCredits

`public func combinedCredits(for personId: Int, language: String? = nil, completion: @escaping TMDBResult<PersonCreditsResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+People.swift:71](../../Sources/TMDBKit/Networking/APIClient/TMDB+People.swift#L71). Official operationId(s): `person-combined-credits`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `api_key`. Dispatch: application.

Response: `PersonCreditsResponse`. Models: `CreditsCast` ([Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift:18](../../Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift#L18)), `PersonCreditsResponse` ([Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift:10](../../Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift#L10)).

Existing public-call tests: `PeopleEndpointTests.testReturnsCombinedCredits` ([Tests/TMDBKitTests/PeopleEnpointTests.swift:47](../../Tests/TMDBKitTests/PeopleEnpointTests.swift#L47)).

Existing endpoint/fixture-associated tests: `PeopleEndpointTests.testReturnsCombinedCredits`; `PeopleEndpointTests.test_httpMethod`; `PeopleEndpointTests.test_httpBody`; `PeopleEndpointTests.test_endpointHeaders`; `PeopleEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7E.

Field crosswalk for `person-combined-credits`:

- `cast.[]genre_ids` → `CreditsCast`: not exposed.
- `cast.[]credit_id` → `CreditsCast`: not exposed.
- `cast.[]order` → `CreditsCast`: not exposed.
- `cast.[]media_type` → `CreditsCast`: not exposed.
- `crew.[]genre_ids` → `CreditsCast`: not exposed.
- `crew.[]credit_id` → `CreditsCast`: not exposed.
- `crew.[]media_type` → `CreditsCast`: not exposed.

### People.externalIds

`public func externalIds(for personId: Int, language: String? = nil, completion: @escaping TMDBResult<ExternalIds>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+People.swift:93](../../Sources/TMDBKit/Networking/APIClient/TMDB+People.swift#L93). Official operationId(s): `person-external-ids`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `api_key`. Dispatch: application.

Response: `ExternalIds`. Models: `ExternalIds` ([Sources/TMDBKit/Model/ExternalIds.swift:11](../../Sources/TMDBKit/Model/ExternalIds.swift#L11)).

Existing public-call tests: `PeopleEndpointTests.testReturnsExternalIds` ([Tests/TMDBKitTests/PeopleEnpointTests.swift:55](../../Tests/TMDBKitTests/PeopleEnpointTests.swift#L55)).

Existing endpoint/fixture-associated tests: `PeopleEndpointTests.testReturnsExternalIds`; `PeopleEndpointTests.test_httpMethod`; `PeopleEndpointTests.test_httpBody`; `PeopleEndpointTests.test_endpointHeaders`; `PeopleEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7A, 7G.

Field crosswalk for `person-external-ids`:

- `freebase_mid` → `ExternalIds`: not exposed.
- `freebase_id` → `ExternalIds`: not exposed.
- `tvrage_id` → `ExternalIds`: not exposed.
- `wikidata_id` → `ExternalIds`: not exposed.
- `tiktok_id` → `ExternalIds`: not exposed.
- `youtube_id` → `ExternalIds`: not exposed; schema type unspecified and example null. Public type unresolved pending authoritative evidence; excluded from Task 7G additions rather than guessing String.

### People.images

`public func images(for personId: Int, completion: @escaping TMDBResult<PersonImageResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+People.swift:103](../../Sources/TMDBKit/Networking/APIClient/TMDB+People.swift#L103). Official operationId(s): `person-images`.

Actual request: GET; no body; no endpoint headers. Query: `api_key`. Dispatch: application.

Response: `PersonImageResponse`. Models: `Image` ([Sources/TMDBKit/Model/Poster.swift:10](../../Sources/TMDBKit/Model/Poster.swift#L10)), `PersonImageResponse` ([Sources/TMDBKit/Responses/People/PersonImageResponse.swift:10](../../Sources/TMDBKit/Responses/People/PersonImageResponse.swift#L10)).

Existing public-call tests: `PeopleEndpointTests.testReturnsImages` ([Tests/TMDBKitTests/PeopleEnpointTests.swift:63](../../Tests/TMDBKitTests/PeopleEnpointTests.swift#L63)).

Existing endpoint/fixture-associated tests: `PeopleEndpointTests.testReturnsImages`; `PeopleEndpointTests.test_httpMethod`; `PeopleEndpointTests.test_httpBody`; `PeopleEndpointTests.test_endpointHeaders`; `PeopleEndpointTests.test_urlConstruction`.

Discrepancies / decisions: No confirmed discrepancy in inspected request/represented response fields; systematic failure/request coverage remains Task 8/9. Repair tasks: none confirmed.

### People.taggedImages

`public func taggedImages(for personId: Int, pageNumber: PageNumber = 1, language: String? = nil, completion: @escaping TMDBResult<TaggedImageResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+People.swift:113](../../Sources/TMDBKit/Networking/APIClient/TMDB+People.swift#L113). Official operationId(s): `person-tagged-images`.

Actual request: GET; no body; no endpoint headers. Query: `page`, `language`, `api_key`. Dispatch: application.

Response: `TaggedImageResponse`. Models: `LastEpisodeToAir` ([Sources/TMDBKit/Model/TVDetails.swift:57](../../Sources/TMDBKit/Model/TVDetails.swift#L57)), `MovieFragment` ([Sources/TMDBKit/Model/MovieFragment.swift:11](../../Sources/TMDBKit/Model/MovieFragment.swift#L11)), `PopularPerson` ([Sources/TMDBKit/Responses/People/PersonDetailsResponse.swift:55](../../Sources/TMDBKit/Responses/People/PersonDetailsResponse.swift#L55)), `TVMedia` ([Sources/TMDBKit/Model/Media.swift:46](../../Sources/TMDBKit/Model/Media.swift#L46)), `TaggedImageResponse` ([Sources/TMDBKit/Responses/People/TaggedImageResponse.swift:10](../../Sources/TMDBKit/Responses/People/TaggedImageResponse.swift#L10)), `TaggedImageResponse.Result` ([Sources/TMDBKit/Responses/People/TaggedImageResponse.swift:11](../../Sources/TMDBKit/Responses/People/TaggedImageResponse.swift#L11)).

Existing public-call tests: `PeopleEndpointTests.testReturnsTaggedImages` ([Tests/TMDBKitTests/PeopleEnpointTests.swift:71](../../Tests/TMDBKitTests/PeopleEnpointTests.swift#L71)); `PeopleEndpointTests.testTaggedImagesResponseParsing` ([Tests/TMDBKitTests/PeopleEnpointTests.swift:79](../../Tests/TMDBKitTests/PeopleEnpointTests.swift#L79)).

Existing endpoint/fixture-associated tests: `PeopleEndpointTests.testReturnsTaggedImages`; `PeopleEndpointTests.testTaggedImagesResponseParsing`; `PeopleEndpointTests.test_httpMethod`; `PeopleEndpointTests.test_httpBody`; `PeopleEndpointTests.test_endpointHeaders`; `PeopleEndpointTests.test_urlConstruction`.

Discrepancies / decisions: Human reference deprecated vs snapshot false; episode media rejected; optional metadata dropped; language query undocumented. Repair tasks: 7A, 7F, 7K.

Field crosswalk for `person-tagged-images`:

- `results.[]id` → `TaggedImageResponse.Result`: not exposed.
- `results.[]image_type` → `TaggedImageResponse.Result`: not exposed.

### People.translations

`public func translations(for personId: Int, language: String? = nil, completion: @escaping TMDBResult<PersonTranslationResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+People.swift:124](../../Sources/TMDBKit/Networking/APIClient/TMDB+People.swift#L124). Official operationId(s): `translations`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `api_key`. Dispatch: application.

Response: `PersonTranslationResponse`. Models: `PersonTranslation` ([Sources/TMDBKit/Model/Translation.swift:25](../../Sources/TMDBKit/Model/Translation.swift#L25)), `PersonTranslation.TranslationData` ([Sources/TMDBKit/Model/Translation.swift:26](../../Sources/TMDBKit/Model/Translation.swift#L26)), `PersonTranslationResponse` ([Sources/TMDBKit/Responses/TranslationsResponse.swift:16](../../Sources/TMDBKit/Responses/TranslationsResponse.swift#L16)).

Existing public-call tests: `PeopleEndpointTests.testReturnsTranslations` ([Tests/TMDBKitTests/PeopleEnpointTests.swift:111](../../Tests/TMDBKitTests/PeopleEnpointTests.swift#L111)).

Existing endpoint/fixture-associated tests: `PeopleEndpointTests.testReturnsTranslations`; `PeopleEndpointTests.test_httpMethod`; `PeopleEndpointTests.test_httpBody`; `PeopleEndpointTests.test_endpointHeaders`; `PeopleEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7A, 7G.

Field crosswalk for `translations`:

- `translations.[]data.name` → `PersonTranslation.TranslationData`: not exposed.

### People.latest

`public func latest(in language: String? = nil, completion: @escaping TMDBResult<PersonDetailsResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+People.swift:134](../../Sources/TMDBKit/Networking/APIClient/TMDB+People.swift#L134). Official operationId(s): `person-latest-id`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `api_key`. Dispatch: application.

Response: `PersonDetailsResponse`. Models: `AppendedImages` ([Sources/TMDBKit/Responses/ImagesResponse.swift:19](../../Sources/TMDBKit/Responses/ImagesResponse.swift#L19)), `AppendedPersonCredits` ([Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift:48](../../Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift#L48)), `AppendedRecommendations` ([Sources/TMDBKit/Responses/TV/RecommendationsResponse.swift:34](../../Sources/TMDBKit/Responses/TV/RecommendationsResponse.swift#L34)), `AppendedReviews` ([Sources/TMDBKit/Responses/ReviewsResponse.swift:21](../../Sources/TMDBKit/Responses/ReviewsResponse.swift#L21)), `AppendedTranslations` ([Sources/TMDBKit/Responses/TranslationsResponse.swift:21](../../Sources/TMDBKit/Responses/TranslationsResponse.swift#L21)), `AppendedVideos` ([Sources/TMDBKit/Responses/VideosResponse.swift:18](../../Sources/TMDBKit/Responses/VideosResponse.swift#L18)), `CreditsCast` ([Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift:18](../../Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift#L18)), `Image` ([Sources/TMDBKit/Model/Poster.swift:10](../../Sources/TMDBKit/Model/Poster.swift#L10)), `MovieFragment` ([Sources/TMDBKit/Model/MovieFragment.swift:11](../../Sources/TMDBKit/Model/MovieFragment.swift#L11)), `PersonDetailsResponse` ([Sources/TMDBKit/Responses/People/PersonDetailsResponse.swift:10](../../Sources/TMDBKit/Responses/People/PersonDetailsResponse.swift#L10)), `PopularMoviesResponse` ([Sources/TMDBKit/Responses/PopularMoviesResponse.swift:11](../../Sources/TMDBKit/Responses/PopularMoviesResponse.swift#L11)), `Review` ([Sources/TMDBKit/Model/Review.swift:10](../../Sources/TMDBKit/Model/Review.swift#L10)), `Review.AuthorDetails` ([Sources/TMDBKit/Model/Review.swift:11](../../Sources/TMDBKit/Model/Review.swift#L11)), `Translation` ([Sources/TMDBKit/Model/Translation.swift:10](../../Sources/TMDBKit/Model/Translation.swift#L10)), `Translation.TranslationData` ([Sources/TMDBKit/Model/Translation.swift:11](../../Sources/TMDBKit/Model/Translation.swift#L11)), `Video` ([Sources/TMDBKit/Model/Video.swift:10](../../Sources/TMDBKit/Model/Video.swift#L10)).

Existing public-call tests: `PeopleEndpointTests.testReturnsLatest` ([Tests/TMDBKitTests/PeopleEnpointTests.swift:119](../../Tests/TMDBKitTests/PeopleEnpointTests.swift#L119)).

Existing endpoint/fixture-associated tests: `PeopleEndpointTests.testReturnsLatest`; `PeopleEndpointTests.test_httpMethod`; `PeopleEndpointTests.test_httpBody`; `PeopleEndpointTests.test_endpointHeaders`; `PeopleEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7A, 7E.

Field crosswalk for `person-latest-id`:

- `deathday` → `PersonDetailsResponse`: not exposed.

### People.popular

`public func popular(pageNumber: PageNumber = 1, language: String? = nil, completion: @escaping TMDBResult<PopularPersonResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+People.swift:145](../../Sources/TMDBKit/Networking/APIClient/TMDB+People.swift#L145). Official operationId(s): `person-popular-list`.

Actual request: GET; no body; no endpoint headers. Query: `page`, `language`, `api_key`. Dispatch: application.

Response: `PopularPersonResponse`. Models: `LastEpisodeToAir` ([Sources/TMDBKit/Model/TVDetails.swift:57](../../Sources/TMDBKit/Model/TVDetails.swift#L57)), `MovieFragment` ([Sources/TMDBKit/Model/MovieFragment.swift:11](../../Sources/TMDBKit/Model/MovieFragment.swift#L11)), `PopularPerson` ([Sources/TMDBKit/Responses/People/PersonDetailsResponse.swift:55](../../Sources/TMDBKit/Responses/People/PersonDetailsResponse.swift#L55)), `PopularPersonResponse` ([Sources/TMDBKit/Responses/People/PersonDetailsResponse.swift:48](../../Sources/TMDBKit/Responses/People/PersonDetailsResponse.swift#L48)), `TVMedia` ([Sources/TMDBKit/Model/Media.swift:46](../../Sources/TMDBKit/Model/Media.swift#L46)).

Existing public-call tests: `PeopleEndpointTests.testReturnsPopular` ([Tests/TMDBKitTests/PeopleEnpointTests.swift:127](../../Tests/TMDBKitTests/PeopleEnpointTests.swift#L127)).

Existing endpoint/fixture-associated tests: `PeopleEndpointTests.testReturnsPopular`; `PeopleEndpointTests.test_httpMethod`; `PeopleEndpointTests.test_httpBody`; `PeopleEndpointTests.test_endpointHeaders`; `PeopleEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7F, 7G.

### Search.movies

`public func searchForMovies(_ movies: String, page: Int, completion: @escaping TMDBResult<PopularMoviesResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Search.swift:14](../../Sources/TMDBKit/Networking/APIClient/TMDB+Search.swift#L14). Official operationId(s): `search-movie`.

Actual request: GET; no body; no endpoint headers. Query: `query`, `page`, `api_key`. Dispatch: application.

Response: `PopularMoviesResponse`. Models: `MovieFragment` ([Sources/TMDBKit/Model/MovieFragment.swift:11](../../Sources/TMDBKit/Model/MovieFragment.swift#L11)), `PopularMoviesResponse` ([Sources/TMDBKit/Responses/PopularMoviesResponse.swift:11](../../Sources/TMDBKit/Responses/PopularMoviesResponse.swift#L11)).

Existing public-call tests: **none**.

Existing endpoint/fixture-associated tests: none.

Discrepancies / decisions: Missing include_adult, language, primary_release_year, region, year options; only query/page currently exposed. Repair tasks: 6.

### TV.details

`public func details(for tvId: Int, language: String? = nil, appending details: [DetailsAppendable]?, completion: @escaping TMDBResult<TVDetails>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:20](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L20). Official operationId(s): `tv-series-details`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `append_to_response`, `append-derived language/include_image_language (may duplicate language)`, `api_key`. Dispatch: application.

Response: `TVDetails`. Models: `AppendedImages` ([Sources/TMDBKit/Responses/ImagesResponse.swift:19](../../Sources/TMDBKit/Responses/ImagesResponse.swift#L19)), `AppendedReviews` ([Sources/TMDBKit/Responses/ReviewsResponse.swift:21](../../Sources/TMDBKit/Responses/ReviewsResponse.swift#L21)), `AppendedVideos` ([Sources/TMDBKit/Responses/VideosResponse.swift:18](../../Sources/TMDBKit/Responses/VideosResponse.swift#L18)), `CreatedBy` ([Sources/TMDBKit/Model/TVDetails.swift:47](../../Sources/TMDBKit/Model/TVDetails.swift#L47)), `Genre` ([Sources/TMDBKit/Model/Genre.swift:10](../../Sources/TMDBKit/Model/Genre.swift#L10)), `Image` ([Sources/TMDBKit/Model/Poster.swift:10](../../Sources/TMDBKit/Model/Poster.swift#L10)), `LastEpisodeToAir` ([Sources/TMDBKit/Model/TVDetails.swift:57](../../Sources/TMDBKit/Model/TVDetails.swift#L57)), `Network` ([Sources/TMDBKit/Model/TVDetails.swift:73](../../Sources/TMDBKit/Model/TVDetails.swift#L73)), `Review` ([Sources/TMDBKit/Model/Review.swift:10](../../Sources/TMDBKit/Model/Review.swift#L10)), `Review.AuthorDetails` ([Sources/TMDBKit/Model/Review.swift:11](../../Sources/TMDBKit/Model/Review.swift#L11)), `Season` ([Sources/TMDBKit/Model/TVDetails.swift:94](../../Sources/TMDBKit/Model/TVDetails.swift#L94)), `TVDetails` ([Sources/TMDBKit/Model/TVDetails.swift:10](../../Sources/TMDBKit/Model/TVDetails.swift#L10)), `Video` ([Sources/TMDBKit/Model/Video.swift:10](../../Sources/TMDBKit/Model/Video.swift#L10)).

Existing public-call tests: `TVEndpointTests.testReturnsDetails` ([Tests/TMDBKitTests/TVEndpointTests.swift:14](../../Tests/TMDBKitTests/TVEndpointTests.swift#L14)); `TVEndpointTests.testReturnsDetailsWithAppendedData` ([Tests/TMDBKitTests/TVEndpointTests.swift:22](../../Tests/TMDBKitTests/TVEndpointTests.swift#L22)).

Existing endpoint/fixture-associated tests: `TVEndpointTests.testReturnsDetails`; `TVEndpointTests.testReturnsDetailsWithAppendedData`; `TVEndpointTests.testDetailsURL`; `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7G, 7J.

Field crosswalk for `tv-series-details`:

- `adult` → `TVDetails`: not exposed.
- `last_episode_to_air.runtime` → `LastEpisodeToAir`: not exposed.
- `production_countries` → `TVDetails`: not exposed.
- `seasons.[]vote_average` → `Season`: not exposed.
- `spoken_languages` → `TVDetails`: not exposed.
- `tagline` → `TVDetails`: not exposed.

### TV.accountStates

`public func accountStates(for tvId: Int, language: String? = nil, completion: @escaping TMDBResult<AccountState>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:35](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L35). Official operationId(s): `tv-series-account-states`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `api_key`. Dispatch: application.

Response: `AccountState`. Models: `AccountState` ([Sources/TMDBKit/Model/AccountState.swift:11](../../Sources/TMDBKit/Model/AccountState.swift#L11)), `AccountState.Rating` ([Sources/TMDBKit/Model/AccountState.swift:12](../../Sources/TMDBKit/Model/AccountState.swift#L12)).

Existing public-call tests: `TVEndpointTests.test_accountStates` ([Tests/TMDBKitTests/TVEndpointTests.swift:57](../../Tests/TMDBKitTests/TVEndpointTests.swift#L57)).

Existing endpoint/fixture-associated tests: `TVEndpointTests.test_accountStates`; `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: Public call uses application fetchObject, so configured user session is omitted; language query unsupported. Repair tasks: 4, 7A, 7H.

AccountState.rated currently uses try? and silently converts malformed payloads to nil, not just false. Task 7H requires strict false/object discrimination.

### TV.aggregateCredits

`public func aggregateCredits(for tvId: Int, language: String? = nil, completion: @escaping TMDBResult<AggregateCredits>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:48](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L48). Official operationId(s): `tv-series-aggregate-credits`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `api_key`. Dispatch: application.

Response: `AggregateCredits`. Models: `AggregateCast` ([Sources/TMDBKit/Responses/CreditsResponse.swift:36](../../Sources/TMDBKit/Responses/CreditsResponse.swift#L36)), `AggregateCredits` ([Sources/TMDBKit/Responses/CreditsResponse.swift:30](../../Sources/TMDBKit/Responses/CreditsResponse.swift#L30)), `AggregateCrew` ([Sources/TMDBKit/Responses/CreditsResponse.swift:55](../../Sources/TMDBKit/Responses/CreditsResponse.swift#L55)).

Existing public-call tests: `TVEndpointTests.test_aggregateCredits` ([Tests/TMDBKitTests/TVEndpointTests.swift:65](../../Tests/TMDBKitTests/TVEndpointTests.swift#L65)).

Existing endpoint/fixture-associated tests: `TVEndpointTests.test_aggregateCredits`; `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7G.

Field crosswalk for `tv-series-aggregate-credits`:

- `cast.[]roles` → `AggregateCast`: not exposed.
- `crew.[]adult` → `AggregateCrew`: not exposed.
- `crew.[]known_for_department` → `AggregateCrew`: not exposed.
- `crew.[]original_name` → `AggregateCrew`: not exposed.
- `crew.[]popularity` → `AggregateCrew`: not exposed.
- `crew.[]jobs` → `AggregateCrew`: not exposed.

### TV.alternativeTitles

`public func alternativeTitles(for tvId: Int, language: String? = nil, completion: @escaping TMDBResult<AlternativeTvTitlesResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:60](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L60). Official operationId(s): `tv-series-alternative-titles`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `api_key`. Dispatch: application.

Response: `AlternativeTvTitlesResponse`. Models: `AlternativeTitle` ([Sources/TMDBKit/Model/AlternativeTitle.swift:10](../../Sources/TMDBKit/Model/AlternativeTitle.swift#L10)), `AlternativeTvTitlesResponse` ([Sources/TMDBKit/Responses/AlternativeTitlesResponse.swift:18](../../Sources/TMDBKit/Responses/AlternativeTitlesResponse.swift#L18)).

Existing public-call tests: `TVEndpointTests.testReturnsAlternativeTitles` ([Tests/TMDBKitTests/TVEndpointTests.swift:73](../../Tests/TMDBKitTests/TVEndpointTests.swift#L73)).

Existing endpoint/fixture-associated tests: `TVEndpointTests.testReturnsAlternativeTitles`; `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7A.

### TV.changes

`public func changes(for tvId: Int, pageNumber: PageNumber = 1, completion: @escaping TMDBResult<TVChangesResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:75](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L75). Official operationId(s): `tv-series-changes`.

Actual request: GET; no body; no endpoint headers. Query: `page`, `api_key`. Dispatch: application.

Response: `TVChangesResponse`. Models: `TVChange` ([Sources/TMDBKit/Model/Change.swift:24](../../Sources/TMDBKit/Model/Change.swift#L24)), `TVChange.Item` ([Sources/TMDBKit/Model/Change.swift:25](../../Sources/TMDBKit/Model/Change.swift#L25)), `TVChange.Item.Value` ([Sources/TMDBKit/Model/Change.swift:26](../../Sources/TMDBKit/Model/Change.swift#L26)), `TVChange.Item.Value.Poster` ([Sources/TMDBKit/Model/Change.swift:27](../../Sources/TMDBKit/Model/Change.swift#L27)), `TVChangesResponse` ([Sources/TMDBKit/Responses/ChangesResponse.swift:17](../../Sources/TMDBKit/Responses/ChangesResponse.swift#L17)).

Existing public-call tests: `TVEndpointTests.testReturnsChanges` ([Tests/TMDBKitTests/TVEndpointTests.swift:81](../../Tests/TMDBKitTests/TVEndpointTests.swift#L81)).

Existing endpoint/fixture-associated tests: `TVEndpointTests.testReturnsChanges`; `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: Missing start_date/end_date; response changes discarded because local key is items. Repair tasks: 5, 7B.

Field crosswalk for `tv-series-changes`:

- `changes` → `TVChangesResponse`: not exposed.

### TV.contentRatings

`public func contentRatings(for tvId: Int, language: String? = nil, completion: @escaping TMDBResult<ContentRatingsResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:88](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L88). Official operationId(s): `tv-series-content-ratings`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `api_key`. Dispatch: application.

Response: `ContentRatingsResponse`. Models: `ContentRatingsResponse` ([Sources/TMDBKit/Responses/TV/ContentRatingsResponse.swift:10](../../Sources/TMDBKit/Responses/TV/ContentRatingsResponse.swift#L10)), `Rating` ([Sources/TMDBKit/Model/Rating.swift:10](../../Sources/TMDBKit/Model/Rating.swift#L10)).

Existing public-call tests: `TVEndpointTests.testReturnsContentRatings` ([Tests/TMDBKitTests/TVEndpointTests.swift:89](../../Tests/TMDBKitTests/TVEndpointTests.swift#L89)).

Existing endpoint/fixture-associated tests: `TVEndpointTests.testReturnsContentRatings`; `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7A, 7G.

Field crosswalk for `tv-series-content-ratings`:

- `results.[]descriptors` → `Rating`: not exposed.

### TV.credits

`public func credits(for tvId: Int, language: String? = nil, completion: @escaping TMDBResult<TVCreditsResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:100](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L100). Official operationId(s): `tv-series-credits`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `api_key`. Dispatch: application.

Response: `TVCreditsResponse`. Models: `Crew` ([Sources/TMDBKit/Model/Crew.swift:10](../../Sources/TMDBKit/Model/Crew.swift#L10)), `TVCast` ([Sources/TMDBKit/Model/Cast.swift:24](../../Sources/TMDBKit/Model/Cast.swift#L24)), `TVCreditsResponse` ([Sources/TMDBKit/Responses/CreditsResponse.swift:19](../../Sources/TMDBKit/Responses/CreditsResponse.swift#L19)).

Existing public-call tests: `TVEndpointTests.testReturnsCredits` ([Tests/TMDBKitTests/TVEndpointTests.swift:97](../../Tests/TMDBKitTests/TVEndpointTests.swift#L97)).

Existing endpoint/fixture-associated tests: `TVEndpointTests.testReturnsCredits`; `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7G.

Field crosswalk for `tv-series-credits`:

- `crew.[]adult` → `Crew`: not exposed.
- `crew.[]known_for_department` → `Crew`: not exposed.
- `crew.[]original_name` → `Crew`: not exposed.
- `crew.[]popularity` → `Crew`: not exposed.

### TV.episodeGroups

`public func episodeGroups(for tvId: Int, language: String? = nil, completion: @escaping TMDBResult<EpisodeGroupsResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:112](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L112). Official operationId(s): `tv-series-episode-groups`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `api_key`. Dispatch: application.

Response: `EpisodeGroupsResponse`. Models: `EpisodeGroupsResponse` ([Sources/TMDBKit/Responses/TV/EpisodeGroupResponse.swift:10](../../Sources/TMDBKit/Responses/TV/EpisodeGroupResponse.swift#L10)), `GroupResult` ([Sources/TMDBKit/Responses/TV/EpisodeGroupResponse.swift:15](../../Sources/TMDBKit/Responses/TV/EpisodeGroupResponse.swift#L15)), `Network` ([Sources/TMDBKit/Model/TVDetails.swift:73](../../Sources/TMDBKit/Model/TVDetails.swift#L73)).

Existing public-call tests: `TVEndpointTests.testReturnsEpisodeGroups` ([Tests/TMDBKitTests/TVEndpointTests.swift:105](../../Tests/TMDBKitTests/TVEndpointTests.swift#L105)).

Existing endpoint/fixture-associated tests: `TVEndpointTests.testReturnsEpisodeGroups`; `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7A.

### TV.externalIds

`public func externalIds(for tvId: Int, language: String? = nil, completion: @escaping TMDBResult<ExternalIds>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:130](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L130). Official operationId(s): `tv-series-external-ids`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `api_key`. Dispatch: application.

Response: `ExternalIds`. Models: `ExternalIds` ([Sources/TMDBKit/Model/ExternalIds.swift:11](../../Sources/TMDBKit/Model/ExternalIds.swift#L11)).

Existing public-call tests: `TVEndpointTests.testReturnsExternalIds` ([Tests/TMDBKitTests/TVEndpointTests.swift:113](../../Tests/TMDBKitTests/TVEndpointTests.swift#L113)).

Existing endpoint/fixture-associated tests: `TVEndpointTests.testReturnsExternalIds`; `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7A, 7G.

Field crosswalk for `tv-series-external-ids`:

- `freebase_mid` → `ExternalIds`: not exposed.
- `freebase_id` → `ExternalIds`: not exposed.
- `tvdb_id` → `ExternalIds`: not exposed.
- `tvrage_id` → `ExternalIds`: not exposed.
- `wikidata_id` → `ExternalIds`: not exposed.

### TV.images

`public func images(for tvId: Int, language: String? = nil, completion: @escaping TMDBResult<ImagesResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:143](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L143). Official operationId(s): `tv-series-images`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `api_key`. Dispatch: application.

Response: `ImagesResponse`. Models: `Image` ([Sources/TMDBKit/Model/Poster.swift:10](../../Sources/TMDBKit/Model/Poster.swift#L10)), `ImagesResponse` ([Sources/TMDBKit/Responses/ImagesResponse.swift:13](../../Sources/TMDBKit/Responses/ImagesResponse.swift#L13)).

Existing public-call tests: `TVEndpointTests.testReturnsImages` ([Tests/TMDBKitTests/TVEndpointTests.swift:121](../../Tests/TMDBKitTests/TVEndpointTests.swift#L121)).

Existing endpoint/fixture-associated tests: `TVEndpointTests.testReturnsImages`; `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7A, 7G.

Field crosswalk for `tv-series-images`:

- `logos` → `ImagesResponse`: not exposed.

### TV.keywords

`public func keywords(for tvId: Int, completion: @escaping TMDBResult<TVKeywordsResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:154](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L154). Official operationId(s): `tv-series-keywords`.

Actual request: GET; no body; no endpoint headers. Query: `api_key`. Dispatch: application.

Response: `TVKeywordsResponse`. Models: `Keyword` ([Sources/TMDBKit/Model/Keyword.swift:10](../../Sources/TMDBKit/Model/Keyword.swift#L10)), `TVKeywordsResponse` ([Sources/TMDBKit/Responses/KeywordsResponse.swift:18](../../Sources/TMDBKit/Responses/KeywordsResponse.swift#L18)).

Existing public-call tests: `TVEndpointTests.testReturnsKeywords` ([Tests/TMDBKitTests/TVEndpointTests.swift:129](../../Tests/TMDBKitTests/TVEndpointTests.swift#L129)).

Existing endpoint/fixture-associated tests: `TVEndpointTests.testReturnsKeywords`; `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: No confirmed discrepancy in inspected request/represented response fields; systematic failure/request coverage remains Task 8/9. Repair tasks: none confirmed.

### TV.recommendations

`public func recommendations(for tvId: Int, pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<RecommendationsResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:165](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L165). Official operationId(s): `tv-series-recommendations`.

Actual request: GET; no body; no endpoint headers. Query: `page`, `language`, `api_key`. Dispatch: application.

Response: `RecommendationsResponse`. Models: `RecommendationNetwork` ([Sources/TMDBKit/Model/TVDetails.swift:80](../../Sources/TMDBKit/Model/TVDetails.swift#L80)), `RecommendationNetwork.Logo` ([Sources/TMDBKit/Model/TVDetails.swift:81](../../Sources/TMDBKit/Model/TVDetails.swift#L81)), `RecommendationsResponse` ([Sources/TMDBKit/Responses/TV/RecommendationsResponse.swift:10](../../Sources/TMDBKit/Responses/TV/RecommendationsResponse.swift#L10)), `RecommendationsResponse.Result` ([Sources/TMDBKit/Responses/TV/RecommendationsResponse.swift:11](../../Sources/TMDBKit/Responses/TV/RecommendationsResponse.swift#L11)).

Existing public-call tests: `TVEndpointTests.testReturnsRecommendations` ([Tests/TMDBKitTests/TVEndpointTests.swift:137](../../Tests/TMDBKitTests/TVEndpointTests.swift#L137)).

Existing endpoint/fixture-associated tests: `TVEndpointTests.testReturnsRecommendations`; `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: Pinned example fails because networks absent; image nullability is unspecified and requires evidence before changing public image types. Repair tasks: 7D.

Field crosswalk for `tv-series-recommendations`:

- `results.[]adult` → `RecommendationsResponse.Result`: not exposed.
- `results.[]media_type` → `RecommendationsResponse.Result`: not exposed.
- `results.[]networks` → `RecommendationsResponse.Result`: local required field absent from schema.

### TV.reviews

`public func reviews(for tvId: Int, pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<ReviewsResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:178](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L178). Official operationId(s): `tv-series-reviews`.

Actual request: GET; no body; no endpoint headers. Query: `page`, `language`, `api_key`. Dispatch: application.

Response: `ReviewsResponse`. Models: `Review` ([Sources/TMDBKit/Model/Review.swift:10](../../Sources/TMDBKit/Model/Review.swift#L10)), `Review.AuthorDetails` ([Sources/TMDBKit/Model/Review.swift:11](../../Sources/TMDBKit/Model/Review.swift#L11)), `ReviewsResponse` ([Sources/TMDBKit/Responses/ReviewsResponse.swift:13](../../Sources/TMDBKit/Responses/ReviewsResponse.swift#L13)).

Existing public-call tests: `TVEndpointTests.testReturnsReviews` ([Tests/TMDBKitTests/TVEndpointTests.swift:145](../../Tests/TMDBKitTests/TVEndpointTests.swift#L145)).

Existing endpoint/fixture-associated tests: `TVEndpointTests.testReturnsReviews`; `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7G.

Field crosswalk for `tv-series-reviews`:

- `results.[]author_details.username` → `Review.AuthorDetails`: not exposed.

### TV.screenedTheatrically

`public func screenedTheatrically(for tvId: Int, completion: @escaping TMDBResult<ScreenedTheatricallyResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:188](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L188). Official operationId(s): `tv-series-screened-theatrically`.

Actual request: GET; no body; no endpoint headers. Query: `api_key`. Dispatch: application.

Response: `ScreenedTheatricallyResponse`. Models: `ScreenedTheatricallyResponse` ([Sources/TMDBKit/Responses/TV/ScreenedTheatricallyResponse.swift:10](../../Sources/TMDBKit/Responses/TV/ScreenedTheatricallyResponse.swift#L10)), `ScreenedTheatricallyResponse.Result` ([Sources/TMDBKit/Responses/TV/ScreenedTheatricallyResponse.swift:11](../../Sources/TMDBKit/Responses/TV/ScreenedTheatricallyResponse.swift#L11)).

Existing public-call tests: `TVEndpointTests.testReturnsScreenedTheatrically` ([Tests/TMDBKitTests/TVEndpointTests.swift:153](../../Tests/TMDBKitTests/TVEndpointTests.swift#L153)).

Existing endpoint/fixture-associated tests: `TVEndpointTests.testReturnsScreenedTheatrically`; `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: No confirmed discrepancy in inspected request/represented response fields; systematic failure/request coverage remains Task 8/9. Repair tasks: none confirmed.

### TV.similarShows

`public func similarShows(for tvId: Int, pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<SimilarShowsResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:199](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L199). Official operationId(s): `tv-series-similar`.

Actual request: GET; no body; no endpoint headers. Query: `page`, `language`, `api_key`. Dispatch: application.

Response: `SimilarShowsResponse`. Models: `SimilarShowsResponse` ([Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift:10](../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift#L10)), `TVShowFragment` ([Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift:17](../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift#L17)).

Existing public-call tests: `TVEndpointTests.testReturnsSimilarShows` ([Tests/TMDBKitTests/TVEndpointTests.swift:161](../../Tests/TMDBKitTests/TVEndpointTests.swift#L161)).

Existing endpoint/fixture-associated tests: `TVEndpointTests.testReturnsSimilarShows`; `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7G.

Field crosswalk for `tv-series-similar`:

- `results.[]adult` → `TVShowFragment`: not exposed.

### TV.translations

`public func translations(for tvId: Int, completion: @escaping TMDBResult<TranslationsResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:210](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L210). Official operationId(s): `tv-series-translations`.

Actual request: GET; no body; no endpoint headers. Query: `api_key`. Dispatch: application.

Response: `TranslationsResponse`. Models: `Translation` ([Sources/TMDBKit/Model/Translation.swift:10](../../Sources/TMDBKit/Model/Translation.swift#L10)), `Translation.TranslationData` ([Sources/TMDBKit/Model/Translation.swift:11](../../Sources/TMDBKit/Model/Translation.swift#L11)), `TranslationsResponse` ([Sources/TMDBKit/Responses/TranslationsResponse.swift:11](../../Sources/TMDBKit/Responses/TranslationsResponse.swift#L11)).

Existing public-call tests: `TVEndpointTests.testReturnsTranslations` ([Tests/TMDBKitTests/TVEndpointTests.swift:169](../../Tests/TMDBKitTests/TVEndpointTests.swift#L169)).

Existing endpoint/fixture-associated tests: `TVEndpointTests.testReturnsTranslations`; `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7G.

Field crosswalk for `tv-series-translations`:

- `translations.[]data.tagline` → `Translation.TranslationData`: not exposed.

### TV.videos

`public func videos(for tvId: Int, language: String? = nil, completion: @escaping TMDBResult<VideosResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:222](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L222). Official operationId(s): `tv-series-videos`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `api_key`. Dispatch: application.

Response: `VideosResponse`. Models: `Video` ([Sources/TMDBKit/Model/Video.swift:10](../../Sources/TMDBKit/Model/Video.swift#L10)), `VideosResponse` ([Sources/TMDBKit/Responses/VideosResponse.swift:13](../../Sources/TMDBKit/Responses/VideosResponse.swift#L13)).

Existing public-call tests: `TVEndpointTests.testReturnsVideos` ([Tests/TMDBKitTests/TVEndpointTests.swift:177](../../Tests/TMDBKitTests/TVEndpointTests.swift#L177)).

Existing endpoint/fixture-associated tests: `TVEndpointTests.testReturnsVideos`; `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7A, 7G.

Field crosswalk for `tv-series-videos`:

- `results.[]official` → `Video`: not exposed.
- `results.[]published_at` → `Video`: not exposed.

### TV.watchProviders

`public func watchProviders(for tvId: Int, completion: @escaping TMDBResult<WatchProviderResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:240](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L240). Official operationId(s): `tv-series-watch-providers`.

Actual request: GET; no body; no endpoint headers. Query: `api_key`. Dispatch: application.

Response: `WatchProviderResponse`. Models: `ProviderResult` ([Sources/TMDBKit/Model/WatchProvider.swift:22](../../Sources/TMDBKit/Model/WatchProvider.swift#L22)), `Results` ([Sources/TMDBKit/Model/WatchProvider.swift:29](../../Sources/TMDBKit/Model/WatchProvider.swift#L29)), `WatchProvider` ([Sources/TMDBKit/Model/WatchProvider.swift:15](../../Sources/TMDBKit/Model/WatchProvider.swift#L15)), `WatchProviderResponse` ([Sources/TMDBKit/Model/WatchProvider.swift:10](../../Sources/TMDBKit/Model/WatchProvider.swift#L10)).

Existing public-call tests: `TVEndpointTests.test_watchProviders` ([Tests/TMDBKitTests/TVEndpointTests.swift:225](../../Tests/TMDBKitTests/TVEndpointTests.swift#L225)).

Existing endpoint/fixture-associated tests: `TVEndpointTests.test_watchProviders`; `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7C.

Field crosswalk for `tv-series-watch-providers`:

- `results.{region}` → `Results`: dynamic region map required; legacy fixed accessors omit documented regions.

### TV.latest

`public func latest(in language: String? = nil, completion: @escaping TMDBResult<TVDetails>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:251](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L251). Official operationId(s): `tv-series-latest-id`.

Actual request: GET; no body; no endpoint headers. Query: `language`, `api_key`. Dispatch: application.

Response: `TVDetails`. Models: `AppendedImages` ([Sources/TMDBKit/Responses/ImagesResponse.swift:19](../../Sources/TMDBKit/Responses/ImagesResponse.swift#L19)), `AppendedReviews` ([Sources/TMDBKit/Responses/ReviewsResponse.swift:21](../../Sources/TMDBKit/Responses/ReviewsResponse.swift#L21)), `AppendedVideos` ([Sources/TMDBKit/Responses/VideosResponse.swift:18](../../Sources/TMDBKit/Responses/VideosResponse.swift#L18)), `CreatedBy` ([Sources/TMDBKit/Model/TVDetails.swift:47](../../Sources/TMDBKit/Model/TVDetails.swift#L47)), `Genre` ([Sources/TMDBKit/Model/Genre.swift:10](../../Sources/TMDBKit/Model/Genre.swift#L10)), `Image` ([Sources/TMDBKit/Model/Poster.swift:10](../../Sources/TMDBKit/Model/Poster.swift#L10)), `LastEpisodeToAir` ([Sources/TMDBKit/Model/TVDetails.swift:57](../../Sources/TMDBKit/Model/TVDetails.swift#L57)), `Network` ([Sources/TMDBKit/Model/TVDetails.swift:73](../../Sources/TMDBKit/Model/TVDetails.swift#L73)), `Review` ([Sources/TMDBKit/Model/Review.swift:10](../../Sources/TMDBKit/Model/Review.swift#L10)), `Review.AuthorDetails` ([Sources/TMDBKit/Model/Review.swift:11](../../Sources/TMDBKit/Model/Review.swift#L11)), `Season` ([Sources/TMDBKit/Model/TVDetails.swift:94](../../Sources/TMDBKit/Model/TVDetails.swift#L94)), `TVDetails` ([Sources/TMDBKit/Model/TVDetails.swift:10](../../Sources/TMDBKit/Model/TVDetails.swift#L10)), `Video` ([Sources/TMDBKit/Model/Video.swift:10](../../Sources/TMDBKit/Model/Video.swift#L10)).

Existing public-call tests: `TVEndpointTests.testReturnsLatestShows` ([Tests/TMDBKitTests/TVEndpointTests.swift:185](../../Tests/TMDBKitTests/TVEndpointTests.swift#L185)).

Existing endpoint/fixture-associated tests: `TVEndpointTests.testReturnsLatestShows`; `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7A, 7G.

Field crosswalk for `tv-series-latest-id`:

- `adult` → `TVDetails`: not exposed.
- `last_episode_to_air.runtime` → `LastEpisodeToAir`: not exposed.
- `production_countries` → `TVDetails`: not exposed.
- `spoken_languages` → `TVDetails`: not exposed.
- `tagline` → `TVDetails`: not exposed.

### TV.airingToday

`public func airingToday(pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<SimilarShowsResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:265](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L265). Official operationId(s): `tv-series-airing-today-list`.

Actual request: GET; no body; no endpoint headers. Query: `page`, `language`, `api_key`. Dispatch: application.

Response: `SimilarShowsResponse`. Models: `SimilarShowsResponse` ([Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift:10](../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift#L10)), `TVShowFragment` ([Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift:17](../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift#L17)).

Existing public-call tests: `TVEndpointTests.testReturnsAiringToday` ([Tests/TMDBKitTests/TVEndpointTests.swift:193](../../Tests/TMDBKitTests/TVEndpointTests.swift#L193)).

Existing endpoint/fixture-associated tests: `TVEndpointTests.testReturnsAiringToday`; `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7A.

### TV.onTheAir

`public func onTheAir(pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<SimilarShowsResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:278](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L278). Official operationId(s): `tv-series-on-the-air-list`.

Actual request: GET; no body; no endpoint headers. Query: `page`, `language`, `api_key`. Dispatch: application.

Response: `SimilarShowsResponse`. Models: `SimilarShowsResponse` ([Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift:10](../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift#L10)), `TVShowFragment` ([Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift:17](../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift#L17)).

Existing public-call tests: `TVEndpointTests.testReturnsOnAirShows` ([Tests/TMDBKitTests/TVEndpointTests.swift:201](../../Tests/TMDBKitTests/TVEndpointTests.swift#L201)).

Existing endpoint/fixture-associated tests: `TVEndpointTests.testReturnsOnAirShows`; `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7A.

### TV.popular

`public func popular(pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<SimilarShowsResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:290](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L290). Official operationId(s): `tv-series-popular-list`.

Actual request: GET; no body; no endpoint headers. Query: `page`, `language`, `api_key`. Dispatch: application.

Response: `SimilarShowsResponse`. Models: `SimilarShowsResponse` ([Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift:10](../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift#L10)), `TVShowFragment` ([Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift:17](../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift#L17)).

Existing public-call tests: `TVEndpointTests.testReturnsPopular` ([Tests/TMDBKitTests/TVEndpointTests.swift:209](../../Tests/TMDBKitTests/TVEndpointTests.swift#L209)).

Existing endpoint/fixture-associated tests: `TVEndpointTests.testReturnsPopular`; `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: No confirmed discrepancy in inspected request/represented response fields; systematic failure/request coverage remains Task 8/9. Repair tasks: none confirmed.

### TV.topRated

`public func topRated(pageNumber: PageNumber, language: String? = nil, completion: @escaping TMDBResult<SimilarShowsResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:302](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L302). Official operationId(s): `tv-series-top-rated-list`.

Actual request: GET; no body; no endpoint headers. Query: `page`, `language`, `api_key`. Dispatch: application.

Response: `SimilarShowsResponse`. Models: `SimilarShowsResponse` ([Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift:10](../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift#L10)), `TVShowFragment` ([Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift:17](../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift#L17)).

Existing public-call tests: `TVEndpointTests.testReturnsTopRated` ([Tests/TMDBKitTests/TVEndpointTests.swift:217](../../Tests/TMDBKitTests/TVEndpointTests.swift#L217)).

Existing endpoint/fixture-associated tests: `TVEndpointTests.testReturnsTopRated`; `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: No confirmed discrepancy in inspected request/represented response fields; systematic failure/request coverage remains Task 8/9. Repair tasks: none confirmed.

### TV.rateShow

`public func rateShow(_ tvId: Int, rating: Double, completion: @escaping TMDBResult<StatusResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:318](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L318). Official operationId(s): `tv-series-add-rating`.

Actual request: POST JSON {value: tvId} (BUG: rating ignored); application/json;charset=utf-8. Query: `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `StatusResponse`. Models: `StatusResponse` ([Sources/TMDBKit/Networking/APIClient/TMDB.swift:36](../../Sources/TMDBKit/Networking/APIClient/TMDB.swift#L36)).

Existing public-call tests: **none**.

Existing endpoint/fixture-associated tests: `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_rateShow_httpBody`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: Body binds tvId as value, ignores rating; regression must use distinct tvId=1399/rating=8.5. Repair tasks: 3, 7H.

### TV.deleteRating

`public func deleteRating(of tvId: Int, completion: @escaping TMDBResult<StatusResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:330](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L330). Official operationId(s): `tv-series-delete-rating`.

Actual request: DELETE no body; application/json;charset=utf-8. Query: `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `StatusResponse`. Models: `StatusResponse` ([Sources/TMDBKit/Networking/APIClient/TMDB.swift:36](../../Sources/TMDBKit/Networking/APIClient/TMDB.swift#L36)).

Existing public-call tests: **none**.

Existing endpoint/fixture-associated tests: `TVEndpointTests.test_httpMethod`; `TVEndpointTests.test_httpBody`; `TVEndpointTests.test_requestHeaders`; `TVEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7H.

### Trending.trending

`public func trending(_ mediaType: MediaType, withinLast timeWindow: TimeWindow, completion: @escaping TMDBResult<TrendingResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB+Trending.swift:19](../../Sources/TMDBKit/Networking/APIClient/TMDB+Trending.swift#L19). Official operationId(s): `trending-all`, `trending-movies`, `trending-people`, `trending-tv`.

Actual request: GET; no body; no endpoint headers. Query: `api_key`. Dispatch: application.

Response: `TrendingResponse`. Models: `LastEpisodeToAir` ([Sources/TMDBKit/Model/TVDetails.swift:57](../../Sources/TMDBKit/Model/TVDetails.swift#L57)), `MovieFragment` ([Sources/TMDBKit/Model/MovieFragment.swift:11](../../Sources/TMDBKit/Model/MovieFragment.swift#L11)), `PopularPerson` ([Sources/TMDBKit/Responses/People/PersonDetailsResponse.swift:55](../../Sources/TMDBKit/Responses/People/PersonDetailsResponse.swift#L55)), `TVMedia` ([Sources/TMDBKit/Model/Media.swift:46](../../Sources/TMDBKit/Model/Media.swift#L46)), `TrendingResponse` ([Sources/TMDBKit/Responses/TrendingResponse.swift:10](../../Sources/TMDBKit/Responses/TrendingResponse.swift#L10)).

Existing public-call tests: `TrendingEndpointTests.testReturnsTrendingMovies` ([Tests/TMDBKitTests/TrendingEndpointTests.swift:12](../../Tests/TMDBKitTests/TrendingEndpointTests.swift#L12)); `TrendingEndpointTests.testReturnsTrendingTVShows` ([Tests/TMDBKitTests/TrendingEndpointTests.swift:20](../../Tests/TMDBKitTests/TrendingEndpointTests.swift#L20)); `TrendingEndpointTests.testReturnsTrendingPeople` ([Tests/TMDBKitTests/TrendingEndpointTests.swift:28](../../Tests/TMDBKitTests/TrendingEndpointTests.swift#L28)); `TrendingEndpointTests.testReturnsTrendingEverything` ([Tests/TMDBKitTests/TrendingEndpointTests.swift:36](../../Tests/TMDBKitTests/TrendingEndpointTests.swift#L36)).

Existing endpoint/fixture-associated tests: `TrendingEndpointTests.testReturnsTrendingMovies`; `TrendingEndpointTests.testReturnsTrendingTVShows`; `TrendingEndpointTests.testReturnsTrendingPeople`; `TrendingEndpointTests.testReturnsTrendingEverything`; `TrendingEndpointTests.test_httpMethod`; `TrendingEndpointTests.test_httpBody`; `TrendingEndpointTests.test_requestHeaders`; `TrendingEndpointTests.test_urlConstruction`.

Discrepancies / decisions: See exact local request, schema field crosswalk, and assigned repair entries. See exact local request, schema field crosswalk, and assigned repair entries. See exact local request, schema field crosswalk, and assigned repair entries. See exact local request, schema field crosswalk, and assigned repair entries. Repair tasks: 7A, 7F, 7G.

Media is decoded by shape probing today, not media_type. The model graph additionally contains knownFor nested media. Task 7F preserves explicit discriminators and adds episode support; Task 7G exposes TV adult/media type metadata.

### Authentication.requestToken

`public func createRequestToken(completion: @escaping TMDBResult<RequestToken>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB.swift:79](../../Sources/TMDBKit/Networking/APIClient/TMDB.swift#L79). Official operationId(s): `authentication-create-request-token`.

Actual request: GET; no body; no endpoint headers. Query: `api_key`. Dispatch: application.

Response: `RequestToken`. Models: `RequestToken` ([Sources/TMDBKit/Networking/APIClient/TMDB.swift:21](../../Sources/TMDBKit/Networking/APIClient/TMDB.swift#L21)).

Existing public-call tests: `AuthenticationEndpointTests.test_createRequestToken_returnsToken` ([Tests/TMDBKitTests/AuthenticationEndpointTests.swift:12](../../Tests/TMDBKitTests/AuthenticationEndpointTests.swift#L12)).

Existing endpoint/fixture-associated tests: `AuthenticationEndpointTests.test_createRequestToken_returnsToken`; `AuthenticationEndpointTests.test_endpointURLs`; `AuthenticationEndpointTests.test_endpointHeaders`; `AuthenticationEndpointTests.test_httpMethod`.

Discrepancies / decisions: No confirmed discrepancy in inspected request/represented response fields; systematic failure/request coverage remains Task 8/9. Repair tasks: none confirmed.

### Authentication.createSession

`public func createSession(requestToken: RequestToken, completion: @escaping TMDBResult<Session>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB.swift:84](../../Sources/TMDBKit/Networking/APIClient/TMDB.swift#L84). Official operationId(s): `authentication-create-session`.

Actual request: POST JSON {request_token}; application/json;charset=utf-8; token ALSO in query. Query: `request_token`, `api_key`. Dispatch: application.

Response: `Session`. Models: `Session` ([Sources/TMDBKit/Networking/APIClient/TMDB.swift:27](../../Sources/TMDBKit/Networking/APIClient/TMDB.swift#L27)).

Existing public-call tests: `AuthenticationEndpointTests.test_createSession_returnsSession` ([Tests/TMDBKitTests/AuthenticationEndpointTests.swift:20](../../Tests/TMDBKitTests/AuthenticationEndpointTests.swift#L20)).

Existing endpoint/fixture-associated tests: `AuthenticationEndpointTests.test_createSession_returnsSession`; `AuthenticationEndpointTests.test_endpointURLs`; `AuthenticationEndpointTests.test_createSession_HTTPBody`; `AuthenticationEndpointTests.test_endpointHeaders`; `AuthenticationEndpointTests.test_httpMethod`.

Discrepancies / decisions: Undocumented request_token query duplicates documented JSON token. Repair tasks: 4.

### Authentication.deleteSession

`public func deleteSession(completion: @escaping TMDBResult<SuccessResponse>)`

Source: [Sources/TMDBKit/Networking/APIClient/TMDB.swift:91](../../Sources/TMDBKit/Networking/APIClient/TMDB.swift#L91). Official operationId(s): `authentication-delete-session`.

Actual request: DELETE JSON {session_id}; application/json;charset=utf-8; session ALSO in query. Query: `session_id (configured user; mandatory gate)`, `api_key`. Dispatch: user-session.

Response: `SuccessResponse`. Models: `SuccessResponse` ([Sources/TMDBKit/Networking/APIClient/TMDB.swift:32](../../Sources/TMDBKit/Networking/APIClient/TMDB.swift#L32)).

Existing public-call tests: `AuthenticationEndpointTests.test_deleteSession_withoutSession_returnsError` ([Tests/TMDBKitTests/AuthenticationEndpointTests.swift:28](../../Tests/TMDBKitTests/AuthenticationEndpointTests.swift#L28)).

Existing endpoint/fixture-associated tests: `AuthenticationEndpointTests.test_endpointURLs`; `AuthenticationEndpointTests.test_deleteSession_HTTPBody`; `AuthenticationEndpointTests.test_endpointHeaders`; `AuthenticationEndpointTests.test_httpMethod`.

Discrepancies / decisions: Undocumented session_id query duplicates documented JSON session_id body; preserve missing-session guard but dispatch body with application authentication (7A). Repair tasks: 7A.

## Model declaration crosswalk

Current stored properties are recorded exactly below, including legacy acronym spellings. New canonical properties and named regression tests are specified in Task 7. This table plus per-operation field gaps traces every public response model rather than assuming fixture decode proves field completeness.

| Model | Source | Stored field : Swift type |
| --- | --- | --- |
| `AccountDetails` | [Sources/TMDBKit/Model/AccountDetails.swift:11](../../Sources/TMDBKit/Model/AccountDetails.swift#L11) | `avatar: Avatar`, `id: Int`, `iso6391: String`, `iso31661: String`, `name: String`, `includeAdult: Bool`, `username: String` |
| `AccountDetails.Avatar` | [Sources/TMDBKit/Model/AccountDetails.swift:12](../../Sources/TMDBKit/Model/AccountDetails.swift#L12) | `gravatar: Gravatar` |
| `AccountDetails.Avatar.Gravatar` | [Sources/TMDBKit/Model/AccountDetails.swift:13](../../Sources/TMDBKit/Model/AccountDetails.swift#L13) | `hash: String` |
| `AccountState` | [Sources/TMDBKit/Model/AccountState.swift:11](../../Sources/TMDBKit/Model/AccountState.swift#L11) | `id: Int`, `favorite: Bool`, `rated: Rating?`, `watchlist: Bool` |
| `AccountState.Rating` | [Sources/TMDBKit/Model/AccountState.swift:12](../../Sources/TMDBKit/Model/AccountState.swift#L12) | `value: Double` |
| `AggregateCast` | [Sources/TMDBKit/Responses/CreditsResponse.swift:36](../../Sources/TMDBKit/Responses/CreditsResponse.swift#L36) | `adult: Bool`, `gender: Int`, `id: Int`, `knownForDepartment: String`, `name: String`, `originalName: String`, `order: Int`, `popularity: Double`, `profilePath: String?`, `totalEpisodeCount: Int` |
| `AggregateCast.Role` | [Sources/TMDBKit/Responses/CreditsResponse.swift:37](../../Sources/TMDBKit/Responses/CreditsResponse.swift#L37) | `creditId: String`, `character: String`, `episodeCount: Int` |
| `AggregateCredits` | [Sources/TMDBKit/Responses/CreditsResponse.swift:30](../../Sources/TMDBKit/Responses/CreditsResponse.swift#L30) | `id: Int`, `cast: [AggregateCast]`, `crew: [AggregateCrew]` |
| `AggregateCrew` | [Sources/TMDBKit/Responses/CreditsResponse.swift:55](../../Sources/TMDBKit/Responses/CreditsResponse.swift#L55) | `department: String`, `gender: Int?`, `id: Int`, `name: String`, `profilePath: String?`, `totalEpisodeCount: Int` |
| `AggregateCrew.Job` | [Sources/TMDBKit/Responses/CreditsResponse.swift:56](../../Sources/TMDBKit/Responses/CreditsResponse.swift#L56) | `creditId: String`, `job: String`, `episodeCount: Int` |
| `AlternativeTitle` | [Sources/TMDBKit/Model/AlternativeTitle.swift:10](../../Sources/TMDBKit/Model/AlternativeTitle.swift#L10) | `iso31661: String`, `title: String`, `type: String` |
| `AlternativeTitlesResponse` | [Sources/TMDBKit/Responses/AlternativeTitlesResponse.swift:13](../../Sources/TMDBKit/Responses/AlternativeTitlesResponse.swift#L13) | `id: Int`, `titles: [AlternativeTitle]` |
| `AlternativeTvTitlesResponse` | [Sources/TMDBKit/Responses/AlternativeTitlesResponse.swift:18](../../Sources/TMDBKit/Responses/AlternativeTitlesResponse.swift#L18) | `id: Int`, `results: [AlternativeTitle]` |
| `AppendedCredits` | [Sources/TMDBKit/Responses/CreditsResponse.swift:25](../../Sources/TMDBKit/Responses/CreditsResponse.swift#L25) | `cast: [Cast]`, `crew: [Crew]` |
| `AppendedImages` | [Sources/TMDBKit/Responses/ImagesResponse.swift:19](../../Sources/TMDBKit/Responses/ImagesResponse.swift#L19) | `backdrops: [Image]`, `posters: [Image]` |
| `AppendedPersonCredits` | [Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift:48](../../Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift#L48) | `cast: [CreditsCast]`, `crew: [CreditsCast]` |
| `AppendedRecommendations` | [Sources/TMDBKit/Responses/TV/RecommendationsResponse.swift:34](../../Sources/TMDBKit/Responses/TV/RecommendationsResponse.swift#L34) | `page: Int`, `results: [MovieFragment]`, `totalPages: Int`, `totalResults: Int` |
| `AppendedReviews` | [Sources/TMDBKit/Responses/ReviewsResponse.swift:21](../../Sources/TMDBKit/Responses/ReviewsResponse.swift#L21) | `page: Int`, `results: [Review]`, `totalPages: Int`, `totalResults: Int` |
| `AppendedTranslations` | [Sources/TMDBKit/Responses/TranslationsResponse.swift:21](../../Sources/TMDBKit/Responses/TranslationsResponse.swift#L21) | `translations: [Translation]` |
| `AppendedVideos` | [Sources/TMDBKit/Responses/VideosResponse.swift:18](../../Sources/TMDBKit/Responses/VideosResponse.swift#L18) | `results: [Video]` |
| `Cast` | [Sources/TMDBKit/Model/Cast.swift:10](../../Sources/TMDBKit/Model/Cast.swift#L10) | `adult: Bool`, `character: String`, `creditId: String`, `gender: Int`, `id: Int`, `knownForDepartment: String`, `name: String`, `originalName: String`, `order: Int`, `popularity: Double`, `profilePath: String?` |
| `Change` | [Sources/TMDBKit/Model/Change.swift:10](../../Sources/TMDBKit/Model/Change.swift#L10) | `key: String`, `items: [Item]` |
| `Change.Item` | [Sources/TMDBKit/Model/Change.swift:11](../../Sources/TMDBKit/Model/Change.swift#L11) | `id: String`, `action: String`, `time: String`, `iso6391: String`, `value: String`, `originalValue: String` |
| `ChangesResponse` | [Sources/TMDBKit/Responses/ChangesResponse.swift:13](../../Sources/TMDBKit/Responses/ChangesResponse.swift#L13) | `changes: [Change]?` |
| `ContentRatingsResponse` | [Sources/TMDBKit/Responses/TV/ContentRatingsResponse.swift:10](../../Sources/TMDBKit/Responses/TV/ContentRatingsResponse.swift#L10) | `id: Int`, `results: [Rating]` |
| `CreatedBy` | [Sources/TMDBKit/Model/TVDetails.swift:47](../../Sources/TMDBKit/Model/TVDetails.swift#L47) | `id: Int`, `creditId: String`, `name: String`, `gender: Int`, `profilePath: String` |
| `CreditsCast` | [Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift:18](../../Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift#L18) | `character: String?`, `creditID: String?`, `posterPath: String?`, `id: Int`, `voteCount: Int`, `backdropPath: String?`, `genreIDS: [Int]?`, `originalLanguage: String`, `popularity: Double`, `voteAverage: Double`, `overview: String`, `department: String?`, `job: String?`, `video: Bool?`, `adult: Bool?`, `originalTitle: String?`, `title: String?`, `releaseDate: String?`, `originalName: String?`, `name: String?`, `episodeCount: Int?`, `firstAirDate: String?`, `originCountry: [String]?` |
| `CreditsResponse` | [Sources/TMDBKit/Responses/CreditsResponse.swift:13](../../Sources/TMDBKit/Responses/CreditsResponse.swift#L13) | `id: Int`, `cast: [Cast]`, `crew: [Crew]` |
| `Crew` | [Sources/TMDBKit/Model/Crew.swift:10](../../Sources/TMDBKit/Model/Crew.swift#L10) | `creditId: String`, `department: String`, `gender: Int?`, `id: Int`, `job: String`, `name: String`, `profilePath: String?` |
| `EpisodeGroupsResponse` | [Sources/TMDBKit/Responses/TV/EpisodeGroupResponse.swift:10](../../Sources/TMDBKit/Responses/TV/EpisodeGroupResponse.swift#L10) | `results: [GroupResult]?`, `id: Int` |
| `EpisodeListResponse` | [Sources/TMDBKit/Responses/EpisodeListResponse.swift:11](../../Sources/TMDBKit/Responses/EpisodeListResponse.swift#L11) | `page: Int`, `results: [LastEpisodeToAir]`, `totalPages: Int`, `totalResults: Int` |
| `ExternalIds` | [Sources/TMDBKit/Model/ExternalIds.swift:11](../../Sources/TMDBKit/Model/ExternalIds.swift#L11) | `imdbId: String?`, `facebookId: String?`, `instagramId: String?`, `twitterId: String?`, `id: Int` |
| `Genre` | [Sources/TMDBKit/Model/Genre.swift:10](../../Sources/TMDBKit/Model/Genre.swift#L10) | `id: Int`, `name: String` |
| `GroupResult` | [Sources/TMDBKit/Responses/TV/EpisodeGroupResponse.swift:15](../../Sources/TMDBKit/Responses/TV/EpisodeGroupResponse.swift#L15) | `description: String`, `episodeCount: Int`, `groupCount: Int`, `id: String`, `name: String`, `network: Network?`, `type: Int` |
| `HTTPResponseContaining` | [Sources/TMDBKit/Networking/APIClient/TMDB.swift:13](../../Sources/TMDBKit/Networking/APIClient/TMDB.swift#L13) | `object: Object`, `responseStatusCode: Int` |
| `Image` | [Sources/TMDBKit/Model/Poster.swift:10](../../Sources/TMDBKit/Model/Poster.swift#L10) | `aspectRatio: Double`, `filePath: String`, `height: Int`, `iso6391: String?`, `voteAverage: Double`, `voteCount: Int`, `width: Int` |
| `ImagesResponse` | [Sources/TMDBKit/Responses/ImagesResponse.swift:13](../../Sources/TMDBKit/Responses/ImagesResponse.swift#L13) | `id: Int`, `backdrops: [Image]`, `posters: [Image]` |
| `Keyword` | [Sources/TMDBKit/Model/Keyword.swift:10](../../Sources/TMDBKit/Model/Keyword.swift#L10) | `id: Int`, `name: String` |
| `KeywordsResponse` | [Sources/TMDBKit/Responses/KeywordsResponse.swift:13](../../Sources/TMDBKit/Responses/KeywordsResponse.swift#L13) | `id: Int`, `keywords: [Keyword]` |
| `Language` | [Sources/TMDBKit/Model/Language.swift:10](../../Sources/TMDBKit/Model/Language.swift#L10) | `iso6391: String`, `name: String` |
| `LastEpisodeToAir` | [Sources/TMDBKit/Model/TVDetails.swift:57](../../Sources/TMDBKit/Model/TVDetails.swift#L57) | `airDate: String`, `episodeNumber: Int`, `id: Int`, `name: String`, `overview: String`, `productionCode: String?`, `seasonNumber: Int`, `showId: Int?`, `stillPath: String?`, `voteAverage: Double`, `voteCount: Int` |
| `List` | [Sources/TMDBKit/Model/List.swift:10](../../Sources/TMDBKit/Model/List.swift#L10) | `description: String`, `favoriteCount: Int`, `id: Int`, `iso6391: String`, `itemCount: Int`, `listType: String`, `name: String`, `posterPath: String?` |
| `ListCreateResponse` | [Sources/TMDBKit/Model/List.swift:39](../../Sources/TMDBKit/Model/List.swift#L39) | `statusMessage: String`, `success: Bool`, `statusCode: Int`, `listId: Int` |
| `ListDetails` | [Sources/TMDBKit/Model/List.swift:21](../../Sources/TMDBKit/Model/List.swift#L21) | `createdBy: String`, `description: String`, `favoriteCount: Int`, `id: String`, `items: [MovieFragment]`, `iso6391: String`, `itemCount: Int`, `listType: String?`, `name: String`, `posterPath: String?` |
| `ListItemStatus` | [Sources/TMDBKit/Model/List.swift:34](../../Sources/TMDBKit/Model/List.swift#L34) | `id: String`, `itemPresent: Bool` |
| `ListModificationResponse` | [Sources/TMDBKit/Model/List.swift:46](../../Sources/TMDBKit/Model/List.swift#L46) | `statusMessage: String`, `statusCode: Int` |
| `ListableMedia` | [Sources/TMDBKit/Networking/Endpoints/Account.swift:11](../../Sources/TMDBKit/Networking/Endpoints/Account.swift#L11) | `type: MediaType`, `id: Int` |
| `ListsResponse` | [Sources/TMDBKit/Responses/ListsResponse.swift:11](../../Sources/TMDBKit/Responses/ListsResponse.swift#L11) | `id: Int?`, `page: Int`, `results: [List]`, `totalPages: Int`, `totalResults: Int` |
| `Movie` | [Sources/TMDBKit/Model/Movie.swift:11](../../Sources/TMDBKit/Model/Movie.swift#L11) | `adult: Bool`, `backdropPath: String?`, `belongsToCollection: MovieCollection?`, `budget: Int`, `genres: [Genre]`, `homepage: String?`, `id: Int`, `imdbId: String?`, `originalLanguage: String`, `originalTitle: String`, `overview: String`, `popularity: Double`, `posterPath: String?`, `productionCompanies: [ProductionCompany]`, `productionCountries: [ProductionCountry]`, `releaseDate: String`, `revenue: Int`, `runtime: Int?`, `spokenLanguages: [Language]`, `status: String`, `tagline: String?`, `title: String`, `video: Bool`, `voteAverage: Double`, `voteCount: Int`, `reviews: AppendedReviews?`, `videos: AppendedVideos?`, `images: AppendedImages?`, `credits: AppendedCredits?`, `recommendations: AppendedRecommendations?`, `similar: PopularMoviesResponse?`, `translations: AppendedTranslations?` |
| `MovieCollection` | [Sources/TMDBKit/Model/MovieCollection.swift:10](../../Sources/TMDBKit/Model/MovieCollection.swift#L10) | `id: Int`, `name: String`, `posterPath: String?`, `backdropPath: String?` |
| `MovieFragment` | [Sources/TMDBKit/Model/MovieFragment.swift:11](../../Sources/TMDBKit/Model/MovieFragment.swift#L11) | `posterPath: String?`, `adult: Bool`, `overview: String`, `releaseDate: String?`, `genreIds: [Int]`, `id: Int`, `originalTitle: String`, `originalLanguage: String`, `title: String`, `backdropPath: String?`, `popularity: Double?`, `voteCount: Int`, `video: Bool`, `voteAverage: Double`, `rating: Double?` |
| `Network` | [Sources/TMDBKit/Model/TVDetails.swift:73](../../Sources/TMDBKit/Model/TVDetails.swift#L73) | `name: String`, `id: Int`, `logoPath: String?`, `originCountry: String` |
| `NowPlayingMoviesResponse` | [Sources/TMDBKit/Responses/NowPlayingMoviesResponse.swift:11](../../Sources/TMDBKit/Responses/NowPlayingMoviesResponse.swift#L11) | `dates: TMDBDate`, `page: Int`, `results: [MovieFragment]`, `totalResults: Int`, `totalPages: Int` |
| `PersonCreditsResponse` | [Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift:10](../../Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift#L10) | `cast: [CreditsCast]`, `crew: [CreditsCast]`, `id: Int` |
| `PersonDetailsResponse` | [Sources/TMDBKit/Responses/People/PersonDetailsResponse.swift:10](../../Sources/TMDBKit/Responses/People/PersonDetailsResponse.swift#L10) | `birthday: String?`, `knownForDepartment: String?`, `deathDay: String?`, `id: Int`, `name: String`, `alsoKnownAs: [String]`, `gender: Int`, `biography: String`, `popularity: Double`, `placeOfBirth: String?`, `profilePath: String?`, `adult: Bool`, `imdbId: String?`, `homepage: String?`, `reviews: AppendedReviews?`, `videos: AppendedVideos?`, `images: AppendedImages?`, `credits: AppendedPersonCredits?`, `recommendations: AppendedRecommendations?`, `similar: PopularMoviesResponse?`, `translations: AppendedTranslations?` |
| `PersonImageResponse` | [Sources/TMDBKit/Responses/People/PersonImageResponse.swift:10](../../Sources/TMDBKit/Responses/People/PersonImageResponse.swift#L10) | `id: Int`, `profiles: [Image]` |
| `PersonTranslation` | [Sources/TMDBKit/Model/Translation.swift:25](../../Sources/TMDBKit/Model/Translation.swift#L25) | `data: TranslationData`, `englishName: String`, `iso31661: String`, `iso6391: String`, `name: String` |
| `PersonTranslation.TranslationData` | [Sources/TMDBKit/Model/Translation.swift:26](../../Sources/TMDBKit/Model/Translation.swift#L26) | `biography: String` |
| `PersonTranslationResponse` | [Sources/TMDBKit/Responses/TranslationsResponse.swift:16](../../Sources/TMDBKit/Responses/TranslationsResponse.swift#L16) | `id: Int`, `translations: [PersonTranslation]` |
| `PopularMoviesResponse` | [Sources/TMDBKit/Responses/PopularMoviesResponse.swift:11](../../Sources/TMDBKit/Responses/PopularMoviesResponse.swift#L11) | `page: Int`, `results: [MovieFragment]`, `totalResults: Int`, `totalPages: Int` |
| `PopularPerson` | [Sources/TMDBKit/Responses/People/PersonDetailsResponse.swift:55](../../Sources/TMDBKit/Responses/People/PersonDetailsResponse.swift#L55) | `popularity: Double`, `knownForDepartment: String?`, `gender: Int`, `id: Int`, `profilePath: String?`, `adult: Bool`, `knownFor: [Media]`, `name: String` |
| `PopularPersonResponse` | [Sources/TMDBKit/Responses/People/PersonDetailsResponse.swift:48](../../Sources/TMDBKit/Responses/People/PersonDetailsResponse.swift#L48) | `page: Int`, `totalResults: Int`, `totalPages: Int`, `results: [PopularPerson]` |
| `ProductionCompany` | [Sources/TMDBKit/Model/ProductionCompany.swift:10](../../Sources/TMDBKit/Model/ProductionCompany.swift#L10) | `id: Int`, `name: String`, `logoPath: String?`, `originCountry: String` |
| `ProductionCountry` | [Sources/TMDBKit/Model/ProductionCountry.swift:10](../../Sources/TMDBKit/Model/ProductionCountry.swift#L10) | `iso31661: String`, `name: String` |
| `ProviderResult` | [Sources/TMDBKit/Model/WatchProvider.swift:22](../../Sources/TMDBKit/Model/WatchProvider.swift#L22) | `link: String?`, `buy: [WatchProvider]?`, `rent: [WatchProvider]?`, `flatrate: [WatchProvider]?` |
| `Rating` | [Sources/TMDBKit/Model/Rating.swift:10](../../Sources/TMDBKit/Model/Rating.swift#L10) | `rating: String`, `iso31661: String` |
| `RecommendationNetwork` | [Sources/TMDBKit/Model/TVDetails.swift:80](../../Sources/TMDBKit/Model/TVDetails.swift#L80) | `name: String`, `id: Int`, `logo: Logo?`, `originCountry: String` |
| `RecommendationNetwork.Logo` | [Sources/TMDBKit/Model/TVDetails.swift:81](../../Sources/TMDBKit/Model/TVDetails.swift#L81) | `path: String`, `aspectRatio: Double` |
| `RecommendationsResponse` | [Sources/TMDBKit/Responses/TV/RecommendationsResponse.swift:10](../../Sources/TMDBKit/Responses/TV/RecommendationsResponse.swift#L10) | `page: Int`, `results: [Result]`, `totalPages: Int`, `totalResults: Int` |
| `RecommendationsResponse.Result` | [Sources/TMDBKit/Responses/TV/RecommendationsResponse.swift:11](../../Sources/TMDBKit/Responses/TV/RecommendationsResponse.swift#L11) | `backdropPath: String`, `firstAirDate: String`, `genreIds: [Int]`, `id: Int`, `name: String`, `originCountry: [String]`, `originalLanguage: String`, `originalName: String`, `overview: String`, `posterPath: String`, `voteAverage: Double`, `voteCount: Int`, `networks: [RecommendationNetwork]`, `popularity: Double` |
| `ReleaseDate` | [Sources/TMDBKit/Model/ReleaseDate.swift:10](../../Sources/TMDBKit/Model/ReleaseDate.swift#L10) | `certification: String`, `iso6391: String`, `releaseDate: String`, `type: Int`, `note: String?` |
| `ReleaseDateResult` | [Sources/TMDBKit/Model/ReleaseDateResult.swift:10](../../Sources/TMDBKit/Model/ReleaseDateResult.swift#L10) | `iso31661: String`, `releaseDates: [ReleaseDate]` |
| `ReleaseDatesResponse` | [Sources/TMDBKit/Responses/ReleaseDatesResponse.swift:11](../../Sources/TMDBKit/Responses/ReleaseDatesResponse.swift#L11) | `id: Int`, `results: [ReleaseDateResult]` |
| `RequestToken` | [Sources/TMDBKit/Networking/APIClient/TMDB.swift:21](../../Sources/TMDBKit/Networking/APIClient/TMDB.swift#L21) | `success: Bool`, `expiresAt: String`, `requestToken: String` |
| `Results` | [Sources/TMDBKit/Model/WatchProvider.swift:29](../../Sources/TMDBKit/Model/WatchProvider.swift#L29) | `ar: ProviderResult?`, `at: ProviderResult?`, `au: ProviderResult?`, `be: ProviderResult?`, `bg: ProviderResult?`, `bo: ProviderResult?`, `br: ProviderResult?`, `ca: ProviderResult?`, `ch: ProviderResult?`, `cl: ProviderResult?`, `co: ProviderResult?`, `cr: ProviderResult?`, `cz: ProviderResult?`, `de: ProviderResult?`, `dk: ProviderResult?`, `ec: ProviderResult?`, `ee: ProviderResult?`, `es: ProviderResult?`, `fi: ProviderResult?`, `fr: ProviderResult?`, `gb: ProviderResult?`, `gr: ProviderResult?`, `gt: ProviderResult?`, `hk: ProviderResult?`, `hn: ProviderResult?`, `hu: ProviderResult?`, `id: ProviderResult?`, `ie: ProviderResult?`, `iN: ProviderResult?`, `it: ProviderResult?`, `jp: ProviderResult?`, `kr: ProviderResult?`, `lt: ProviderResult?`, `lv: ProviderResult?`, `mx: ProviderResult?`, `my: ProviderResult?`, `nl: ProviderResult?`, `no: ProviderResult?`, `nz: ProviderResult?`, `pe: ProviderResult?`, `ph: ProviderResult?`, `pl: ProviderResult?`, `pt: ProviderResult?`, `py: ProviderResult?`, `ro: ProviderResult?`, `ru: ProviderResult?`, `se: ProviderResult?`, `sg: ProviderResult?`, `th: ProviderResult?`, `tr: ProviderResult?`, `us: ProviderResult?`, `ve: ProviderResult?`, `za: ProviderResult?` |
| `Review` | [Sources/TMDBKit/Model/Review.swift:10](../../Sources/TMDBKit/Model/Review.swift#L10) | `id: String`, `author: String`, `authorDetails: AuthorDetails`, `content: String`, `createdAt: String`, `updatedAt: String`, `url: String` |
| `Review.AuthorDetails` | [Sources/TMDBKit/Model/Review.swift:11](../../Sources/TMDBKit/Model/Review.swift#L11) | `avatarPath: String?`, `name: String`, `rating: Double?` |
| `ReviewsResponse` | [Sources/TMDBKit/Responses/ReviewsResponse.swift:13](../../Sources/TMDBKit/Responses/ReviewsResponse.swift#L13) | `id: Int`, `page: Int`, `results: [Review]`, `totalPages: Int`, `totalResults: Int` |
| `ScreenedTheatricallyResponse` | [Sources/TMDBKit/Responses/TV/ScreenedTheatricallyResponse.swift:10](../../Sources/TMDBKit/Responses/TV/ScreenedTheatricallyResponse.swift#L10) | `id: Int`, `results: [Result]` |
| `ScreenedTheatricallyResponse.Result` | [Sources/TMDBKit/Responses/TV/ScreenedTheatricallyResponse.swift:11](../../Sources/TMDBKit/Responses/TV/ScreenedTheatricallyResponse.swift#L11) | `id: Int`, `episodeNumber: Int`, `seasonNumber: Int` |
| `Season` | [Sources/TMDBKit/Model/TVDetails.swift:94](../../Sources/TMDBKit/Model/TVDetails.swift#L94) | `airDate: String?`, `episodeCount: Int`, `id: Int`, `name: String`, `overview: String`, `posterPath: String?`, `seasonNumber: Int` |
| `Session` | [Sources/TMDBKit/Networking/APIClient/TMDB.swift:27](../../Sources/TMDBKit/Networking/APIClient/TMDB.swift#L27) | `success: Bool`, `sessionId: String` |
| `SimilarShowsResponse` | [Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift:10](../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift#L10) | `page: Int`, `results: [TVShowFragment]`, `totalPages: Int`, `totalResults: Int` |
| `StatusResponse` | [Sources/TMDBKit/Networking/APIClient/TMDB.swift:36](../../Sources/TMDBKit/Networking/APIClient/TMDB.swift#L36) | `statusCode: Int`, `statusMessage: String` |
| `SuccessResponse` | [Sources/TMDBKit/Networking/APIClient/TMDB.swift:32](../../Sources/TMDBKit/Networking/APIClient/TMDB.swift#L32) | `success: Bool?` |
| `TMDBDate` | [Sources/TMDBKit/Model/TMDBDate.swift:10](../../Sources/TMDBKit/Model/TMDBDate.swift#L10) | `maximum: String`, `minimum: String` |
| `TVCast` | [Sources/TMDBKit/Model/Cast.swift:24](../../Sources/TMDBKit/Model/Cast.swift#L24) | `adult: Bool`, `character: String`, `creditId: String`, `gender: Int`, `id: Int`, `knownForDepartment: String`, `name: String`, `originalName: String`, `order: Int`, `popularity: Double`, `profilePath: String?` |
| `TVChange` | [Sources/TMDBKit/Model/Change.swift:24](../../Sources/TMDBKit/Model/Change.swift#L24) | `key: String`, `items: [Item]` |
| `TVChange.Item` | [Sources/TMDBKit/Model/Change.swift:25](../../Sources/TMDBKit/Model/Change.swift#L25) | `id: String`, `action: String`, `time: String`, `iso6391: String`, `iso31661: String`, `value: Value`, `originalValue: Value` |
| `TVChange.Item.Value` | [Sources/TMDBKit/Model/Change.swift:26](../../Sources/TMDBKit/Model/Change.swift#L26) | `poster: Poster` |
| `TVChange.Item.Value.Poster` | [Sources/TMDBKit/Model/Change.swift:27](../../Sources/TMDBKit/Model/Change.swift#L27) | `filePath: String`, `iso6391: String?` |
| `TVChangesResponse` | [Sources/TMDBKit/Responses/ChangesResponse.swift:17](../../Sources/TMDBKit/Responses/ChangesResponse.swift#L17) | `items: [TVChange]?` |
| `TVCreditsResponse` | [Sources/TMDBKit/Responses/CreditsResponse.swift:19](../../Sources/TMDBKit/Responses/CreditsResponse.swift#L19) | `id: Int`, `cast: [TVCast]`, `crew: [Crew]` |
| `TVDetails` | [Sources/TMDBKit/Model/TVDetails.swift:10](../../Sources/TMDBKit/Model/TVDetails.swift#L10) | `backdropPath: String?`, `createdBy: [CreatedBy]`, `episodeRunTime: [Int]`, `firstAirDate: String?`, `genres: [Genre]`, `homepage: String`, `id: Int`, `inProduction: Bool`, `languages: [String]`, `lastAirDate: String`, `lastEpisodeToAir: LastEpisodeToAir?`, `name: String`, `nextEpisodeToAir: LastEpisodeToAir?`, `networks: [Network]`, `numberOfEpisodes: Int`, `numberOfSeasons: Int`, `originCountry: [String]`, `originalLanguage: String`, `originalName: String`, `overview: String`, `popularity: Double`, `posterPath: String?`, `productionCompanies: [Network]`, `seasons: [Season]`, `status: String`, `type: String`, `voteAverage: Double`, `voteCount: Int`, `reviews: AppendedReviews?`, `videos: AppendedVideos?`, `images: AppendedImages?` |
| `TVEndpoints` | [Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift:10](../../Sources/TMDBKit/Networking/APIClient/TMDB+TV.swift#L10) |  |
| `TVKeywordsResponse` | [Sources/TMDBKit/Responses/KeywordsResponse.swift:18](../../Sources/TMDBKit/Responses/KeywordsResponse.swift#L18) | `id: Int`, `results: [Keyword]` |
| `TVMedia` | [Sources/TMDBKit/Model/Media.swift:46](../../Sources/TMDBKit/Model/Media.swift#L46) | `posterPath: String?`, `popularity: Double?`, `id: Int`, `backdropPath: String?`, `voteAverage: Double`, `overview: String`, `firstAirDate: String`, `originCountry: [String]`, `genreIds: [Int]`, `originalLanguage: String`, `voteCount: Int`, `name: String`, `originalName: String` |
| `TVShowFragment` | [Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift:17](../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift#L17) | `originalName: String`, `id: Int`, `name: String`, `voteCount: Int`, `voteAverage: Double`, `firstAirDate: String`, `posterPath: String?`, `genreIds: [Int]`, `originalLanguage: String`, `backdropPath: String?`, `overview: String`, `originCountry: [String]`, `popularity: Double` |
| `TaggedImageResponse` | [Sources/TMDBKit/Responses/People/TaggedImageResponse.swift:10](../../Sources/TMDBKit/Responses/People/TaggedImageResponse.swift#L10) | `id: Int`, `page: Int`, `totalResults: Int`, `results: [Result]`, `totalPages: Int` |
| `TaggedImageResponse.Result` | [Sources/TMDBKit/Responses/People/TaggedImageResponse.swift:11](../../Sources/TMDBKit/Responses/People/TaggedImageResponse.swift#L11) | `iso6391: String?`, `voteCount: Int`, `mediaType: MediaType`, `filePath: String`, `aspectRatio: Double`, `media: Media`, `height: Int`, `voteAverage: Double`, `width: Int` |
| `Translation` | [Sources/TMDBKit/Model/Translation.swift:10](../../Sources/TMDBKit/Model/Translation.swift#L10) | `data: TranslationData`, `englishName: String`, `iso31661: String`, `iso6391: String`, `name: String` |
| `Translation.TranslationData` | [Sources/TMDBKit/Model/Translation.swift:11](../../Sources/TMDBKit/Model/Translation.swift#L11) | `title: String?`, `overview: String`, `homepage: String`, `name: String?` |
| `TranslationsResponse` | [Sources/TMDBKit/Responses/TranslationsResponse.swift:11](../../Sources/TMDBKit/Responses/TranslationsResponse.swift#L11) | `id: Int`, `translations: [Translation]` |
| `TrendingEndpoints` | [Sources/TMDBKit/Networking/APIClient/TMDB+Trending.swift:10](../../Sources/TMDBKit/Networking/APIClient/TMDB+Trending.swift#L10) |  |
| `TrendingResponse` | [Sources/TMDBKit/Responses/TrendingResponse.swift:10](../../Sources/TMDBKit/Responses/TrendingResponse.swift#L10) | `page: Int`, `totalPages: Int`, `totalResults: Int`, `results: [Media]` |
| `Video` | [Sources/TMDBKit/Model/Video.swift:10](../../Sources/TMDBKit/Model/Video.swift#L10) | `id: String`, `iso31661: String`, `iso6391: String`, `key: String`, `name: String`, `site: String`, `size: Int`, `type: String` |
| `VideosResponse` | [Sources/TMDBKit/Responses/VideosResponse.swift:13](../../Sources/TMDBKit/Responses/VideosResponse.swift#L13) | `id: Int`, `results: [Video]` |
| `WatchProvider` | [Sources/TMDBKit/Model/WatchProvider.swift:15](../../Sources/TMDBKit/Model/WatchProvider.swift#L15) | `displayPriority: Int`, `logoPath: String`, `providerId: Int`, `providerName: String` |
| `WatchProviderResponse` | [Sources/TMDBKit/Model/WatchProvider.swift:10](../../Sources/TMDBKit/Model/WatchProvider.swift#L10) | `id: Int`, `results: Results?` |

## Official-example decoder probe

Compiled the existing Sources Swift files with a temporary /tmp/main.swift (no repository source edits), using the package JSONDecoder.convertFromSnakeCase policy, and decoded all 85 successful examples mapped to public responses. **79 decoded, 6 failed.** Passing only means the example decodes; TVChangesResponse passing while discarding changes is a demonstrated reason to assert values.

| operationId | Result | Assignment |
| --- | --- | --- |
| list-check-item-status | DecodingError.typeMismatch: expected value of type String. Path: id. Debug description: Expected to decode String but found number instead. | 7A, 7E, 7H, 7E |
| movie-changes | DecodingError.typeMismatch: expected value of type String. Path: changes[0].items[0].value. Debug description: Expected to decode String but found a dictionary instead. | 5, 7B, 7B, 7B, 7B |
| movie-recommendations | DecodingError.keyNotFound: Key 'page' not found in keyed decoding container. Debug description: No value associated with key CodingKeys(stringValue: "page", intValue: nil) ("page"). | 7K |
| person-changes | DecodingError.keyNotFound: Key 'originalValue' not found in keyed decoding container. Path: changes[0].items[0]. Debug description: No value associated with key CodingKeys(stringValue: "originalValue", intValue: nil) ("originalValue"). | 5, 7B, 7B, 7B |
| person-tagged-images | DecodingError.dataCorrupted: Data was corrupted. Path: results[10].mediaType. Debug description: Cannot initialize MediaType from invalid String value episode | 7A, 7F, 7K, 7F, 7F |
| tv-series-recommendations | DecodingError.keyNotFound: Key 'networks' not found in keyed decoding container. Path: results[0]. Debug description: No value associated with key CodingKeys(stringValue: "networks", intValue: nil) ("networks"). | 7D, 7D, 7D, 7D |

Movie recommendations failure is an upstream incomplete-example gap. The other five expose concrete current decoding failures. Details/append failures and dropped fields are recorded separately and need named regression assertions, even when the example probe passes. The probe is supporting evidence, not the test suite.

## Completeness checks and known limits

- One unique normalized METHOD/path key per all 152 pinned operations; 148 unique path objects; no duplicate keys.
- All 82 public network methods in the eight APIClient files are traced; updateAuthenticator/cache utility methods do not initiate endpoint operations and are excluded from that count.
- All current Endpoint enums and all nonconforming TV declaration enums inspected; three local-only route mismatches plus generic trending expansion listed separately.
- All confirmed discrepancies and response-field omissions above have explicit Task 2–7K assignments. Baseline JSON-equality defects have Task 1A; missing request/failure assertions have Tasks 8/9, not a fabricated runtime fix.
- Run `python3 docs/api/verify-audit.py` to verify the contract hash, exact operation denominator, source signatures, named tests, and repair references. The JSON companion has complete nested schema-field inventories, including operations without public methods.
- No endpoint-family additions, credentials, live API mutation, runtime edit, dependency change, branch change, push, or global-settings change is part of Task 1.
