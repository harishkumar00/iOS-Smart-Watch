import SwiftUI

struct ThermostatDetails: View {
    var deviceId: String
    
    @ObservedObject private var viewModel = DeviceListViewModel.shared
    @Environment(Router.self) private var router
    
    @State private var heatSetPoint: Int = 70
    @State private var coolSetPoint: Int = 70
    @State private var isLoading = false
    
    private var thermostat: Device? {
        viewModel.devices.first { $0.id == deviceId }
    }
    
    private var thingName: String {
        thermostat?.iotThingName ?? ""
    }
    
    private var thermostatStatus: ThermostatStatus? {
        if case .thermostatStatus(let status)? = thermostat?.status {
            return status
        }
        return nil
    }
    
    private var mode: ThermostatMode {
        ThermostatMode(from: thermostatStatus?.mode)
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    TopSection(deviceId: deviceId)
                    
                    if mode == .cool || mode == .auto {
                        Slider(title: "Cool", value: $coolSetPoint)
                    }
                    
                    if mode == .heat || mode == .auto {
                        Slider(title: "Heat", highlightColor: LocalColor.Danger.medium, value: $heatSetPoint)
                    }
                }
                .padding(.bottom, 60)
            }
            
            VStack {
                Spacer()
                BottomSection(
                    onCancel: { router.popToRoot() },
                    onSave: { updateThermostatSetpoints() }
                )
            }
            
            if isLoading {
                ProgressView("Updating...")
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10)
            }
        }
        .onAppear {
            heatSetPoint = thermostatStatus?.heatingSetpoint ?? 70
            coolSetPoint = thermostatStatus?.coolingSetpoint ?? 70
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationTitle(thermostat?.deviceName ?? "Thermostat")
    }
    
    private func updateThermostatSetpoints() {
        guard !thingName.isEmpty else { return }
        
        viewModel.setSetPointSettingLoading(for: thingName, isLoading: true)
        
        Task {
            
            let command = ThermostatCommand(
                mode: thermostatStatus?.mode,
                setpoint: nil,
                heatingSetpoint: heatSetPoint,
                coolingSetpoint: coolSetPoint
            )
            
            let request = DeviceUpdateRequest.thermostat(command)
            let result = await DeviceAPI.updateDevice(deviceId: deviceId, requestBody: request)

            switch result {
            case .success(let response):
                print("Device updated: \(response)")
            case .failure(let error):
                // TODO:: Retrun and close the loader
                print("Error updating device: \(error)")
            }
            
            try? await Task.sleep(nanoseconds: MQTT.timeoutNanoseconds)
            
            if viewModel.setPointSettingLoading[thingName] ?? false {
                let deviceResult = await DeviceAPI.fetchDevice(deviceId: deviceId)
                
                if let device = deviceResult {
                    viewModel.updateDevice(by: deviceId) { _ in device }
                } else {
                    print("Error in API call after 8 seconds")
                }
            }
                
            viewModel.setSetPointSettingLoading(for: thingName, isLoading: false)
        }
    }
}

struct TopSection: View {
    var deviceId: String
    
    @Environment(Router.self) private var router
    @ObservedObject private var viewModel = DeviceListViewModel.shared
    
    private var thermostatStatus: ThermostatStatus? {
        if case .thermostatStatus(let status)? = viewModel.devices.first(where: { $0.id == deviceId })?.status {
            return status
        }
        return nil
    }

    private var mode: ThermostatMode {
        ThermostatMode(from: thermostatStatus?.mode)
    }

    private var indoorTemp: String {
        if let temp = thermostatStatus?.roomTemp {
            return "\(temp)°"
        }
        return "--"
    }
    
    var body: some View {
        HStack {
            VStack {
                Label(title: "Indoor", xl20: true, white: true, bold: true)
                Label(title: indoorTemp, xl24: true, white: true, bold: true)
            }
            
            Spacer().frame(width: 15)
            
            OutlinedButton(
                title: mode.rawValue.prefix(1).uppercased() + mode.rawValue.dropFirst().lowercased(),
                heat: mode == .heat,
                cool: mode == .cool,
                auto: mode == .auto,
                off: mode == .off,
                onClick: { router.navigateToModeSelection(deviceId: deviceId) }
            )
        }
        .padding(.horizontal, 2)
        .padding(.top, 2)
    }
}

struct Slider: View {
    var title: String
    var highlightColor: Color = .blue
    @Binding var value: Int
    
    var body: some View {
        VStack {
            Label(title: title, xl20: true, white: true, bold: true)
            CenteredSlider(range: Thermostat_Constants.MINIMUM_SET_POINT...Thermostat_Constants.MAXIMUM_SET_POINT, selectedValue: $value, highlightColor: highlightColor)
        }
    }
}

struct BottomSection: View {
    var onCancel: () -> Void
    var onSave: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Button(action: onCancel) {
                    if let uiImage = UIImage(named: "cancel.png") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 26, height: 26)
                            .clipShape(Circle())
                    }
                }
                .background(LocalColor.Monochrome.black)
                .frame(width: 26, height: 26)
                .clipShape(Circle())
                
                Spacer()
                
                Button(action: onSave) {
                    if let uiImage = UIImage(named: "tick.png") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 26, height: 26)
                            .clipShape(Circle())
                    }
                }
                .background(LocalColor.Monochrome.black)
                .frame(width: 26, height: 26)
                .clipShape(Circle())
            }
            .padding()
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .background(LocalColor.Monochrome.dark)
    }
}

struct CircleButton: View {
    var imageName: String
    var backgroundColor: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: imageName)
        }
        .frame(width: 30, height: 30)
        .background(backgroundColor)
        .clipShape(Circle())
    }
}

