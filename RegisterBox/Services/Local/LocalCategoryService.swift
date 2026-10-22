import Foundation
import SwiftData

final class LocalCategoryService: CategoryServiceProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll(storeId: UUID) async throws -> [Category] {
        // SwiftData no traduce bien `store?.id == storeId` en #Predicate sobre
        // relaciones opcionales (devuelve vacío), así que filtramos en memoria.
        let descriptor = FetchDescriptor<Category>(
            predicate: #Predicate { $0.deletedAt == nil },
            sortBy: [SortDescriptor(\.name)]
        )
        return try context.fetch(descriptor).filter { $0.store?.id == storeId }
    }

    func create(_ category: Category) async throws {
        context.insert(category)
        try context.save()
    }

    func update(_ category: Category) async throws {
        category.updatedAt = Date()
        try context.save()
    }

    func delete(_ category: Category) async throws {
        category.deletedAt = Date()
        category.updatedAt = Date()
        try context.save()
    }
}
