import Foundation
import Result

private let baseEndpointURL = URL(string: "https://api.appstoreconnect.apple.com/")!

public protocol RequestClientType {
    func request(with request: URLRequest,
                 completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void)
}

public struct URLSessionClient: RequestClientType {
    public init() { }
    public func request(with request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: request, completionHandler: completion).resume()
    }
}

public enum ClientError: Swift.Error {
    case decodeError(Error?)
    case apiError([AppStoreConnectError])
    case unknown
}

public typealias SingleResult<Attribute: AttributeType> = Result<SingleContainer<Attribute>, ClientError>
public typealias CollectionResult<Attribute: AttributeType> = Result<CollectionContainer<Attribute>, ClientError>

public struct Client {
    private var requestClient: RequestClientType
    public typealias Completion<EntityContainer: EntityContainerType> = (Result<EntityContainer, ClientError>) -> Void
    
    public enum APIVersion: String {
        case v1
    }
    
    private enum Method: String {
        case get
        case post
        case patch
        case delete
    }
    
    private let token: String
    private var apiVersion: APIVersion = .v1
    private let decoder = JSONDecoder()
    
    private var baseURL: URL {
        return baseEndpointURL.appendingPathComponent(apiVersion.rawValue)
    }
    
    private func urlRequest(of method: Method, to url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(token)"
        ]
        request.httpMethod = method.rawValue.uppercased()
        return request
    }
    
    public init(p8Path: URL,
                issuerID: UUID,
                keyID: String,
                requestClient: RequestClientType = URLSessionClient()) throws {
        let encoder = try JWTEncoder(fileURL: p8Path)
        let token = try encoder.encode(issuerID: issuerID, keyID: keyID)
        self.requestClient = requestClient
        self.token = token
    }
    
    public func get<EntityContainer: EntityContainerType>(from path: String,
                                                          queryItems: [URLQueryItem] = [],
                                                          completion: @escaping Completion<EntityContainer>) {
        var components = URLComponents()
        components.path = path
        components.queryItems = queryItems
        guard let url = components.url(relativeTo: components.url(relativeTo: baseURL)) else {
            return
        }
        let request = urlRequest(of: .get, to: url)
        requestClient.request(with: request) { data, response, error in
            let result: Result<EntityContainer, ClientError>
            if let data = data {
                do {
                    if error == nil {
                        let response = try self.decoder.decode(EntityContainer.self, from: data)
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
        }
    }
    
    public func delete(contentsOf path: String,
                       completion: @escaping (Result<Void, ClientError>) -> Void) {
        let url = baseURL.appendingPathComponent(path)
        let request = urlRequest(of: .delete, to: url)
        requestClient.request(with: request) { data, response, error in
            let result: Result<Void, ClientError>
            if let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 204 {
                result = .init(value: ())
            } else if let data = data {
                do {
                    let errorContainer = try self.decoder.decode(ErrorsContainer.self, from: data)
                    result = .init(error: .apiError(errorContainer.errors))
                } catch {
                    result = .init(error: .decodeError(error))
                }
            } else {
                result = .init(error: .unknown)
            }
            completion(result)
            }
    }
}
