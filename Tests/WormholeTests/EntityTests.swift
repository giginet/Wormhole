import Foundation
import XCTest
@testable import Wormhole

struct User: AttributeType {
    let firstName: String
    let lastName: String
    let email: String
    let inviteType: String
}

final class EntityTests: XCTestCase {
    func testDecodeSingleObject() {
        let jsonData = loadJSON(from: "user")
        let decoder = JSONDecoder()
        let container = try? decoder.decode(SingleContainer<User>.self, from: jsonData)
        XCTAssertNotNil(container?.data.id)
        XCTAssertEqual(container?.data.attributes?.firstName, "John")
    }
    
    func testDecodeMultipleObjects() {
        let jsonData = loadJSON(from: "users")
        let decoder = JSONDecoder()
        let container = try? decoder.decode(CollectionContainer<User>.self, from: jsonData)
        XCTAssertEqual(container?.data.count, 2)
    }
}
