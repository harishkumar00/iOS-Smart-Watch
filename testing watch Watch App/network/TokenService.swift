import Foundation

class TokenService {
    static let shared = TokenService()
    private init() {}
    
    private var accessToken: String? {
        DefaultsManager.get(forKey: UserDefaultsKeys.ACCESS_TOKEN, as: String.self)
    }
    
    private var refreshToken: String? {
        DefaultsManager.get(forKey: UserDefaultsKeys.REFRESH_TOKEN, as: String.self)
    }
    
    private var email: String? {
        DefaultsManager.get(forKey: UserDefaultsKeys.EMAIL, as: String.self)
    }
    
    private var password: String? {
        DefaultsManager.get(forKey: UserDefaultsKeys.PASSWORD, as: String.self)
    }
    
    func validAccessToken() async -> String? {
        if let token = accessToken, !isTokenExpired(token) {
            return token
        } else {
            return await refreshOrLoginIfNeeded()
        }
    }
    
    private func refreshOrLoginIfNeeded() async -> String? {
        if let token = refreshToken {
            if let newToken = await refreshTokenAPI(token: token) {
                return newToken
            } else if let email = email, let password = password {
                return await login(email: email, password: password)
            } else {
                return nil
            }
        } else if let email = email, let password = password {
            return await login(email: email, password: password)
        } else {
            return nil
        }
    }
    
    private func refreshTokenAPI(token: String) async -> String? {
        let result = await AuthAPI.refreshToken(request: RefreshTokenRequest(refreshToken: token))
        switch result {
        case .success(let response):
            if let accessToken = response.accessToken {
                saveTokens(access: accessToken)
                return accessToken
            } else {
                return nil
            }
        case .failure:
            return nil
        }
    }
    
    private func login(email: String, password: String) async -> String? {
        let result = await AuthAPI.login(request: LoginRequest(email: email, password: password))
        switch result {
        case .success(let response):
            saveTokens(access: response.accessToken, refresh: response.refreshToken)
            return response.accessToken
        case .failure:
            return nil
        }
    }
    
    private func saveTokens(access: String, refresh: String? = nil) {
        UserDefaults.standard.setValue(access, forKey: "accessToken")
        if let refresh = refresh {
            UserDefaults.standard.setValue(refresh, forKey: "refreshToken")
        }
    }
    
    private func isTokenExpired(_ token: String) -> Bool {
        do {
            let parts = token.split(separator: ".")
            if parts.count != 3 { return true }
            
            var base64 = String(parts[1])
                .replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")
            let paddedLength = base64.count + (4 - base64.count % 4) % 4
            base64 = base64.padding(toLength: paddedLength, withPad: "=", startingAt: 0)
            
            guard let payloadData = Data(base64Encoded: base64),
                  let jsonObject = try JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
                  let exp = jsonObject["exp"] as? TimeInterval else {
                return true
            }
            
            return Date().timeIntervalSince1970 >= exp
        } catch {
            print("JWT decoding error: \(error)")
            return true
        }
    }
}
