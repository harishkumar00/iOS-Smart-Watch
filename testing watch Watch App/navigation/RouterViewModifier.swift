import SwiftUI

struct RouterViewModifier: ViewModifier {
    @State private var router = Router()
    
    private func routeView(for route: Route) -> some View {
        Group {
            switch route {
            case .thermostatDetails(let deviceId):
                ThermostatDetails(deviceId: deviceId)
            case .modeSelection(let deviceId):
                ModeSelection(deviceId: deviceId)
            }
        }
        .environment(router)
    }
    
    func body(content: Content) -> some View {
        NavigationStack(path: $router.path) {
            content
                .environment(router)
                .navigationDestination(for: Route.self) { route in
                    routeView(for: route)
                }
        }
    }
}

extension View {
    func withRouter() -> some View {
        modifier(RouterViewModifier())
    }
}

