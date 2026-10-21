import SwiftUI

// MARK: - Keyboard Dismiss
extension View {
    /// Oculta el teclado al tocar fuera de cualquier campo de texto.
    /// Usa un gesto que no interfiere con botones ni scroll.
    func dismissKeyboardOnTap() -> some View {
        modifier(DismissKeyboardOnTap())
    }

    /// Cierra el teclado de forma imperativa.
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

// MARK: - Modifier
private struct DismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                // Capa transparente que captura taps en áreas vacías
                // sin bloquear botones, listas ni scroll.
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil,
                            from: nil,
                            for: nil
                        )
                    }
            )
    }
}
