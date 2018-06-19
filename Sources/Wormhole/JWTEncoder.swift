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
    
    func encode(issuerID: Int, keyID: UUID) throws -> String {
        let impl = JWTEncoderImpl()
        return impl.encode(with: privateKey, issuerID: issuerID, keyID: keyID)
    }
}
