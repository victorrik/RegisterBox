import SwiftUI

// MARK: - Color Palette
// Base de estilo: Ant Design v5 (tokens oficiales).
// El texto usa opacidad sobre negro siguiendo el patrón de antd.

extension Color {

    // MARK: Text (opacidad sobre negro — antd)
    /// Texto principal, títulos — colorText (negro 88%)
    static let rbPrimary     = Color.black.opacity(0.88)
    /// Alias de rbPrimary (antd no distingue este nivel extra)
    static let rbDark        = Color.black.opacity(0.88)
    /// Texto secundario — colorTextSecondary (negro 65%)
    static let rbMedium      = Color.black.opacity(0.65)
    /// Terciario / placeholders — colorTextTertiary (negro 45%)
    static let rbGray        = Color.black.opacity(0.45)
    /// Texto deshabilitado — colorTextDisabled (negro 25%)
    static let rbTextDisabled = Color.black.opacity(0.25)

    // MARK: Borders & Dividers
    /// Bordes — colorBorder #D9D9D9
    static let rbLightGray   = Color(hex: "#D9D9D9")
    /// Divisores / split — colorBorderSecondary #F0F0F0
    static let rbLighterGray = Color(hex: "#F0F0F0")

    // MARK: Backgrounds
    /// Fondo general de la app — colorBgLayout #F5F5F5
    static let rbBackground  = Color(hex: "#F5F5F5")
    /// Fondo de cards y superficies — colorBgContainer #FFFFFF
    static let rbSurface     = Color(hex: "#FFFFFF")
    /// Blanco puro — #FFFFFF
    static let rbWhite       = Color.white
    /// Fondo de selección/hover — primary-1 #E6F4FF
    static let rbPrimaryBg   = Color(hex: "#E6F4FF")

    // MARK: Accent & Semantic (antd v5)
    /// Acción primaria — colorPrimary (Daybreak Blue) #1677FF
    static let rbAccent      = Color(hex: "#1677FF")
    /// Advertencias — colorWarning #FAAD14
    static let rbWarning     = Color(hex: "#FAAD14")
    /// Error / destructivo — colorError #FF4D4F
    static let rbError       = Color(hex: "#FF4D4F")
    /// Éxito — colorSuccess #52C41A
    static let rbSuccess     = Color(hex: "#52C41A")
    /// Deuda / pendiente — orange-6 #FA8C16
    static let rbDebt        = Color(hex: "#FA8C16")

    // MARK: Shadow
    /// Color base para sombras — negro (opacidad baja en uso)
    static let rbShadow      = Color.black
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
