import Foundation

class AuthAPI {
    
    static func login(request: LoginRequest) async -> Result<LoginResponse, Error> {
        do {
            let encodedBody = try JSONEncoder().encode(request)
            guard let req = NetworkService.shared.createAuthRequest(
                endpoint: "/oauth/token",
                method: "POST",
                body: encodedBody
            ) else {
                return .failure(NetworkService.NetworkError.invalidURL)
            }
            
            return await NetworkService.shared
                .performRequest(req, decodingType: LoginResponse.self)
                .mapError { $0 as Error }
        } catch {
            return .failure(error)
        }
    }
    
    static func refreshToken(request: RefreshTokenRequest) async -> Result<TokenResponse, Error> {
        do {
            let encodedBody = try JSONEncoder().encode(request)
            guard let req = NetworkService.shared.createAuthRequest(
                endpoint: "/api/refreshtoken",
                method: "POST",
                body: encodedBody
            ) else {
                return .failure(NetworkService.NetworkError.invalidURL)
            }
            
            return await NetworkService.shared
                .performRequest(req, decodingType: TokenResponse.self)
                .mapError { $0 as Error }
        } catch {
            return .failure(error)
        }
    }
}

