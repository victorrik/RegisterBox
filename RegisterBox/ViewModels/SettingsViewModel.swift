import Foundation
import Observation

@Observable
final class SettingsViewModel {

    // MARK: - State
    var store: Store?
    var categories: [Category] = []
    var isLoading = false
    var error: String?

    // MARK: - Dependencies
    private let storeService: StoreServiceProtocol
    private let categoryService: CategoryServiceProtocol
    private let storeId: UUID

    init(
        storeService: StoreServiceProtocol,
        categoryService: CategoryServiceProtocol,
        storeId: UUID
    ) {
        self.storeService    = storeService
        self.categoryService = categoryService
        self.storeId         = storeId
    }

    // MARK: - Load
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let stores = try await storeService.fetch()
            store = stores.first { $0.id == storeId }
            categories = try await categoryService.fetchAll(storeId: storeId)
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Store
    func updateStore(_ store: Store) async throws {
        try await storeService.update(store)
    }

    // MARK: - Categories CRUD
    func createCategory(_ category: Category) async throws {
        try await categoryService.create(category)
        await load()
    }

    func updateCategory(_ category: Category) async throws {
        try await categoryService.update(category)
        await load()
    }

    func deleteCategory(_ category: Category) async throws {
        try await categoryService.delete(category)
        await load()
    }

    // MARK: - Product Count
    /// Número de productos activos en una categoría.
    func productCount(for category: Category) -> Int {
        category.products.filter { $0.deletedAt == nil }.count
    }
}
