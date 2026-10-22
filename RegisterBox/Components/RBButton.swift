import SwiftUI

// MARK: - RBButton Style (Ant Design v5)
enum RBButtonStyle {
    case primary      // default antd: fondo blanco, borde, texto rbPrimary
    case accent       // primary antd: fondo rbAccent, texto blanco
    case secondary    // default antd sobre fondo gris
    case destructive  // danger antd: fondo rbError, texto blanco
    case ghost        // text antd: sin fondo, texto rbAccent
}

// MARK: - RBButton
struct RBButton: View {
    let title: String
    var style: RBButtonStyle = .primary
    var icon: String? = nil
    var isFullWidth: Bool = true
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                        .scaleEffect(0.8)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: IconSize.sm, weight: .semibold))
                    }
                    Text(title)
                        .font(.rbButton)
                }
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(minHeight: 40) // controlHeight antd
            .padding(.horizontal, Spacing.md)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .strokeBorder(borderColor, lineWidth: hasBorder ? 1 : 0)
            )
            .opacity(isDisabled || isLoading ? 0.5 : 1)
        }
        .disabled(isDisabled || isLoading)
        .buttonStyle(.plain)
    }

    // MARK: Colors (Ant Design v5)
    private var backgroundColor: Color {
        switch style {
        case .primary:     return .rbSurface   // default antd: blanco
        case .accent:      return .rbAccent    // primary antd
        case .secondary:   return .rbBackground
        case .destructive: return .rbError     // danger antd
        case .ghost:       return .clear       // text antd
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:     return .rbPrimary
        case .accent:      return .white
        case .secondary:   return .rbPrimary
        case .destructive: return .white
        case .ghost:       return .rbAccent
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary, .secondary: return .rbLightGray
        default:                   return .clear
        }
    }

    private var hasBorder: Bool {
        style == .primary || style == .secondary
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: Spacing.md) {
        RBButton(title: "Confirmar venta", style: .accent) {}
        RBButton(title: "Default", style: .primary) {}
        RBButton(title: "Cobrar", style: .accent, icon: "creditcard") {}
        RBButton(title: "Cancelar", style: .secondary) {}
        RBButton(title: "Eliminar", style: .destructive, icon: "trash") {}
        RBButton(title: "Ver historial", style: .ghost) {}
        RBButton(title: "Cargando...", style: .primary, isLoading: true) {}
    }
    .padding(Spacing.md)
    .background(Color.rbBackground)
}
