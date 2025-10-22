import Foundation

enum DeviceUpdateRequest: Encodable {
    case lock(LockCommand)
    case thermostat(ThermostatCommand)
    
    enum CodingKeys: String, CodingKey {
        case commands
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .lock(let command):
            try container.encode(command, forKey: .commands)
        case .thermostat(let command):
            try container.encode(command, forKey: .commands)
        }
    }
}

struct LockCommand: Encodable {
    let mode: String
}

struct ThermostatCommand: Encodable {
    let mode: String?
    let setpoint: Int?
    let heatingSetpoint: Int?
    let coolingSetpoint: Int?
    
    enum CodingKeys: String, CodingKey {
        case mode
        case setpoint
        case heatingSetpoint = "heating_setpoint"
        case coolingSetpoint = "cooling_setpoint"
    }
}


