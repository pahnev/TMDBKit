import XCTest
@testable import TMDBKit

final class ResponseContractTests: XCTestCase {
    func decode<T: Decodable>(_ type: T.Type, _ data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(type, from: data)
    }

    func fixture(_ name: String) throws -> Data {
        let root = URL(fileURLWithPath: #file).deletingLastPathComponent()
        return try Data(contentsOf: root.appendingPathComponent("Fixtures/Contract/\(name).json"))
    }

    func roundTrip<T: CodableEquatable>(_ value: T) throws {
        XCTAssertEqual(try decode(T.self, JSONEncoder().encode(value)), value)
    }

    func testMovieChangesAcceptPosterObjectAndMissingOriginalValue() throws {
        let response = try decode(ChangesResponse.self, fixture("changes-movie"))
        XCTAssertEqual(response.changes?.first?.key, "images")
        let item = try XCTUnwrap(response.changes?.first?.items.first)
        XCTAssertEqual(item.valueData, .object(["poster": .object(["file_path": .string("/s9ZrHprviFCx3azfWNBtt1LPSnL.jpg")])]))
        XCTAssertNil(item.originalValueData)
        XCTAssertEqual(item.value, "")
        try roundTrip(response)
    }

    func testPersonChangesAllowMissingOriginalValue() throws {
        let response = try decode(ChangesResponse.self, fixture("changes-person"))
        XCTAssertEqual(response.changes?.first?.key, "biography")
        let item = try XCTUnwrap(response.changes?.first?.items.first)
        guard case .string(let biography)? = item.valueData else { return XCTFail("Expected biography string") }
        XCTAssertTrue(biography.hasPrefix("Thomas \"Tom\" Jeffrey Hanks"))
        XCTAssertEqual(item.iso31661, "ES")
        XCTAssertNil(item.originalValueData)
        try roundTrip(response)
    }

    func testTVChangesDecodeCanonicalChanges() throws {
        let response = try decode(TVChangesResponse.self, fixture("changes-tv"))
        let item = try XCTUnwrap(response.changes?.first?.items.first)
        XCTAssertEqual(item.value.posterValue?.filePath, "/ouudK6RCNnsbT1CSXrlATXQIQTG.jpg")
        XCTAssertEqual(item.originalValue.posterValue?.iso6391, "fr")
        XCTAssertEqual(response.items, response.changes)
        try roundTrip(response)
    }

    // Synthetic union boundaries: TMDB's guides describe numeric season/episode IDs;
    // all JSON kinds and absent/null are exercised without attributing them to examples.
    func testChangeValuesRoundTripAllJSONKinds() throws {
        let data = Data(#"{"series_id":9007199254740993,"episode_id":123,"fraction":1.25,"enabled":true,"text":"hi","array":[null,false,4],"nested_key":{"file_path":"/x"}}"#.utf8)
        let value = try decode(ChangeValue.self, data)
        guard case .object(let object) = value else { return XCTFail("Expected object") }
        XCTAssertEqual(object["series_id"], .integer(9007199254740993))
        XCTAssertEqual(object["episode_id"], .integer(123))
        XCTAssertEqual(object["fraction"], .number(1.25))
        XCTAssertEqual(object["enabled"], .bool(true))
        XCTAssertEqual(object["text"], .string("hi"))
        XCTAssertEqual(object["array"], .array([.null, .bool(false), .integer(4)]))
        XCTAssertEqual(object["nested_key"], .object(["file_path": .string("/x")]))
        try roundTrip(value)
        let itemData = Data(#"{"id":"i","action":"updated","time":"t","value":null}"#.utf8)
        let item = try decode(Change.Item.self, itemData)
        XCTAssertEqual(item.valueData, .null)
        XCTAssertNil(item.originalValueData)
        XCTAssertNil(item.iso6391Data)
        try roundTrip(item)
        let tv = try decode(TVChange.Item.self, itemData)
        XCTAssertEqual(tv.valueData, .null)
        XCTAssertNil(tv.originalValueData)
        XCTAssertEqual(tv.originalValue.rawValue, .null)
        XCTAssertEqual(tv.value.poster.filePath, "")
        try roundTrip(tv)
    }

    func testChangeRequiredFieldsRejectMalformedData() throws {
        // Synthetic invalid boundaries preserve strict identity and structure.
        for json in [#"{"action":"a","time":"t"}"#, #"{"id":7,"action":"a","time":"t"}"#,
                     #"{"id":"i","time":"t"}"#, #"{"id":"i","action":"a","time":false}"#] {
            XCTAssertThrowsError(try decode(Change.Item.self, Data(json.utf8)))
            XCTAssertThrowsError(try decode(TVChange.Item.self, Data(json.utf8)))
        }
        for json in [#"{"items":[]}"#, #"{"key":"x","items":{}}"#] {
            XCTAssertThrowsError(try decode(Change.self, Data(json.utf8)))
            XCTAssertThrowsError(try decode(TVChange.self, Data(json.utf8)))
        }
    }

    func testProviderRegionsPreserveAEAndUnknownRegion() throws {
        let response = try decode(WatchProviderResponse.self, fixture("providers-movie"))
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(response)) as? [String: Any])
        let results = try XCTUnwrap(object["results"] as? [String: Any])
        XCTAssertNotNil(results["AE"])
        XCTAssertEqual(response.results?["AE"]?.flatrate?.first?.providerId, 119)
        try roundTrip(response)
        // Synthetic future region and arbitrary key spelling must survive key strategy.
        let future = try decode(WatchProviderResponse.self, Data(#"{"id":1,"results":{"ZZ":{"free":[{"provider_id":42,"provider_name":"Future","display_priority":3,"logo_path":"/future"}]},"NEW_REGION":{}}}"#.utf8))
        XCTAssertEqual(future.results?["ZZ"]?.free?.first?.providerId, 42)
        XCTAssertNotNil(future.results?["NEW_REGION"])
        try roundTrip(future)
        // Synthetic malformed provider identity, including an unknown region.
        XCTAssertThrowsError(try decode(WatchProviderResponse.self, Data(#"{"id":1,"results":{"ZZ":{"free":[{"provider_id":"42","provider_name":"Future","display_priority":3,"logo_path":"/future"}]}}}"#.utf8)))
    }

    func testProviderFreeAndAdsRoundTrip() throws {
        for (fixtureName, region, category) in [("providers-movie", "ES", "ads"), ("providers-tv", "US", "free")] {
            let response = try decode(WatchProviderResponse.self, fixture(fixtureName))
            let object = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(response)) as? [String: Any])
            let results = try XCTUnwrap(object["results"] as? [String: [String: Any]])
            XCTAssertNotNil(results[region]?[category])
            let provider = category == "ads" ? response.results?[region]?.ads?.first : response.results?[region]?.free?.first
            XCTAssertEqual(provider?.providerId, category == "ads" ? 35 : 384)
            XCTAssertEqual(provider?.providerName, category == "ads" ? "Rakuten TV" : "HBO Max")
            XCTAssertEqual(provider?.displayPriority, category == "ads" ? 11 : 7)
            XCTAssertEqual(provider?.logoPath, category == "ads" ? "/5GEbAhFW2S5T8zVc1MNvz00pIzM.jpg" : "/Ajqyt5aNxNGjmF9uOfxArGrdf3X.jpg")
            try roundTrip(response)
        }
    }

    func testLegacyProviderRegionAccessors() throws {
        let response = try decode(WatchProviderResponse.self, fixture("providers-movie"))
        XCTAssertNotNil(response.results?.us)
        XCTAssertNotNil(response.results?.iN)
        XCTAssertEqual(response.results?.us, response.results?["US"])
        XCTAssertEqual(response.results?.iN, response.results?["IN"])
    }

    func testTVRecommendationsWithoutNetworks() throws {
        let response = try decode(RecommendationsResponse.self, fixture("tv-recommendations"))
        let first = try XCTUnwrap(response.results.first)
        XCTAssertEqual(first.id, 1396)
        XCTAssertEqual(first.name, "Breaking Bad")
        XCTAssertEqual(first.adult, false)
        XCTAssertEqual(first.mediaType, "tv")
        XCTAssertTrue(first.networks.isEmpty)
        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.totalPages, 2)
        XCTAssertEqual(response.totalResults, 40)
        try roundTrip(response)
    }

    func testTVRecommendationsRejectMalformedIDAndNetworks() throws {
        // Synthetic boundaries mutate only required identity or network structure.
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: fixture("tv-recommendations")) as? [String: Any])
        let results = try XCTUnwrap(object["results"] as? [[String: Any]])
        for mutation: (inout [String: Any]) -> Void in [
            { $0.removeValue(forKey: "id") }, { $0["id"] = "1396" },
            { $0["networks"] = "wrong" }, { $0["networks"] = NSNull() }
        ] {
            var result = try XCTUnwrap(results.first)
            mutation(&result)
            var malformed = object
            malformed["results"] = [result]
            XCTAssertThrowsError(try decode(RecommendationsResponse.self, JSONSerialization.data(withJSONObject: malformed)))
        }
    }

    func testListItemStatusAcceptsNumericAndLegacyStringID() throws {
        let response = try decode(ListItemStatus.self, fixture("list-item-status"))
        XCTAssertEqual(response.id, "1")
        XCTAssertTrue(response.itemPresent)
        XCTAssertEqual(response.numericId, 1)
        try roundTrip(response)
        let encoded = try decode(ChangeValue.self, JSONEncoder().encode(response))
        XCTAssertEqual(encoded, .object(["id": .integer(1), "item_present": .bool(true)]))
        // Synthetic legacy boundaries preserve textual wire IDs exactly.
        for text in ["legacy-list", "001", "1"] {
            let object: [String: Any] = ["id": text, "item_present": true]
            let legacy = try decode(ListItemStatus.self, JSONSerialization.data(withJSONObject: object))
            XCTAssertEqual(legacy.id, text)
            XCTAssertEqual(legacy.numericId, Int(text))
            XCTAssertEqual(try decode(ChangeValue.self, JSONEncoder().encode(legacy)), .object(["id": .string(text), "item_present": .bool(true)]))
            try roundTrip(legacy)
        }
        for invalid in [#"{"item_present":true}"#, #"{"id":true,"item_present":true}"#,
                        #"{"id":{},"item_present":true}"#, #"{"id":1.5,"item_present":true}"#,
                        #"{"id":null,"item_present":true}"#] {
            XCTAssertThrowsError(try decode(ListItemStatus.self, Data(invalid.utf8)))
        }
    }

    func testPersonDeathdayIsPreserved() throws {
        let official = try decode(PersonDetailsResponse.self, fixture("person-details"))
        XCTAssertEqual(official.id, 31)
        XCTAssertNil(official.deathday)
        XCTAssertNil(official.deathDay)
        try roundTrip(official)
        // Synthetic non-null key regression: the official living person's example is null.
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: fixture("person-details")) as? [String: Any])
        object["deathday"] = "2000-01-02"
        let regression = try decode(PersonDetailsResponse.self, JSONSerialization.data(withJSONObject: object))
        XCTAssertEqual(regression.deathday, "2000-01-02")
        XCTAssertEqual(regression.deathDay, regression.deathday)
        let encoded = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(regression)) as? [String: Any])
        XCTAssertEqual(encoded["deathday"] as? String, "2000-01-02")
        XCTAssertNil(encoded["death_day"])
        try roundTrip(regression)
    }

    func testPersonCreditsPreserveIDsGenresAndOrder() throws {
        for (name, credit, genres) in [
            ("person-movie-credits", "52fe420ec3a36847f800074f", [35, 18, 10749]),
            ("person-tv-credits", "52571af019c29571140d5c92", [10767]),
            ("person-combined-credits", "52fe420ec3a36847f800074f", [35, 18, 10749])
        ] {
            let response = try decode(PersonCreditsResponse.self, fixture(name))
            XCTAssertEqual(response.id, 31)
            let cast = try XCTUnwrap(response.cast.first)
            XCTAssertEqual(cast.creditID, credit)
            XCTAssertEqual(cast.genreIDS, genres)
            XCTAssertEqual(cast.creditId, credit)
            XCTAssertEqual(cast.genreIds, genres)
            XCTAssertEqual(cast.id, name == "person-tv-credits" ? 1900 : 13)
            XCTAssertEqual(cast.order, name == "person-tv-credits" ? nil : 0)
            XCTAssertEqual(cast.mediaType, name == "person-combined-credits" ? "movie" : nil)
            let crew = try XCTUnwrap(response.crew.first)
            XCTAssertEqual(crew.creditID, name == "person-tv-credits" ? "525734f3760ee3776a397211" : "5d818a63d34eb3002c4f8fea")
            XCTAssertEqual(crew.genreIDS, name == "person-tv-credits" ? [35, 9648, 80, 10765] : [99])
            let encoded = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(cast)) as? [String: Any])
            XCTAssertEqual(encoded["credit_id"] as? String, credit)
            XCTAssertEqual(encoded["genre_ids"] as? [Int], genres)
            XCTAssertNil(encoded["creditID"])
            XCTAssertNil(encoded["genreIDS"])
            try roundTrip(response)
            // Synthetic required-ID and malformed optional-value boundaries.
            for mutation: (inout [String: Any]) -> Void in [
                { $0.removeValue(forKey: "id") }, { $0["id"] = "13" },
                { $0["id"] = false }, { $0["credit_id"] = 5 },
                { $0["genre_ids"] = ["wrong"] }
            ] {
                var malformed = encoded
                mutation(&malformed)
                XCTAssertThrowsError(try decode(CreditsCast.self, JSONSerialization.data(withJSONObject: malformed)))
            }
        }
    }
    func testTaggedImagesDecodeEpisodeMedia() throws {
        let response = try decode(TaggedImageResponse.self, fixture("person-tagged-images"))
        let tagged = response.results[10]
        XCTAssertEqual(tagged.mediaType, .episode)
        XCTAssertEqual(tagged.id, "574e9546c3a3687ff1001ba0")
        XCTAssertEqual(tagged.imageType, "still")
        guard case .episode(let episode) = tagged.media else { return XCTFail("Expected episode media") }
        XCTAssertEqual(episode.id, 1196876)
        XCTAssertEqual(episode.showId, 66623)
        try roundTrip(response)
    }

    func testMediaDiscriminatorIsRespected() throws {
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: fixture("person-tagged-images")) as? [String: Any])
        let results = try XCTUnwrap(object["results"] as? [[String: Any]])
        var movie = try XCTUnwrap(results.first?["media"] as? [String: Any])
        // Synthetic explicit discriminators must never fall through to another shape.
        for discriminator in ["unknown", "tv", "person", "tv_episode"] {
            movie["media_type"] = discriminator
            XCTAssertThrowsError(try decode(Media.self, JSONSerialization.data(withJSONObject: movie)))
        }
        for malformedTag: Any in [NSNull(), 7, false, [:], []] {
            movie["media_type"] = malformedTag
            XCTAssertThrowsError(try decode(Media.self, JSONSerialization.data(withJSONObject: movie)))
        }
        movie["media_type"] = "movie"
        for malformed: Any in ["13", true, NSNull()] {
            movie["id"] = malformed
            XCTAssertThrowsError(try decode(Media.self, JSONSerialization.data(withJSONObject: movie)))
        }
    }

    func testMediaRoundTripsAllSupportedCases() throws {
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: fixture("person-tagged-images")) as? [String: Any])
        let results = try XCTUnwrap(object["results"] as? [[String: Any]])
        let movie = try XCTUnwrap(results.first?["media"] as? [String: Any])
        let episode = try XCTUnwrap(results[10]["media"] as? [String: Any])
        // Synthetic person/TV shapes complement the official tagged movie/episode.
        let tv: [String: Any] = ["id": 7, "vote_average": 1.5, "overview": "TV", "first_air_date": "2020-01-01", "origin_country": ["US"], "genre_ids": [1], "original_language": "en", "vote_count": 2, "name": "TV", "original_name": "TV"]
        let person: [String: Any] = ["id": 8, "popularity": 2.5, "gender": 1, "adult": false, "known_for": [], "name": "Person"]
        for (type, payload, id) in [("movie", movie, 857), ("tv", tv, 7), ("person", person, 8), ("tv_episode", episode, 1196876)] {
            var explicit = payload
            explicit["media_type"] = type
            let value = try decode(Media.self, JSONSerialization.data(withJSONObject: explicit))
            switch value {
            case .movie(let model): XCTAssertEqual(type, "movie"); XCTAssertEqual(model.id, id)
            case .tv(let model): XCTAssertEqual(type, "tv"); XCTAssertEqual(model.id, id)
            case .person(let model): XCTAssertEqual(type, "person"); XCTAssertEqual(model.id, id)
            case .episode(let model): XCTAssertEqual(type, "tv_episode"); XCTAssertEqual(model.id, id)
            }
            let encoded = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(value)) as? [String: Any])
            XCTAssertEqual(encoded["media_type"] as? String, type)
            XCTAssertNil(encoded["mediaType"])
            try roundTrip(value)
            explicit.removeValue(forKey: "media_type")
            let historical = try decode(Media.self, JSONSerialization.data(withJSONObject: explicit))
            // Only Media's shape inference supplies known wrapper metadata; standalone models
            // preserve omission. Inferred wrappers are equal and stable through round trips.
            XCTAssertEqual(historical, value)
            try roundTrip(historical)
            let standaloneData = try JSONSerialization.data(withJSONObject: explicit)
            switch type {
            case "movie": XCTAssertNil(try decode(MovieFragment.self, standaloneData).mediaType)
            case "tv": XCTAssertNil(try decode(TVMedia.self, standaloneData).mediaType)
            case "person": XCTAssertNil(try decode(PopularPerson.self, standaloneData).mediaType)
            default: break
            }
        }
    }

    func fixtureValue(_ operation: String, _ path: String = "") throws -> Any {
        var value = try JSONSerialization.jsonObject(with: fixture(operation))
        for component in path.split(separator: ".").map(String.init) {
            if let index = Int(component), let array = value as? [Any], index < array.count { value = array[index] }
            else { value = try XCTUnwrap((value as? [String: Any])?[component]) }
        }
        return value
    }

    func comparableJSON(_ value: Any) -> NSObject {
        if let object = value as? [String: Any] {
            var result: [String: NSObject] = [:]
            for (key, value) in object where !(value is NSNull) {
                let normalized = key == "iso_639_1" ? "iso6391" : (key == "iso_3166_1" ? "iso31661" : key)
                result[normalized] = comparableJSON(value)
            }
            return result as NSDictionary
        }
        if let array = value as? [Any] { return array.map(comparableJSON) as NSArray }
        return value as! NSObject
    }

    @discardableResult
    func preserves<T: CodableEquatable>(_ type: T.Type, _ operation: String, _ path: String = "", _ fields: [String], file: StaticString = #file, line: UInt = #line) throws -> T {
        let source = try XCTUnwrap(fixtureValue(operation, path) as? [String: Any])
        let value = try decode(type, JSONSerialization.data(withJSONObject: source))
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let encoded = try XCTUnwrap(JSONSerialization.jsonObject(with: encoder.encode(value)) as? [String: Any])
        for field in fields {
            let expected = try XCTUnwrap(source[field], "Pinned field \(field)", file: file, line: line)
            if !(expected is NSNull) {
                XCTAssertEqual(encoded[field].map(comparableJSON), comparableJSON(expected), "Preserve \(operation).\(path).\(field)", file: file, line: line)
            }
            // Synthetic absent/null/malformed-present boundaries for each new optional.
            var boundary = source
            boundary.removeValue(forKey: field)
            let absent = try decode(type, JSONSerialization.data(withJSONObject: boundary))
            let absentObject = try XCTUnwrap(JSONSerialization.jsonObject(with: encoder.encode(absent)) as? [String: Any])
            XCTAssertNil(absentObject[field], "Absent optional \(field) stays nil", file: file, line: line)
            try roundTrip(absent)
            boundary[field] = NSNull()
            let null = try decode(type, JSONSerialization.data(withJSONObject: boundary))
            XCTAssertEqual(null, absent, "Null optional \(field) becomes nil", file: file, line: line)
            boundary[field] = field == "tmdb" ? "wrong" : [:]
            XCTAssertThrowsError(try decode(type, JSONSerialization.data(withJSONObject: boundary)), "Reject malformed \(field)", file: file, line: line)
        }
        try roundTrip(value)
        return value
    }

    func testAccountAvatarPreservesTMDBPath() throws {
        try preserves(AccountDetails.Avatar.self, "account-details", "avatar", ["tmdb"])
        try preserves(AccountDetails.Avatar.TMDBAvatar.self, "account-details", "avatar.tmdb", ["avatar_path"])
    }

    func testMoviePreservesCountryLanguageAndMediaType() throws {
        try preserves(Movie.self, "movie-details", "", ["origin_country"])
        try preserves(Language.self, "movie-details", "spoken_languages.0", ["english_name"])
        try preserves(MovieFragment.self, "list-details", "items.0", ["media_type"])
        try preserves(MovieFragment.self, "trending-all", "results.0", ["media_type"])
    }

    func testCreditsPreserveCastIDAndCrewMetadata() throws {
        try preserves(Cast.self, "movie-credits", "cast.0", ["cast_id"])
        for op in ["movie-credits", "tv-series-credits"] {
            try preserves(Crew.self, op, "crew.0", ["adult", "known_for_department", "original_name", "popularity"])
        }
    }

    func testAggregateCreditsPreserveRolesAndJobs() throws {
        try preserves(AggregateCast.self, "tv-series-aggregate-credits", "cast.0", ["roles"])
        try preserves(AggregateCrew.self, "tv-series-aggregate-credits", "crew.0", ["jobs", "adult", "known_for_department", "original_name", "popularity"])
    }

    func testExternalIDsPreserveAllDocumentedSources() throws {
        for op in ["movie-external-ids", "person-external-ids", "tv-series-external-ids"] {
            let source = try XCTUnwrap(fixtureValue(op) as? [String: Any])
            let fields = ["wikidata_id", "freebase_mid", "freebase_id", "tiktok_id", "tvdb_id", "tvrage_id"].filter { source[$0] != nil }
            try preserves(ExternalIds.self, op, "", fields)
        }
    }

    func testImagesPreserveLogos() throws {
        for op in ["movie-images", "tv-series-images"] {
            try preserves(ImagesResponse.self, op, "", ["logos"])
            try preserves(AppendedImages.self, op, "", ["logos"])
        }
    }

    func testReviewsPreserveUsername() throws {
        for op in ["movie-reviews", "tv-series-reviews"] {
            try preserves(Review.AuthorDetails.self, op, "results.0.author_details", ["username"])
        }
    }

    func testVideosPreserveOfficialAndPublishedAt() throws {
        for op in ["movie-videos", "tv-series-videos"] {
            try preserves(Video.self, op, "results.0", ["official", "published_at"])
        }
    }

    func testTranslationsPreserveRuntimeTaglineAndPersonName() throws {
        try preserves(Translation.TranslationData.self, "movie-translations", "translations.0.data", ["runtime", "tagline"])
        try preserves(Translation.TranslationData.self, "tv-series-translations", "translations.0.data", ["tagline"])
        try preserves(PersonTranslation.TranslationData.self, "translations", "translations.0.data", ["name"])
    }

    func testTVDetailsPreserveAdditionalFields() throws {
        for op in ["tv-series-details", "tv-series-latest-id"] {
            try preserves(TVDetails.self, op, "", ["adult", "production_countries", "spoken_languages", "tagline"])
        }
        try preserves(Season.self, "tv-series-details", "seasons.0", ["vote_average"])
    }

    func testRatedEpisodesPreserveRatingAndNullableRuntime() throws {
        try preserves(LastEpisodeToAir.self, "account-rated-tv-episodes", "results.0", ["rating", "runtime"])
        try preserves(LastEpisodeToAir.self, "tv-series-details", "last_episode_to_air", ["runtime"])
        try preserves(LastEpisodeToAir.self, "tv-series-latest-id", "last_episode_to_air", ["runtime"])
    }

    func testRatedTVPreservesRating() throws {
        try preserves(TVShowFragment.self, "account-rated-tv", "results.0", ["adult", "rating"])
        try preserves(TVShowFragment.self, "tv-series-similar", "results.0", ["adult"])
    }

    func testTVMediaPreservesAdultAndType() throws {
        try preserves(TVMedia.self, "trending-tv", "results.0", ["adult", "media_type"])
    }

    func testPopularPersonPreservesOriginalNameAndType() throws {
        try preserves(PopularPerson.self, "trending-people", "results.0", ["original_name", "media_type"])
    }

    func testCertificationDescriptorsRoundTrip() throws {
        try preserves(ReleaseDate.self, "movie-release-dates", "results.0.release_dates.0", ["descriptors"])
        try preserves(Rating.self, "tv-series-content-ratings", "results.0", ["descriptors"])
    }

    func testAddedPublicFieldsHaveExactPinnedValues() throws {
        let account = try decode(AccountDetails.self, fixture("account-details"))
        XCTAssertEqual(account.avatar.tmdb?.avatarPath, "/xy44UvpbTgzs9kWmp4C3fEaCl5h.png")
        try roundTrip(account)
        let movie = try decode(Movie.self, fixture("movie-details"))
        XCTAssertEqual(movie.originCountry, ["US"])
        XCTAssertEqual(movie.spokenLanguages.first?.englishName, "English")
        try roundTrip(movie)
        let list = try preserves(MovieFragment.self, "list-details", "items.0", ["media_type"])
        XCTAssertEqual(list.mediaType, "movie")
        let cast = try preserves(Cast.self, "movie-credits", "cast.0", ["cast_id"])
        XCTAssertEqual(cast.castId, 4)
        for (op, department, name, popularity) in [("movie-credits", "Production", "Arnon Milchan", 2.931), ("tv-series-credits", "Production", "Duncan Muggoch", 1.592)] {
            let crew = try preserves(Crew.self, op, "crew.0", ["adult", "known_for_department", "original_name", "popularity"])
            XCTAssertEqual(crew.adult, false)
            XCTAssertEqual(crew.knownForDepartment, department)
            XCTAssertEqual(crew.originalName, name)
            XCTAssertEqual(crew.popularity, popularity)
        }
        let aggregate = try decode(AggregateCredits.self, fixture("tv-series-aggregate-credits"))
        let role = try XCTUnwrap(aggregate.cast.first?.roles?.first)
        XCTAssertEqual(role.creditId, "5256c8af19c2956ff60479f6")
        XCTAssertEqual(role.character, "Daenerys Targaryen")
        XCTAssertEqual(role.episodeCount, 78)
        let crew = try XCTUnwrap(aggregate.crew.first)
        XCTAssertEqual(crew.adult, false)
        XCTAssertEqual(crew.knownForDepartment, "Art")
        XCTAssertEqual(crew.originalName, "Deborah Riley")
        XCTAssertEqual(crew.popularity, 1.4)
        let job = try XCTUnwrap(crew.jobs?.first)
        XCTAssertEqual(job.creditId, "54eee9e5c3a3686d5800584e")
        XCTAssertEqual(job.job, "Production Design")
        XCTAssertEqual(job.episodeCount, 43)
        try roundTrip(aggregate)
        let personIDs = try decode(ExternalIds.self, fixture("person-external-ids"))
        XCTAssertEqual(personIDs.wikidataId, "Q2263")
        XCTAssertEqual(personIDs.freebaseMid, "/m/0bxtg")
        XCTAssertEqual(personIDs.freebaseId, "/en/tom_hanks")
        XCTAssertEqual(personIDs.tiktokId, "tomhanks")
        XCTAssertEqual(personIDs.tvrageId, 14293)
        XCTAssertNil(personIDs.tvdbId)
        try roundTrip(personIDs)
        let tvIDs = try decode(ExternalIds.self, fixture("tv-series-external-ids"))
        XCTAssertEqual(tvIDs.tvdbId, 121361)
        XCTAssertEqual(tvIDs.tvrageId, 24493)
        XCTAssertEqual(tvIDs.wikidataId, "Q23572")
        XCTAssertEqual(tvIDs.freebaseMid, "/m/0524b41")
        XCTAssertEqual(tvIDs.freebaseId, "/en/game_of_thrones")
        XCTAssertNil(tvIDs.tiktokId)
        XCTAssertNil(try decode(ExternalIds.self, fixture("movie-external-ids")).wikidataId)
        try roundTrip(tvIDs)
        for op in ["movie-images", "tv-series-images"] {
            let images = try decode(ImagesResponse.self, fixture(op))
            let appended = try decode(AppendedImages.self, fixture(op))
            XCTAssertEqual(images.logos?.first?.filePath, "/c1KLulrIhUqY5fT42nmC5aERGCp.png")
            XCTAssertEqual(appended.logos, images.logos)
            try roundTrip(images)
            try roundTrip(appended)
        }
        for (op, username) in [("movie-reviews", "Goddard"), ("tv-series-reviews", "lmao7")] {
            let reviews = try decode(ReviewsResponse.self, fixture(op))
            XCTAssertEqual(reviews.results.first?.authorDetails.username, username)
            try roundTrip(reviews)
        }
        for (op, official, published) in [("movie-videos", false, "2016-03-05T02:03:14.000Z"), ("tv-series-videos", true, "2019-03-25T14:00:06.000Z")] {
            let videos = try decode(VideosResponse.self, fixture(op))
            XCTAssertEqual(videos.results.first?.official, official)
            XCTAssertEqual(videos.results.first?.publishedAt, published)
            try roundTrip(videos)
        }
        let translations = try decode(TranslationsResponse.self, fixture("movie-translations"))
        XCTAssertEqual(translations.translations.first?.data.runtime, 0)
        XCTAssertEqual(translations.translations.first?.data.tagline, "")
        try roundTrip(translations)
        let tvTranslations = try decode(TranslationsResponse.self, fixture("tv-series-translations"))
        XCTAssertEqual(tvTranslations.translations.first?.data.tagline, "الشتاء قادم")
        XCTAssertNil(tvTranslations.translations.first?.data.runtime)
        try roundTrip(tvTranslations)
        let personTranslations = try decode(PersonTranslationResponse.self, fixture("translations"))
        XCTAssertEqual(personTranslations.translations.first?.data.name, "Tom Hanks")
        try roundTrip(personTranslations)
        let tv = try decode(TVDetails.self, fixture("tv-series-details"))
        XCTAssertEqual(tv.adult, false)
        XCTAssertEqual(tv.productionCountries?.map { $0.iso31661 }, ["GB", "US"])
        XCTAssertEqual(tv.spokenLanguages?.first?.englishName, "English")
        XCTAssertEqual(tv.tagline, "Winter Is Coming")
        XCTAssertEqual(tv.lastEpisodeToAir?.runtime, 80)
        XCTAssertEqual(tv.seasons.first?.voteAverage, 0)
        try roundTrip(tv)
        let latest = try decode(TVDetails.self, fixture("tv-series-latest-id"))
        XCTAssertNil(latest.lastEpisodeToAir?.runtime)
        XCTAssertNil(latest.seasons.first?.voteAverage)
        XCTAssertEqual(latest.productionCountries, [])
        XCTAssertEqual(latest.spokenLanguages, [])
        XCTAssertEqual(latest.tagline, "")
        try roundTrip(latest)
        let episodes = try decode(EpisodeListResponse.self, fixture("account-rated-tv-episodes"))
        XCTAssertEqual(episodes.results.first?.rating, 8)
        XCTAssertEqual(episodes.results.first?.runtime, 22)
        try roundTrip(episodes)
        let ratedTV = try preserves(TVShowFragment.self, "account-rated-tv", "results.0", ["rating", "adult"])
        XCTAssertEqual(ratedTV.rating, 9)
        XCTAssertEqual(ratedTV.adult, false)
        let similar = try decode(SimilarShowsResponse.self, fixture("tv-series-similar"))
        XCTAssertEqual(similar.results.first?.adult, false)
        XCTAssertNil(similar.results.first?.rating)
        try roundTrip(similar)
        let tvMedia = try preserves(TVMedia.self, "trending-tv", "results.0", ["adult", "media_type"])
        XCTAssertEqual(tvMedia.adult, false)
        XCTAssertEqual(tvMedia.mediaType, "tv")
        let person = try preserves(PopularPerson.self, "trending-people", "results.0", ["original_name", "media_type"])
        XCTAssertEqual(person.originalName, "Ana de Armas")
        XCTAssertEqual(person.mediaType, "person")
        let dates = try decode(ReleaseDatesResponse.self, fixture("movie-release-dates"))
        XCTAssertEqual(dates.results.first?.releaseDates.first?.descriptors, [])
        try roundTrip(dates)
        let ratings = try decode(ContentRatingsResponse.self, fixture("tv-series-content-ratings"))
        XCTAssertEqual(ratings.results.first?.descriptors, [])
        try roundTrip(ratings)
    }

    func testCertificationDescriptorsPreserveSyntheticMixedJSON() throws {
        // Synthetic: the pinned schema and examples only establish empty descriptor arrays.
        let mixed: [ChangeValue] = [.string("violence"), .integer(7), .bool(true), .null, .object(["unknown_key": .array([.number(1.5)])])]
        for (op, path) in [("movie-release-dates", "results.0.release_dates.0"), ("tv-series-content-ratings", "results.0")] {
            var source = try XCTUnwrap(fixtureValue(op, path) as? [String: Any])
            source["descriptors"] = try JSONSerialization.jsonObject(with: JSONEncoder().encode(mixed))
            let data = try JSONSerialization.data(withJSONObject: source)
            if op == "movie-release-dates" {
                let value = try decode(ReleaseDate.self, data)
                XCTAssertEqual(value.descriptors, mixed)
                try roundTrip(value)
            } else {
                let value = try decode(Rating.self, data)
                XCTAssertEqual(value.descriptors, mixed)
                try roundTrip(value)
            }
        }
    }

}
