import Foundation

public protocol AttributeType: Decodable { }

public struct Entity<Attribute: AttributeType>: Decodable {
    let id: UUID?
    let type: String?
    let attributes: Attribute?
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case attributes
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        attributes = try container.decodeIfPresent(Attribute.self, forKey: .attributes)
    }
}

private enum EntityCodingKeys: String, CodingKey {
    case data
}

struct EntityContainer<Attribute: AttributeType>: Decodable {
    let data: Entity<Attribute>
    
    init(_ decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: EntityCodingKeys.self)
        var nested = try container.nestedUnkeyedContainer(forKey: .data)
        data = try nested.decode(Entity<Attribute>.self)
    }
}

struct EntityCollectionContainer<Attribute: AttributeType>: Decodable {
    let data: [Entity<Attribute>]
    
    init(_ decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: EntityCodingKeys.self)
        var nested = try container.nestedUnkeyedContainer(forKey: .data)
        data = try nested.decode([Entity<Attribute>].self)
    }
}
