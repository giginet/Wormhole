import Foundation

public protocol RequestPayloadType: Encodable { }
public struct VoidPayload: RequestPayloadType { }

public enum HTTPMethod: String {
    case get
    case post
    case patch
    case delete
}

public protocol RequestType {
    associatedtype Payload: RequestPayloadType
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
