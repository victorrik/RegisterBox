import SwiftUI

// MARK: - RBButton Style
enum RBButtonStyle {
    case primary      // fondo rbMedium, texto blanco
    case accent       // fondo rbAccent, texto blanco
    case secondary    // fondo rbBackground, texto rbPrimary
    case destructive  // fondo rbError, texto blanco
    case ghost        // sin fondo, texto rbAccent
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
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm + 2)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg)
                    .strokeBorder(borderColor, lineWidth: style == .ghost ? 0 : 0)
            )
            .opacity(isDisabled || isLoading ? 0.5 : 1)
        }
        .disabled(isDisabled || isLoading)
        .buttonStyle(.plain)
    }

    // MARK: Colors
    private var backgroundColor: Color {
        switch style {
        case .primary:     return .rbMedium
        case .accent:      return .rbAccent
        case .secondary:   return .rbBackground
        case .destructive: return .rbError
        case .ghost:       return .clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:     return .white
        case .accent:      return .white
        case .secondary:   return .rbPrimary
        case .destructive: return .white
        case .ghost:       return .rbAccent
        }
    }

    private var borderColor: Color {
        switch style {
        case .secondary: return .rbLightGray
        default:         return .clear
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: Spacing.md) {
        RBButton(title: "Confirmar venta", style: .primary) {}
        RBButton(title: "Cobrar", style: .accent, icon: "creditcard") {}
        RBButton(title: "Cancelar", style: .secondary) {}
        RBButton(title: "Eliminar", style: .destructive, icon: "trash") {}
        RBButton(title: "Ver historial", style: .ghost) {}
        RBButton(title: "Cargando...", style: .primary, isLoading: true) {}
    }
    .padding(Spacing.md)
    .background(Color.rbBackground)
}
