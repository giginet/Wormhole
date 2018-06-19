import Foundation
import Result

public class Client {
    public typealias Completion<Entity: EntityType> = (Result<Entity, ClientError>) -> Void
    
    public enum APIVersion: String {
        case v1
    }
    
    private enum Method: String {
        case get
        case post
        case patch
        case delete
    }
    
    public enum ClientError: Swift.Error {
        case decodeError(Error?)
        case apiError([AppStoreConnectError])
        case unknown
    }
    
    private let token: String
    private var apiVersion: APIVersion = .v1
    private static let baseURL = URL(string: "https://api.appstoreconnect.apple.com/")!
    private let decoder = JSONDecoder()
    
    private var baseURL: URL {
        return Client.baseURL.appendingPathComponent(apiVersion.rawValue)
    }
    
    private func urlRequest(of method: Method, to url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(token)"
        ]
        request.httpMethod = method.rawValue.uppercased()
        return request
    }
    
    public init(p8Path: URL, issuerID: Int, keyID: UUID) throws {
        let encoder = try JWTEncoder(fileURL: p8Path)
        token = try encoder.encode(issuerID: issuerID, keyID: keyID)
    }
    
    public func get<Entity: EntityType>(to path: String,
                                        queryItems: [URLQueryItem] = [],
                                        completion: @escaping Completion<Entity>) {
        var components = URLComponents()
        components.path = path
        components.queryItems = queryItems
        guard let url = components.url(relativeTo: components.url(relativeTo: baseURL)) else {
            return
        }
        let request = urlRequest(of: .get, to: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            let result: Result<Entity, ClientError>
            if let data = data {
                do {
                    if error == nil {
                        let response = try self.decoder.decode(Entity.self, from: data)
                        result = .init(value: response)
                    } else {
                        let errorContainer = try self.decoder.decode(ErrorsContainer.self, from: data)
                        result = .init(error: .apiError(errorContainer.errors))
                    }
                } catch {
                    result = .init(error: .decodeError(error))
                }
            } else {
                result = .init(error: .unknown)
            }
            completion(result)
            }.resume()
    }
}
