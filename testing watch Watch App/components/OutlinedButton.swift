import SwiftUI

struct OutlinedButton: View {
    
    var title: String

    // Font Size Options
    var xs: Bool = false
    var s: Bool = false
    var m: Bool = false
    var l: Bool = false
    var xl18: Bool = false
    var xl20: Bool = false
    var xl22: Bool = false
    var xl24: Bool = false
    var xl26: Bool = false
    var xl28: Bool = false
    var xxl: Bool = false

    // Font Weight Options
    var light: Bool = false
    var medium: Bool = false
    var semiBold: Bool = false
    var bold: Bool = false

    var heat: Bool = false
    var cool: Bool = false
    var auto: Bool = false
    var off: Bool = false

    var cornerRadius: CGFloat = 30
    var isDisabled: Bool = false
    var onClick: () -> Void

    var body: some View {
        let fontSize: Font = if xs { .caption2 }
        else if s { .caption }
        else if m { .footnote }
        else if l { .callout }
        else if xl18 { .body }
        else if xl20 { .subheadline }
        else if xl22 { .headline }
        else if xl24 { .title3 }
        else if xl26 { .title2 }
        else if xl28 { .title }
        else if xxl { .largeTitle }
        else { .body }

        let fontWeight: Font.Weight = {
            if bold { return .bold }
            if semiBold { return .semibold }
            if medium { return .medium }
            if light { return .light }
            return .regular
        }()

        Button(action: {
            if !isDisabled {
                onClick()
            }
        }) {
            Text(title)
                .font(fontSize)
                .fontWeight(fontWeight)
                .foregroundColor(labelColor())
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, maxHeight: 40)
                .background(containerColor())
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor(), lineWidth: off ? 2 : 0)
                )
                .opacity(isDisabled ? 0.6 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
    }

    private func containerColor() -> Color {
        if isDisabled {
            return Color.gray.opacity(0.2)
        } else if off {
            return LocalColor.Monochrome.transparent
        } else if cool {
            return LocalColor.Mode.cool
        } else if heat {
            return LocalColor.Mode.heat
        } else if auto {
            return LocalColor.Mode.auto
        } else {
            return LocalColor.Monochrome.transparent
        }
    }

    private func labelColor() -> Color {
        if isDisabled {
            return Color.gray
        } else if off {
            return LocalColor.Monochrome.grey
        } else {
            return LocalColor.Monochrome.white
        }
    }

    private func borderColor() -> Color {
        if off {
            return LocalColor.Monochrome.grey
        } else {
            return LocalColor.Monochrome.transparent
        }
    }
}

#Preview {
    ScrollView {
        OutlinedButton(
            title: "Heat",
            heat: true,
            onClick: { print("Heat Button Clicked") }
        )
        
        OutlinedButton(
            title: "Cool",
            cool: true,
            onClick: { print("Cool Button Clicked") }
        )
        
        OutlinedButton(
            title: "Auto",
            auto: true,
            onClick: { print("Auto Button Clicked") }
        )
        
        OutlinedButton(
            title: "Off",
            off: true,
            onClick: { print("Off Button Clicked") }
        )
        
        OutlinedButton(
            title: "Disabled",
            isDisabled: true,
            onClick: { print("Disabled Button Clicked") }
        )
    }
    .padding()
}

