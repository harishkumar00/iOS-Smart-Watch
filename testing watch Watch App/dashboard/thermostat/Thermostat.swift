import SwiftUI

enum ThermostatMode: String {
    case heat
    case cool
    case auto
    case off
    case unknown
    
    init(from rawValue: String?) {
        guard let rawValue = rawValue?.lowercased() else {
            self = .unknown
            return
        }
        self = ThermostatMode(rawValue: rawValue) ?? .unknown
    }
}

struct Thermostat: View {
    let deviceId: String
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
    
    private var scheduleStatus: String {
        if let schedule = viewModel.devices.first(where: { $0.id == deviceId })?.settings?.schedule,
           !schedule.isEmpty {
            return "Active"
        } else {
            return "Not Active"
        }
    }
    
    private var scheduleColor: Color {
        if let schedule = viewModel.devices.first(where: { $0.id == deviceId })?.settings?.schedule,
           !schedule.isEmpty {
            return LocalColor.Primary.extraDark
        } else {
            return LocalColor.Monochrome.grey
        }
    }
    
    // TODO:: Add 3 degree logic and min set point if not present
    private var setPoint: String {
        guard let status = thermostatStatus else { return "--" }
        switch mode {
        case .heat:
            return "\(status.heatingSetpoint ?? 72)°"
        case .cool:
            return "\(status.coolingSetpoint ?? 72)°"
        case .auto:
            return "Heat: \(status.heatingSetpoint ?? 0)° Cool: \(status.coolingSetpoint ?? 0)°"
        default:
            return "--"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Label(title: viewModel.devices.first(where: { $0.id == deviceId })?.deviceName ?? "Thermostat", xl18: true, grey: true, left: true)
                .padding(.top)
            
            OutlinedButton(
                title: mode.rawValue.uppercased(),
                heat: mode == .heat,
                cool: mode == .cool,
                auto: mode == .auto,
                off: mode == .off,
                onClick: { router.navigateToModeSelection(deviceId: deviceId) }
            )
            
            
            VStack {
                ThermostatRow(title: "Indoor", value: indoorTemp)
                
                if mode != .off {
                    ThermostatRow(title: "Set to", value: setPoint, small: mode == .auto)
                        .padding(.vertical, mode == .auto ? 1 : 0)
                    ThermostatRow(title: "Schedule", value: scheduleStatus, valueColor: scheduleColor)
                }
            }
        }
        .padding(.horizontal, 5)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct ThermostatRow: View {
    var title: String
    var value: String
    var valueColor: Color = LocalColor.Monochrome.white
    var small: Bool = false
    
    var body: some View {
        HStack {
            Label(title: title, xl18: true, semiBold: true, left: true)
            Spacer()
            Label(title: value,  m: small, xl24: !small, textColor: valueColor, semiBold: true, left: true)
        }
    }
}
