//import SwiftUI
//
//struct LockDetails: View {
//    
//    var deviceId: String
//    @State private var isLoading = true
//    @State private var lock: Device?
//    @StateObject private var apiManager = APIManager()
//
//    var body: some View {
//        VStack {
//            if isLoading {
//                ProgressView()
//            } else if lock == nil {
//                Label(title: "Error fetching data")
//            } else {
//                LockCard(
//                    title: lock?.deviceName ?? "",
//                    status: statusText.uppercased(),
//                    lockAction: { updateLock(mode: "lock") },
//                    unlockAction: { updateLock(mode: "unlock") },
//                    actionMessage: ""
//                )
//            }
//        }
//        .onAppear(perform: fetchDevice)
//    }
//
//    private var statusText: String {
//        if case .lockStatus(let lockStatus)? = lock?.status {
//            return lockStatus.mode?.type ?? "Unknown"
//        }
//        return "Unknown"
//    }
//
//    private func fetchDevice() {
//        isLoading = true
//        apiManager.fetchDeviceData(deviceId: deviceId) { device, error in
//            DispatchQueue.main.async {
//                isLoading = false
//                lock = device
//                if let error = error {
//                    print("Error fetching lock data:", error)
//                }
//            }
//        }
//    }
//
//    private func updateLock(mode: String) {
//        let lockStatus = LockStatus(
//            mode: Mode(type: mode),
//            battery: nil,
//            powerSource: nil,
//            zwaveSignal: nil,
//            batteryZwave: nil
//        )
//
//        let updatedDevice = Device(
//            id: nil,
//            deviceName: nil,
//            occupantSetting: nil,
//            deviceType: nil,
//            iotThingName: nil,
//            roomHumidity: nil,
//            topicName: nil,
//            lastActivity: nil,
//            modeUpdatedAt: nil,
//            status: .lockStatus(lockStatus)
//        )
//
//        apiManager.updateDeviceData(deviceId: deviceId, updatedDevice: updatedDevice)
//    }
//}
//
//struct LockCard: View {
//    let title: String
//    let status: String
//    let lockAction: () -> Void
//    let unlockAction: () -> Void
//    let actionMessage: String
//
//    var body: some View {
//        VStack(spacing: 16) {
//            HeaderSection(title: title, status: status)
//            ActionButtons(lockAction: lockAction, unlockAction: unlockAction)
//            StatusLabel(message: actionMessage)
//        }
//        .padding()
//    }
//}
//
//struct HeaderSection: View {
//    let title: String
//    let status: String
//
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 4) {
//                Label(title: title, xl18: true, grey: true)
//                Label(title: status, xl20: true, bold: true)
//            }
//            Spacer()
//        }
//    }
//}
//
//struct ActionButtons: View {
//    let lockAction: () -> Void
//    let unlockAction: () -> Void
//
//    var body: some View {
//        HStack(spacing: 40) {
//            CircularButton(imageName: "lock.png", backgroundColor: .blue, onPress: {}, onLongPress: lockAction)
//            CircularButton(imageName: "unlock.png", backgroundColor: .red, onPress: {}, onLongPress: unlockAction)
//        }
//    }
//}
//
//struct StatusLabel: View {
//    let message: String
//
//    var body: some View {
//        Label(title: message, xl18: true)
//    }
//}
//
//
