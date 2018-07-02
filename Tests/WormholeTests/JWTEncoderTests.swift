import XCTest
@testable import Wormhole

final class JWTEncoderTests: XCTestCase {
    func testEncode() {
        let privateKey = """
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgevZzL1gdAFr88hb2
OF/2NxApJCzGCEDdfSp6VQO30hyhRANCAAQRWz+jn65BtOMvdyHKcvjBeBSDZH2r
1RTwjmYSi9R/zpBnuQ4EiMnCqfMPWiZqB4QdbAd0E7oH50VpuZ1P087G
-----END PRIVATE KEY-----
"""
        
        let encoder = JWTEncoder(privateKey: privateKey)
        let encoded = try! encoder.encode(issuerID: UUID(uuidString: "B58A79D0-14D9-4C3C-A6E1-846DF1AAFDEB")!,
                                          keyID: "14241745")
        XCTAssertNotNil(encoded)
        let components = encoded.split(separator: ".")
        let header = components[0]
        XCTAssertEqual(header, "eyJraWQiOiIxNDI0MTc0NSIsInR5cCI6IkpXVCIsImFsZyI6IkVTMjU2In0")
    }
}
