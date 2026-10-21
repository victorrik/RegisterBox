import SwiftUI

// MARK: - Typography
// Fuente: Rubik (bundled en Resources/Fonts)
// Pesos: Light(300), Regular(400), Medium(500), SemiBold(600),
//        Bold(700), ExtraBold(800), Black(900)

extension Font {

    // MARK: Display
    /// 32px SemiBold — títulos de sección, encabezados grandes
    static let rbDisplay      = Font.custom("Rubik-SemiBold", size: 32)

    // MARK: Titles
    /// 24px SemiBold — títulos de pantalla
    static let rbTitle        = Font.custom("Rubik-SemiBold", size: 24)
    /// 20px SemiBold — títulos de sección dentro de pantalla
    static let rbTitle2       = Font.custom("Rubik-SemiBold", size: 20)
    /// 18px SemiBold — subtítulos
    static let rbSubtitle     = Font.custom("Rubik-SemiBold", size: 18)

    // MARK: Product & Price
    /// 20px SemiBold — nombre de producto en detalle
    static let rbProductName  = Font.custom("Rubik-SemiBold", size: 20)
    /// 16px SemiBold — nombre de producto en card
    static let rbProductCard  = Font.custom("Rubik-SemiBold", size: 16)
    /// 24px Bold — precio grande (detalle, carrito)
    static let rbPriceLarge   = Font.custom("Rubik-Bold", size: 24)
    /// 16px Bold — precio en card
    static let rbPrice        = Font.custom("Rubik-Bold", size: 16)
    /// 14px Bold — precio pequeño
    static let rbPriceSmall   = Font.custom("Rubik-Bold", size: 14)

    // MARK: Body
    /// 16px Regular — cuerpo principal
    static let rbBody         = Font.custom("Rubik-Regular", size: 16)
    /// 14px Regular — cuerpo secundario
    static let rbBody2        = Font.custom("Rubik-Regular", size: 14)
    /// 14px Light — descripciones, notas
    static let rbBodyLight    = Font.custom("Rubik-Light", size: 14)

    // MARK: UI Elements
    /// 16px Bold — texto de botón primario
    static let rbButton       = Font.custom("Rubik-Bold", size: 16)
    /// 14px Medium — texto de botón secundario
    static let rbButtonSm     = Font.custom("Rubik-Medium", size: 14)
    /// 12px SemiBold — labels, badges, chips
    static let rbLabel        = Font.custom("Rubik-SemiBold", size: 12)
    /// 12px Regular — captions, texto auxiliar
    static let rbCaption      = Font.custom("Rubik-Regular", size: 12)
    /// 10px Medium — etiquetas muy pequeñas
    static let rbMicro        = Font.custom("Rubik-Medium", size: 10)
}

// MARK: - Dynamic Type Support
extension Font {
    /// Crea una fuente Rubik con tamaño y peso específicos.
    static func rubik(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .ultraLight: name = "Rubik-Light"
        case .thin:       name = "Rubik-Light"
        case .light:      name = "Rubik-Light"
        case .regular:    name = "Rubik-Regular"
        case .medium:     name = "Rubik-Medium"
        case .semibold:   name = "Rubik-SemiBold"
        case .bold:       name = "Rubik-Bold"
        case .heavy:      name = "Rubik-ExtraBold"
        case .black:      name = "Rubik-Black"
        default:          name = "Rubik-Regular"
        }
        return Font.custom(name, size: size)
    }
}
