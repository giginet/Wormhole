import Foundation

public protocol AttributeType: Codable { }
public struct VoidAttribute: AttributeType { }

public struct Entity<Attribute: AttributeType>: Decodable {
    public let id: UUID?
    public let type: String?
    public let attributes: Attribute?
}

public protocol EntityContainerType: Decodable {
    associatedtype Attribute: AttributeType
    init?(from data: Data?)
}

public extension EntityContainerType {
    public init?(from data: Data?) {
        return nil
    }
}

private enum EntityCodingKeys: String, CodingKey {
    case data
}

public struct SingleContainer<Attribute: AttributeType>: Decodable, EntityContainerType {
    public let data: Entity<Attribute>
    
    init(_ decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: EntityCodingKeys.self)
        var nested = try container.nestedUnkeyedContainer(forKey: .data)
        data = try nested.decode(Entity<Attribute>.self)
    }
}

public struct CollectionContainer<Attribute: AttributeType>: Decodable, EntityContainerType {
    public let data: [Entity<Attribute>]
    
    init(_ decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: EntityCodingKeys.self)
        var nested = try container.nestedUnkeyedContainer(forKey: .data)
        data = try nested.decode([Entity<Attribute>].self)
    }
}

public struct VoidContainer: Decodable, EntityContainerType {
    public typealias Attribute = VoidAttribute
    
    init(_ decoder: Decoder) { }
    
    public init?(from data: Data?) { }
}
