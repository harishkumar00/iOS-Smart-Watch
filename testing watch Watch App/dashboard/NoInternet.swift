import SwiftUI

struct NoInternet: View {
    
    var body: some View {
        ScrollView {
            Label(title: "No Internet Connection", xl18: true, snow: true, left: true)
            
            Spacer().frame(height: 15)
            
            Label(title: "Check your connection and try again.", xl18: true, snow: true, center: true)
            
            Spacer().frame(height: 15)
            
            OutlinedButton(
                title: "Try again",
                off: true,
                onClick: {
                    
                }
            )
        }
    }
}
