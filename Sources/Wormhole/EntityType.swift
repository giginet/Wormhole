import Foundation

public protocol EntityType: Decodable { }

struct EntityContainer<Entity: EntityType>: Decodable {
    let data: Entity
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    init(_ decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var nested = try container.nestedUnkeyedContainer(forKey: .data)
        data = try nested.decode(Entity.self)
    }
}

extension Array: EntityType where Element: EntityType { }
