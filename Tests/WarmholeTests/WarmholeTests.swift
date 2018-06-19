import XCTest
@testable import Warmhole

final class WarmholeTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Warmhole().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
