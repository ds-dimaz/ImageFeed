import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private let urlSession = URLSession.shared
    private let builder = URLRequestBuilder.shared
    private let storage = OAuth2TokenStorage.shared
    private var currentTask: URLSessionTask?
    private var lastCode: String?
    
    var isAuthenticated: Bool {
        storage.token != nil
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void ){
        guard !(code == lastCode && currentTask != nil) else {
            return
        }
        
        lastCode = code
        guard let request = authTokenRequest(code: code) else {
            assertionFailure("Не верный запрос")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let currentTask = urlSession.objectTask(for: request) { [weak self] (response: Result<OAuthTokenResponseBody, Error>) in
            self?.currentTask = nil
            switch response {
            case .success(let body):
                let authToken = body.accessToken
                OAuth2TokenStorage().token = authToken
                completion(.success(authToken))
            case .failure(let error):
                self?.lastCode = nil
                completion(.failure(error))
            }
        }
        self.currentTask = currentTask
        currentTask.resume()
    }
}

// MARK: - extension OAuth2Service
extension OAuth2Service {
    private func authTokenRequest(code: String) -> URLRequest? {
        builder.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(AccessKey)"
            + "&&client_secret=\(SecretKey)"
            + "&&redirect_uri=\(RedirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURLString: "https://unsplash.com"
        )
    }
}

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
}
