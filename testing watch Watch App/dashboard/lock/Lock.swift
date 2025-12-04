import SwiftUI

enum LockMode: String {
    case lock = "LOCK"
    case unlock = "UNLOCK"
}

struct Lock: View {
    let deviceId: String
    
    @State private var showHoldLabelFor: LockMode? = nil
    @State private var holdLabelText = ""
    
    @ObservedObject private var viewModel = DeviceListViewModel.shared
    
    private var lockDevice: Device? {
        viewModel.devices.first { $0.id == deviceId }
    }
    
    private var thingName: String {
        lockDevice?.iotThingName ?? ""
    }
    
    private var lockStatusText: String {
        guard case .lockStatus(let lockStatus)? = lockDevice?.status else {
            return "UNKNOWN"
        }
        return lockStatus.mode?.type?.uppercased() ?? "UNKNOWN"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Label(title: lockDevice?.occupantSetting ?? "Lock", xl18: true, grey: true, left: true)
                Label(title: lockStatusText, xl26: true, snow: true, bold: true, left: true)
            }
            .padding(.top)
            
            HStack {
                actionButton(
                    imageName: "lock.png",
                    backgroundColor: LocalColor.Primary.dark,
                    isLoading: viewModel.lockLoading[lockDevice?.iotThingName ?? ""] ?? false,
                    disabled: viewModel.unlockLoading[lockDevice?.iotThingName ?? ""] ?? false,
                    showHint: showHoldLabelFor == .unlock,
                    onClick: {
                        holdLabelText = "HOLD TO LOCK"
                        showHint(for: .lock)
                    },
                    onLongPress: {
                        handleLockAction(mode: .lock)
                    }
                )
                
                if showHoldLabelFor == nil {
                    Spacer()
                }
                
                actionButton(
                    imageName: "unlock.png",
                    backgroundColor: LocalColor.Danger.dark,
                    isLoading: viewModel.unlockLoading[lockDevice?.iotThingName ?? ""] ?? false,
                    disabled: viewModel.lockLoading[lockDevice?.iotThingName ?? ""] ?? false,
                    showHint: showHoldLabelFor == .lock,
                    onClick: {
                        holdLabelText = "HOLD TO UNLOCK"
                        showHint(for: .unlock)
                    },
                    onLongPress: {
                        handleLockAction(mode: .unlock)
                    }
                )
            }
        }
        .padding(.horizontal, 5)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private func showHint(for mode: LockMode) {
        showHoldLabelFor = mode
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showHoldLabelFor = nil
        }
    }
    
    private func handleLockAction(mode: LockMode) {
        guard !thingName.isEmpty else { return }
        
        if mode == .lock {
            viewModel.setLockLoading(for: thingName, isLoading: true)
        } else {
            viewModel.setUnlockLoading(for: thingName, isLoading: true)
        }
        
        Task {
            let command = LockCommand(mode: mode.rawValue.lowercased())
            let request = DeviceUpdateRequest.lock(command)
            let result = await DeviceAPI.updateDevice(deviceId: deviceId, requestBody: request)
            
            switch result {
            case .success(let response):
                print("Device updated: \(response)")
            case .failure(let error):
                // TODO:: Retrun and close the loader
                print("Error updating device: \(error)")
            }
            
            try? await Task.sleep(nanoseconds: MQTT.timeoutNanoseconds)
            
            if viewModel.lockLoading[thingName] ?? false || viewModel.unlockLoading[thingName] ?? false {
                let deviceResult = await DeviceAPI.fetchDevice(deviceId: deviceId)
                if let device = deviceResult {
                    viewModel.updateDevice(by: deviceId) { _ in device }
                } else {
                    print("Error in API call after 8 seconds")
                }
                
                if mode == .lock {
                    viewModel.setLockLoading(for: thingName, isLoading: false)
                } else {
                    viewModel.setUnlockLoading(for: thingName, isLoading: false)
                }
            }
        }
    }
    
    @ViewBuilder
    private func actionButton(
        imageName: String,
        backgroundColor: Color,
        isLoading: Bool,
        disabled: Bool,
        showHint: Bool,
        onClick: @escaping () -> Void,
        onLongPress: @escaping () -> Void
    ) -> some View {
        if showHint {
            if showHoldLabelFor == .lock {
                Spacer()
            }
            
            Label(title: holdLabelText, xl24: true, white: true, bold: true, left: true, maxLines: 3)
                .padding(
                    showHoldLabelFor == .lock ? .leading : .trailing,
                    15
                )
            
            if showHoldLabelFor == .unlock {
                Spacer()
            }
        } else if isLoading {
            // TODO:: Add lottie view
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
        } else {
            CircularButton(
                imageName: imageName,
                backgroundColor: backgroundColor,
                onPress: {
                    guard !disabled else { return }
                    onClick()
                },
                onLongPress: {
                    guard !disabled else { return }
                    onLongPress()
                }
            )
        }
    }
}

