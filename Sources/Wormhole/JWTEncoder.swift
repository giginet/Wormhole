import Foundation

struct JWTEncoder {
    enum Error: Swift.Error {
        case keyNotFound
        case decodeError
    }
    
    private let privateKey: String
    
    init(fileURL: URL) throws {
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            throw Error.keyNotFound
        }
        let privateKey = try String(contentsOf: fileURL)
        self.init(privateKey: privateKey)
    }
    
    init(privateKey: String) {
        self.privateKey = privateKey
    }
    
    func encode(issuerID: UUID, keyID: String) throws -> String {
//        let header = UnsafeMutablePointer<json_t>.allocate(capacity: MemoryLayout<json_t>.size)
        let header = json_object()
        let alg = json_string("ES256")
        let typ = json_string("JWT")
        let kid = json_string(keyID.cString(using: .utf8))
        json_object_set(header, "alg", alg)
        json_object_set(header, "typ", typ)
        json_object_set(header, "kid", kid)
        
        let payload = json_object()
        let iss = json_string(issuerID.uuidString.lowercased().cString(using: .utf8))
        let exp = json_integer(json_int_t(Date(timeIntervalSinceNow: 60 * 20).timeIntervalSince1970))
        let aud = json_string("appstoreconnect-v1")
        json_object_set(payload, "iss", iss)
        json_object_set(payload, "exp", exp)
        json_object_set(payload, "aud", aud)
        
        let jwkObject = json_object()
        json_object_set(jwkObject, "alg", json_string("ES256"))
        
        let dlen = jose_jwk_thp_buf(nil, nil, "ES256", nil, 0)
        let dec = UnsafeMutablePointer<UInt8>.allocate(capacity: dlen)
        let elen = jose_b64_enc_buf(nil, dlen, nil, 0)
        let enc = UnsafeMutablePointer<UInt8>.allocate(capacity: elen)
        
        jose_jwk_thp_buf(nil, jwkObject, "ES256", dec, dlen)
        jose_b64_enc_buf(dec, dlen, enc, elen)
//        jose_jwk_gen(nil, jwk)
        
//        return impl.encode(with: privateKey, issuerID: issuerID, keyID: keyID)
        return String(cString: enc)
    }
}
