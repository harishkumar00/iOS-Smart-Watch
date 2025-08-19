import Foundation

enum MQTT {
    static let timeoutSeconds: TimeInterval = 8
    static var timeoutNanoseconds: UInt64 {
        UInt64(timeoutSeconds * 1_000_000_000)
    }
}

enum UserDefaultsKeys {
    static let EMAIL: String = "EMAIL"
    static let PASSWORD: String = "PASSWORD"
    static let ACCESS_TOKEN: String = "ACCESS_TOKEN"
    static let REFRESH_TOKEN: String = "REFRESH_TOKEN"
    static let ASSET_DEVICE_MAP: String = "ASSET_DEVICE_MAP"
}

enum Thermostat_Constants {
    static let MINIMUM_SET_POINT: Int = 45
    static let MAXIMUM_SET_POINT: Int = 99
}
