import Network
import Foundation

final class ConnectivityService {
    static let shared = ConnectivityService()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private(set) var isConnected: Bool = true
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = (path.status == .satisfied)
            print("Network Status:", self?.isConnected == true ? "Connected" : "Disconnected")
        }
        
        monitor.start(queue: queue)
    }
}

final class NetworkService {
    static let shared = NetworkService()
    private init() {}
    
    enum NetworkError: Error {
        case invalidURL
        case noData
        case noInternet
        case decodingError(Error)
        case serverError(Int, String?)
        case unknown(Error)
    }
    
    func createBaseRequest(endpoint: String, method: String, body: Data? = nil) async -> URLRequest? {
        
        guard ConnectivityService.shared.isConnected else {
            ErrorViewModel.shared.showError(
                title: "No Internet Connection",
                message: "Please check your network connection and try again."
            )
            print("API: Request Cancelled → No Internet")
            return nil
        }
        
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
            ErrorViewModel.shared.showSyncRequired()
            return nil
        }
        
        request.httpBody = body
        return request
    }
    
    func createAuthRequest(endpoint: String, method: String, body: Data? = nil) -> URLRequest? {
        
        guard ConnectivityService.shared.isConnected else {
            ErrorViewModel.shared.showError(
                title: "No Internet Connection",
                message: "Please check your network connection and try again."
            )
            print("API: Auth Request Cancelled → No Internet")
            return nil
        }
        
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
        
        if ConnectivityService.shared.isConnected == false {
            ErrorViewModel.shared.showError(
                title: "No Internet Connection",
                message: "Please check your network connection and try again."
            )
            print("API: Cancelled → No Internet")
            return .failure(.noInternet)
        }
        
        logRequest(request)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.noData)
            }
            
            if !(200..<300).contains(httpResponse.statusCode) {
                let errorMessage = String(data: data, encoding: .utf8)
                
                switch httpResponse.statusCode {
                case 400, 401, 403:
                    ErrorViewModel.shared.showSyncRequired()
                case 500...599:
                    ErrorViewModel.shared.showSyncRequired()
                default:
                    ErrorViewModel.shared.showError(
                        title: "Server Error: \(httpResponse.statusCode)",
                        message: errorMessage ?? "Unknown error occurred."
                    )
                }

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
