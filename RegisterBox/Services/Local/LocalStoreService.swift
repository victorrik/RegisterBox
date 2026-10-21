import Foundation
import SwiftData

final class LocalStoreService: StoreServiceProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetch() async throws -> [Store] {
        let descriptor = FetchDescriptor<Store>(
            predicate: #Predicate { $0.deletedAt == nil },
            sortBy: [SortDescriptor(\.createdAt)]
        )
        return try context.fetch(descriptor)
    }

    func create(_ store: Store) async throws {
        context.insert(store)
        try context.save()
    }

    func update(_ store: Store) async throws {
        store.updatedAt = Date()
        try context.save()
    }

    func delete(_ store: Store) async throws {
        store.deletedAt = Date()
        store.updatedAt = Date()
        try context.save()
    }
}
