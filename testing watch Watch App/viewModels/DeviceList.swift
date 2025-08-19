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

