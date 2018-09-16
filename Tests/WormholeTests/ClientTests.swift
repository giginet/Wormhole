import Foundation
import XCTest
import Wormhole
import Result

struct TestingSession: SessionType {
    init() { }
    
    var data: Data? = nil
    var response: URLResponse? = nil
    var error: Error? = nil
    
    func request(with request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
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
            typealias Payload = VoidPayload
            typealias Response = SingleContainer<User>
            let method: HTTPMethod = .get
            let path = "/users"
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
    
    func testDelete() {
        let uuid = UUID()
        session.response = makeResponse(to: "/users/\(uuid.uuidString)", statusCode: 204)
        struct DeleteUserRequest: RequestType {
            typealias Payload = VoidPayload
            typealias Response = VoidContainer
            let id: UUID
            let method: HTTPMethod = .delete
            var path: String {
                return "/users/\(id.uuidString)"
            }
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
