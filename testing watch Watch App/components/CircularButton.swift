import SwiftUI

struct CircularButton: View {
    let imageName: String
    let backgroundColor: Color
    let onPress: () -> Void
    let onLongPress: () -> Void
    var size: CGFloat = 55
    var imageSize: CGFloat = 25
    
    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: size, height: size)
            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageSize, height: imageSize)
            }
        }
        .onTapGesture(perform: onPress)
        .onLongPressGesture(minimumDuration: 0.8, perform: onLongPress)
    }
}
