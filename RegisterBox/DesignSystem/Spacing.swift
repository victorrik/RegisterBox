import SwiftUI

// MARK: - Spacing Scale
// Sistema de espaciado en múltiplos de 4pt

enum Spacing {
    /// 4pt — micro separación
    static let xxs:  CGFloat = 4
    /// 8pt — separación pequeña
    static let xs:   CGFloat = 8
    /// 12pt — padding interno de componentes
    static let sm:   CGFloat = 12
    /// 16pt — padding estándar
    static let md:   CGFloat = 16
    /// 20pt — separación media
    static let lg:   CGFloat = 20
    /// 24pt — separación grande
    static let xl:   CGFloat = 24
    /// 32pt — secciones
    static let xxl:  CGFloat = 32
    /// 40pt — espaciado extra
    static let xxxl: CGFloat = 40
    /// 48pt — separación máxima
    static let huge: CGFloat = 48
}

// MARK: - Corner Radius (Ant Design v5)
enum Radius {
    /// 2pt — badges/tags (borderRadiusXS antd)
    static let xs:  CGFloat = 2
    /// 6pt — inputs, botones (borderRadius base antd)
    static let sm:  CGFloat = 6
    /// 8pt — cards (borderRadiusLG antd)
    static let md:  CGFloat = 8
    /// 8pt — botones (alineado con cards)
    static let lg:  CGFloat = 8
    /// 16pt — sheets
    static let xl:  CGFloat = 16
    /// 32pt — pills, FAB
    static let full: CGFloat = 32
}

// MARK: - Shadow
struct RBShadow: ViewModifier {
    var color: Color = .rbShadow
    var opacity: Double = 0.06
    var radius: CGFloat = 16
    var x: CGFloat = 0
    var y: CGFloat = 4

    func body(content: Content) -> some View {
        content.shadow(
            color: color.opacity(opacity),
            radius: radius,
            x: x,
            y: y
        )
    }
}

extension View {
    /// Sombra sutil estilo Ant Design (boxShadowSecondary).
    func rbShadow(opacity: Double = 0.06, radius: CGFloat = 16) -> some View {
        modifier(RBShadow(opacity: opacity, radius: radius))
    }
}

// MARK: - Icon Sizes
enum IconSize {
    static let sm:  CGFloat = 16
    static let md:  CGFloat = 20
    static let lg:  CGFloat = 24
    static let xl:  CGFloat = 32
}
