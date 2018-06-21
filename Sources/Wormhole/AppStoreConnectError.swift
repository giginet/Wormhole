import Foundation

public struct AppStoreConnectError: Decodable, CustomStringConvertible {
    public struct Source: Decodable {
        let parameter: String?
    }
    
    public let id: UUID
    public let status: String
    public let code: String
    public let title: String
    public let detail: String
    public let source: Source?
    public var description: String {
        return "\(status) \(title): \(detail)"
    }
}

struct ErrorsContainer: Decodable {
    let errors: [AppStoreConnectError]
    
    enum CodingKeys: String, CodingKey {
        case errors
    }
    
    init(_ decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var nested = try container.nestedUnkeyedContainer(forKey: .errors)
        errors = try nested.decode([AppStoreConnectError].self)
    }
}
