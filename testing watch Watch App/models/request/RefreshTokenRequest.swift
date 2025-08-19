import Foundation

struct RefreshTokenRequest: Codable {
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refreshtoken"
    }
}

