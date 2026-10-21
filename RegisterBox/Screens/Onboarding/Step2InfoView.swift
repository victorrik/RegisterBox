import SwiftUI
import SwiftData

struct Step2InfoView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var context

    @State private var logoURL = ""

    var body: some View {
        VStack(spacing: 0) {

            // Header de progreso
            OnboardingProgressHeader(step: 2, total: 4, title: "Info de la tienda")

            ScrollView {
                VStack(spacing: Spacing.xl) {

                    // Preview logo
                    ZStack {
                        RoundedRectangle(cornerRadius: Radius.md)
                            .fill(Color.rbLighterGray)
                            .frame(width: 100, height: 100)

                        if let url = URL(string: logoURL), !logoURL.isEmpty {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                        } else {
                            Image(systemName: "photo")
                                .font(.system(size: 32))
                                .foregroundStyle(Color.rbLightGray)
                        }
                    }

                    RBTextField(
                        label: "Logo de la tienda",
                        placeholder: "https://... (URL de imagen)",
                        text: $logoURL,
                        keyboardType: .URL,
                        icon: "link"
                    )

                    Text("Opcional — puedes agregarlo después desde Configuración")
                        .font(.rbCaption)
                        .foregroundStyle(Color.rbGray)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.xl)
            }

            Spacer()

            VStack(spacing: Spacing.sm) {
                RBButton(title: "Siguiente", style: .primary, icon: "arrow.right") {
                    // Guardar logo si se ingresó
                    if let store = appState.activeStore, !logoURL.isEmpty {
                        store.logo = logoURL
                        try? context.save()
                    }
                    appState.nextOnboardingStep()
                }

                RBButton(title: "Saltar por ahora", style: .ghost) {
                    appState.nextOnboardingStep()
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
        .background(Color.rbBackground.ignoresSafeArea())
    }
}
