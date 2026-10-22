import SwiftUI

// MARK: - POSView
/// Pantalla principal de punto de venta.
/// iPhone: sheet de carrito desde abajo.
/// iPad: panel lateral derecho.
struct POSView: View {
    @Environment(\.productService) private var productService
    @Environment(\.categoryService) private var categoryService
    @Environment(\.customerService) private var customerService
    @Environment(\.saleService) private var saleService
    @Environment(AppState.self) private var appState
    @Environment(CartStore.self) private var cartStore

    @State private var viewModel: POSViewModel?
    @State private var showCart = false
    @State private var showCheckout = false

    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    private var columns: [GridItem] {
        isPad
            ? Array(repeating: GridItem(.flexible(), spacing: Spacing.sm), count: 3)
            : [GridItem(.flexible(), spacing: Spacing.sm)]
    }

    var body: some View {
        Group {
            if let vm = viewModel {
                if isPad {
                    ipadLayout(vm)
                } else {
                    iphoneLayout(vm)
                }
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
                  let cs = categoryService,
                  let cus = customerService,
                  let ss = saleService else { return }
            let vm = POSViewModel(
                productService: ps,
                categoryService: cs,
                customerService: cus,
                saleService: ss,
                cartStore: cartStore,
                store: store
            )
            viewModel = vm
            await vm.load()
        }
        .onAppear {
            // Recarga al volver al tab de POS para reflejar productos/categorías
            // creados en otras pantallas (Inventario, Settings).
            if let viewModel {
                Task { await viewModel.load() }
            }
        }
    }

    // MARK: - Shared POS Content
    @ViewBuilder
    private func posContent(_ vm: POSViewModel) -> some View {
        VStack(spacing: 0) {
            CategoryChipsView(
                categories: vm.categories,
                selectedCategory: Binding(
                    get: { vm.selectedCategory },
                    set: { vm.selectedCategory = $0 }
                )
            )

            ScrollView {
                if vm.filteredProducts.isEmpty {
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "tray")
                            .font(.system(size: IconSize.xl))
                            .foregroundStyle(Color.rbGray)
                        Text("No hay productos")
                            .font(.rbBody)
                            .foregroundStyle(Color.rbGray)
                    }
                    .padding(.top, Spacing.xxxl)
                } else {
                    LazyVGrid(columns: columns, spacing: Spacing.sm) {
                        ForEach(vm.filteredProducts) { product in
                            ProductCardView(
                                product: product,
                                cartQuantity: cartStore.quantity(for: product.id),
                                isAtStockLimit: cartStore.isAtStockLimit(for: product.id),
                                onTap: { cartStore.add(product) }
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.xs)
                    .padding(.bottom, 80)
                }
            }
        }
        .background(Color.rbBackground.ignoresSafeArea())
    }

    // MARK: - FAB
    @ViewBuilder
    private func fabView() -> some View {
        CartFABView(itemCount: cartStore.itemCount) {
            showCart = true
        }
        .padding(.trailing, Spacing.md)
        .padding(.bottom, Spacing.md)
    }

    // MARK: - iPhone Layout
    @ViewBuilder
    private func iphoneLayout(_ vm: POSViewModel) -> some View {
        ZStack(alignment: .bottomTrailing) {
            posContent(vm)
            fabView()
        }
        .sheet(isPresented: $showCart) {
            CartSheetView {
                showCheckout = true
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showCheckout) {
            if let vm = viewModel {
                CheckoutView(viewModel: vm, cartStore: cartStore) {}
            }
        }
    }

    // MARK: - iPad Layout
    @ViewBuilder
    private func ipadLayout(_ vm: POSViewModel) -> some View {
        ZStack(alignment: .bottomTrailing) {
            posContent(vm)
            fabView()
        }
        .overlay {
            if showCart {
                ZStack(alignment: .trailing) {
                    Color.rbShadow.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture { showCart = false }

                    CartSidePanelView(
                        cartStore: cartStore,
                        onClose: { showCart = false },
                        onCheckout: {
                            showCart = false
                            showCheckout = true
                        }
                    )
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
                .animation(.easeInOut(duration: 0.3), value: showCart)
            }
        }
        .sheet(isPresented: $showCheckout) {
            if let vm = viewModel {
                CheckoutView(viewModel: vm, cartStore: cartStore) {}
            }
        }
    }
}
