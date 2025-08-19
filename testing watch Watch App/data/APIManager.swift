import Foundation

class APIManager {
    
    static let shared = APIManager() // Singleton pattern for reusability
    
    private init() {}
    
    private func createRequest(endpoint: String, method: String, body: Data? = nil) -> URLRequest? {
        guard let url = URL(string: "\(EnvConfig.values.baseUrl)\(endpoint)") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = body {
            request.httpBody = body
        }
        return request
    }
    
    func performRequest<T: Decodable>(
        endpoint: String,
        method: String,
        body: Data? = nil,
        decodingType: T.Type,
        retryOnAuthFailure: Bool = true,
        completion: @escaping (Result<T, String>) -> Void
    ) {
        guard let request = createRequest(endpoint: endpoint, method: method, body: body) else {
            completion(.failure("Invalid URL"))
            return
        }
        
        var authorizedRequest = request
        authorizedRequest.setValue("Bearer \(DataUtil.accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: authorizedRequest) { [weak self] data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401, retryOnAuthFailure {
                print("⚠️ Unauthorized, refreshing token...")
                DataUtil.refreshAccessToken { success in
                    if success {
                        self?.performRequest(
                            endpoint: endpoint,
                            method: method,
                            body: body,
                            decodingType: decodingType,
                            retryOnAuthFailure: false,
                            completion: completion
                        )
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure("Unauthorized and token refresh failed"))
                        }
                    }
                }
            } else {
                self?.handleResponse(data: data, error: error, decodingType: decodingType, completion: completion)
            }
        }.resume()
    }
    
    private func handleResponse<T: Decodable>(
        data: Data?,
        error: Error?,
        decodingType: T.Type,
        completion: @escaping (Result<T, String>) -> Void
    ) {
        if let error = error {
            DispatchQueue.main.async {
                completion(.failure("Network Error: \(error.localizedDescription)"))
            }
            return
        }
        
        guard let data = data else {
            DispatchQueue.main.async {
                completion(.failure("No data received"))
            }
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode(decodingType, from: data)
            DispatchQueue.main.async {
                completion(.success(decoded))
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure("Decoding failed: \(error.localizedDescription)"))
            }
        }
    }
}
