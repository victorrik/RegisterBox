import SwiftUI

// MARK: - RBTextField
struct RBTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isRequired: Bool = false
    var errorMessage: String? = nil
    var icon: String? = nil
    var isSecure: Bool = false
    /// Icono clickeable a la derecha (ej: "xmark.circle.fill" para limpiar)
    var trailingIcon: String? = nil
    var onTrailingIconTap: (() -> Void)? = nil

    @FocusState private var isFocused: Bool
    @State private var isSecureVisible: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {

            // Label
            HStack(spacing: 2) {
                Text(label)
                    .font(.rbLabel)
                    .foregroundStyle(Color.rbMedium)
                if isRequired {
                    Text("*")
                        .font(.rbLabel)
                        .foregroundStyle(Color.rbError)
                }
            }

            // Input container
            HStack(spacing: Spacing.xs) {

                // Icono izquierdo
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: IconSize.sm, weight: .medium))
                        .foregroundStyle(isFocused ? Color.rbAccent : Color.rbGray)
                        .frame(width: 20)
                }

                // Campo de texto
                Group {
                    if isSecure && !isSecureVisible {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(keyboardType == .URL ? .never : .sentences)
                    }
                }
                .font(.rbBody2)
                .foregroundStyle(Color.rbPrimary)
                .focused($isFocused)

                // Icono derecho — limpiar, toggle password, o custom
                if isSecure {
                    Button {
                        isSecureVisible.toggle()
                    } label: {
                        Image(systemName: isSecureVisible ? "eye.slash" : "eye")
                            .font(.system(size: IconSize.sm))
                            .foregroundStyle(Color.rbGray)
                    }
                    .buttonStyle(.plain)
                } else if !text.isEmpty {
                    // Botón limpiar si hay texto
                    Button {
                        text = ""
                        isFocused = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: IconSize.sm))
                            .foregroundStyle(Color.rbLightGray)
                    }
                    .buttonStyle(.plain)
                } else if let trailingIcon {
                    Button {
                        onTrailingIconTap?()
                    } label: {
                        Image(systemName: trailingIcon)
                            .font(.system(size: IconSize.sm))
                            .foregroundStyle(Color.rbGray)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.sm + 2)
            .background(Color.rbSurface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .strokeBorder(borderColor, lineWidth: 1)
            )
            // Anillo de foco estilo antd
            .overlay(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .strokeBorder(Color.rbAccent.opacity(isFocused && errorMessage == nil ? 0.2 : 0), lineWidth: 4)
            )
            .animation(.easeInOut(duration: 0.15), value: isFocused)

            // Error
            if let errorMessage {
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 11))
                    Text(errorMessage)
                        .font(.rbCaption)
                }
                .foregroundStyle(Color.rbError)
            }
        }
    }

    private var borderColor: Color {
        if errorMessage != nil { return .rbError }
        if isFocused { return .rbAccent }
        return .rbLightGray  // borde siempre visible
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var name = ""
    @Previewable @State var price = "99.00"
    @Previewable @State var password = ""

    VStack(spacing: Spacing.lg) {
        RBTextField(
            label: "Nombre de la tienda",
            placeholder: "Ej. Tienda El Sol",
            text: $name,
            isRequired: true
        )
        RBTextField(
            label: "Precio",
            placeholder: "0.00",
            text: $price,
            keyboardType: .decimalPad,
            icon: "dollarsign"
        )
        RBTextField(
            label: "Contraseña",
            placeholder: "••••••••",
            text: $password,
            icon: "lock", isSecure: true
        )
        RBTextField(
            label: "URL",
            placeholder: "https://...",
            text: $name,
            errorMessage: "URL inválida",
            icon: "link"
        )
    }
    .padding(Spacing.md)
    .background(Color.rbBackground)
}
