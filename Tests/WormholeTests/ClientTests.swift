import Foundation
import XCTest
import Wormhole

struct TestingRequestClient: RequestClientType {
    init() { }
    
    var data: Data? = nil
    var response: URLResponse? = nil
    var error: Error? = nil
    
    func request(with request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        completion(data, response, error)
    }
}

final class ClientTests: XCTestCase {
    var requestClient = TestingRequestClient()
    var client: Client {
        let data = loadFixture(privateKey)
        return try! Client(p8Data: data,
                           issuerID: UUID(),
                           keyID: "999999",
                           requestClient: requestClient)
    }
    func makeResponse(to path: String, statusCode: Int) -> HTTPURLResponse {
        let baseURL = URL(string: "https://api.appstoreconnect.apple.com/v1")!
        return HTTPURLResponse(url: baseURL.appendingPathComponent(path),
                               statusCode: statusCode,
                               httpVersion: nil,
                               headerFields: nil)!
    }
    
    func testGet() {
        requestClient.data = loadFixture(userResponse)
        requestClient.response = makeResponse(to: "/users", statusCode: 200)
        client.get(from: "/users") { (result: SingleResult<User>) in
            switch result {
            case .success(let container):
                let user = container.data
                XCTAssertEqual(user.attributes?.firstName, "John")
            case .failure(_):
                XCTFail("Request should be success")
            }
        }
    }
}
