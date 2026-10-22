import SwiftUI
import SwiftData

struct Step3CategoriesView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var context

    @State private var categories: [Category] = []
    @State private var showAddSheet = false
    @State private var showError = false

    var body: some View {
        VStack(spacing: 0) {
            OnboardingProgressHeader(step: 3, total: 4, title: "Categorías")

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.md) {

                    Text("Crea al menos una categoría para organizar tus productos.")
                        .font(.rbBody)
                        .foregroundStyle(Color.rbGray)
                        .padding(.horizontal, Spacing.md)
                        .padding(.top, Spacing.md)

                    if showError {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("Debes crear al menos una categoría para continuar")
                        }
                        .font(.rbCaption)
                        .foregroundStyle(Color.rbError)
                        .padding(.horizontal, Spacing.md)
                    }

                    // Lista de categorías creadas
                    ForEach(categories) { category in
                        CategoryRowView(category: category) {
                            deleteCategory(category)
                        }
                        .padding(.horizontal, Spacing.md)
                    }

                    // Botón agregar
                    Button {
                        showAddSheet = true
                    } label: {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(Color.rbAccent)
                            Text("Agregar categoría")
                                .font(.rbButton)
                                .foregroundStyle(Color.rbAccent)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.md)
                        .background(Color.rbAccent.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, Spacing.md)
                }
                .padding(.bottom, Spacing.xxl)
            }

            Spacer()

            RBButton(title: "Siguiente", style: .accent, icon: "arrow.right") {
                guard !categories.isEmpty else {
                    showError = true
                    return
                }
                appState.nextOnboardingStep()
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
        .background(Color.rbBackground.ignoresSafeArea())
        .sheet(isPresented: $showAddSheet) {
            CategoryFormSheet { name, color, image in
                addCategory(name: name, color: color, image: image)
            }
        }
    }

    private func addCategory(name: String, color: String, image: String?) {
        guard let store = appState.activeStore else { return }
        let category = Category(name: name, color: color, image: image, store: store)
        context.insert(category)
        try? context.save()
        categories.append(category)
        showError = false
    }

    private func deleteCategory(_ category: Category) {
        category.deletedAt = Date()
        try? context.save()
        categories.removeAll { $0.id == category.id }
    }
}

// MARK: - CategoryRowView
private struct CategoryRowView: View {
    let category: Category
    let onDelete: () -> Void

    var body: some View {
        RBCard {
            HStack(spacing: Spacing.sm) {
                Circle()
                    .fill(Color(hex: category.color))
                    .frame(width: 32, height: 32)

                Text(category.name)
                    .font(.rbBody)
                    .foregroundStyle(Color.rbPrimary)

                Spacer()

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: IconSize.sm))
                        .foregroundStyle(Color.rbError)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - CategoryFormSheet
struct CategoryFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (String, String, String?) -> Void

    @State private var name = ""
    @State private var color = "#2C21FC"
    @State private var imageURL = ""
    @State private var showNameError = false

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
                        errorMessage: showNameError ? "El nombre es obligatorio" : nil
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
            .scrollDismissesKeyboard(.interactively)
            .simultaneousGesture(TapGesture().onEnded { hideKeyboard() })
            .navigationTitle("Nueva categoría")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(Color.rbGray)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
                            showNameError = true
                            return
                        }
                        onSave(name, color, imageURL.isEmpty ? nil : imageURL)
                        dismiss()
                    }
                    .font(.rbButton)
                    .foregroundStyle(Color.rbAccent)
                }
            }
            .background(Color.rbBackground.ignoresSafeArea())
        }
    }
}
