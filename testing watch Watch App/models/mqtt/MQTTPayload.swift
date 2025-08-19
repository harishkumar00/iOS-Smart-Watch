import Foundation

struct MqttPayload: Codable {
    let state: MQTTState?
}

struct MQTTState: Codable {
    let reported: Reported?
}

struct Reported: Codable {
    let thingName: String?
    let status: Status?
    
    enum CodingKeys: String, CodingKey {
        case thingName = "thing_name"
        case status
    }
}

struct Status: Codable {
    let mode: MQTTMode?
    let thermostatMode: String?
    let coolingSetpoint: Int?
    let heatingSetpoint: Int?
    
    enum CodingKeys: String, CodingKey {
        case mode
        case thermostatMode = "thermostat_mode"
        case coolingSetpoint = "cooling_setpoint"
        case heatingSetpoint = "heating_setpoint"
    }
}

struct MQTTMode: Codable {
    let type: String?
    let source: String?
    let agentId: Int64?
    
    enum CodingKeys: String, CodingKey {
        case type
        case source
        case agentId = "agent_id"
    }
}

