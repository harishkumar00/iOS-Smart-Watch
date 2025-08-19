import SwiftUI

struct ContentView: View {
    
    @ObservedObject var connector = WatchConnector()
        
    var body: some View {
        VStack {
            Text(connector.receivedMessage)
        }
    }
}

#Preview {
    ContentView()
}
