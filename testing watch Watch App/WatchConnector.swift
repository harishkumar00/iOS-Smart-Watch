import Foundation
import WatchConnectivity

class WatchConnector: NSObject, WCSessionDelegate, ObservableObject {
  
  var session: WCSession
  @Published var receivedMessage: String = "No message received yet"
  
  init(session: WCSession = .default) {
    self.session = session
    super.init()
    self.session.delegate = self
    session.activate()
  }
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    if let error = error {
      print("WatchSessionManager: Activation failed with error: \(error.localizedDescription)")
    } else {
      print("WatchSessionManager: Activated with state: \(activationState.rawValue)")
    }
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    print("Harish didReceiveMessage \(message)")
    DispatchQueue.main.async {
      if let text = message["message"] as? String {
        self.receivedMessage = text
        print("WatchSessionManager: Message received - \(text)")
      } else {
        print("WatchSessionManager: Received message with invalid format")
      }
    }
  }
}


