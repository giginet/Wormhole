import Foundation

public struct AppStoreConnectError: Decodable {
    public struct Source: Decodable {
        let parameter: String
    }
    
    public let id: UUID
    public let status: String
    public let code: String
    public let title: String
    public let detail: String
    public let source: Source?
    
    enum CodingKeys: String, CodingKey {
        case id
        case status
        case code
        case title
        case detail
        case source
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
