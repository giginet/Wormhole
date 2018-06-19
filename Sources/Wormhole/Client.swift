import Foundation

public class Client {
    public enum APIVersion: String {
        case v1
    }
    
    public enum Method: String {
        case get
        case post
        case patch
        case delete
    }
    
    private let token: String
    private var apiVersion: APIVersion = .v1
    private static let baseURL = URL(string: "https://api.appstoreconnect.apple.com/")!
    
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
    
    public func get(to path: String,
                    queryItems: [URLQueryItem] = []) {
        var components = URLComponents()
        components.path = path
        components.queryItems = queryItems
        guard let url = components.url(relativeTo: components.url(relativeTo: baseURL)) else {
            return
        }
        let request = urlRequest(of: .get, to: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
        }.resume()
    }
}
