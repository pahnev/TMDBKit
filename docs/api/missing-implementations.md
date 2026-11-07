# Missing public TMDB v3 APIs

Final source: `e8e91849edd65c5adfabbf2969ce4e3920b652dc`. The pinned [contract](spec/README.md) has **152 operations / 148 paths**: **85 public** (84 supported + 1 deprecated) and **67 without a public API** (66 supported + 1 deprecated). The 67 entries below are exhaustive for that pinned snapshot, not a claim about future TMDB additions. [Final machine-readable inventory](final-api-inventory.json) reconciles every operation; [historical audit](implemented-api-audit.md) retains initial findings. A fixture, model or internal enum alone does not count as a usable public API.

Supported missing statuses: **40 absent, 18 declaration-only, 8 internal-only**. The deprecated keyword movie listing is separate. `internal-only` means an Endpoint implementation exists without a public wrapper (review details is also broken); `declaration-only` means an enum case exists without Endpoint conformance, URL/body construction or a public wrapper. No operations are inferred removed from absence in this pinned source.

## Recommended follow-up order

This is an implementation recommendation, not a user-approved schedule. Prepare a **separate future implementation plan for each family** below; these entries are a backlog, not authorization to implement it in this refresh. S/M/L are relative sizes, not elapsed-time estimates. Every plan should first settle its response schema/auth evidence, then add callback APIs with independent offline wire/model/error tests. Existing model candidates below may supply leaves only; verify nested schemas before reuse. Historical fixtures are test inputs requiring provenance review, not current contract guarantees.

| Priority | Families | Relative size / dependencies |
| --- | --- | --- |
| P1 | Configuration; Genres | M / S; shared response and locale prerequisites |
| P2 | Search; Discover; Find; Watch Providers | M / L / M / M; shared media and configuration/genre/region types |
| P3 | TV; TV Seasons; TV Episodes; TV Episode Groups | S / L / L / M; identifiers, hierarchy leaves, then session and mutation handling |
| P4 | Authentication; Certifications; Changes; Collections; Companies; Credits; Guest Sessions; Keywords; Networks; Reviews | S–M per family; metadata envelopes and explicit auth flows |

The TV family is partial only because series lists remain missing. The other partial families are Authentication and Search. Account, Lists, Movies, Trending and supported People operations have no supported missing operations; [README](../../README.md) gives the full family counts. Per-title movie/TV provider availability is already exposed; catalog/region operations remain missing.

## Supported missing operations

### Authentication

Proposed public group: `AuthenticationEndpoints`. P4, relative size M. Dependencies: Review authentication guides and token lifetimes; keep application credentials separate from resulting user/guest tokens.

#### `GET /3/authentication`

- Operation: [authentication-validate-key](https://developer.themoviedb.org/reference/authentication-validate-key); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [TMDB.swift](<../../Sources/TMDBKit/Networking/APIClient/TMDB.swift>); fixtures none; use pinned example or explicitly labeled boundary fixture.
- Response work: proposed `AuthenticationValidateKeyResponse`; typed response envelope: success, status_code, status_message; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `AuthenticationEndpoints`, P4/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify documented path and parameter omission. Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/authentication/guest_session/new`

- Operation: [authentication-create-guest-session](https://developer.themoviedb.org/reference/authentication-create-guest-session); status **internal-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [Authentication.createQuestSession](<../../Sources/TMDBKit/Networking/Endpoints/Authentication.swift>); candidate model files [TMDB.swift](<../../Sources/TMDBKit/Networking/APIClient/TMDB.swift>); fixtures [v3_authentication_guest_session_new.json](<../../Tests/TMDBKitTests/Fixtures/Authentication/v3_authentication_guest_session_new.json>).
- Response work: proposed `AuthenticationCreateGuestSessionResponse`; typed response envelope: success, guest_session_id, expires_at; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `AuthenticationEndpoints`, P4/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify documented path and parameter omission. Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `POST /3/authentication/session/convert/4`

- Operation: [authentication-create-session-from-v4-token](https://developer.themoviedb.org/reference/authentication-create-session-from-v4-token); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [TMDB.swift](<../../Sources/TMDBKit/Networking/APIClient/TMDB.swift>); fixtures none; use pinned example or explicitly labeled boundary fixture.
- Response work: proposed `AuthenticationCreateSessionFromV4TokenResponse`; typed response envelope: success, session_id; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential plus v4 access_token in body; v3 conversion route only, no v4 API client.
- Group/order/dependencies: `AuthenticationEndpoints`, P4/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify documented path and parameter omission. Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and POST/DELETE body/header, no cache reads/writes. Pinned request schema uses a RAW_BODY placeholder; example body keys are access_token. Reconcile request guide/schema before choosing requiredness.

#### `POST /3/authentication/token/validate_with_login`

- Operation: [authentication-create-session-from-login](https://developer.themoviedb.org/reference/authentication-create-session-from-login); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [TMDB.swift](<../../Sources/TMDBKit/Networking/APIClient/TMDB.swift>); fixtures none; use pinned example or explicitly labeled boundary fixture.
- Response work: proposed `AuthenticationCreateSessionFromLoginResponse`; typed response envelope: success, expires_at, request_token; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential plus username/password/request_token body; review login workflow before exposure.
- Group/order/dependencies: `AuthenticationEndpoints`, P4/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify documented path and parameter omission. Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and POST/DELETE body/header, no cache reads/writes. Pinned request schema uses a RAW_BODY placeholder; example body keys are access_token. Reconcile request guide/schema before choosing requiredness.

### Certifications

Proposed public group: `CertificationsEndpoints`. P4, relative size S. Dependencies: Add country-keyed certification descriptor envelope; no prerequisite beyond application auth.

#### `GET /3/certification/movie/list`

- Operation: [certification-movie-list](https://developer.themoviedb.org/reference/certification-movie-list); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files none; fixtures [v3_certification_movie_list.json](<../../Tests/TMDBKitTests/Fixtures/Certifications/v3_certification_movie_list.json>).
- Response work: proposed `CertificationMovieListResponse`; typed response envelope: certifications; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `CertificationsEndpoints`, P4/S; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify documented path and parameter omission. Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/certification/tv/list`

- Operation: [certifications-tv-list](https://developer.themoviedb.org/reference/certifications-tv-list); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files none; fixtures [v3_certification_tv_list.json](<../../Tests/TMDBKitTests/Fixtures/Certifications/v3_certification_tv_list.json>).
- Response work: proposed `CertificationsTvListResponse`; typed response envelope: certifications; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `CertificationsEndpoints`, P4/S; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify documented path and parameter omission. Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

### Changes

Proposed public group: `ChangesEndpoints`. P4, relative size M. Dependencies: Add paginated changed-ID/adult rows; per-resource change-value models are different envelopes.

#### `GET /3/movie/changes`

- Operation: [changes-movie-list](https://developer.themoviedb.org/reference/changes-movie-list); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [ChangeValue.swift](<../../Sources/TMDBKit/Model/ChangeValue.swift>); fixtures [v3_movie_changes.json](<../../Tests/TMDBKitTests/Fixtures/Changes/v3_movie_changes.json>).
- Response work: proposed `ChangesMovieListResponse`; typed response envelope: results, page, total_pages, total_results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `ChangesEndpoints`, P4/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify end_date (optional), page (optional), start_date (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/person/changes`

- Operation: [changes-people-list](https://developer.themoviedb.org/reference/changes-people-list); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [ChangeValue.swift](<../../Sources/TMDBKit/Model/ChangeValue.swift>); fixtures [v3_person_changes.json](<../../Tests/TMDBKitTests/Fixtures/Changes/v3_person_changes.json>), [v3_person_changes.json](<../../Tests/TMDBKitTests/Fixtures/People/v3_person_changes.json>).
- Response work: proposed `ChangesPeopleListResponse`; typed response envelope: results, page, total_pages, total_results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `ChangesEndpoints`, P4/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify end_date (optional), page (optional), start_date (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/tv/changes`

- Operation: [changes-tv-list](https://developer.themoviedb.org/reference/changes-tv-list); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [ChangeValue.swift](<../../Sources/TMDBKit/Model/ChangeValue.swift>); fixtures [v3_tv_changes.json](<../../Tests/TMDBKitTests/Fixtures/Changes/v3_tv_changes.json>), [v3_tv_changes.json](<../../Tests/TMDBKitTests/Fixtures/TV/v3_tv_changes.json>).
- Response work: proposed `ChangesTvListResponse`; typed response envelope: results, page, total_pages, total_results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `ChangesEndpoints`, P4/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify end_date (optional), page (optional), start_date (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

### Collections

Proposed public group: `CollectionsEndpoints`. P4, relative size M. Dependencies: Complete collection details/parts, images and translation envelopes; reuse only compatible leaf models.

#### `GET /3/collection/{collection_id}`

- Operation: [collection-details](https://developer.themoviedb.org/reference/collection-details); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [MovieCollection.swift](<../../Sources/TMDBKit/Model/MovieCollection.swift>), [MovieFragment.swift](<../../Sources/TMDBKit/Model/MovieFragment.swift>), [ImagesResponse.swift](<../../Sources/TMDBKit/Responses/ImagesResponse.swift>), [TranslationsResponse.swift](<../../Sources/TMDBKit/Responses/TranslationsResponse.swift>); fixtures [v3_collection_529892.json](<../../Tests/TMDBKitTests/Fixtures/Collections/v3_collection_529892.json>).
- Response work: proposed `CollectionDetailsResponse`; typed response envelope: id, name, original_language, original_name, overview, poster_path, backdrop_path, parts; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `CollectionsEndpoints`, P4/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify collection_id (required), language (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/collection/{collection_id}/images`

- Operation: [collection-images](https://developer.themoviedb.org/reference/collection-images); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [MovieCollection.swift](<../../Sources/TMDBKit/Model/MovieCollection.swift>), [MovieFragment.swift](<../../Sources/TMDBKit/Model/MovieFragment.swift>), [ImagesResponse.swift](<../../Sources/TMDBKit/Responses/ImagesResponse.swift>), [TranslationsResponse.swift](<../../Sources/TMDBKit/Responses/TranslationsResponse.swift>); fixtures [v3_collection_529892_images.json](<../../Tests/TMDBKitTests/Fixtures/Collections/v3_collection_529892_images.json>).
- Response work: proposed `CollectionImagesResponse`; typed response envelope: id, backdrops, posters; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `CollectionsEndpoints`, P4/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify collection_id (required), include_image_language (optional), language (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/collection/{collection_id}/translations`

- Operation: [collection-translations](https://developer.themoviedb.org/reference/collection-translations); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [MovieCollection.swift](<../../Sources/TMDBKit/Model/MovieCollection.swift>), [MovieFragment.swift](<../../Sources/TMDBKit/Model/MovieFragment.swift>), [ImagesResponse.swift](<../../Sources/TMDBKit/Responses/ImagesResponse.swift>), [TranslationsResponse.swift](<../../Sources/TMDBKit/Responses/TranslationsResponse.swift>); fixtures [v3_collection_529892_translations.json](<../../Tests/TMDBKitTests/Fixtures/Collections/v3_collection_529892_translations.json>).
- Response work: proposed `CollectionTranslationsResponse`; typed response envelope: id, translations; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `CollectionsEndpoints`, P4/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify collection_id (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

### Companies

Proposed public group: `CompaniesEndpoints`. P4, relative size M. Dependencies: Add company details including parent-company shape, alternate-name rows and logo envelope.

#### `GET /3/company/{company_id}`

- Operation: [company-details](https://developer.themoviedb.org/reference/company-details); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [ProductionCompany.swift](<../../Sources/TMDBKit/Model/ProductionCompany.swift>), [Poster.swift](<../../Sources/TMDBKit/Model/Poster.swift>); fixtures [v3_company_3_details.json](<../../Tests/TMDBKitTests/Fixtures/Companies/v3_company_3_details.json>).
- Response work: proposed `CompanyDetailsResponse`; typed response envelope: description, headquarters, homepage, id, logo_path, name, origin_country, parent_company; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `CompaniesEndpoints`, P4/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify company_id (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/company/{company_id}/alternative_names`

- Operation: [company-alternative-names](https://developer.themoviedb.org/reference/company-alternative-names); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [ProductionCompany.swift](<../../Sources/TMDBKit/Model/ProductionCompany.swift>), [Poster.swift](<../../Sources/TMDBKit/Model/Poster.swift>); fixtures [v3_company_3_alternative_names.json](<../../Tests/TMDBKitTests/Fixtures/Companies/v3_company_3_alternative_names.json>).
- Response work: proposed `CompanyAlternativeNamesResponse`; typed response envelope: id, results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `CompaniesEndpoints`, P4/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify company_id (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/company/{company_id}/images`

- Operation: [company-images](https://developer.themoviedb.org/reference/company-images); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [ProductionCompany.swift](<../../Sources/TMDBKit/Model/ProductionCompany.swift>), [Poster.swift](<../../Sources/TMDBKit/Model/Poster.swift>); fixtures [v3_company_3_images.json](<../../Tests/TMDBKitTests/Fixtures/Companies/v3_company_3_images.json>).
- Response work: proposed `CompanyImagesResponse`; typed response envelope: id, logos; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `CompaniesEndpoints`, P4/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify company_id (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

### Configuration

Proposed public group: `ConfigurationEndpoints`. P1, relative size M. Dependencies: Add image configuration and country/job/language/timezone/translation list envelopes; settle unspecified schemas first.

#### `GET /3/configuration`

- Operation: [configuration-details](https://developer.themoviedb.org/reference/configuration-details); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [Language.swift](<../../Sources/TMDBKit/Model/Language.swift>), [ProductionCountry.swift](<../../Sources/TMDBKit/Model/ProductionCountry.swift>); fixtures [v3_configuration.json](<../../Tests/TMDBKitTests/Fixtures/Configuration/v3_configuration.json>).
- Response work: proposed `ConfigurationDetailsResponse`; typed response envelope: images, change_keys; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `ConfigurationEndpoints`, P1/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify documented path and parameter omission. Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/configuration/countries`

- Operation: [configuration-countries](https://developer.themoviedb.org/reference/configuration-countries); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [Language.swift](<../../Sources/TMDBKit/Model/Language.swift>), [ProductionCountry.swift](<../../Sources/TMDBKit/Model/ProductionCountry.swift>); fixtures [v3_configuration_countries.json](<../../Tests/TMDBKitTests/Fixtures/Configuration/v3_configuration_countries.json>).
- Response work: proposed `ConfigurationCountriesResponse`; country array with ISO codes and names (inspect item schema).
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `ConfigurationEndpoints`, P1/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify language (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/configuration/jobs`

- Operation: [configuration-jobs](https://developer.themoviedb.org/reference/configuration-jobs); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [Language.swift](<../../Sources/TMDBKit/Model/Language.swift>), [ProductionCountry.swift](<../../Sources/TMDBKit/Model/ProductionCountry.swift>); fixtures [v3_configuration_jobs.json](<../../Tests/TMDBKitTests/Fixtures/Configuration/v3_configuration_jobs.json>).
- Response work: proposed `ConfigurationJobsResponse`; department/jobs array (inspect item schema).
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `ConfigurationEndpoints`, P1/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify documented path and parameter omission. Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/configuration/languages`

- Operation: [configuration-languages](https://developer.themoviedb.org/reference/configuration-languages); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [Language.swift](<../../Sources/TMDBKit/Model/Language.swift>), [ProductionCountry.swift](<../../Sources/TMDBKit/Model/ProductionCountry.swift>); fixtures [v3_configuration_languages.json](<../../Tests/TMDBKitTests/Fixtures/Configuration/v3_configuration_languages.json>).
- Response work: proposed `ConfigurationLanguagesResponse`; language array with ISO code/English/native names.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `ConfigurationEndpoints`, P1/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify documented path and parameter omission. Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/configuration/primary_translations`

- Operation: [configuration-primary-translations](https://developer.themoviedb.org/reference/configuration-primary-translations); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [Language.swift](<../../Sources/TMDBKit/Model/Language.swift>), [ProductionCountry.swift](<../../Sources/TMDBKit/Model/ProductionCountry.swift>); fixtures [v3_configuration_primary_translations.json](<../../Tests/TMDBKitTests/Fixtures/Configuration/v3_configuration_primary_translations.json>).
- Response work: proposed `ConfigurationPrimaryTranslationsResponse`; array of locale strings.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `ConfigurationEndpoints`, P1/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify documented path and parameter omission. Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/configuration/timezones`

- Operation: [configuration-timezones](https://developer.themoviedb.org/reference/configuration-timezones); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [Language.swift](<../../Sources/TMDBKit/Model/Language.swift>), [ProductionCountry.swift](<../../Sources/TMDBKit/Model/ProductionCountry.swift>); fixtures [v3_configuration_timezones.json](<../../Tests/TMDBKitTests/Fixtures/Configuration/v3_configuration_timezones.json>).
- Response work: proposed `ConfigurationTimezonesResponse`; country/timezone array (inspect item schema).
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `ConfigurationEndpoints`, P1/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify documented path and parameter omission. Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

### Credits

Proposed public group: `CreditsEndpoints`. P4, relative size M. Dependencies: Add credit lookup envelope with typed media/person data and string credit identity.

#### `GET /3/credit/{credit_id}`

- Operation: [credit-details](https://developer.themoviedb.org/reference/credit-details); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [PersonCreditsResponse.swift](<../../Sources/TMDBKit/Responses/People/PersonCreditsResponse.swift>), [Media.swift](<../../Sources/TMDBKit/Model/Media.swift>); fixtures [v3_credit_5256bdc319c2956ff600157c.json](<../../Tests/TMDBKitTests/Fixtures/Credits/v3_credit_5256bdc319c2956ff600157c.json>).
- Response work: proposed `CreditDetailsResponse`; typed response envelope: credit_type, department, job, media, media_type, id, person; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `CreditsEndpoints`, P4/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify credit_id (required), language (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

### Discover

Proposed public group: `DiscoverEndpoints`. P2, relative size L. Dependencies: Configuration/Genres and shared media envelopes first; model endpoint-specific filter options and delimiters.

#### `GET /3/discover/movie`

- Operation: [discover-movie](https://developer.themoviedb.org/reference/discover-movie); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [PopularMoviesResponse.swift](<../../Sources/TMDBKit/Responses/PopularMoviesResponse.swift>), [SimilarShowsResponse.swift](<../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift>); fixtures [v3_discover_movie.json](<../../Tests/TMDBKitTests/Fixtures/Discover/v3_discover_movie.json>).
- Response work: proposed `DiscoverMovieResponse`; typed response envelope: page, results, total_pages, total_results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `DiscoverEndpoints`, P2/L; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify certification (optional), certification.gte (optional), certification.lte (optional), certification_country (optional), include_adult (optional), include_video (optional), language (optional), page (optional), primary_release_year (optional), primary_release_date.gte (optional), primary_release_date.lte (optional), region (optional), release_date.gte (optional), release_date.lte (optional), sort_by (optional), vote_average.gte (optional), vote_average.lte (optional), vote_count.gte (optional), vote_count.lte (optional), watch_region (optional), with_cast (optional), with_companies (optional), with_crew (optional), with_genres (optional), with_keywords (optional), with_origin_country (optional), with_original_language (optional), with_people (optional), with_release_type (optional), with_runtime.gte (optional), with_runtime.lte (optional), with_watch_monetization_types (optional), with_watch_providers (optional), without_companies (optional), without_genres (optional), without_keywords (optional), without_watch_providers (optional), year (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/discover/tv`

- Operation: [discover-tv](https://developer.themoviedb.org/reference/discover-tv); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [PopularMoviesResponse.swift](<../../Sources/TMDBKit/Responses/PopularMoviesResponse.swift>), [SimilarShowsResponse.swift](<../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift>); fixtures [v3_discover_tv.json](<../../Tests/TMDBKitTests/Fixtures/Discover/v3_discover_tv.json>).
- Response work: proposed `DiscoverTvResponse`; typed response envelope: page, results, total_pages, total_results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `DiscoverEndpoints`, P2/L; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify air_date.gte (optional), air_date.lte (optional), first_air_date_year (optional), first_air_date.gte (optional), first_air_date.lte (optional), include_adult (optional), include_null_first_air_dates (optional), language (optional), page (optional), screened_theatrically (optional), sort_by (optional), timezone (optional), vote_average.gte (optional), vote_average.lte (optional), vote_count.gte (optional), vote_count.lte (optional), watch_region (optional), with_companies (optional), with_genres (optional), with_keywords (optional), with_networks (optional), with_origin_country (optional), with_original_language (optional), with_runtime.gte (optional), with_runtime.lte (optional), with_status (optional), with_watch_monetization_types (optional), with_watch_providers (optional), without_companies (optional), without_genres (optional), without_keywords (optional), without_watch_providers (optional), with_type (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

### Find

Proposed public group: `FindEndpoints`. P2, relative size M. Dependencies: Shared movie/person/TV fragments and TV hierarchy result models; preserve each result bucket and external_source.

#### `GET /3/find/{external_id}`

- Operation: [find-by-id](https://developer.themoviedb.org/reference/find-by-id); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [MovieFragment.swift](<../../Sources/TMDBKit/Model/MovieFragment.swift>), [Media.swift](<../../Sources/TMDBKit/Model/Media.swift>), [TVDetails.swift](<../../Sources/TMDBKit/Model/TVDetails.swift>); fixtures [v3_find_tt0020629.json](<../../Tests/TMDBKitTests/Fixtures/Find/v3_find_tt0020629.json>).
- Response work: proposed `FindByIdResponse`; typed response envelope: movie_results, person_results, tv_results, tv_episode_results, tv_season_results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `FindEndpoints`, P2/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify external_id (required), external_source (required), language (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

### Genres

Proposed public group: `GenresEndpoints`. P1, relative size S. Dependencies: Wrap existing Genre leaves in a genres envelope; shared configuration language options.

#### `GET /3/genre/movie/list`

- Operation: [genre-movie-list](https://developer.themoviedb.org/reference/genre-movie-list); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [Genre.swift](<../../Sources/TMDBKit/Model/Genre.swift>); fixtures [v3_genre_movie_list.json](<../../Tests/TMDBKitTests/Fixtures/Genres/v3_genre_movie_list.json>).
- Response work: proposed `GenreMovieListResponse`; typed response envelope: genres; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `GenresEndpoints`, P1/S; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify language (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/genre/tv/list`

- Operation: [genre-tv-list](https://developer.themoviedb.org/reference/genre-tv-list); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [Genre.swift](<../../Sources/TMDBKit/Model/Genre.swift>); fixtures [v3_genre_tv_list.json](<../../Tests/TMDBKitTests/Fixtures/Genres/v3_genre_tv_list.json>).
- Response work: proposed `GenreTvListResponse`; typed response envelope: genres; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `GenresEndpoints`, P1/S; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify language (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

### Guest Sessions

Proposed public group: `GuestSessionsEndpoints`. P4, relative size M. Dependencies: Guest-session creation and explicit path credential; preserve rating and pagination fields in all three result families.

#### `GET /3/guest_session/{guest_session_id}/rated/movies`

- Operation: [guest-session-rated-movies](https://developer.themoviedb.org/reference/guest-session-rated-movies); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [PopularMoviesResponse.swift](<../../Sources/TMDBKit/Responses/PopularMoviesResponse.swift>), [SimilarShowsResponse.swift](<../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift>), [EpisodeListResponse.swift](<../../Sources/TMDBKit/Responses/EpisodeListResponse.swift>); fixtures none; use pinned example or explicitly labeled boundary fixture.
- Response work: proposed `GuestSessionRatedMoviesResponse`; typed response envelope: page, results, total_pages, total_results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential plus guest_session_id in path; no user session substitution.
- Group/order/dependencies: `GuestSessionsEndpoints`, P4/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify guest_session_id (required), language (optional), page (optional), sort_by (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/guest_session/{guest_session_id}/rated/tv`

- Operation: [guest-session-rated-tv](https://developer.themoviedb.org/reference/guest-session-rated-tv); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [PopularMoviesResponse.swift](<../../Sources/TMDBKit/Responses/PopularMoviesResponse.swift>), [SimilarShowsResponse.swift](<../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift>), [EpisodeListResponse.swift](<../../Sources/TMDBKit/Responses/EpisodeListResponse.swift>); fixtures none; use pinned example or explicitly labeled boundary fixture.
- Response work: proposed `GuestSessionRatedTvResponse`; typed response envelope: page, results, total_pages, total_results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential plus guest_session_id in path; no user session substitution.
- Group/order/dependencies: `GuestSessionsEndpoints`, P4/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify guest_session_id (required), language (optional), page (optional), sort_by (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/guest_session/{guest_session_id}/rated/tv/episodes`

- Operation: [guest-session-rated-tv-episodes](https://developer.themoviedb.org/reference/guest-session-rated-tv-episodes); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [PopularMoviesResponse.swift](<../../Sources/TMDBKit/Responses/PopularMoviesResponse.swift>), [SimilarShowsResponse.swift](<../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift>), [EpisodeListResponse.swift](<../../Sources/TMDBKit/Responses/EpisodeListResponse.swift>); fixtures none; use pinned example or explicitly labeled boundary fixture.
- Response work: proposed `GuestSessionRatedTvEpisodesResponse`; typed response envelope: page, results, total_pages, total_results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential plus guest_session_id in path; no user session substitution.
- Group/order/dependencies: `GuestSessionsEndpoints`, P4/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify guest_session_id (required), language (optional), page (optional), sort_by (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

### Keywords

Proposed public group: `KeywordsEndpoints`. P4, relative size S. Dependencies: Keyword details wrapper; deprecated movie listing requires separate policy/evidence review.

#### `GET /3/keyword/{keyword_id}`

- Operation: [keyword-details](https://developer.themoviedb.org/reference/keyword-details); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [Keyword.swift](<../../Sources/TMDBKit/Model/Keyword.swift>), [PopularMoviesResponse.swift](<../../Sources/TMDBKit/Responses/PopularMoviesResponse.swift>); fixtures [v3_keyword_192544.json](<../../Tests/TMDBKitTests/Fixtures/Keywords/v3_keyword_192544.json>).
- Response work: proposed `KeywordDetailsResponse`; typed response envelope: id, name; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `KeywordsEndpoints`, P4/S; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify keyword_id (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

### Networks

Proposed public group: `NetworksEndpoints`. P4, relative size M. Dependencies: Network leaf is incomplete for details; add headquarters/homepage, name and logo envelopes.

#### `GET /3/network/{network_id}`

- Operation: [network-details](https://developer.themoviedb.org/reference/network-details); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [TVDetails.swift](<../../Sources/TMDBKit/Model/TVDetails.swift>), [Poster.swift](<../../Sources/TMDBKit/Model/Poster.swift>); fixtures [v3_network_2.json](<../../Tests/TMDBKitTests/Fixtures/Networks/v3_network_2.json>).
- Response work: proposed `NetworkDetailsResponse`; typed response envelope: headquarters, homepage, id, logo_path, name, origin_country; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `NetworksEndpoints`, P4/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify network_id (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/network/{network_id}/alternative_names`

- Operation: [details-copy](https://developer.themoviedb.org/reference/details-copy); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [TVDetails.swift](<../../Sources/TMDBKit/Model/TVDetails.swift>), [Poster.swift](<../../Sources/TMDBKit/Model/Poster.swift>); fixtures [v3_network_2_alternative_names.json](<../../Tests/TMDBKitTests/Fixtures/Networks/v3_network_2_alternative_names.json>).
- Response work: proposed `NetworkAlternativeNamesResponse`; typed response envelope: id, results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `NetworksEndpoints`, P4/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify network_id (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/network/{network_id}/images`

- Operation: [alternative-names-copy](https://developer.themoviedb.org/reference/alternative-names-copy); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [TVDetails.swift](<../../Sources/TMDBKit/Model/TVDetails.swift>), [Poster.swift](<../../Sources/TMDBKit/Model/Poster.swift>); fixtures [v3_network_2_images.json](<../../Tests/TMDBKitTests/Fixtures/Networks/v3_network_2_images.json>).
- Response work: proposed `NetworkImagesResponse`; typed response envelope: id, logos; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `NetworksEndpoints`, P4/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify network_id (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

### Reviews

Proposed public group: `ReviewsEndpoints`. P4, relative size S. Dependencies: Repair malformed internal review route and Int ID to documented string ID before exposing wrapper; add detail-only fields.

#### `GET /3/review/{review_id}`

- Operation: [review-details](https://developer.themoviedb.org/reference/review-details); status **internal-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [Reviews.details](<../../Sources/TMDBKit/Networking/Endpoints/Reviews.swift>); candidate model files [Review.swift](<../../Sources/TMDBKit/Model/Review.swift>); fixtures [v3_review_5d975abdae26be001abe129b.json](<../../Tests/TMDBKitTests/Fixtures/Reviews/v3_review_5d975abdae26be001abe129b.json>).
- Response work: proposed `ReviewDetailsResponse`; typed response envelope: id, author, author_details, content, created_at, iso_639_1, media_id, media_title, media_type, updated_at, url; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `ReviewsEndpoints`, P4/S; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify review_id (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

### Search

Proposed public group: `SearchEndpoints`. P2, relative size M. Dependencies: Shared paginated envelopes and Configuration/Genres first; expose six independent result models and documented query options.

#### `GET /3/search/collection`

- Operation: [search-collection](https://developer.themoviedb.org/reference/search-collection); status **internal-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [Search.collections](<../../Sources/TMDBKit/Networking/Endpoints/Search.swift>); candidate model files [MovieCollection.swift](<../../Sources/TMDBKit/Model/MovieCollection.swift>); fixtures [v3_search_collection.json](<../../Tests/TMDBKitTests/Fixtures/Search/v3_search_collection.json>).
- Response work: proposed `SearchCollectionResponse`; typed response envelope: page, results, total_pages, total_results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `SearchEndpoints`, P2/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify query (required), include_adult (optional), language (optional), page (optional), region (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/search/company`

- Operation: [search-company](https://developer.themoviedb.org/reference/search-company); status **internal-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [Search.companies](<../../Sources/TMDBKit/Networking/Endpoints/Search.swift>); candidate model files [ProductionCompany.swift](<../../Sources/TMDBKit/Model/ProductionCompany.swift>); fixtures [v3_search_company.json](<../../Tests/TMDBKitTests/Fixtures/Search/v3_search_company.json>).
- Response work: proposed `SearchCompanyResponse`; typed response envelope: page, results, total_pages, total_results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `SearchEndpoints`, P2/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify query (required), page (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/search/keyword`

- Operation: [search-keyword](https://developer.themoviedb.org/reference/search-keyword); status **internal-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [Search.keywords](<../../Sources/TMDBKit/Networking/Endpoints/Search.swift>); candidate model files [Keyword.swift](<../../Sources/TMDBKit/Model/Keyword.swift>); fixtures [v3_search_keyword.json](<../../Tests/TMDBKitTests/Fixtures/Search/v3_search_keyword.json>).
- Response work: proposed `SearchKeywordResponse`; typed response envelope: page, results, total_pages, total_results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `SearchEndpoints`, P2/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify query (required), page (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/search/multi`

- Operation: [search-multi](https://developer.themoviedb.org/reference/search-multi); status **internal-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [Search.multiSearch](<../../Sources/TMDBKit/Networking/Endpoints/Search.swift>); candidate model files [Media.swift](<../../Sources/TMDBKit/Model/Media.swift>); fixtures [v3_search_multi.json](<../../Tests/TMDBKitTests/Fixtures/Search/v3_search_multi.json>).
- Response work: proposed `SearchMultiResponse`; typed response envelope: page, results, total_pages, total_results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `SearchEndpoints`, P2/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify query (required), include_adult (optional), language (optional), page (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/search/person`

- Operation: [search-person](https://developer.themoviedb.org/reference/search-person); status **internal-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [Search.people](<../../Sources/TMDBKit/Networking/Endpoints/Search.swift>); candidate model files [PersonDetailsResponse.swift](<../../Sources/TMDBKit/Responses/People/PersonDetailsResponse.swift>); fixtures [v3_search_person.json](<../../Tests/TMDBKitTests/Fixtures/Search/v3_search_person.json>).
- Response work: proposed `SearchPersonResponse`; typed response envelope: page, results, total_pages, total_results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `SearchEndpoints`, P2/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify query (required), include_adult (optional), language (optional), page (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/search/tv`

- Operation: [search-tv](https://developer.themoviedb.org/reference/search-tv); status **internal-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [Search.tvShows](<../../Sources/TMDBKit/Networking/Endpoints/Search.swift>); candidate model files [SimilarShowsResponse.swift](<../../Sources/TMDBKit/Responses/TV/SimilarShowsResponse.swift>); fixtures [v3_search_tv.json](<../../Tests/TMDBKitTests/Fixtures/Search/v3_search_tv.json>).
- Response work: proposed `SearchTvResponse`; typed response envelope: page, results, total_pages, total_results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `SearchEndpoints`, P2/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify query (required), first_air_date_year (optional), include_adult (optional), language (optional), page (optional), year (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

### TV

Proposed public group: `TVEndpoints`. P3, relative size S. Dependencies: Add TV lists envelope; existing ListsResponse is a candidate, verify ID and list row shapes.

#### `GET /3/tv/{series_id}/lists`

- Operation: [lists-copy](https://developer.themoviedb.org/reference/lists-copy); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [ListsResponse.swift](<../../Sources/TMDBKit/Responses/ListsResponse.swift>); fixtures none; use pinned example or explicitly labeled boundary fixture.
- Response work: proposed `TVListsResponse`; typed response envelope: id, page, results, total_pages, total_results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `TVEndpoints`, P3/S; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify series_id (required), language (optional), page (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

### TV Seasons

Proposed public group: `TVSeasonsEndpoints`. P3, relative size L. Dependencies: TV hierarchy identifiers, season/episode leaves and auth selection; declarations lack Endpoint conformance and request construction.

#### `GET /3/tv/{series_id}/season/{season_number}`

- Operation: [tv-season-details](https://developer.themoviedb.org/reference/tv-season-details); status **declaration-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [TVSeasons.details](<../../Sources/TMDBKit/Networking/Endpoints/TVSeasons.swift>); candidate model files [TVDetails.swift](<../../Sources/TMDBKit/Model/TVDetails.swift>); fixtures [v3_tv_1399_season_1.json](<../../Tests/TMDBKitTests/Fixtures/TV Seasons/v3_tv_1399_season_1.json>).
- Response work: proposed `TvSeasonDetailsResponse`; typed response envelope: _id, air_date, episodes, name, networks, overview, id, poster_path, season_number, vote_average; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `TVSeasonsEndpoints`, P3/L; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify series_id (required), season_number (required), append_to_response (optional), language (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/tv/{series_id}/season/{season_number}/account_states`

- Operation: [tv-season-account-states](https://developer.themoviedb.org/reference/tv-season-account-states); status **declaration-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [TVSeasons.accountStates](<../../Sources/TMDBKit/Networking/Endpoints/TVSeasons.swift>); candidate model files [AccountState.swift](<../../Sources/TMDBKit/Model/AccountState.swift>); fixtures [v3_tv_1399_season_1_account_states.json](<../../Tests/TMDBKitTests/Fixtures/TV Seasons/v3_tv_1399_season_1_account_states.json>).
- Response work: proposed `TvSeasonAccountStatesResponse`; typed response envelope: id, results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential plus one documented user session_id or guest_session_id alternative.
- Group/order/dependencies: `TVSeasonsEndpoints`, P3/L; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify series_id (required), session_id (optional), guest_session_id (optional), season_number (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/tv/{series_id}/season/{season_number}/aggregate_credits`

- Operation: [tv-season-aggregate-credits](https://developer.themoviedb.org/reference/tv-season-aggregate-credits); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [CreditsResponse.swift](<../../Sources/TMDBKit/Responses/CreditsResponse.swift>); fixtures none; use pinned example or explicitly labeled boundary fixture.
- Response work: proposed `TvSeasonAggregateCreditsResponse`; typed response envelope: cast, crew, id; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `TVSeasonsEndpoints`, P3/L; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify series_id (required), language (optional), season_number (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/tv/season/{season_id}/changes`

- Operation: [tv-season-changes-by-id](https://developer.themoviedb.org/reference/tv-season-changes-by-id); status **declaration-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [TVSeasons.changes](<../../Sources/TMDBKit/Networking/Endpoints/TVSeasons.swift>); candidate model files [ChangeValue.swift](<../../Sources/TMDBKit/Model/ChangeValue.swift>); fixtures [v3_tv_season_136074_changes.json](<../../Tests/TMDBKitTests/Fixtures/TV Seasons/v3_tv_season_136074_changes.json>).
- Response work: proposed `TvSeasonChangesByIdResponse`; typed response envelope: changes; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `TVSeasonsEndpoints`, P3/L; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify end_date (optional), page (optional), start_date (optional), season_id (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/tv/{series_id}/season/{season_number}/credits`

- Operation: [tv-season-credits](https://developer.themoviedb.org/reference/tv-season-credits); status **declaration-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [TVSeasons.credits](<../../Sources/TMDBKit/Networking/Endpoints/TVSeasons.swift>); candidate model files [CreditsResponse.swift](<../../Sources/TMDBKit/Responses/CreditsResponse.swift>); fixtures [v3_tv_1399_season_1_credits.json](<../../Tests/TMDBKitTests/Fixtures/TV Seasons/v3_tv_1399_season_1_credits.json>).
- Response work: proposed `TvSeasonCreditsResponse`; typed response envelope: cast, crew, id; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `TVSeasonsEndpoints`, P3/L; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify series_id (required), season_number (required), language (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/tv/{series_id}/season/{season_number}/external_ids`

- Operation: [tv-season-external-ids](https://developer.themoviedb.org/reference/tv-season-external-ids); status **declaration-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [TVSeasons.externalIds](<../../Sources/TMDBKit/Networking/Endpoints/TVSeasons.swift>); candidate model files [ExternalIds.swift](<../../Sources/TMDBKit/Model/ExternalIds.swift>); fixtures [v3_tv_1399_season_1_external_ids.json](<../../Tests/TMDBKitTests/Fixtures/TV Seasons/v3_tv_1399_season_1_external_ids.json>).
- Response work: proposed `TvSeasonExternalIdsResponse`; typed response envelope: id, freebase_mid, freebase_id, tvdb_id, tvrage_id, wikidata_id; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `TVSeasonsEndpoints`, P3/L; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify series_id (required), season_number (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/tv/{series_id}/season/{season_number}/images`

- Operation: [tv-season-images](https://developer.themoviedb.org/reference/tv-season-images); status **declaration-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [TVSeasons.images](<../../Sources/TMDBKit/Networking/Endpoints/TVSeasons.swift>); candidate model files [ImagesResponse.swift](<../../Sources/TMDBKit/Responses/ImagesResponse.swift>), [Poster.swift](<../../Sources/TMDBKit/Model/Poster.swift>); fixtures [v3_tv_1399_season_1_images.json](<../../Tests/TMDBKitTests/Fixtures/TV Seasons/v3_tv_1399_season_1_images.json>).
- Response work: proposed `TvSeasonImagesResponse`; typed response envelope: id, posters; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `TVSeasonsEndpoints`, P3/L; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify series_id (required), include_image_language (optional), language (optional), season_number (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/tv/{series_id}/season/{season_number}/translations`

- Operation: [tv-season-translations](https://developer.themoviedb.org/reference/tv-season-translations); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [TranslationsResponse.swift](<../../Sources/TMDBKit/Responses/TranslationsResponse.swift>); fixtures none; use pinned example or explicitly labeled boundary fixture.
- Response work: proposed `TvSeasonTranslationsResponse`; typed response envelope: id, translations; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `TVSeasonsEndpoints`, P3/L; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify series_id (required), season_number (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/tv/{series_id}/season/{season_number}/videos`

- Operation: [tv-season-videos](https://developer.themoviedb.org/reference/tv-season-videos); status **declaration-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [TVSeasons.videos](<../../Sources/TMDBKit/Networking/Endpoints/TVSeasons.swift>); candidate model files [VideosResponse.swift](<../../Sources/TMDBKit/Responses/VideosResponse.swift>); fixtures [v3_tv_1399_season_1_videos.json](<../../Tests/TMDBKitTests/Fixtures/TV Seasons/v3_tv_1399_season_1_videos.json>).
- Response work: proposed `TvSeasonVideosResponse`; typed response envelope: id, results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `TVSeasonsEndpoints`, P3/L; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify series_id (required), include_video_language (optional), language (optional), season_number (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/tv/{series_id}/season/{season_number}/watch/providers`

- Operation: [tv-season-watch-providers](https://developer.themoviedb.org/reference/tv-season-watch-providers); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [WatchProvider.swift](<../../Sources/TMDBKit/Model/WatchProvider.swift>); fixtures none; use pinned example or explicitly labeled boundary fixture.
- Response work: proposed `TvSeasonWatchProvidersResponse`; typed response envelope: id, results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `TVSeasonsEndpoints`, P3/L; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify series_id (required), language (optional), season_number (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

### TV Episodes

Proposed public group: `TVEpisodesEndpoints`. P3, relative size L. Dependencies: TV Seasons and episode leaves; implement string-safe identifiers, guest/user states and mutation cache bypass.

#### `GET /3/tv/{series_id}/season/{season_number}/episode/{episode_number}`

- Operation: [tv-episode-details](https://developer.themoviedb.org/reference/tv-episode-details); status **declaration-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [TVEpisodes.details](<../../Sources/TMDBKit/Networking/Endpoints/TVEpisodes.swift>); candidate model files [TVDetails.swift](<../../Sources/TMDBKit/Model/TVDetails.swift>); fixtures [v3_tv_1399_season_1_episode_1.json](<../../Tests/TMDBKitTests/Fixtures/TV Episodes/v3_tv_1399_season_1_episode_1.json>).
- Response work: proposed `TvEpisodeDetailsResponse`; typed response envelope: air_date, crew, episode_number, guest_stars, name, overview, id, production_code, runtime, season_number, still_path, vote_average, vote_count; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `TVEpisodesEndpoints`, P3/L; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify series_id (required), season_number (required), episode_number (required), append_to_response (optional), language (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/tv/{series_id}/season/{season_number}/episode/{episode_number}/account_states`

- Operation: [tv-episode-account-states](https://developer.themoviedb.org/reference/tv-episode-account-states); status **declaration-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [TVEpisodes.accountStates](<../../Sources/TMDBKit/Networking/Endpoints/TVEpisodes.swift>); candidate model files [AccountState.swift](<../../Sources/TMDBKit/Model/AccountState.swift>); fixtures [v3_tv_1399_season_1_episode_1_account_states.json](<../../Tests/TMDBKitTests/Fixtures/TV Episodes/v3_tv_1399_season_1_episode_1_account_states.json>).
- Response work: proposed `TvEpisodeAccountStatesResponse`; typed response envelope: id, favorite, rated, watchlist; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential plus one documented user session_id or guest_session_id alternative.
- Group/order/dependencies: `TVEpisodesEndpoints`, P3/L; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify series_id (required), session_id (optional), season_number (required), episode_number (required), guest_session_id (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/tv/episode/{episode_id}/changes`

- Operation: [tv-episode-changes-by-id](https://developer.themoviedb.org/reference/tv-episode-changes-by-id); status **declaration-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [TVEpisodes.changes](<../../Sources/TMDBKit/Networking/Endpoints/TVEpisodes.swift>); candidate model files [ChangeValue.swift](<../../Sources/TMDBKit/Model/ChangeValue.swift>); fixtures [v3_tv_episode_1988661_changes.json](<../../Tests/TMDBKitTests/Fixtures/TV Episodes/v3_tv_episode_1988661_changes.json>).
- Response work: proposed `TvEpisodeChangesByIdResponse`; typed response envelope: changes; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `TVEpisodesEndpoints`, P3/L; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify episode_id (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/tv/{series_id}/season/{season_number}/episode/{episode_number}/credits`

- Operation: [tv-episode-credits](https://developer.themoviedb.org/reference/tv-episode-credits); status **declaration-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [TVEpisodes.credits](<../../Sources/TMDBKit/Networking/Endpoints/TVEpisodes.swift>); candidate model files [CreditsResponse.swift](<../../Sources/TMDBKit/Responses/CreditsResponse.swift>); fixtures [v3_tv_1399_season_1_episode_1_credits.json](<../../Tests/TMDBKitTests/Fixtures/TV Episodes/v3_tv_1399_season_1_episode_1_credits.json>).
- Response work: proposed `TvEpisodeCreditsResponse`; typed response envelope: cast, crew, guest_stars, id; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `TVEpisodesEndpoints`, P3/L; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify series_id (required), season_number (required), language (optional), episode_number (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/tv/{series_id}/season/{season_number}/episode/{episode_number}/external_ids`

- Operation: [tv-episode-external-ids](https://developer.themoviedb.org/reference/tv-episode-external-ids); status **declaration-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [TVEpisodes.externalIds](<../../Sources/TMDBKit/Networking/Endpoints/TVEpisodes.swift>); candidate model files [ExternalIds.swift](<../../Sources/TMDBKit/Model/ExternalIds.swift>); fixtures [v3_tv_1399_season_1_episode_1_external_ids.json](<../../Tests/TMDBKitTests/Fixtures/TV Episodes/v3_tv_1399_season_1_episode_1_external_ids.json>).
- Response work: proposed `TvEpisodeExternalIdsResponse`; typed response envelope: id, imdb_id, freebase_mid, freebase_id, tvdb_id, tvrage_id, wikidata_id; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `TVEpisodesEndpoints`, P3/L; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify series_id (required), season_number (required), episode_number (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/tv/{series_id}/season/{season_number}/episode/{episode_number}/images`

- Operation: [tv-episode-images](https://developer.themoviedb.org/reference/tv-episode-images); status **declaration-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [TVEpisodes.images](<../../Sources/TMDBKit/Networking/Endpoints/TVEpisodes.swift>); candidate model files [ImagesResponse.swift](<../../Sources/TMDBKit/Responses/ImagesResponse.swift>), [Poster.swift](<../../Sources/TMDBKit/Model/Poster.swift>); fixtures [v3_tv_1399_season_1_episode_1_images.json](<../../Tests/TMDBKitTests/Fixtures/TV Episodes/v3_tv_1399_season_1_episode_1_images.json>).
- Response work: proposed `TvEpisodeImagesResponse`; typed response envelope: id, stills; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `TVEpisodesEndpoints`, P3/L; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify series_id (required), include_image_language (optional), language (optional), season_number (required), episode_number (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/tv/{series_id}/season/{season_number}/episode/{episode_number}/translations`

- Operation: [tv-episode-translations](https://developer.themoviedb.org/reference/tv-episode-translations); status **declaration-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [TVEpisodes.translations](<../../Sources/TMDBKit/Networking/Endpoints/TVEpisodes.swift>); candidate model files [TranslationsResponse.swift](<../../Sources/TMDBKit/Responses/TranslationsResponse.swift>); fixtures [v3_tv_1399_season_1_episode_1_translations.json](<../../Tests/TMDBKitTests/Fixtures/TV Episodes/v3_tv_1399_season_1_episode_1_translations.json>).
- Response work: proposed `TvEpisodeTranslationsResponse`; typed response envelope: id, translations; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `TVEpisodesEndpoints`, P3/L; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify series_id (required), season_number (required), episode_number (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/tv/{series_id}/season/{season_number}/episode/{episode_number}/videos`

- Operation: [tv-episode-videos](https://developer.themoviedb.org/reference/tv-episode-videos); status **declaration-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [TVEpisodes.videos](<../../Sources/TMDBKit/Networking/Endpoints/TVEpisodes.swift>); candidate model files [VideosResponse.swift](<../../Sources/TMDBKit/Responses/VideosResponse.swift>); fixtures [v3_tv_1399_season_1_episode_1_videos.json](<../../Tests/TMDBKitTests/Fixtures/TV Episodes/v3_tv_1399_season_1_episode_1_videos.json>).
- Response work: proposed `TvEpisodeVideosResponse`; typed response envelope: id, results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `TVEpisodesEndpoints`, P3/L; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify series_id (required), include_video_language (optional), language (optional), season_number (required), episode_number (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `POST /3/tv/{series_id}/season/{season_number}/episode/{episode_number}/rating`

- Operation: [tv-episode-add-rating](https://developer.themoviedb.org/reference/tv-episode-add-rating); status **declaration-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [TVEpisodes.rateEpisode](<../../Sources/TMDBKit/Networking/Endpoints/TVEpisodes.swift>); candidate model files [TMDB.swift](<../../Sources/TMDBKit/Networking/APIClient/TMDB.swift>); fixtures [v3_tv_1399_season_1_episode_1_rating.json](<../../Tests/TMDBKitTests/Fixtures/TV Episodes/v3_tv_1399_season_1_episode_1_rating.json>).
- Response work: proposed `TvEpisodeAddRatingResponse`; typed response envelope: status_code, status_message; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential plus one documented user session_id or guest_session_id alternative.
- Group/order/dependencies: `TVEpisodesEndpoints`, P3/L; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify series_id (required), guest_session_id (optional), session_id (optional), Content-Type (required), season_number (required), episode_number (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and POST/DELETE body/header, no cache reads/writes. Pinned request schema uses a RAW_BODY placeholder; example body keys are value. Reconcile request guide/schema before choosing requiredness.

#### `DELETE /3/tv/{series_id}/season/{season_number}/episode/{episode_number}/rating`

- Operation: [tv-episode-delete-rating](https://developer.themoviedb.org/reference/tv-episode-delete-rating); status **declaration-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [TVEpisodes.deleteRating](<../../Sources/TMDBKit/Networking/Endpoints/TVEpisodes.swift>); candidate model files [TMDB.swift](<../../Sources/TMDBKit/Networking/APIClient/TMDB.swift>); fixtures [v3_tv_1399_season_1_episode_1_rating.json](<../../Tests/TMDBKitTests/Fixtures/TV Episodes/v3_tv_1399_season_1_episode_1_rating.json>).
- Response work: proposed `TvEpisodeDeleteRatingResponse`; typed response envelope: status_code, status_message; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential plus one documented user session_id or guest_session_id alternative.
- Group/order/dependencies: `TVEpisodesEndpoints`, P3/L; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify series_id (required), Content-Type (optional), guest_session_id (optional), session_id (optional), season_number (required), episode_number (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and POST/DELETE body/header, no cache reads/writes.

### TV Episode Groups

Proposed public group: `TVEpisodeGroupsEndpoints`. P3, relative size M. Dependencies: TV hierarchy episode leaves; existing EpisodeGroupsResponse is a series listing, not nested group details.

#### `GET /3/tv/episode_group/{tv_episode_group_id}`

- Operation: [tv-episode-group-details](https://developer.themoviedb.org/reference/tv-episode-group-details); status **declaration-only**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum [TVEpisodeGroups.details](<../../Sources/TMDBKit/Networking/Endpoints/TVEpisodeGroups.swift>); candidate model files [EpisodeGroupResponse.swift](<../../Sources/TMDBKit/Responses/TV/EpisodeGroupResponse.swift>); fixtures [v3_tv_episode_group_5b09cf3892514146fb007a0e.json](<../../Tests/TMDBKitTests/Fixtures/TV Episode Groups/v3_tv_episode_group_5b09cf3892514146fb007a0e.json>).
- Response work: proposed `TvEpisodeGroupDetailsResponse`; typed response envelope: description, episode_count, group_count, groups, id, name, network, type; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `TVEpisodeGroupsEndpoints`, P3/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify tv_episode_group_id (required). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

### Watch Providers

Proposed public group: `WatchProvidersEndpoints`. P2, relative size M. Dependencies: Configuration/region metadata first; catalog/region envelopes differ from per-title provider availability.

#### `GET /3/watch/providers/regions`

- Operation: [watch-providers-available-regions](https://developer.themoviedb.org/reference/watch-providers-available-regions); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [WatchProvider.swift](<../../Sources/TMDBKit/Model/WatchProvider.swift>), [Language.swift](<../../Sources/TMDBKit/Model/Language.swift>); fixtures none; use pinned example or explicitly labeled boundary fixture.
- Response work: proposed `WatchProvidersAvailableRegionsResponse`; typed response envelope: results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `WatchProvidersEndpoints`, P2/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify language (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/watch/providers/movie`

- Operation: [watch-providers-movie-list](https://developer.themoviedb.org/reference/watch-providers-movie-list); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [WatchProvider.swift](<../../Sources/TMDBKit/Model/WatchProvider.swift>), [Language.swift](<../../Sources/TMDBKit/Model/Language.swift>); fixtures none; use pinned example or explicitly labeled boundary fixture.
- Response work: proposed `WatchProvidersMovieListResponse`; typed response envelope: results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `WatchProvidersEndpoints`, P2/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify language (optional), watch_region (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

#### `GET /3/watch/providers/tv`

- Operation: [watch-provider-tv-list](https://developer.themoviedb.org/reference/watch-provider-tv-list); status **absent**; public **no**; snapshot deprecated **false**, reference deprecated **false**.
- Existing assets: enum none; candidate model files [WatchProvider.swift](<../../Sources/TMDBKit/Model/WatchProvider.swift>), [Language.swift](<../../Sources/TMDBKit/Model/Language.swift>); fixtures none; use pinned example or explicitly labeled boundary fixture.
- Response work: proposed `WatchProviderTvListResponse`; typed response envelope: results; inspect nested pinned schema before choosing requiredness.
- Auth: Application credential required; no user/guest session required.
- Group/order/dependencies: `WatchProvidersEndpoints`, P2/M; prerequisites in this family’s introduction.
- Next implementation/tests: Implement public callback wrapper and typed response; verify language (optional), watch_region (optional). Add independent literal wire assertions, exact returned fields, malformed identity/wrong-type boundaries, shared error mapping and GET no body and pagination where present.

## Deprecated operations (separate policy decision)

### `GET /3/keyword/{keyword_id}/movies`

[keyword-movies](https://developer.themoviedb.org/reference/keyword-movies): status **deprecated**, public **no**. Snapshot deprecated **false**, human reference deprecated **true**. No enum. Candidate models: [Keyword.swift](<../../Sources/TMDBKit/Model/Keyword.swift>), [PopularMoviesResponse.swift](<../../Sources/TMDBKit/Responses/PopularMoviesResponse.swift>). Fixtures: [v3_keyword_192544_movies.json](<../../Tests/TMDBKitTests/Fixtures/Keywords/v3_keyword_192544_movies.json>).

Response work: typed response envelope: id, page, results, total_pages, total_results; inspect nested pinned schema before choosing requiredness. Auth: Application credential required; no user/guest session required. Proposed group `KeywordsEndpoints`; P4/S, dependent on deprecation policy and current authoritative evidence. Next: decide whether to expose at all in a separate Keywords plan; if approved, implement exact path/query, typed pagination and independent success/error tests. Do not silently count as supported missing work.

The other deprecated operation, [person-tagged-images](https://developer.themoviedb.org/reference/person-tagged-images), **is public** and covered by [the operation matrix](test-coverage.md); snapshot false/reference true also remains recorded. No wrapper is removed.

## Existing local routes and templates

| Local route/template | Final disposition |
| --- | --- |
| `GET /3/account` | Preserved legacy current-user accessor; explicit `/account/{account_id}` is now available. Default account ID `0` semantics remain unverified. See [evidence boundaries](response-evidence-boundaries.md). |
| `GET /3/movie/{movie_id}/similar_movies` | Repaired to pinned `/similar` in `ea36126`; historical fixture retained. |
| `GET /3/review{reviewId}` | Still malformed internal-only route with Int ID; repair slash/string ID before a future Reviews public wrapper. |
| `GET /3/trending/{mediaType}/{timeWindow}` | Generic implementation expands four pinned literal resource namespaces; never a fifth operation. |

## Scope and verification limits

No missing-family runtime APIs were added. [Implementation decisions and migration notes](implementation-decisions.md) retain compatibility rulings and costs. [Response evidence boundaries](response-evidence-boundaries.md) retain unknown schema/nullability/account conventions; those are evidence gaps rather than unimplemented confirmed repairs. The tests are offline and shared transport errors do not prove every server-specific error payload. Final verification is recorded in [test coverage](test-coverage.md).
