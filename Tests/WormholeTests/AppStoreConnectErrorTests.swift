import Foundation
import XCTest
@testable import Wormhole

final class AppStoreConnectErrorTests: XCTestCase {
    func testDecodeError() {
        let jsonData = loadFixture(errorResponse)
        let decoder = JSONDecoder()
        let container = try! decoder.decode(ErrorsContainer.self, from: jsonData)
        XCTAssertEqual(container.errors.count, 1)
        
        let error = container.errors.first!
        XCTAssertNotNil(error.id)
        XCTAssertEqual(error.title, "A parameter has an invalid value")
        XCTAssertEqual(error.status, "400")
        XCTAssertEqual(error.detail, "'emaill' is not a valid filter type")
        XCTAssertEqual(error.code, "PARAMETER_ERROR.INVALID")
        XCTAssertNotNil(error.source)
    }
    
    func testDescription() {
        let jsonData = loadFixture(errorResponse)
        let decoder = JSONDecoder()
        let container = try! decoder.decode(ErrorsContainer.self, from: jsonData)
        let error = container.errors.first!
        XCTAssertEqual(String(describing: error), "400 A parameter has an invalid value: 'emaill' is not a valid filter type")
    }
}
