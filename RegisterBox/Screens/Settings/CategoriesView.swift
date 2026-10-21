import SwiftUI

// MARK: - CategoriesView
/// Lista de categorías con color, nombre, conteo de productos.
/// Permite crear, editar, eliminar y ver productos por categoría.
struct CategoriesView: View {
    let categories: [Category]
    var productCount: (Category) -> Int
    var onCreate: () -> Void
    var onEdit: (Category) -> Void
    var onDelete: (Category) -> Void

    @State private var showProducts: Category?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Categorías")
                    .font(.rbTitle2)
                    .foregroundStyle(Color.rbPrimary)
                Spacer()
                Button {
                    onCreate()
                } label: {
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: IconSize.sm))
                        Text("Nueva")
                            .font(.rbButtonSm)
                    }
                    .foregroundStyle(Color.rbAccent)
                }
                .buttonStyle(.plain)
            }

            if categories.isEmpty {
                Text("No hay categorías")
                    .font(.rbCaption)
                    .foregroundStyle(Color.rbGray)
                    .padding(Spacing.sm)
            } else {
                ForEach(categories) { category in
                    Button {
                        showProducts = category
                    } label: {
                        CategoryRow(
                            category: category,
                            count: productCount(category),
                            onEdit: { onEdit(category) },
                            onDelete: { onDelete(category) }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .sheet(item: $showProducts) { category in
            CategoryProductsSheet(category: category)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - CategoryRow
private struct CategoryRow: View {
    let category: Category
    let count: Int
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Circle()
                .fill(Color(hex: category.color))
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.rbBody)
                    .foregroundStyle(Color.rbPrimary)
                Text("\(count) producto(s)")
                    .font(.rbCaption)
                    .foregroundStyle(Color.rbGray)
            }

            Spacer()

            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: IconSize.sm))
                    .foregroundStyle(Color.rbMedium)
            }
            .buttonStyle(.plain)

            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: IconSize.sm))
                    .foregroundStyle(Color.rbError)
            }
            .buttonStyle(.plain)
        }
        .padding(Spacing.sm)
        .background(Color.rbSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
    }
}

// MARK: - CategoryProductsSheet
/// Muestra los productos de una categoría con su stock.
private struct CategoryProductsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let category: Category

    private var products: [Product] {
        category.products.filter { $0.deletedAt == nil }.sorted { $0.name < $1.name }
    }

    var body: some View {
        VStack(spacing: 0) {
            RBSheetHeader(title: category.name, subtitle: "\(products.count) producto(s)") {
                dismiss()
            }
            Divider()

            if products.isEmpty {
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "shippingbox")
                        .font(.system(size: IconSize.xl))
                        .foregroundStyle(Color.rbGray)
                    Text("Sin productos en esta categoría")
                        .font(.rbBody)
                        .foregroundStyle(Color.rbGray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: Spacing.xs) {
                        ForEach(products, id: \.id) { product in
                            HStack {
                                Text(product.name)
                                    .font(.rbBody2)
                                    .foregroundStyle(Color.rbPrimary)
                                Spacer()
                                Text("Stock: \(product.stock)")
                                    .font(.rbCaption)
                                    .foregroundStyle(product.isOutOfStock ? Color.rbError : Color.rbMedium)
                            }
                            .padding(Spacing.sm)
                            .background(Color.rbSurface)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
                        }
                    }
                    .padding(Spacing.md)
                }
            }
        }
        .background(Color.rbBackground.ignoresSafeArea())
    }
}
