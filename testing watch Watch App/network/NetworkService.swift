import Foundation

// TODO:: Also add interceptor for Internet
final class NetworkService {
    static let shared = NetworkService()
    private init() {}

    enum NetworkError: Error {
        case invalidURL
        case noData
        case decodingError(Error)
        case serverError(Int, String?)
        case unknown(Error)
    }

    func createBaseRequest(endpoint: String, method: String, body: Data? = nil) async -> URLRequest? {
        guard let url = URL(string: "\(EnvConfig.values.baseUrl)\(endpoint)") else {
            print("Network: Invalid base URL for endpoint: \(endpoint)")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = await TokenService.shared.validAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            // TODO::
            print("Network: No valid token available")
        }

        request.httpBody = body
        return request
    }

    func createAuthRequest(endpoint: String, method: String, body: Data? = nil) -> URLRequest? {
        guard let url = URL(string: "\(EnvConfig.values.authUrl)\(endpoint)") else {
            print("Network: Invalid auth URL for endpoint: \(endpoint)")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        return request
    }

    func performRequest<T: Decodable>(
        _ request: URLRequest,
        decodingType: T.Type
    ) async -> Result<T, NetworkError> {
        logRequest(request)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.noData)
            }

            if !(200..<300).contains(httpResponse.statusCode) {
                let errorMessage = String(data: data, encoding: .utf8)
                print("Network: Server Error \(httpResponse.statusCode) - \(errorMessage ?? "Unknown Error")")
                return .failure(.serverError(httpResponse.statusCode, errorMessage))
            }

            logResponse(data)

            let decoded = try JSONDecoder().decode(decodingType, from: data)
            return .success(decoded)
        } catch let decodingError as DecodingError {
            print("Network: Decoding error: \(decodingError)")
            return .failure(.decodingError(decodingError))
        } catch {
            print("Network: Unknown error: \(error)")
            return .failure(.unknown(error))
        }
    }

    private func logRequest(_ request: URLRequest) {
        var log = "\n API: REQUEST → \(request.httpMethod ?? "UNKNOWN") \(request.url?.absoluteString ?? "")"

        if let body = request.httpBody, !body.isEmpty {
            if let json = try? JSONSerialization.jsonObject(with: body, options: .mutableContainers),
               let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let prettyString = String(data: pretty, encoding: .utf8) {
                log += "\n API: BODY → \(prettyString)"
            } else if let raw = String(data: body, encoding: .utf8) {
                log += "\n API: BODY (raw) → \(raw)"
            }
        }

        print(log)
    }


    private func logResponse(_ data: Data) {
        guard !data.isEmpty else {
            print("\n API: RESPONSE → <empty>")
            return
        }

        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("\n API: RESPONSE → \(prettyString)")
        } else if let rawString = String(data: data, encoding: .utf8) {
            print("\n API: RESPONSE (raw) → \(rawString)")
        } else {
            print("\n API: RESPONSE → <non-UTF8 or unreadable>")
        }
    }
}
