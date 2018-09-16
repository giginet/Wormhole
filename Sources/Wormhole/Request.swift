import Foundation

public enum RequestPayload<Attribute: AttributeType> {
    case none
    case some(id: UUID?, type: String, attributes: Attribute)
}

private enum PayloadCodingKey: String, CodingKey {
    case id
    case type
    case attributes
}

extension RequestPayload {
    func encode(to encoder: Encoder) throws {
        switch self {
        case .none:
            break
        case let .some(uuid, type, attributes):
            var container = encoder.container(keyedBy: PayloadCodingKey.self)
            if let id = uuid {
                try container.encode(id, forKey: .id)
            }
            try container.encode(type, forKey: .type)
            var attributeContainer = container.nestedUnkeyedContainer(forKey: .attributes)
            try attributeContainer.encode(attributes)
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
    associatedtype Payload: AttributeType
    associatedtype Response: EntityContainerType
    var method: HTTPMethod { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    var payload: RequestPayload<Payload> { get }
}

public extension RequestType {
    var queryItems: [URLQueryItem] {
        return []
    }
}
