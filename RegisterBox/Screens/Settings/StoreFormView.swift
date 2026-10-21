import SwiftUI

// MARK: - StoreFormView
/// Edición de tienda: nombre y logo (URL con preview).
struct StoreFormView: View {
    @Environment(\.dismiss) private var dismiss

    let store: Store
    var onSave: (Store) -> Void

    @State private var name = ""
    @State private var logoURL = ""
    @State private var nameError: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {

                    // Logo preview
                    VStack(spacing: Spacing.sm) {
                        if let url = URL(string: logoURL), !logoURL.isEmpty {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                placeholderLogo
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        } else {
                            placeholderLogo
                        }
                    }

                    RBTextField(
                        label: "Nombre de la tienda",
                        placeholder: "Ej. Mi Tienda",
                        text: $name,
                        isRequired: true,
                        errorMessage: nameError,
                        icon: "storefront"
                    )

                    RBTextField(
                        label: "Logo (URL)",
                        placeholder: "https://... (opcional)",
                        text: $logoURL,
                        keyboardType: .URL,
                        icon: "link"
                    )
                }
                .padding(Spacing.md)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Editar tienda")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(Color.rbGray)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { validateAndSave() }
                        .font(.rbButton)
                        .foregroundStyle(Color.rbAccent)
                }
            }
            .background(Color.rbBackground.ignoresSafeArea())
        }
        .onAppear {
            name = store.name
            logoURL = store.logo ?? ""
        }
    }

    private var placeholderLogo: some View {
        Circle()
            .fill(Color.rbLighterGray)
            .frame(width: 100, height: 100)
            .overlay {
                Image(systemName: "storefront")
                    .font(.system(size: IconSize.xl))
                    .foregroundStyle(Color.rbGray)
            }
    }

    private func validateAndSave() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            nameError = "El nombre es obligatorio"
            return
        }
        nameError = nil
        store.name = trimmed
        store.logo = logoURL.isEmpty ? nil : logoURL
        onSave(store)
        dismiss()
    }
}
