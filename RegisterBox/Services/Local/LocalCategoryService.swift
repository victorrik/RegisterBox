import Foundation
import SwiftData

final class LocalCategoryService: CategoryServiceProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll(storeId: UUID) async throws -> [Category] {
        let descriptor = FetchDescriptor<Category>(
            predicate: #Predicate { $0.store?.id == storeId && $0.deletedAt == nil },
            sortBy: [SortDescriptor(\.name)]
        )
        return try context.fetch(descriptor)
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
