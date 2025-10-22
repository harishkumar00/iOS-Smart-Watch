import Foundation

class DeviceAPI {    
    
    static func fetchDevice(deviceId: String) async -> Device? {
        guard let request = await NetworkService.shared.createBaseRequest(
            endpoint: "/api/devices/\(deviceId)",
            method: "GET"
        ) else {
            return nil
        }
        
        let result: Result<Device, NetworkService.NetworkError> = await NetworkService.shared.performRequest(request, decodingType: Device.self)
        switch result {
        case .success(let device): return device
        case .failure(let error):
            print("Failed to fetch device \(deviceId): \(error)")
            return nil
        }
    }
    
    static func updateDevice(deviceId: String, requestBody: DeviceUpdateRequest) async -> Result<UpdateDeviceDetailsResponse, Error> {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        guard let data = try? encoder.encode(requestBody),
              let request = await NetworkService.shared.createBaseRequest(
                endpoint: "/api/devices/\(deviceId)",
                method: "PUT",
                body: data
              )
        else {
            return .failure(NetworkService.NetworkError.invalidURL)
        }
        
        return await NetworkService.shared.performRequest(request, decodingType: UpdateDeviceDetailsResponse.self)
            .mapError { $0 as Error } // TODO:: map NetworkError to Error for interface consistency
    }
    
    static func getCognitoCredentials(assetId: String) async -> Result<GetCognitoCredentialsResponse, Error> {
        guard let request = await NetworkService.shared.createBaseRequest(
            endpoint: "/api/properties/\(assetId)/cognito_credentials",
            method: "GET"
        ) else {
            return .failure(NetworkService.NetworkError.invalidURL)
        }
        
        return await NetworkService.shared
            .performRequest(request, decodingType: GetCognitoCredentialsResponse.self)
            .mapError { $0 as Error }
    }
}
