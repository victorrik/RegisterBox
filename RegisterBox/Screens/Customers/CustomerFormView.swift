import SwiftUI

// MARK: - CustomerFormView
/// Form de cliente: crear o editar. Campos: nombre (obligatorio), teléfono (opcional).
struct CustomerFormView: View {
    @Environment(\.dismiss) private var dismiss

    let customer: Customer?
    var onSave: (String, String?) -> Void

    @State private var name = ""
    @State private var phone = ""
    @State private var nameError: String?

    private var isEditing: Bool { customer != nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    RBTextField(
                        label: "Nombre",
                        placeholder: "Nombre del cliente",
                        text: $name,
                        isRequired: true,
                        errorMessage: nameError,
                        icon: "person"
                    )

                    RBTextField(
                        label: "Teléfono",
                        placeholder: "Opcional",
                        text: $phone,
                        keyboardType: .phonePad,
                        icon: "phone"
                    )
                }
                .padding(Spacing.md)
            }
            .scrollDismissesKeyboard(.interactively)
            .simultaneousGesture(TapGesture().onEnded { hideKeyboard() })
            .navigationTitle(isEditing ? "Editar cliente" : "Nuevo cliente")
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
            if let customer {
                name = customer.name
                phone = customer.phone ?? ""
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
        onSave(trimmed, phone.isEmpty ? nil : phone)
        dismiss()
    }
}
