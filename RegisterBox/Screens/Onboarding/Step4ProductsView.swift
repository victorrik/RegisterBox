import SwiftUI
import SwiftData

struct Step4ProductsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var context

    @State private var products: [Product] = []
    @State private var showAddSheet = false

    var body: some View {
        VStack(spacing: 0) {
            OnboardingProgressHeader(step: 4, total: 4, title: "Productos")

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.md) {

                    Text("Agrega tus productos. Puedes hacerlo ahora o después desde Inventario.")
                        .font(.rbBody)
                        .foregroundStyle(Color.rbGray)
                        .padding(.horizontal, Spacing.md)
                        .padding(.top, Spacing.md)

                    ForEach(products) { product in
                        RBCard {
                            HStack(spacing: Spacing.sm) {
                                VStack(alignment: .leading, spacing: Spacing.xxs) {
                                    Text(product.name)
                                        .font(.rbProductCard)
                                        .foregroundStyle(Color.rbPrimary)
                                    Text("SKU: \(product.sku)")
                                        .font(.rbCaption)
                                        .foregroundStyle(Color.rbGray)
                                }
                                Spacer()
                                Text(product.price.currencyString)
                                    .font(.rbPrice)
                                    .foregroundStyle(Color.rbPrimary)
                            }
                        }
                        .padding(.horizontal, Spacing.md)
                    }

                    Button {
                        showAddSheet = true
                    } label: {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(Color.rbAccent)
                            Text("Agregar producto")
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

            VStack(spacing: Spacing.sm) {
                RBButton(title: "Finalizar", style: .primary, icon: "checkmark") {
                    appState.completeOnboarding()
                }

                if products.isEmpty {
                    RBButton(title: "Saltar, lo haré después", style: .ghost) {
                        appState.completeOnboarding()
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
        .background(Color.rbBackground.ignoresSafeArea())
        .sheet(isPresented: $showAddSheet) {
            QuickProductFormSheet { sku, name, price, stock in
                addProduct(sku: sku, name: name, price: price, stock: stock)
            }
        }
    }

    private func addProduct(sku: String, name: String, price: Decimal, stock: Int) {
        guard let store = appState.activeStore else { return }
        let product = Product(sku: sku, name: name, price: price, stock: stock, store: store)
        context.insert(product)
        try? context.save()
        products.append(product)
    }
}

// MARK: - QuickProductFormSheet
private struct QuickProductFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (String, String, Decimal, Int) -> Void

    @State private var sku = ""
    @State private var name = ""
    @State private var priceText = ""
    @State private var stockText = "0"
    @State private var showError = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    RBTextField(label: "Nombre", placeholder: "Ej. Coca Cola 600ml", text: $name, isRequired: true)
                    RBTextField(label: "SKU", placeholder: "Código único", text: $sku, isRequired: true)
                    RBTextField(label: "Precio", placeholder: "0.00", text: $priceText, keyboardType: .decimalPad, icon: "dollarsign")
                    RBTextField(label: "Stock inicial", placeholder: "0", text: $stockText, keyboardType: .numberPad)

                    if showError {
                        Text("Nombre, SKU y precio son obligatorios")
                            .font(.rbCaption)
                            .foregroundStyle(Color.rbError)
                    }
                }
                .padding(Spacing.md)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Nuevo producto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }.foregroundStyle(Color.rbGray)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        guard !name.isEmpty, !sku.isEmpty, let price = Decimal(string: priceText), price > 0 else {
                            showError = true
                            return
                        }
                        let stock = Int(stockText) ?? 0
                        onSave(sku, name, price, stock)
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
