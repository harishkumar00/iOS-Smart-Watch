import SwiftUI

struct DeviceCard: Identifiable {
    let id = UUID()
    let mode: ThermostatMode
    let icon: String
    let selectedColor: Color
}

struct ModeSelection: View {
    var deviceId: String
    
    @State private var selectedCardIndex: Int?
    @ObservedObject private var viewModel = DeviceListViewModel.shared
    
    private var thermostatDevice: Device? {
        viewModel.devices.first { $0.id == deviceId }
    }
    
    private var thingName: String {
        thermostatDevice?.iotThingName ?? ""
    }
    
    private var thermostatStatus: ThermostatStatus? {
        if case .thermostatStatus(let status)? = thermostatDevice?.status {
            return status
        }
        return nil
    }
    
    private var isModeSettingLoading: Bool {
        viewModel.modeSettingLoading[thingName] ?? false
    }
    
    private var currentMode: ThermostatMode {
        ThermostatMode(from: thermostatStatus?.mode)
    }
    
    private var cards: [DeviceCard] {
        [
            .init(mode: .auto, icon: "auto.png", selectedColor: LocalColor.Mode.auto),
            .init(mode: .cool, icon: "cool.png", selectedColor: LocalColor.Mode.cool),
            .init(mode: .heat, icon: "heat.png", selectedColor: LocalColor.Mode.heat),
            .init(mode: .off,  icon: "off.png",  selectedColor: LocalColor.Mode.off)
        ]
    }
    
    var body: some View {
        ScrollView {
            Label(
                title: "Current: \(currentMode.rawValue.uppercased())",
                l: true,
                textColor: LocalColor.Monochrome.medium,
                semiBold: true
            )
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                ForEach(cards.indices, id: \.self) { index in
                    deviceCard(for: index)
                }
            }
        }
        .padding(.horizontal)
        .onAppear {
            selectedCardIndex = cards.firstIndex(where: { $0.mode == currentMode })
        }
        .overlay {
            if isModeSettingLoading {
                ProgressView()
            }
        }
    }
    
    private func deviceCard(for index: Int) -> some View {
        let card = cards[index]
        let isSelected = selectedCardIndex == index
        
        return Card(
            cornerRadius: 4,
            backgroundColor: isSelected ? card.selectedColor : LocalColor.Monochrome.transparent
        ) {
            handleModeChange(card.mode)
        } content: {
            VStack(spacing: 6) {
                Label(title: card.mode.rawValue.uppercased(), l: true, snow: true)
                
                if let uiImage = UIImage(named: card.icon) {
                    Image(uiImage: uiImage)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(isSelected ? LocalColor.Monochrome.white : card.selectedColor)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 80, height: 65) // Wider than tall for watch
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(isSelected ? LocalColor.Monochrome.transparent : LocalColor.Mode.off, lineWidth: 2)
        )
    }
    
    private func handleModeChange(_ mode: ThermostatMode) {
        guard !thingName.isEmpty else { return }
        viewModel.setModeSettingLoading(for: thingName, isLoading: true)
        
        Task {
            let heatingSetPoint = (mode == .auto) ? thermostatStatus?.heatingSetpoint  : nil
            let coolingSetPoint = (mode == .auto) ? thermostatStatus?.coolingSetpoint : nil
            let setPoint = (mode == .cool) ? thermostatStatus?.coolingSetpoint :
                           (mode == .heat) ? thermostatStatus?.heatingSetpoint : nil
            
            let command = ThermostatCommand(
                mode: mode.rawValue.lowercased(),
                setpoint: setPoint,
                heatingSetpoint: heatingSetPoint,
                coolingSetpoint: coolingSetPoint
            )
            
            let request = DeviceUpdateRequest.thermostat(command)
            let result = await DeviceAPI.updateDevice(deviceId: deviceId, requestBody: request)

            if case .failure(let error) = result {
                print("Error updating device: \(error)")
            }
            
            try? await Task.sleep(nanoseconds: MQTT.timeoutNanoseconds)
            
            if viewModel.modeSettingLoading[thingName] ?? false {
                if let device = await DeviceAPI.fetchDevice(deviceId: deviceId) {
                    viewModel.updateDevice(by: deviceId) { _ in device }
                } else {
                    print("Error in API call after timeout")
                }
            }
            
            viewModel.setModeSettingLoading(for: thingName, isLoading: false)
        }
    }
}

