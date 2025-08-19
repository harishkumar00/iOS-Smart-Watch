import Foundation

struct EnvValues {
    let baseUrl: String
    let authUrl: String
}

enum Env: String {
    case production = "PRODUCTION"
    case atlas = "ATLAS"
    case aura = "AURA"
    case auraqe = "AURAQE"
    case core = "CORE"
    case coreqe = "COREQE"
    case opcertify = "OPCERTIFY"
    case pulse = "PULSE"
    case qeop = "QEOP"
    
    var values: EnvValues {
        switch self {
        case .production:
            return EnvValues(baseUrl: "https://app2.keyless.rocks", authUrl: "https://remotapp.rently.com")
        case .atlas:
            return EnvValues(baseUrl: "https://smarthome.rentlyatlas.com", authUrl: "https://remotapp.rentlyatlas.com")
        case .aura:
            return EnvValues(baseUrl: "https://smarthome.rentlyaura.com", authUrl: "https://remotapp.rentlyprotons.com")
        case .auraqe:
            return EnvValues(baseUrl: "https://smarthome.qe.rentlyaura.com", authUrl: "https://remotapp.qe.rentlyaura.com")
        case .core:
            return EnvValues(baseUrl: "https://smarthome.rentlycore.com", authUrl: "https://remotapp.rentlycore.com")
        case .coreqe:
            return EnvValues(baseUrl: "https://smarthome.qe.rentlycore.com", authUrl: "https://remotapp.qe.rentlycore.com")
        case .opcertify:
            return EnvValues(baseUrl: "https://smarthome.rentlycertify.com", authUrl: "https://remotapp.rentlycertify.com")
        case .pulse:
            return EnvValues(baseUrl: "https://smarthome.rentlypulse.com", authUrl: "https://remotapp.rentlypulse.com")
        case .qeop:
            return EnvValues(baseUrl: "https://smarthome.rentlyqeop.com", authUrl: "https://remotapp.rentlyqeop.com")
        }
    }
}

class EnvConfig {
    static let current: Env = .qeop

    static var values: EnvValues {
        return current.values
    }
}

