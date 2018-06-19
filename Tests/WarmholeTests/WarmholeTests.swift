import XCTest
@testable import Warmhole

final class WarmholeTests: XCTestCase {
    func testExample() {
        let privateKey = """
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgevZzL1gdAFr88hb2
OF/2NxApJCzGCEDdfSp6VQO30hyhRANCAAQRWz+jn65BtOMvdyHKcvjBeBSDZH2r
1RTwjmYSi9R/zpBnuQ4EiMnCqfMPWiZqB4QdbAd0E7oH50VpuZ1P087G
-----END PRIVATE KEY-----
"""
        
        let encoder = JWTEncoder()
        let encoded = encoder.encode(privateKey: privateKey,
                                     issuerID: 14241745,
                                     keyID: UUID(uuidString: "B58A79D0-14D9-4C3C-A6E1-846DF1AAFDEB")!)
        XCTAssertNotNil(encoded)
        print(encoded)
    }
    
    
    static var allTests = [
        ("testExample", testExample),
        ]
}
