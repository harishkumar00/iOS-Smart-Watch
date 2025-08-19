import Foundation
import SwiftUI
import Observation

@Observable
class Router {
    var path = NavigationPath()
    
    func navigateToThermostatDetails(deviceId: String) {
        path.append(Route.thermostatDetails(deviceId: deviceId))
    }

    func navigateToModeSelection(deviceId: String) {
        path.append(Route.modeSelection(deviceId: deviceId))
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}

enum Route: Hashable {
    case thermostatDetails(deviceId: String)
    case modeSelection(deviceId: String)
}

