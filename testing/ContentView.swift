import SwiftUI

struct ContentView: View {
    
    var connnector = WatchConnector()
    
    func activateWatch() {
        if connnector.session.isReachable {
            print("Harish watch is reachable")
        } else {
            print("Harish watch is not reachable")
        }
    }
    
    func sendMessage() {
        if connnector.session.isReachable {
            print("Harish watch is reachable")
            connnector.session.sendMessage(["message": String("Harish")], replyHandler: nil) { (error) in
                print("Harish error in sending message \(error.localizedDescription)")
            }
        } else {
            print("Harish watch is not reachable")
        }
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            Button(action: {
                sendMessage()
            }, label: {
                Text("Send Message")
            })
        }
        .padding()
    }
}

//#Preview {
//    ContentView()
//}
