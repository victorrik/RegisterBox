import Foundation
import SwiftData

@Model
final class Store {
    var id: UUID
    var name: String
    var logo: String?
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \Category.store)
    var categories: [Category] = []

    @Relationship(deleteRule: .cascade, inverse: \Product.store)
    var products: [Product] = []

    @Relationship(deleteRule: .cascade, inverse: \Customer.store)
    var customers: [Customer] = []

    @Relationship(deleteRule: .cascade, inverse: \Sale.store)
    var sales: [Sale] = []

    init(name: String, logo: String? = nil) {
        self.id        = makeUUIDv7()
        self.name      = name
        self.logo      = logo
        self.createdAt = Date()
        self.updatedAt = Date()
        self.deletedAt = nil
    }
}
