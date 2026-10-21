import SwiftUI

// MARK: - Color Palette
// Extraída del Figma: E-Commerce App UI Design Kit (Rubik / FetchMart)

extension Color {

    // MARK: Text
    /// Texto principal, títulos — #171A1C
    static let rbPrimary     = Color(hex: "#171A1C")
    /// Texto secundario — #26292B
    static let rbDark        = Color(hex: "#26292B")
    /// Iconos, bordes, texto sobre fondo claro — #303336
    static let rbMedium      = Color(hex: "#303336")
    /// Placeholders, texto deshabilitado — #828384
    static let rbGray        = Color(hex: "#828384")

    // MARK: Borders & Dividers
    /// Bordes suaves — #BFC0C1
    static let rbLightGray   = Color(hex: "#BFC0C1")
    /// Fondos alternativos — #E0E0E1
    static let rbLighterGray = Color(hex: "#E0E0E1")

    // MARK: Backgrounds
    /// Fondo general de la app — #F2F2F2
    static let rbBackground  = Color(hex: "#F2F2F2")
    /// Fondo de cards y superficies elevadas — #F6F7FB
    static let rbSurface     = Color(hex: "#F6F7FB")
    /// Blanco puro — #FFFFFF
    static let rbWhite       = Color.white

    // MARK: Accent & Semantic
    /// Acción primaria, botones principales — #2C21FC
    static let rbAccent      = Color(hex: "#2C21FC")
    /// Alertas, stock bajo, advertencias — #F7A827
    static let rbWarning     = Color(hex: "#F7A827")
    /// Error, stock agotado, destructivo — #FF3B30
    static let rbError       = Color(hex: "#FF3B30")
    /// Éxito, venta confirmada — #34C759
    static let rbSuccess     = Color(hex: "#34C759")
    /// Deuda / pendiente — #FF9500
    static let rbDebt        = Color(hex: "#FF9500")

    // MARK: Shadow
    /// Color base para sombras — #000D09
    static let rbShadow      = Color(hex: "#000D09")
}

// MARK: - Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
