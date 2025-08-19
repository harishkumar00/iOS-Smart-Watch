import SwiftUI

struct Label: View {
    var id: String = ""
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
    
    // Color Options
    var grey: Bool = false
    var snow: Bool = false
    var white: Bool = false
    var black: Bool = false
    var textColor: Color? = nil
    
    // Font Weight Options
    var light: Bool = false
    var medium: Bool = false
    var semiBold: Bool = false
    var bold: Bool = false
    
    // Text Alignment Options
    var left: Bool = false
    var right: Bool = false
    var center: Bool = false
    
    // Text Decoration
    var underLine: Bool = false
    var strikeThrough: Bool = false
    
    var maxLines: Int? = nil
    
    var body: some View {
        let textAlign: Alignment = {
            if left { return .leading }
            if right { return .trailing }
            if center { return .center }
            return .leading
        }()
        
        let color: Color = {
            if textColor != nil {
                return textColor!
            }
            if grey { return LocalColor.Monochrome.white.opacity(0.5) }
            if snow { return LocalColor.Secondary.extraLight }
            if white { return LocalColor.Monochrome.white }
            if black { return LocalColor.Monochrome.black }
            return LocalColor.Monochrome.white.opacity(0.7)
        }()
        
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
            else { .largeTitle }
        
        let fontWeight: Font.Weight = {
            if bold { return .bold }
            if semiBold { return .semibold }
            if medium { return .medium }
            if light { return .light }
            return .regular
        }()
        
        Text(title)
            .font(fontSize)
            .fontWeight(fontWeight)
            .foregroundColor(color)
            .lineLimit(maxLines)
            .fixedSize(horizontal: false, vertical: true)
            .frame(alignment: textAlign)
            .accessibility(identifier: id.isEmpty ? title : id)
    }
}
