import SwiftUI
import Combine

enum DeviceType: String, Codable {
    case lock
    case thermostat
}

@MainActor
class DeviceListViewModel: ObservableObject {
    
    static let shared = DeviceListViewModel()
    private init() {}
    
    @Published var devices: [Device] = []
    @Published var dashboardLoader: Bool = false
    
    // Loaders per device
    @Published var lockLoading: [String: Bool] = [:]
    @Published var unlockLoading: [String: Bool] = [:]
    @Published var modeSettingLoading: [String: Bool] = [:]
    @Published var setPointSettingLoading: [String: Bool] = [:]
    
    func fetchData(for ids: [String]) async {
        dashboardLoader = true
        let fetchedDevices = await fetchDevices(for: ids)
        self.devices = fetchedDevices
        dashboardLoader = false
    }
    
    // TODO:: Check if fetch device failure case
    private func fetchDevices(for ids: [String]) async -> [Device] {
        await withTaskGroup(of: Device?.self) { group in
            for id in ids {
                group.addTask {
                    await self.fetchDevice(for: id)
                }
            }
            var result: [Device] = []
            for await device in group {
                if let device = device {
                    result.append(device)
                }
            }
            return result
        }
    }
    
    private func fetchDevice(for deviceId: String) async -> Device? {
        return await DeviceAPI.fetchDevice(deviceId: deviceId)
    }
    
    // MARK: - MQTT Device Update
    func updateDeviceFromMQTT(topic: String, payload: String) {
        Task { @MainActor in
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                guard let data = payload.data(using: .utf8) else {
                    print("MQTT: Invalid UTF8 payload")
                    return
                }
                
                let mqttPayload = try decoder.decode(MqttPayload.self, from: data)
                
                guard let reported = mqttPayload.state?.reported else { return }
                guard let status = reported.status else { return }
                let thingName = reported.thingName ?? ""
                
                if thingName.isEmpty {
                    print("MQTT: Update ignored, Missing thing name.")
                    return
                }
                
                print("MQTT: Status \(status)")
                
                let lockMode = status.mode?.type
                let thermostatMode = status.thermostatMode
                let coolingSetPoint = status.coolingSetpoint
                let heatingSetPoint = status.heatingSetpoint
                
                if lockMode != nil {
                    setLockLoading(for: thingName, isLoading: false)
                    setUnlockLoading(for: thingName, isLoading: false)
                }
                
                if thermostatMode != nil {
                    setModeSettingLoading(for: thingName, isLoading: false)
                }
                
                if coolingSetPoint != nil || heatingSetPoint != nil {
                    setSetPointSettingLoading(for: thingName, isLoading: false)
                }
                
                devices = devices.map { device in
                    guard device.iotThingName == thingName else { return device }
                    
                    var updatedDevice = device
                    
                    switch device.status {
                        
                    case .lockStatus(var lockStatus):
                        if let modeVal = lockMode, !modeVal.isEmpty {
                            lockStatus.mode = Mode(type: modeVal)
                        }
                        
                        updatedDevice = Device(
                            batteryUpdatedAt: device.batteryUpdatedAt,
                            deviceName: device.deviceName,
                            deviceType: device.deviceType,
                            id: device.id,
                            iotThingName: device.iotThingName,
                            lastActivity: device.lastActivity,
                            logMinDate: device.logMinDate,
                            modelNumber: device.modelNumber,
                            occupantSetting: device.occupantSetting,
                            powerSource: device.powerSource,
                            remoteDeviceId: device.remoteDeviceId,
                            sharedArea: device.sharedArea,
                            topicName: device.topicName,
                            twoWayPowerSource: device.twoWayPowerSource,
                            zWaveSecurity: device.zWaveSecurity,
                            status: .lockStatus(lockStatus),
                            settings: device.settings
                        )
                        
                    case .thermostatStatus(var tStatus):
                        if let newMode = thermostatMode {
                            tStatus.mode = newMode
                        }
                        if let newCool = coolingSetPoint {
                            tStatus.coolingSetpoint = newCool
                        }
                        if let newHeat = heatingSetPoint {
                            tStatus.heatingSetpoint = newHeat
                        }
                        
                        updatedDevice = Device(
                            batteryUpdatedAt: device.batteryUpdatedAt,
                            deviceName: device.deviceName,
                            deviceType: device.deviceType,
                            id: device.id,
                            iotThingName: device.iotThingName,
                            lastActivity: device.lastActivity,
                            logMinDate: device.logMinDate,
                            modelNumber: device.modelNumber,
                            occupantSetting: device.occupantSetting,
                            powerSource: device.powerSource,
                            remoteDeviceId: device.remoteDeviceId,
                            sharedArea: device.sharedArea,
                            topicName: device.topicName,
                            twoWayPowerSource: device.twoWayPowerSource,
                            zWaveSecurity: device.zWaveSecurity,
                            status: .thermostatStatus(tStatus),
                            settings: device.settings
                        )
                        
                    case .none:
                        break
                    }
                    
                    return updatedDevice
                }                
            } catch {
                print("MQTT: Update failed: \(error)")
            }
        }
    }
    
    // MARK: - Helpers
    func getDevice(by id: String) -> Device? {
        devices.first { $0.id == id }
    }
    
    func updateDevice(by id: String, update: (Device) -> Device) {
        if let index = devices.firstIndex(where: { $0.id == id }) {
            devices[index] = update(devices[index])
        }
    }
    
    // MARK: - Loading State Management
    func setLockLoading(for thingName: String, isLoading: Bool) {
        lockLoading[thingName] = isLoading
    }
    
    func setUnlockLoading(for thingName: String, isLoading: Bool) {
        unlockLoading[thingName] = isLoading
    }
    
    func setModeSettingLoading(for thingName: String, isLoading: Bool) {
        modeSettingLoading[thingName] = isLoading
    }
    
    func setSetPointSettingLoading(for thingName: String, isLoading: Bool) {
        setPointSettingLoading[thingName] = isLoading
    }
}

