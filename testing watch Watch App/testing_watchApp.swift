import SwiftUI

@main
struct testing_watch_Watch_AppApp: App {
        
    var body: some Scene {
        WindowGroup {
            // TODO:: Need show the error alert if needed and show when moveout or API fails
            // TODO:: Need to add the listener logic which is if data is received then automatically add the devices and connect for MQTT
            Dashboard()
                .withRouter()
                .onAppear {
                    
                    // TODO:: Only to test
                    DefaultsManager.set("hari7@sharklasers.com", forKey: UserDefaultsKeys.EMAIL)
                    DefaultsManager.set("Hari@123", forKey: UserDefaultsKeys.PASSWORD)
                    DefaultsManager.set("", forKey: UserDefaultsKeys.ACCESS_TOKEN)
                    DefaultsManager.set("", forKey: UserDefaultsKeys.REFRESH_TOKEN)
                    
                    let testAssetDeviceMap: [String: [String]] = [
                        "233334": [
                            "05fb1c42-316d-4cdd-94aa-b05490c895f9", // LOCK_ID
                            "01470a23-c6c2-4d5c-b3aa-85f87c99183f"  // THERMOSTAT_ID
                        ]
                    ]
                    
                    DefaultsManager.set(testAssetDeviceMap, forKey: UserDefaultsKeys.ASSET_DEVICE_MAP)
                }
        }
    }
}

