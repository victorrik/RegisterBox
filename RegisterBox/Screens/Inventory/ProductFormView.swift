import SwiftUI

// MARK: - ProductFormView
/// Form de producto: crear o editar.
/// Campos: SKU, nombre, precio, stock, minStock, categoría, imagen.
struct ProductFormView: View {
    @Environment(\.dismiss) private var dismiss

    let categories: [Category]
    let product: Product?
    var isSKUUnique: (String) -> Bool
    var onSave: (Product) -> Void

    @State private var sku = ""
    @State private var name = ""
    @State private var price = ""
    @State private var stock = ""
    @State private var minStock = ""
    @State private var selectedCategory: Category?
    @State private var imageURL = ""

    @State private var skuError: String?
    @State private var nameError: String?
    @State private var priceError: String?
    @State private var stockError: String?

    private var isEditing: Bool { product != nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {

                    RBTextField(
                        label: "SKU",
                        placeholder: "Ej. PRD-001",
                        text: $sku,
                        isRequired: true,
                        errorMessage: skuError,
                        icon: "barcode"
                    )

                    RBTextField(
                        label: "Nombre",
                        placeholder: "Ej. Coca-Cola 600ml",
                        text: $name,
                        isRequired: true,
                        errorMessage: nameError
                    )

                    RBTextField(
                        label: "Precio",
                        placeholder: "0.00",
                        text: $price,
                        keyboardType: .decimalPad,
                        isRequired: true,
                        errorMessage: priceError,
                        icon: "dollarsign.circle"
                    )

                    RBTextField(
                        label: "Stock",
                        placeholder: "0",
                        text: $stock,
                        keyboardType: .numberPad,
                        isRequired: true,
                        errorMessage: stockError,
                        icon: "shippingbox"
                    )

                    RBTextField(
                        label: "Stock mínimo",
                        placeholder: "Opcional (alerta)",
                        text: $minStock,
                        keyboardType: .numberPad,
                        icon: "exclamationmark.triangle"
                    )

                    // Categoría
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Categoría")
                            .font(.rbLabel)
                            .foregroundStyle(Color.rbMedium)

                        Menu {
                            Button("Sin categoría") { selectedCategory = nil }
                            ForEach(categories) { cat in
                                Button(cat.name) { selectedCategory = cat }
                            }
                        } label: {
                            HStack {
                                if let cat = selectedCategory {
                                    Circle()
                                        .fill(Color(hex: cat.color))
                                        .frame(width: 12, height: 12)
                                    Text(cat.name)
                                } else {
                                    Text("Sin categoría")
                                        .foregroundStyle(Color.rbGray)
                                }
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: IconSize.sm))
                                    .foregroundStyle(Color.rbMedium)
                            }
                            .padding(Spacing.sm)
                            .background(Color.rbBackground)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
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
            .navigationTitle(isEditing ? "Editar producto" : "Nuevo producto")
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
        .onAppear { populateFields() }
    }

    // MARK: - Populate (edit mode)
    private func populateFields() {
        guard let product else { return }
        sku = product.sku
        name = product.name
        price = String(format: "%.2f", NSDecimalNumber(decimal: product.price).doubleValue)
        stock = "\(product.stock)"
        minStock = product.minStock.map { "\($0)" } ?? ""
        selectedCategory = product.category
        imageURL = product.image ?? ""
    }

    // MARK: - Validate & Save
    private func validateAndSave() {
        // Reset errors
        skuError = nil
        nameError = nil
        priceError = nil
        stockError = nil

        let trimmedSKU = sku.trimmingCharacters(in: .whitespaces)
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        // Validar SKU
        if trimmedSKU.isEmpty {
            skuError = "El SKU es obligatorio"
        } else if !isSKUUnique(trimmedSKU) {
            skuError = "Ya existe un producto con este SKU"
        }

        // Validar nombre
        if trimmedName.isEmpty {
            nameError = "El nombre es obligatorio"
        }

        // Validar precio
        let priceValue = Decimal(string: price)
        if price.isEmpty {
            priceError = "El precio es obligatorio"
        } else if priceValue == nil || (priceValue ?? 0) < 0 {
            priceError = "Precio inválido"
        }

        // Validar stock
        let stockValue = Int(stock)
        if stock.isEmpty {
            stockError = "El stock es obligatorio"
        } else if stockValue == nil || (stockValue ?? 0) < 0 {
            stockError = "Stock inválido"
        }

        guard skuError == nil, nameError == nil, priceError == nil, stockError == nil else { return }

        // Guardar
        if let product {
            // Editar
            product.sku = trimmedSKU
            product.name = trimmedName
            product.price = priceValue ?? 0
            product.stock = stockValue ?? 0
            product.minStock = Int(minStock)
            product.category = selectedCategory
            product.image = imageURL.isEmpty ? nil : imageURL
            onSave(product)
        } else {
            // Crear
            let newProduct = Product(
                sku: trimmedSKU,
                name: trimmedName,
                price: priceValue ?? 0,
                stock: stockValue ?? 0,
                minStock: Int(minStock),
                image: imageURL.isEmpty ? nil : imageURL
            )
            newProduct.category = selectedCategory
            onSave(newProduct)
        }
        dismiss()
    }
}
