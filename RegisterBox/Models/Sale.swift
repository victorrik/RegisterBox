import Foundation
import SwiftData

// MARK: - Sale Status
enum SaleStatus: String, Codable {
    case paid  = "paid"
    case debt  = "debt"
}

// MARK: - Sale
@Model
final class Sale {
    var id: UUID
    var total: Decimal
    var change: Decimal
    var status: SaleStatus
    var note: String?
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?

    var store: Store?
    var customer: Customer?

    @Relationship(deleteRule: .cascade, inverse: \SaleItem.sale)
    var items: [SaleItem] = []

    @Relationship(deleteRule: .cascade, inverse: \Payment.sale)
    var payments: [Payment] = []

    init(
        store: Store?,
        customer: Customer? = nil,
        total: Decimal,
        change: Decimal = 0,
        status: SaleStatus = .paid,
        note: String? = nil
    ) {
        self.id        = makeUUIDv7()
        self.store     = store
        self.customer  = customer
        self.total     = total
        self.change    = change
        self.status    = status
        self.note      = note
        self.createdAt = Date()
        self.updatedAt = Date()
        self.deletedAt = nil
    }

    /// Suma de todos los abonos registrados.
    var totalPaid: Decimal {
        payments.reduce(Decimal(0)) { $0 + $1.amount }
    }

    /// Saldo pendiente por pagar.
    var remainingBalance: Decimal {
        max(total - totalPaid, 0)
    }

    /// Indica si la deuda está completamente saldada.
    var isFullyPaid: Bool {
        totalPaid >= total
    }

    var isActive: Bool { deletedAt == nil }
}

// MARK: - SaleItem
@Model
final class SaleItem {
    var id: UUID
    var productName: String   // snapshot del nombre al momento de la venta
    var priceAtSale: Decimal  // snapshot del precio al momento de la venta
    var quantity: Int
    var subtotal: Decimal     // quantity × priceAtSale
    var createdAt: Date

    var sale: Sale?
    var product: Product?

    init(
        sale: Sale?,
        product: Product,
        quantity: Int
    ) {
        self.id          = makeUUIDv7()
        self.sale        = sale
        self.product     = product
        self.productName = product.name
        self.priceAtSale = product.price
        self.quantity    = quantity
        self.subtotal    = (product.price * Decimal(quantity)).rounded2
        self.createdAt   = Date()
    }
}

// MARK: - Payment
@Model
final class Payment {
    var id: UUID
    var amount: Decimal
    var createdAt: Date

    var sale: Sale?

    init(sale: Sale?, amount: Decimal) {
        self.id        = makeUUIDv7()
        self.sale      = sale
        self.amount    = amount
        self.createdAt = Date()
    }
}
