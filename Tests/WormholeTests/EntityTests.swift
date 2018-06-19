import Foundation
import XCTest
@testable import Wormhole

struct User: EntityType {
    let type: String
    let id: UUID
}

final class EntityTests: XCTestCase {
    func loadJSON(from fileName: String) -> Data {
        let bundle = Bundle(for: EntityTests.self)
        let path = bundle.path(forResource: fileName, ofType: ".json")!
        let url = URL(fileURLWithPath: path)
        return try! Data(contentsOf: url)
    }
    
    func testDecodeSingleObject() {
        let jsonData = loadJSON(from: "user")
        let decoder = JSONDecoder()
        let container = try? decoder.decode(EntityContainer<User>.self, from: jsonData)
        XCTAssertNotNil(container?.data.id)
    }
    
    func testDecodeMultipleObjects() {
        let jsonData = loadJSON(from: "users")
        let decoder = JSONDecoder()
        let container = try? decoder.decode(EntityContainer<[User]>.self, from: jsonData)
        XCTAssertEqual(container?.data.count, 2)
    }
}
