import Foundation
import SwiftData

// MARK: - Event Type
enum ProductEventType: String, Codable {
    case stockUpdate    = "stock_update"    // ajuste manual
    case sale           = "sale"            // vendido
    case saleCancelled  = "sale_cancelled"  // venta cancelada, stock revertido
}

// MARK: - ProductHistory
@Model
final class ProductHistory {
    var id: UUID
    var eventType: ProductEventType
    var quantityChange: Int   // positivo = entrada, negativo = salida
    var stockBefore: Int
    var stockAfter: Int
    var note: String?
    var createdAt: Date

    var product: Product?
    var store: Store?

    /// ID de la venta asociada (nil si es ajuste manual).
    var saleId: UUID?

    init(
        product: Product,
        store: Store?,
        eventType: ProductEventType,
        quantityChange: Int,
        stockBefore: Int,
        stockAfter: Int,
        saleId: UUID? = nil,
        note: String? = nil
    ) {
        self.id             = makeUUIDv7()
        self.product        = product
        self.store          = store
        self.eventType      = eventType
        self.quantityChange = quantityChange
        self.stockBefore    = stockBefore
        self.stockAfter     = stockAfter
        self.saleId         = saleId
        self.note           = note
        self.createdAt      = Date()
    }

    /// Descripción legible del evento.
    var eventDescription: String {
        switch eventType {
        case .stockUpdate:
            let sign = quantityChange >= 0 ? "+" : ""
            return "Stock ajustado \(sign)\(quantityChange)"
        case .sale:
            return "Vendido \(abs(quantityChange)) unidad(es)"
        case .saleCancelled:
            return "Venta cancelada, +\(abs(quantityChange)) revertido"
        }
    }
}
