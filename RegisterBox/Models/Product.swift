import Foundation
import SwiftData

@Model
final class Product {
    var id: UUID
    var sku: String
    var name: String
    var price: Decimal
    var stock: Int
    var minStock: Int?
    var image: String?
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?

    var store: Store?
    var category: Category?

    @Relationship(deleteRule: .cascade, inverse: \ProductHistory.product)
    var history: [ProductHistory] = []

    init(
        sku: String,
        name: String,
        price: Decimal,
        stock: Int = 0,
        minStock: Int? = nil,
        image: String? = nil,
        store: Store? = nil,
        category: Category? = nil
    ) {
        self.id        = makeUUIDv7()
        self.sku       = sku
        self.name      = name
        self.price     = price
        self.stock     = stock
        self.minStock  = minStock
        self.image     = image
        self.store     = store
        self.category  = category
        self.createdAt = Date()
        self.updatedAt = Date()
        self.deletedAt = nil
    }

    /// Indica si el stock está por debajo del mínimo configurado.
    var isLowStock: Bool {
        guard let minStock else { return false }
        return stock <= minStock && stock > 0
    }

    /// Indica si el producto está agotado.
    var isOutOfStock: Bool { stock <= 0 }

    /// Indica si el producto está activo (no eliminado).
    var isActive: Bool { deletedAt == nil }
}
