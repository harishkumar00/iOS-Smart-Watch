import Foundation
import Combine

struct AlertData {
    let title: String
    let message: String
}

final class ErrorViewModel: ObservableObject {
    static let shared = ErrorViewModel()
    
    @Published var title: String? = nil
    @Published var errorMessage: String? = nil
    @Published var isErrorModalVisible: Bool = false
    @Published var syncRequired: Bool = false
    
    private init() {}
    
    func showError(title: String, message: String) {
        DispatchQueue.main.async {
            self.title = title
            self.errorMessage = message
            self.isErrorModalVisible = true
        }
    }
    
    func showSyncRequired() {
        DispatchQueue.main.async {
            self.syncRequired = true
        }
    }
    
    func clearError() {
        DispatchQueue.main.async {
            self.title = nil
            self.errorMessage = nil
            self.isErrorModalVisible = false
            self.syncRequired = false
        }
    }
}

