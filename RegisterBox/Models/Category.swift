import Foundation
import SwiftData

@Model
final class Category {
    var id: UUID
    var name: String
    var image: String?
    var color: String
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?

    var store: Store?

    @Relationship(inverse: \Product.category)
    var products: [Product] = []

    init(name: String, color: String = "#303336", image: String? = nil, store: Store? = nil) {
        self.id        = makeUUIDv7()
        self.name      = name
        self.color     = color
        self.image     = image
        self.store     = store
        self.createdAt = Date()
        self.updatedAt = Date()
        self.deletedAt = nil
    }

    /// Indica si la categoría está activa (no eliminada).
    var isActive: Bool { deletedAt == nil }
}
