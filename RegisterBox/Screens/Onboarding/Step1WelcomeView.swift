import SwiftUI
import SwiftData

struct Step1WelcomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var context

    @State private var storeName = ""
    @State private var showError = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo / ícono
            ZStack {
                Circle()
                    .fill(Color.rbAccent.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "storefront.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.rbAccent)
            }
            .padding(.bottom, Spacing.xl)

            // Título
            Text("Bienvenido a RegisterBox")
                .font(.rbDisplay)
                .foregroundStyle(Color.rbPrimary)
                .multilineTextAlignment(.center)
                .padding(.bottom, Spacing.xs)

            Text("Gestiona tu tienda de forma simple y rápida")
                .font(.rbBody)
                .foregroundStyle(Color.rbGray)
                .multilineTextAlignment(.center)
                .padding(.bottom, Spacing.xxl)

            // Input nombre de tienda
            VStack(spacing: Spacing.xs) {
                RBTextField(
                    label: "¿Cómo se llama tu tienda?",
                    placeholder: "Ej. Tienda El Sol",
                    text: $storeName,
                    isRequired: true,
                    errorMessage: showError ? "El nombre es obligatorio" : nil
                )
                .focused($isFocused)
                .padding(.horizontal, Spacing.md)
            }

            Spacer()

            // Botón siguiente
            RBButton(title: "Comenzar", style: .primary, icon: "arrow.right") {
                let trimmed = storeName.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else {
                    showError = true
                    return
                }
                let store = Store(name: trimmed)
                context.insert(store)
                try? context.save()
                appState.activeStore = store
                isFocused = false
                appState.nextOnboardingStep()
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
        .onTapGesture { isFocused = false }
    }
}

#Preview {
    Step1WelcomeView()
        .environment(AppState())
}
