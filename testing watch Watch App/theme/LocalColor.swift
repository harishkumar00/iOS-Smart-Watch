import SwiftUI

struct LocalColor {
    
    struct Primary {
        static let extraWhite = Color(hex: "#F1F9FD")
        static let white = Color(hex: "#F3FBFF")
        static let extraLight = Color(hex: "#E6ECF3")
        static let light = Color(hex: "#C5DFED")
        static let regular = Color(hex: "#92C9E8")
        static let medium = Color(hex: "#0072EC")
        static let semiDark = Color(hex: "#0889CA")
        static let dark = Color(hex: "#177BB5")
        static let extraDark = Color(hex: "#44A5C2")
    }
    
    struct Secondary {
        static let extraLight = Color(hex: "#F9FAFB")
        static let semiDark = Color(hex: "#464646")
        static let dark = Color(hex: "#111827")
        static let extraDark = Color(hex: "#374151")
        static let success = Color(hex: "#0C893F")
    }
    
    struct Mode {
        static let cool = Color(hex: "#177BB5")
        static let heat = Color(hex: "#BA1C1C")
        static let auto = Color(hex: "#15803D")
        static let off = Color(hex: "#1F2937")
    }
    
    struct Danger {
        static let regular = Color(hex: "#E52828")
        static let medium = Color(hex: "#EC1010")
        static let dark = Color(hex: "#EF4343")
    }
    
    struct Warning {
        static let light = Color(hex: "#FEF3C7")
        static let regular = Color(hex: "#FBBF24")
        static let medium = Color(hex: "#F59E0B")
        static let dark = Color(hex: "#FF6902")
    }
    
    struct Monochrome {
        static let white = Color(hex: "#FFFFFF")
        static let extraLight = Color(hex: "#E5E7EB")
        static let light = Color(hex: "#6B7280")
        static let medium = Color(hex: "#C7C7C7")
        static let grey = Color(hex: "#9CA3AF")
        static let background = Color(hex: "#CBCBCB").opacity(0.14)
        static let dark = Color(hex: "#1C1C1C")
        static let black = Color(hex: "#000000")
        static let transparent = Color.clear
    }
}

extension Color {
    init(hex: String) {
        let cleanedHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        
        var rgb: UInt64 = 0
        Scanner(string: cleanedHex).scanHexInt64(&rgb)
        
        let length = cleanedHex.count
        let r, g, b, a: Double
        
        switch length {
        case 6:
            r = Double((rgb >> 16) & 0xFF) / 255.0
            g = Double((rgb >> 8) & 0xFF) / 255.0
            b = Double(rgb & 0xFF) / 255.0
            a = 1.0
        case 8:
            r = Double((rgb >> 24) & 0xFF) / 255.0
            g = Double((rgb >> 16) & 0xFF) / 255.0
            b = Double((rgb >> 8) & 0xFF) / 255.0
            a = Double(rgb & 0xFF) / 255.0
        default:
            r = 0.0
            g = 0.0
            b = 0.0
            a = 1.0
            print("Invalid hex string, defaulting to black.")
        }
        
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
