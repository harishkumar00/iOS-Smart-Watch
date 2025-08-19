//import Foundation
//
//class APIManager: ObservableObject {
//    
//    @Published var deviceData: Device?
//    @Published var errorMessage: String?
//        
//    private func createRequest(endpoint: String, method: String, body: Data? = nil) -> URLRequest? {
//        guard let url = URL(string: "\(EnvConfig.values.baseUrl)\(endpoint)") else { return nil }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = method
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        if let body = body {
//            request.httpBody = body
//        }
//        return request
//    }
//
//    private func performRequest<T: Decodable>(
//        _ request: URLRequest,
//        decodingType: T.Type,
//        retryOnAuthFailure: Bool = true,
//        completion: @escaping (T?, String?) -> Void
//    ) {
//        var authorizedRequest = request
//        authorizedRequest.setValue("Bearer \(DataUtil.accessToken)", forHTTPHeaderField: "Authorization")
//
//        URLSession.shared.dataTask(with: authorizedRequest) { [weak self] data, response, error in
//            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401, retryOnAuthFailure {
//                print("⚠️ Unauthorized, attempting to refresh token...")
//                DataUtil.refreshAccessToken { success in
//                    if success {
//                        self?.performRequest(request, decodingType: decodingType, retryOnAuthFailure: false, completion: completion)
//                    } else {
//                        DispatchQueue.main.async {
//                            completion(nil, "Unauthorized and failed to refresh token.")
//                        }
//                    }
//                }
//            } else {
//                self?.handleResponse(data: data, response: response, error: error, decodingType: decodingType, completion: completion)
//            }
//        }.resume()
//    }
//
//    private func handleResponse<T: Decodable>(
//        data: Data?,
//        response: URLResponse?,
//        error: Error?,
//        decodingType: T.Type,
//        completion: @escaping (T?, String?) -> Void
//    ) {
//        print("Data", response ?? "No data")
//        if let error = error {
//            DispatchQueue.main.async {
//                completion(nil, "Error: \(error.localizedDescription)")
//                print("Error:", error.localizedDescription)
//            }
//            return
//        }
//        
//        guard let data = data else {
//            DispatchQueue.main.async {
//                completion(nil, "No data received")
//            }
//            return
//        }
//        
//        do {
//            let decodedResponse = try JSONDecoder().decode(decodingType, from: data)
//            DispatchQueue.main.async {
//                completion(decodedResponse, nil)
//            }
//        } catch let error {
//            DispatchQueue.main.async {
//                completion(nil, "Failed to decode response: \(error.localizedDescription)")
//                print("Error decoding data:", error)
//            }
//        }
//    }
//    
//    // Fetch Device Details
//    func fetchDeviceData(deviceId: String, completion: @escaping (Device?, String?) -> Void) {
//        guard let request = createRequest(endpoint: "/api/devices/\(deviceId)", method: "GET") else {
//            completion(nil, "Invalid URL")
//            return
//        }
//        
//        print("Harish calling API")
//
//        performRequest(request, decodingType: Device.self, completion: completion)
//    }
//    
//    // Update Device Details
//    func updateDeviceData(deviceId: String, updatedDevice: Device) {
//        do {
//            let encoder = JSONEncoder()
//            encoder.keyEncodingStrategy = .convertToSnakeCase
//            let jsonData = try encoder.encode(updatedDevice)
//            
//            guard let request = createRequest(endpoint: "/api/devices/\(deviceId)", method: "PUT", body: jsonData) else { return }
//            
//            performRequest(request, decodingType: Response.self) { [weak self] response, errorMessage in
//                DispatchQueue.main.async {
//                    if let response = response {
//                        print("Device updated successfully:", response)
//                    } else if let errorMessage = errorMessage {
//                        self?.errorMessage = errorMessage
//                    }
//                }
//            }
//        } catch let error {
//            DispatchQueue.main.async {
//                self.errorMessage = "Failed to encode updated device: \(error.localizedDescription)"
//                print("Error encoding device data:", error)
//            }
//        }
//    }
//}
//
