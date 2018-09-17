import Foundation
import Result

private let baseEndpointURL = URL(string: "https://api.appstoreconnect.apple.com/")!

public protocol SessionType {
    func request(with request: URLRequest,
                 completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void)
}

public struct HTTPSession: SessionType {
    public init() { }
    public func request(with request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: request, completionHandler: completion).resume()
    }
}

public enum ClientError: Swift.Error {
    case invalidRequest
    case decodeError(Error?)
    case apiError([AppStoreConnectError])
    case unknown
}

public struct Client {
    private var session: SessionType
    public typealias Completion<EntityContainer: EntityContainerType> = (Result<EntityContainer, ClientError>) -> Void
    
    public enum APIVersion: String {
        case v1
    }
    
    private let token: String
    private var apiVersion: APIVersion = .v1
    private let decoder = JSONDecoder()
    
    private var baseURL: URL {
        return baseEndpointURL.appendingPathComponent(apiVersion.rawValue)
    }
    
    private func buildURLRequest<Request: RequestType>(from request: Request) throws -> URLRequest {
        var urlComponent = URLComponents()
        urlComponent.path = request.path
        urlComponent.queryItems = request.queryItems
        guard let url = urlComponent.url(relativeTo: baseURL) else {
            throw ClientError.invalidRequest
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = [
            "Authorization": "Bearer \(token)"
        ]
        urlRequest.httpMethod = request.method.rawValue.uppercased()
        switch request.payload {
        case .none: break
        case .some(_, _, let attachment):
            urlRequest.httpBody = attachment.httpBody
        }
        return urlRequest
    }
    
    public init(p8Path: URL,
                issuerID: UUID,
                keyID: String,
                session: SessionType = HTTPSession()) throws {
        let encoder = try JWTEncoder(fileURL: p8Path)
        let token = try encoder.encode(issuerID: issuerID, keyID: keyID)
        self.session = session
        self.token = token
    }
    
    public init(p8Data: Data,
                issuerID: UUID,
                keyID: String,
                session: SessionType = HTTPSession()) throws {
        let encoder = try JWTEncoder(data: p8Data)
        let token = try encoder.encode(issuerID: issuerID, keyID: keyID)
        self.session = session
        self.token = token
    }
    
    public func send<Request: RequestType>(_ request: Request,
                                           completion: @escaping (Result<Request.Response, ClientError>) -> Void) {
        let urlRequest: URLRequest
        do {
            urlRequest = try buildURLRequest(from: request)
        } catch {
            let clientError = (error as? ClientError) ?? ClientError.unknown
            return completion(Result(error: clientError))
        }
        session.request(with: urlRequest) { data, response, error in
            let result: Result<Request.Response, ClientError>
            if let data = data {
                do {
                    if error == nil {
                        let response = try self.decoder.decode(Request.Response.self, from: data)
                        result = .init(value: response)
                    } else {
                        let errorContainer = try self.decoder.decode(ErrorsContainer.self, from: data)
                        result = .init(error: .apiError(errorContainer.errors))
                    }
                } catch {
                    result = .init(error: .decodeError(error))
                }
            } else {
                if let container = Request.Response(from: data) {
                    result = .init(value: container)
                } else {
                    result = .init(error: .unknown)
                }
            }
            completion(result)
        }
    }
}
