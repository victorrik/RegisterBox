import SwiftUI

// MARK: - CategoryFormView
/// Form de categoría: crear o editar. Campos: nombre, color, imagen.
/// Versión con modo editar del CategoryFormSheet del Onboarding.
struct CategoryFormView: View {
    @Environment(\.dismiss) private var dismiss

    let category: Category?
    var onSave: (String, String, String?) -> Void

    @State private var name = ""
    @State private var color = "#2C21FC"
    @State private var imageURL = ""
    @State private var nameError: String?

    private var isEditing: Bool { category != nil }

    let colorOptions = ["#2C21FC","#FF3B30","#34C759","#FF9500","#F7A827",
                        "#5856D6","#007AFF","#FF2D55","#303336","#30B0C7"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {

                    RBTextField(
                        label: "Nombre",
                        placeholder: "Ej. Bebidas",
                        text: $name,
                        isRequired: true,
                        errorMessage: nameError,
                        icon: "tag"
                    )

                    // Color picker
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Color")
                            .font(.rbLabel)
                            .foregroundStyle(Color.rbMedium)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: Spacing.sm) {
                            ForEach(colorOptions, id: \.self) { hex in
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(Color.rbPrimary, lineWidth: color == hex ? 3 : 0)
                                    )
                                    .onTapGesture { color = hex }
                            }
                        }
                    }

                    RBTextField(
                        label: "Imagen",
                        placeholder: "https://... (opcional)",
                        text: $imageURL,
                        keyboardType: .URL,
                        icon: "link"
                    )
                }
                .padding(Spacing.md)
            }
            .navigationTitle(isEditing ? "Editar categoría" : "Nueva categoría")
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
            if let category {
                name = category.name
                color = category.color
                imageURL = category.image ?? ""
            }
        }
    }

    private func validateAndSave() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            nameError = "El nombre es obligatorio"
            return
        }
        nameError = nil
        onSave(trimmed, color, imageURL.isEmpty ? nil : imageURL)
        dismiss()
    }
}
