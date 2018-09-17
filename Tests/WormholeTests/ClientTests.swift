import Foundation
import XCTest
import Wormhole
import Result

struct TestingSession: SessionType {
    init() { }
    
    var data: Data? = nil
    var response: URLResponse? = nil
    var error: Error? = nil
    var requestBlock: ((URLRequest) -> Void)?
    
    func request(with request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        requestBlock?(request)
        completion(data, response, error)
    }
}

final class ClientTests: XCTestCase {
    var session: TestingSession!
    var client: Client {
        let data = loadFixture(privateKey)
        return try! Client(p8Data: data,
                           issuerID: UUID(),
                           keyID: "999999",
                           session: session)
    }
    
    func makeResponse(to path: String, statusCode: Int) -> HTTPURLResponse {
        let baseURL = URL(string: "https://api.appstoreconnect.apple.com/v1")!
        return HTTPURLResponse(url: baseURL.appendingPathComponent(path),
                               statusCode: statusCode,
                               httpVersion: nil,
                               headerFields: nil)!
    }
    
    override func setUp() {
        session = TestingSession()
        
        super.setUp()
    }
    
    func testGet() {
        session.data = loadFixture(userResponse)
        session.response = makeResponse(to: "/users", statusCode: 200)
        struct UsersRequest: RequestType {
            typealias Response = SingleContainer<User>
            let method: HTTPMethod = .get
            let path = "/users"
            let payload: RequestPayload = .void
        }
        
        session.requestBlock = { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url, URL(string: "https://api.appstoreconnect.apple.com/v1/users")!)
            XCTAssertNil(request.httpBody)
        }
        client.send(UsersRequest()) { (result: Result<SingleContainer<User>, ClientError>) in
            switch result {
            case .success(let container):
                let user = container.data
                XCTAssertEqual(user.attributes?.firstName, "John")
            case .failure(_):
                XCTFail("Request should be success")
            }
        }
    }
    
    func testPost() {
        struct UserInvitation: AttributeType, PayloadAttachable {
            let firstName: String
            let lastName: String
            let email: String
            let roles: [Role]
            let allAppsVisible: Bool
        }
        struct PostUserInvitationRequest: RequestType {
            typealias Response = SingleContainer<UserInvitation>
            let method: HTTPMethod = .post
            let path = "/userInvitations"
            let invitation: UserInvitation
            var payload: RequestPayload {
                return .init(type: "userInvitations", attributes: invitation)
            }
        }
        let request = PostUserInvitationRequest(
            invitation: UserInvitation(firstName: "John",
                                       lastName: "Appleseed",
                                       email: "john-appleseed@mac.com",
                                       roles: [.developer],
                                       allAppsVisible: true)
        )
        session.data = loadFixture(postUserInvitations)
        session.response = makeResponse(to: "/userInvitations", statusCode: 201)
        session.requestBlock = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url, URL(string: "https://api.appstoreconnect.apple.com/v1/userInvitations")!)
            XCTAssertNotNil(request.httpBody)
            let body = try! JSONSerialization.jsonObject(with: request.httpBody!, options: []) as! [String: Any]
            XCTAssertEqual(body.count, 2)
            XCTAssertEqual(body["type"] as! String, "userInvitations")
            XCTAssertNotNil(body["attributes"])
        }
        client.send(request) { result in
            switch result {
            case .success(let createdInvitation):
                XCTAssertEqual(createdInvitation.data.attributes?.firstName, "John")
            case .failure(_):
                XCTFail("Request should be success")
            }
        }
    }
    
    func testPatch() {
        let uuid = UUID()
        struct RoleModificationRequest: RequestType {
            typealias Response = SingleContainer<User>
            let method: HTTPMethod = .patch
            var path: String {
                return "/users/\(id.uuidString.lowercased())"
            }
            let id: UUID
            let roles: [Role]
            var payload: RequestPayload {
                return .init(id: id,
                             type: "users",
                             attributes: roles)
            }
        }
        let request = RoleModificationRequest(id: uuid, roles: [.developer, .marketing])
        session.data = loadFixture(userResponse)
        session.response = makeResponse(to: "/users", statusCode: 200)
        session.requestBlock = { request in
            XCTAssertEqual(request.httpMethod, "PATCH")
            XCTAssertEqual(request.url, URL(string: "https://api.appstoreconnect.apple.com/v1/users/\(uuid.uuidString.lowercased())")!)
            XCTAssertNotNil(request.httpBody)
            let body = try! JSONSerialization.jsonObject(with: request.httpBody!, options: []) as! [String: Any]
            XCTAssertEqual(body.count, 3)
            XCTAssertEqual(body["type"] as! String, "users")
            XCTAssertEqual(body["id"] as! String, uuid.uuidString)
            XCTAssertNotNil(body["attributes"])
        }
        client.send(request) { result in
            switch result {
            case .success(let createdInvitation):
                XCTAssertEqual(createdInvitation.data.attributes?.firstName, "John")
                XCTAssertEqual(createdInvitation.data.attributes?.roles, [.developer])
            case .failure(_):
                XCTFail("Request should be success")
            }
        }
    }
    
    func testDelete() {
        let uuid = UUID()
        session.response = makeResponse(to: "/users/\(uuid.uuidString)", statusCode: 204)
        struct DeleteUserRequest: RequestType {
            typealias Response = VoidContainer
            let id: UUID
            let method: HTTPMethod = .delete
            var path: String {
                return "/users/\(id.uuidString.lowercased())"
            }
            let payload: RequestPayload = .void
        }
        
        session.requestBlock = { request in
            XCTAssertEqual(request.httpMethod, "DELETE")
            XCTAssertEqual(request.url, URL(string: "https://api.appstoreconnect.apple.com/v1/users/\(uuid.uuidString.lowercased())")!)
            XCTAssertNil(request.httpBody)
        }
        client.send(DeleteUserRequest(id: uuid)) { result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                XCTFail("Request should be success")
            }
        }
    }
}
