import Foundation
import Observation

@Observable
final class POSViewModel {

    // MARK: - State
    var products: [Product] = []
    var categories: [Category] = []
    var selectedCategory: Category?
    var customers: [Customer] = []
    var isLoading = false
    var error: String?

    // Checkout
    var checkoutMode: CheckoutMode = .paid
    var amountReceived: Decimal = 0
    var isProcessing = false

    enum CheckoutMode { case paid, debt }

    // MARK: - Dependencies
    private let productService: ProductServiceProtocol
    private let categoryService: CategoryServiceProtocol
    private let customerService: CustomerServiceProtocol
    private let saleService: SaleServiceProtocol
    private let cartStore: CartStore
    private let store: Store

    init(
        productService: ProductServiceProtocol,
        categoryService: CategoryServiceProtocol,
        customerService: CustomerServiceProtocol,
        saleService: SaleServiceProtocol,
        cartStore: CartStore,
        store: Store
    ) {
        self.productService  = productService
        self.categoryService = categoryService
        self.customerService = customerService
        self.saleService     = saleService
        self.cartStore       = cartStore
        self.store           = store
    }

    // MARK: - Load
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products   = try await productService.fetchAll(storeId: store.id)
            categories = try await categoryService.fetchAll(storeId: store.id)
            customers  = try await customerService.fetchAll(storeId: store.id)
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Filtering
    var filteredProducts: [Product] {
        if let selectedCategory {
            return products.filter { $0.category?.id == selectedCategory.id }
        }
        return products
    }

    // MARK: - Checkout
    var change: Decimal {
        max(amountReceived - cartStore.total, 0)
    }

    var canCheckout: Bool {
        switch checkoutMode {
        case .paid:
            return !cartStore.isEmpty && amountReceived >= cartStore.total
        case .debt:
            return !cartStore.isEmpty && cartStore.selectedCustomer != nil
        }
    }

    func checkout() async throws -> Sale {
        isProcessing = true
        defer { isProcessing = false }

        let sale = try await saleService.create(
            from: cartStore,
            store: store,
            status: checkoutMode == .paid ? .paid : .debt,
            change: checkoutMode == .paid ? change : 0
        )
        cartStore.clear()
        amountReceived = 0
        return sale
    }
}
