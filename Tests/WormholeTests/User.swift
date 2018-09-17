import Foundation
import Wormhole

struct User: AttributeType, PayloadAttachable {
    let firstName: String
    let lastName: String
    let email: String
    let inviteType: String
    let httpBody: Data? = nil
}
