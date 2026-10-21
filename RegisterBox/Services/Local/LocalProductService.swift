import Foundation
import SwiftData

final class LocalProductService: ProductServiceProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll(storeId: UUID) async throws -> [Product] {
        let descriptor = FetchDescriptor<Product>(
            predicate: #Predicate { $0.store?.id == storeId && $0.deletedAt == nil },
            sortBy: [SortDescriptor(\.name)]
        )
        return try context.fetch(descriptor)
    }

    func create(_ product: Product) async throws {
        context.insert(product)
        try context.save()
    }

    func update(_ product: Product) async throws {
        product.updatedAt = Date()
        try context.save()
    }

    func delete(_ product: Product) async throws {
        product.deletedAt = Date()
        product.updatedAt = Date()
        try context.save()
    }

    func adjustStock(
        product: Product,
        change: Int,
        eventType: ProductEventType,
        saleId: UUID?,
        note: String?
    ) async throws {
        let before = product.stock
        product.stock += change
        product.updatedAt = Date()

        let historyEntry = ProductHistory(
            product: product,
            store: product.store,
            eventType: eventType,
            quantityChange: change,
            stockBefore: before,
            stockAfter: product.stock,
            saleId: saleId,
            note: note
        )
        context.insert(historyEntry)
        try context.save()
    }
}
