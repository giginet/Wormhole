import Foundation

public protocol PayloadAttachable {
    var httpBody: Data? { get }
}
extension Array: PayloadAttachable where Element: Encodable { }
extension Dictionary: PayloadAttachable where Key: Encodable, Value: Encodable { }
extension PayloadAttachable where Self: Encodable {
    public var httpBody: Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
}

public struct RequestPayload {
    private struct Payload<Attachment: PayloadAttachable>: Encodable {
        let id: UUID?
        let type: String
        let attributes: Attachment
        
        private enum CodingKeys: CodingKey {
            case id
            case type
            case attributes
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            if let id = id {
                try container.encode(id, forKey: .id)
            }
            try container.encode(type, forKey: .type)
            var attributeContainer = container.nestedUnkeyedContainer(forKey: .attributes)
            try attributeContainer.encode(attributes.httpBody)
        }
    }
    public static let void: RequestPayload = RequestPayload { return nil }
    private let makeHTTPBody: () -> Data?
    internal var httpBody: Data? {
        return makeHTTPBody()
    }
}

public extension RequestPayload {
    public init<Attachment: PayloadAttachable>(id: UUID? = nil, type: String, attributes: Attachment) {
        makeHTTPBody = {
            let encoder = JSONEncoder()
            let payload = Payload(id: id, type: type, attributes: attributes)
            return try? encoder.encode(payload)
        }
    }
}

public enum HTTPMethod: String {
    case get
    case post
    case patch
    case delete
}

public protocol RequestType {
    associatedtype Response: EntityContainerType
    var method: HTTPMethod { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    var payload: RequestPayload { get }
}

public extension RequestType {
    var queryItems: [URLQueryItem] {
        return []
    }
}
