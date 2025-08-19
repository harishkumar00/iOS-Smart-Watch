import Foundation

struct Util {
    func storeValuesinUserDefaults(key: String, value: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
    }
    
    func getValuesFromUserDefaults(key: String) -> String {
        let defaults = UserDefaults.standard
        let value = defaults.string(forKey: key)

        return value ?? ""
    }
}

struct DefaultsManager {
    static func set<T: Encodable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    static func get<T: Decodable>(forKey key: String, as type: T.Type) -> T? {
        if let data = UserDefaults.standard.data(forKey: key),
           let value = try? JSONDecoder().decode(type, from: data) {
            return value
        }
        return nil
    }
    
    static func remove(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    static func contains(_ key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}

