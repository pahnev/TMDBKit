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
}
