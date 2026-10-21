import Foundation
import SwiftData

@Model
final class Customer {
    var id: UUID
    var name: String
    var phone: String?
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?

    var store: Store?

    @Relationship(inverse: \Sale.customer)
    var sales: [Sale] = []

    init(name: String, phone: String? = nil, store: Store? = nil) {
        self.id        = makeUUIDv7()
        self.name      = name
        self.phone     = phone
        self.store     = store
        self.createdAt = Date()
        self.updatedAt = Date()
        self.deletedAt = nil
    }

    /// Total adeudado: suma de saldos pendientes en ventas con deuda.
    var totalDebt: Decimal {
        sales
            .filter { $0.status == .debt && $0.deletedAt == nil }
            .reduce(Decimal(0)) { $0 + $1.remainingBalance }
    }

    /// Total gastado en ventas pagadas.
    var totalSpent: Decimal {
        sales
            .filter { $0.status == .paid && $0.deletedAt == nil }
            .reduce(Decimal(0)) { $0 + $1.total }
    }

    var isActive: Bool { deletedAt == nil }
}
