import Foundation
import XCTest
@testable import Wormhole

struct User: EntityType {
    let type: String
    let id: UUID
}

final class EntityTests: XCTestCase {
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
