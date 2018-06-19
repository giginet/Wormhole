import Foundation

struct JWTEncoder {
    func encode(privateKey: String, issuerID: Int, keyID: UUID) -> String {
        let impl = JWTEncoderImpl()
        return impl.encode(withPrivateKey: privateKey, issuerID: issuerID, keyID: keyID)
    }
}
