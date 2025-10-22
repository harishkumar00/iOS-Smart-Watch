import SwiftUI

struct Dashboard: View {
    
    @Environment(Router.self) private var router
    @StateObject private var deviceList = DeviceListViewModel.shared
    
    var lockDevices: [Device] {
        deviceList.devices.filter { $0.deviceType == "lock" }
    }
    
    var thermostatDevices: [Device] {
        deviceList.devices.filter { $0.deviceType == "thermostat" }
    }
    
    // TODO:: When any device is added connect to MQTT for the asset if not connected and subscribe to the device
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 8) {
                    lockTabView
                    thermostatTabView
                }
            }
            .overlay {
                if deviceList.dashboardLoader {
                    ProgressView()
                }
            }
            .task {
                if deviceList.devices.isEmpty {
                    if let assetDeviceMap = DefaultsManager.get(
                        forKey: UserDefaultsKeys.ASSET_DEVICE_MAP,
                        as: [String: [String]].self
                    ) {
                        let allDeviceIds = assetDeviceMap.values.flatMap { $0 }
                        
                        await deviceList.fetchData(for: allDeviceIds)
                    }
                }
            }
        }
        .navigationTitle("Smart Home")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var lockTabView: some View {
        Group {
            if !lockDevices.isEmpty {
                TabView {
                    ForEach(lockDevices, id: \.id) { device in
                        Card {
                            Lock(deviceId: device.id ?? "")
                        }
                        .padding(.horizontal)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .frame(maxWidth: .infinity, minHeight: 155, maxHeight: 155)
            }
        }
    }
    
    private var thermostatTabView: some View {
        Group {
            if !thermostatDevices.isEmpty {
                TabView {
                    ForEach(thermostatDevices, id: \.id) { device in
                        Card(onClick: {
                            if let deviceId = device.id {
                                router.navigateToThermostatDetails(deviceId: deviceId)
                            }
                        }) {
                            Thermostat(deviceId: device.id ?? "")
                        }
                        .padding(.horizontal)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .frame(maxWidth: .infinity, minHeight: 210, maxHeight: 210)
            }
        }
    }
}
