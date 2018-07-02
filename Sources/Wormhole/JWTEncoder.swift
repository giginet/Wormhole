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
        let object = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: MemoryLayout<OpaquePointer>.size)
        jwt_new(object)
        defer { jwt_free(object.pointee) }
        
        let keyPointer = convertToCString(privateKey)
        jwt_set_alg(object.pointee,
                    JWT_ALG_ES256,
                    keyPointer,
                    Int32(privateKey.utf16.count + 1))
        jwt_add_header(object.pointee, "kid", keyID)
        
        jwt_add_grant(object.pointee, "iss", issuerID.uuidString.lowercased())
        let expirationDate = Date().addingTimeInterval(20 * 60)
        jwt_add_grant_int(object.pointee, "exp", Int(expirationDate.timeIntervalSince1970))
        jwt_add_grant(object.pointee, "aud", "appstoreconnect-v1")
        
        guard let encodedCString = jwt_encode_str(object.pointee) else {
            throw Error.decodeError
        }
        
        return String(cString: encodedCString)
    }
}

fileprivate func convertToCString(_ string: String) -> UnsafeMutablePointer<UInt8>? {
    let result = string.withCString { c -> (Int, UnsafeMutablePointer<Int8>?) in
        let len = Int(strlen(c) + 1)
        let dst = strcpy(UnsafeMutablePointer<CChar>.allocate(capacity: len), c)
        return (len, dst)
    }
    let uint8 = UnsafeMutablePointer<UInt8>.allocate(capacity: result.0)
    memcpy(uint8, result.1, result.0)
    result.1?.deallocate()
    return uint8
}
