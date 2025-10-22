import SwiftUI

struct Card<Content: View>: View {
    var cornerRadius: CGFloat = 10
    var shadowRadius: CGFloat = 5
    var backgroundColor: Color = LocalColor.Monochrome.background
    var onClick: () -> Void = {}
    let content: () -> Content
    
    var body: some View {
        Button(action: {
            onClick()
        }) {
            VStack {
                content()
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(radius: shadowRadius)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

