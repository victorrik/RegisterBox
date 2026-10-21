import SwiftUI

// MARK: - ProductDetailSheet
/// Bottom sheet de detalle de producto.
/// Muestra info, permite editar, ver historial, ajustar stock y eliminar.
struct ProductDetailSheet: View {
    @Environment(\.dismiss) private var dismiss

    let product: Product
    let categories: [Category]
    var onEdit: (Product) -> Void
    var onDelete: (Product) -> Void
    var onAdjustStock: (Product, Int, String?) -> Void

    @State private var showEditSheet = false
    @State private var showHistorySheet = false
    @State private var stockAmount = ""
    @State private var stockNote = ""
    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            RBSheetHeader(title: product.name, subtitle: "SKU: \(product.sku)") {
                dismiss()
            }
            Divider()

            ScrollView {
                VStack(spacing: Spacing.lg) {

                    // Imagen + info
                    VStack(spacing: Spacing.sm) {
                        if let imageURL = product.image, let url = URL(string: imageURL) {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                RoundedRectangle(cornerRadius: Radius.md)
                                    .fill(Color.rbLighterGray)
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                        } else {
                            RoundedRectangle(cornerRadius: Radius.md)
                                .fill(Color.rbLighterGray)
                                .frame(width: 100, height: 100)
                                .overlay {
                                    Image(systemName: "photo")
                                        .font(.system(size: IconSize.xl))
                                        .foregroundStyle(Color.rbGray)
                                }
                        }

                        // Badges de stock
                        HStack(spacing: Spacing.xs) {
                            if product.isOutOfStock {
                                RBBadge(text: "Agotado", style: .error, icon: "xmark.circle")
                            } else if product.isLowStock {
                                RBBadge(text: "Stock bajo", style: .warning, icon: "exclamationmark.triangle")
                            }
                            if let category = product.category {
                                RBBadge(text: category.name, style: .custom(Color(hex: category.color)))
                            }
                        }
                    }
                    .padding(.top, Spacing.md)

                    // Datos
                    detailGrid

                    Divider()

                    // Ajustar stock
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Ajustar stock")
                            .font(.rbLabel)
                            .foregroundStyle(Color.rbMedium)

                        RBTextField(
                            label: "Cantidad",
                            placeholder: "Ej. 10",
                            text: $stockAmount,
                            keyboardType: .numberPad,
                            icon: "shippingbox"
                        )

                        RBTextField(
                            label: "Nota (opcional)",
                            placeholder: "Motivo del ajuste",
                            text: $stockNote
                        )

                        HStack(spacing: Spacing.sm) {
                            RBButton(title: "+ Agregar", style: .accent, icon: "plus", isDisabled: stockAmount.isEmpty) {
                                adjustStock(change: Int(stockAmount) ?? 0)
                            }

                            RBButton(title: "- Quitar", style: .secondary, icon: "minus", isDisabled: stockAmount.isEmpty) {
                                adjustStock(change: -(Int(stockAmount) ?? 0))
                            }
                        }
                    }

                    Divider()

                    // Acciones
                    VStack(spacing: Spacing.xs) {
                        RBButton(title: "Editar producto", style: .secondary, icon: "pencil") {
                            showEditSheet = true
                        }

                        RBButton(title: "Ver historial", style: .ghost, icon: "clock") {
                            showHistorySheet = true
                        }

                        RBButton(title: "Eliminar producto", style: .destructive, icon: "trash") {
                            showDeleteConfirm = true
                        }
                    }
                    .padding(.bottom, Spacing.xxl)
                }
                .padding(.horizontal, Spacing.md)
            }
        }
        .background(Color.rbBackground.ignoresSafeArea())
        .sheet(isPresented: $showEditSheet) {
            ProductFormView(
                categories: categories,
                product: product,
                isSKUUnique: { _ in true } // ya validado al editar
            ) { updated in
                onEdit(updated)
            }
        }
        .sheet(isPresented: $showHistorySheet) {
            NavigationStack {
                ProductHistoryView(history: product.history.sorted { $0.createdAt > $1.createdAt })
                    .navigationTitle("Historial")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Cerrar") { showHistorySheet = false }
                                .foregroundStyle(Color.rbGray)
                        }
                    }
            }
        }
        .alert("¿Eliminar producto?", isPresented: $showDeleteConfirm) {
            Button("Cancelar", role: .cancel) {}
            Button("Eliminar", role: .destructive) {
                onDelete(product)
                dismiss()
            }
        } message: {
            Text("El producto se marcará como eliminado.")
        }
    }

    // MARK: - Detail Grid
    private var detailGrid: some View {
        VStack(spacing: Spacing.sm) {
            detailRow(label: "Precio", value: product.price.currencyString)
            detailRow(label: "Stock actual", value: "\(product.stock)")
            if let minStock = product.minStock {
                detailRow(label: "Stock mínimo", value: "\(minStock)")
            }
            detailRow(label: "Categoría", value: product.category?.name ?? "Sin categoría")
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.rbBody2)
                .foregroundStyle(Color.rbGray)
            Spacer()
            Text(value)
                .font(.rbBody)
                .foregroundStyle(Color.rbPrimary)
        }
    }

    // MARK: - Adjust Stock
    private func adjustStock(change: Int) {
        guard change != 0 else { return }
        onAdjustStock(product, change, stockNote.isEmpty ? nil : stockNote)
        stockAmount = ""
        stockNote = ""
    }
}
