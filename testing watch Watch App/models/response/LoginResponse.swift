import Foundation

struct LoginResponse: Codable {
    let success: Bool
    let accessToken: String
    let refreshToken: String
    let idToken: String

    enum CodingKeys: String, CodingKey {
        case success = "success"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case idToken = "id_token"
    }
}

