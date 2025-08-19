import Foundation

class NetworkService {
    static let shared = NetworkService()

    private init() {}

    func createRequest(endpoint: String, method: String, body: Data? = nil) -> URLRequest? {
        guard let url = URL(string: "\(EnvConfig.values.baseUrl)\(endpoint)") else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(DataUtil.accessToken)", forHTTPHeaderField: "Authorization")

        if let body = body {
            request.httpBody = body
        }

        return request
    }

    func performRequest<T: Decodable>(
        _ request: URLRequest,
        retryOnAuthFailure: Bool = true,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 401, retryOnAuthFailure {
                print("⚠️ Unauthorized, attempting token refresh...")

                DataUtil.refreshAccessToken { success in
                    if success, let refreshedRequest = self.cloneRequestWithNewToken(request) {
                        self.performRequest(refreshedRequest, retryOnAuthFailure: false, completion: completion)
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized and failed to refresh token."])))
                        }
                    }
                }
                return
            }

            self.handleResponse(data: data, error: error, completion: completion)
        }.resume()
    }

    private func handleResponse<T: Decodable>(
        data: Data?,
        error: Error?,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        if let error = error {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }

        guard let data = data else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received."])))
            }
            return
        }

        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            DispatchQueue.main.async {
                completion(.success(decoded))
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response: \(error.localizedDescription)"])))
            }
        }
    }

    private func cloneRequestWithNewToken(_ request: URLRequest) -> URLRequest? {
        guard let url = request.url else { return nil }

        var newRequest = URLRequest(url: url)
        newRequest.httpMethod = request.httpMethod
        newRequest.httpBody = request.httpBody
        newRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        newRequest.setValue("Bearer \(DataUtil.accessToken)", forHTTPHeaderField: "Authorization")

        return newRequest
    }
}

