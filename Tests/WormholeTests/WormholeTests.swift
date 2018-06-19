import XCTest
@testable import Wormhole

final class WormholeTests: XCTestCase {
    func testExample() {
        let privateKey = """
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgevZzL1gdAFr88hb2
OF/2NxApJCzGCEDdfSp6VQO30hyhRANCAAQRWz+jn65BtOMvdyHKcvjBeBSDZH2r
1RTwjmYSi9R/zpBnuQ4EiMnCqfMPWiZqB4QdbAd0E7oH50VpuZ1P087G
-----END PRIVATE KEY-----
"""
        
        let encoder = JWTEncoder(privateKey: privateKey)
        let encoded = try? encoder.encode(issuerID: 14241745,
                                          keyID: UUID(uuidString: "B58A79D0-14D9-4C3C-A6E1-846DF1AAFDEB")!)
        XCTAssertNotNil(encoded)
        let components = encoded!.split(separator: ".")
        let header = components[0]
        XCTAssertEqual(header, "eyJhbGciOiJFUzI1NiIsImtpZCI6ImI1OGE3OWQwLTE0ZDktNGMzYy1hNmUxLTg0NmRmMWFhZmRlYiIsInR5cCI6IkpXVCJ9")
    }
    
    
    static var allTests = [
        ("testExample", testExample),
        ]
}
