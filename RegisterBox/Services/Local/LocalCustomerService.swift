import Foundation
import SwiftData

final class LocalCustomerService: CustomerServiceProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll(storeId: UUID) async throws -> [Customer] {
        let descriptor = FetchDescriptor<Customer>(
            predicate: #Predicate { $0.store?.id == storeId && $0.deletedAt == nil },
            sortBy: [SortDescriptor(\.name)]
        )
        return try context.fetch(descriptor)
    }

    func create(_ customer: Customer) async throws {
        context.insert(customer)
        try context.save()
    }

    func update(_ customer: Customer) async throws {
        customer.updatedAt = Date()
        try context.save()
    }

    func delete(_ customer: Customer) async throws {
        customer.deletedAt = Date()
        customer.updatedAt = Date()
        try context.save()
    }
}
