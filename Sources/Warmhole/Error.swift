import Foundation

public struct AppStoreConnectError: Error, Decodable {
    public struct Source: Decodable {
        let parameter: String
    }
    
    let id: UUID
    let status: String
    let code: String
    let title: String
    let detail: String
    let source: Source?
    
    enum CodingKeys: CodingKey {
        case id
        case status
        case code
        case title
        case detail
        case source
    }
}
