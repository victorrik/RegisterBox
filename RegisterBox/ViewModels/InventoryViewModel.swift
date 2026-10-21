import Foundation
import Observation

@Observable
final class InventoryViewModel {

    // MARK: - State
    var products: [Product] = []
    var categories: [Category] = []
    var searchText = ""
    var selectedCategory: Category?
    var isLoading = false
    var error: String?

    // MARK: - Dependencies
    private let productService: ProductServiceProtocol
    private let categoryService: CategoryServiceProtocol
    private let storeId: UUID

    init(
        productService: ProductServiceProtocol,
        categoryService: CategoryServiceProtocol,
        storeId: UUID
    ) {
        self.productService  = productService
        self.categoryService = categoryService
        self.storeId          = storeId
    }

    // MARK: - Load
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products   = try await productService.fetchAll(storeId: storeId)
            categories = try await categoryService.fetchAll(storeId: storeId)
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Filtering
    var filteredProducts: [Product] {
        var result = products
        if let selectedCategory {
            result = result.filter { $0.category?.id == selectedCategory.id }
        }
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(query) ||
                $0.sku.lowercased().contains(query)
            }
        }
        return result
    }

    // MARK: - CRUD
    func createProduct(_ product: Product) async throws {
        try await productService.create(product)
        await load()
    }

    func updateProduct(_ product: Product) async throws {
        try await productService.update(product)
        await load()
    }

    func deleteProduct(_ product: Product) async throws {
        try await productService.delete(product)
        await load()
    }

    // MARK: - Stock
    func adjustStock(
        product: Product,
        change: Int,
        note: String? = nil
    ) async throws {
        try await productService.adjustStock(
            product: product,
            change: change,
            eventType: .stockUpdate,
            saleId: nil,
            note: note
        )
        await load()
    }

    // MARK: - History
    func history(for product: Product) -> [ProductHistory] {
        product.history.sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Validation
    /// Verifica si un SKU es único dentro de la tienda.
    func isSKUUnique(_ sku: String, excluding product: Product? = nil) -> Bool {
        products
            .filter { $0.id != product?.id }
            .allSatisfy { $0.sku.lowercased() != sku.lowercased() }
    }
}
