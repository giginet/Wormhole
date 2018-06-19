import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(WormholeTests.allTests),
    ]
}
#endif
