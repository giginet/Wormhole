import Foundation
import Wormhole

enum Role: String, Codable {
    case developer = "DEVELOPER"
    case marketing = "MARKETING"
}

struct User: AttributeType, PayloadAttachable {
    let firstName: String
    let lastName: String
    let email: String
    let inviteType: String
    let httpBody: Data? = nil
    let roles: [Role]
}
