import Foundation

public protocol AttributeType: Decodable { }

public struct Entity<Attribute: AttributeType>: Decodable {
    public let id: UUID?
    public let type: String?
    public let attributes: Attribute?
}

public protocol EntityContainerType: Decodable {
    associatedtype Attribute: AttributeType
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
