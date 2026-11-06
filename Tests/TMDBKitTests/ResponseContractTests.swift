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
            try roundTrip(value)
            explicit.removeValue(forKey: "media_type")
            XCTAssertEqual(try decode(Media.self, JSONSerialization.data(withJSONObject: explicit)), value)
        }
    }

}
