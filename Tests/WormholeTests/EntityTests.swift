import Foundation
import XCTest
@testable import Wormhole

final class EntityTests: XCTestCase {
    func testDecodeSingleObject() {
        let jsonData = loadFixture(userResponse)
        let decoder = JSONDecoder()
        let container = try? decoder.decode(SingleContainer<User>.self, from: jsonData)
        XCTAssertNotNil(container?.data.id)
        XCTAssertEqual(container?.data.attributes?.firstName, "John")
    }
    
    func testDecodeMultipleObjects() {
        let jsonData = loadFixture(usersResponse)
        let decoder = JSONDecoder()
        let container = try? decoder.decode(CollectionContainer<User>.self, from: jsonData)
        XCTAssertEqual(container?.data.count, 2)
    }
}
