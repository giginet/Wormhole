import Foundation

public protocol RequestPayloadType: Encodable {
    associatedtype Attribute: AttributeType
    var id: UUID? { get }
    var type: String? { get }
    var attributes: Attribute { get }
}

private enum PayloadCodingKey: String, CodingKey {
    case id
    case type
    case attributes
}

extension RequestPayloadType {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PayloadCodingKey.self)
        if let id = self.id {
            try container.encode(id, forKey: .id)
        }
        if let type = self.type {
            try container.encode(type, forKey: .type)
        }
        var attributeContainer = container.nestedUnkeyedContainer(forKey: .attributes)
        try attributeContainer.encode(attributes)
    }
}

public struct VoidPayload: RequestPayloadType {
    public typealias Attribute = VoidAttribute
    public let attributes = VoidAttribute()
    public let id: UUID? = nil
    public let type: String? = nil
    public func encode(to encoder: Encoder) throws { }
}

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
    var payload: Payload? { get }
}

public extension RequestType {
    var queryItems: [URLQueryItem] {
        return []
    }
}

public extension RequestType where Payload == VoidPayload {
    var payload: Payload? {
        return nil
    }
}
