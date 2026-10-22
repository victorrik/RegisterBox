import SwiftUI

// MARK: - RBBadge Style
enum RBBadgeStyle {
    case warning     // stock bajo — amarillo
    case error       // stock agotado — rojo
    case success     // confirmado — verde
    case debt        // deuda pendiente — naranja
    case info        // info general — gris
    case custom(Color) // color de categoría
}

// MARK: - RBBadge
struct RBBadge: View {
    let text: String
    var style: RBBadgeStyle = .info
    var icon: String? = nil

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .semibold))
            }
            Text(text)
                .font(.rbMicro)
        }
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, Spacing.xxs)
        .background(backgroundColor.opacity(0.15))
        .foregroundStyle(foregroundColor)
        .clipShape(RoundedRectangle(cornerRadius: Radius.xs))
    }

    // MARK: Colors
    private var backgroundColor: Color {
        switch style {
        case .warning:        return .rbWarning
        case .error:          return .rbError
        case .success:        return .rbSuccess
        case .debt:           return .rbDebt
        case .info:           return .rbGray
        case .custom(let c):  return c
        }
    }

    private var foregroundColor: Color {
        // Tonos "7" de antd para texto sobre fondo tenue (tag style)
        switch style {
        case .warning:        return Color(hex: "#D48806") // gold-7
        case .error:          return Color(hex: "#CF1322") // red-7
        case .success:        return Color(hex: "#389E0D") // green-7
        case .debt:           return Color(hex: "#D46B08") // orange-7
        case .info:           return .rbMedium
        case .custom(let c):  return c
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: Spacing.sm) {
        RBBadge(text: "Stock bajo", style: .warning, icon: "exclamationmark.triangle")
        RBBadge(text: "Sin stock", style: .error, icon: "xmark.circle")
        RBBadge(text: "Pagado", style: .success, icon: "checkmark.circle")
        RBBadge(text: "En deuda", style: .debt, icon: "clock")
        RBBadge(text: "Bebidas", style: .custom(Color(hex: "#2C21FC")))
        RBBadge(text: "General", style: .info)
    }
    .padding(Spacing.md)
    .background(Color.rbBackground)
}
