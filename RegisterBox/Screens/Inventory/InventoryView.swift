import SwiftUI

// MARK: - InventoryView
/// Lista de productos con badges, buscador, filtro de categoría, crear/editar/eliminar.
struct InventoryView: View {
    @Environment(\.productService) private var productService
    @Environment(\.categoryService) private var categoryService
    @Environment(AppState.self) private var appState

    @State private var viewModel: InventoryViewModel?
    @State private var showAddSheet = false
    @State private var selectedProduct: Product?

    var body: some View {
        Group {
            if let vm = viewModel {
                content(vm)
            } else {
                ProgressView("Cargando...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.rbBackground.ignoresSafeArea())
            }
        }
        .task {
            guard viewModel == nil,
                  let store = appState.activeStore,
                  let ps = productService,
                  let cs = categoryService else { return }
            let vm = InventoryViewModel(
                productService: ps,
                categoryService: cs,
                storeId: store.id
            )
            viewModel = vm
            await vm.load()
        }
    }

    // MARK: - Content
    @ViewBuilder
    private func content(_ vm: InventoryViewModel) -> some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Buscador
                RBTextField(
                    label: "",
                    placeholder: "Buscar producto o SKU...",
                    text: Binding(
                        get: { vm.searchText },
                        set: { vm.searchText = $0 }
                    ),
                    icon: "magnifyingglass"
                )
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.sm)

                // Filtro de categoría
                CategoryChipsView(
                    categories: vm.categories,
                    selectedCategory: Binding(
                        get: { vm.selectedCategory },
                        set: { vm.selectedCategory = $0 }
                    )
                )
                .padding(.top, Spacing.xs)

                // Lista
                if vm.filteredProducts.isEmpty {
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "shippingbox")
                            .font(.system(size: IconSize.xl))
                            .foregroundStyle(Color.rbGray)
                        Text("No hay productos")
                            .font(.rbBody)
                            .foregroundStyle(Color.rbGray)
                        Text("Crea uno con el botón +")
                            .font(.rbCaption)
                            .foregroundStyle(Color.rbGray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(vm.filteredProducts) { product in
                            Button {
                                selectedProduct = product
                            } label: {
                                ProductRow(product: product)
                            }
                            .buttonStyle(.plain)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: Spacing.xxs, leading: Spacing.md, bottom: Spacing.xxs, trailing: Spacing.md))
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    Task { try? await vm.deleteProduct(product) }
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollDismissesKeyboard(.immediately)
                }
            }
            .navigationTitle("Inventario")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: IconSize.md, weight: .semibold))
                            .foregroundStyle(Color.rbAccent)
                    }
                }
            }
            .background(Color.rbBackground.ignoresSafeArea())
            .sheet(isPresented: $showAddSheet) {
                ProductFormView(
                    categories: vm.categories,
                    product: nil,
                    isSKUUnique: { sku in vm.isSKUUnique(sku) }
                ) { newProduct in
                    newProduct.store = appState.activeStore
                    Task { try? await vm.createProduct(newProduct) }
                }
            }
            .sheet(item: $selectedProduct) { product in
                ProductDetailSheet(
                    product: product,
                    categories: vm.categories,
                    onEdit: { updated in
                        Task { try? await vm.updateProduct(updated) }
                    },
                    onDelete: { deleted in
                        Task { try? await vm.deleteProduct(deleted) }
                    },
                    onAdjustStock: { prod, change, note in
                        Task { try? await vm.adjustStock(product: prod, change: change, note: note) }
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }
}

// MARK: - ProductRow
private struct ProductRow: View {
    let product: Product

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Imagen
            if let imageURL = product.image, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    RoundedRectangle(cornerRadius: Radius.sm)
                        .fill(Color.rbLighterGray)
                }
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
            } else {
                RoundedRectangle(cornerRadius: Radius.sm)
                    .fill(Color.rbLighterGray)
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: IconSize.sm))
                            .foregroundStyle(Color.rbGray)
                    }
            }

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .font(.rbProductCard)
                    .foregroundStyle(Color.rbPrimary)

                Text("SKU: \(product.sku)")
                    .font(.rbCaption)
                    .foregroundStyle(Color.rbGray)
            }

            Spacer()

            // Stock + precio
            VStack(alignment: .trailing, spacing: Spacing.xxs) {
                Text(product.price.currencyString)
                    .font(.rbPriceSmall)
                    .foregroundStyle(Color.rbAccent)

                HStack(spacing: Spacing.xxs) {
                    Text("Stock: \(product.stock)")
                        .font(.rbCaption)
                        .foregroundStyle(Color.rbMedium)

                    if product.isOutOfStock {
                        RBBadge(text: "Agotado", style: .error)
                    } else if product.isLowStock {
                        RBBadge(text: "Bajo", style: .warning)
                    }
                }
            }
        }
        .padding(Spacing.sm)
        .background(Color.rbSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .rbShadow()
    }
}
