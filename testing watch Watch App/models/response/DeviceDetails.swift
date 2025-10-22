import Foundation

struct Device: Codable {
    let batteryUpdatedAt: Int?
    let deviceName: String?
    let deviceType: String?
    let id: String?
    let iotThingName: String?
    let lastActivity: Int?
    let logMinDate: String?
    let modelNumber: String?
    let occupantSetting: String?
    let powerSource: String?
    let remoteDeviceId: String?
    let sharedArea: Bool?
    let topicName: String?
    let twoWayPowerSource: Bool?
    let zWaveSecurity: String?
    let status: DeviceStatus?
    let settings: Settings?
    
    enum CodingKeys: String, CodingKey {
        case batteryUpdatedAt = "battery_updated_at"
        case deviceName = "device_name"
        case deviceType = "device_type"
        case id = "id"
        case iotThingName = "iot_thing_name"
        case lastActivity = "last_activity"
        case logMinDate = "log_mindate"
        case modelNumber = "model_number"
        case occupantSetting = "occupant_setting"
        case powerSource = "power_source"
        case remoteDeviceId = "remote_device_id"
        case sharedArea = "shared_area"
        case topicName = "topic_name"
        case twoWayPowerSource = "two_way_power_source"
        case zWaveSecurity = "zwave_security"
        case status
        case settings = "settings"
    }
}

enum DeviceStatus: Codable {
    case lockStatus(LockStatus)
    case thermostatStatus(ThermostatStatus)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let lockStatus = try? container.decode(LockStatus.self) {
            self = .lockStatus(lockStatus)
            return
        }
        
        if let thermostatStatus = try? container.decode(ThermostatStatus.self) {
            self = .thermostatStatus(thermostatStatus)
            return
        }
        
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unexpected status type")
    }
}

// TODO:: If needed move to different file like android
// Lock Status
struct LockStatus: Codable {
    let mode: Mode?
    let battery: Int?
    let powerSource: String?
    let zwaveSignal: Int?
    let batteryZwave: Int?
    
    enum CodingKeys: String, CodingKey {
        case mode = "mode"
        case battery = "battery"
        case powerSource = "power_source"
        case zwaveSignal = "zwave_signal"
        case batteryZwave = "battery_zwave"
    }
}

struct Mode: Codable {
    let type: String?
}

// Thermostat Staus
struct ThermostatStatus: Codable {
    let fan: String?
    let mode: String?
    let battery: Int?
    let roomTemp: Int?
    let powerSource: String?
    let zwaveSignal: Int?
    let roomHumidity: Int?
    let operatingState: String?
    let coolingSetpoint: Int?
    let heatingSetpoint: Int?
    let batteryZwave: Int?
    
    enum CodingKeys: String, CodingKey {
        case fan = "fan"
        case mode = "mode"
        case battery = "battery"
        case roomTemp = "room_temp"
        case powerSource = "power_source"
        case zwaveSignal = "zwave_signal"
        case roomHumidity = "room_humidity"
        case operatingState = "operating_state"
        case coolingSetpoint = "cooling_setpoint"
        case heatingSetpoint = "heating_setpoint"
        case batteryZwave = "battery_zwave"
    }
}

struct Settings: Codable {
    let schedule: String?
    
    enum CodingKeys: String, CodingKey {
        case schedule = "schedule"
    }
}

