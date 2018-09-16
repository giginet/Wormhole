import Foundation

public protocol RequestPayloadType: Encodable { }
public struct EmptyPayload: RequestPayloadType { }

public enum HTTPMethod: String {
    case get
    case post
    case patch
    case delete
}

public protocol RequestType {
    associatedtype Request: RequestPayloadType
    associatedtype Response: EntityContainerType
    var method: HTTPMethod { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
}

public extension RequestType {
    var queryItems: [URLQueryItem] {
        return []
    }
}
