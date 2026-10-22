import Foundation
import SwiftData

// MARK: - LocalSaleService
final class LocalSaleService: SaleServiceProtocol {
    private let context: ModelContext
    private let productService: LocalProductService

    init(context: ModelContext) {
        self.context = context
        self.productService = LocalProductService(context: context)
    }

    func fetchAll(storeId: UUID) async throws -> [Sale] {
        // Filtro de store en memoria: SwiftData no traduce `store?.id` en #Predicate.
        let descriptor = FetchDescriptor<Sale>(
            predicate: #Predicate { $0.deletedAt == nil },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor).filter { $0.store?.id == storeId }
    }

    /// Crea una venta a partir del carrito, descuenta stock y registra historial.
    func create(
        from cart: CartStore,
        store: Store,
        status: SaleStatus,
        change: Decimal
    ) async throws -> Sale {
        let sale = Sale(
            store: store,
            customer: cart.selectedCustomer,
            total: cart.total,
            change: change,
            status: status,
            note: cart.note.isEmpty ? nil : cart.note
        )
        context.insert(sale)

        // Crear SaleItems y descontar stock
        for cartItem in cart.items {
            // Buscar el producto en SwiftData
            let productId = cartItem.productId
            let descriptor = FetchDescriptor<Product>(
                predicate: #Predicate { $0.id == productId }
            )
            guard let product = try context.fetch(descriptor).first else { continue }

            let item = SaleItem(sale: sale, product: product, quantity: cartItem.quantity)
            context.insert(item)

            // Descontar stock y registrar historial
            try await productService.adjustStock(
                product: product,
                change: -cartItem.quantity,
                eventType: .sale,
                saleId: sale.id,
                note: nil
            )
        }

        try context.save()
        return sale
    }

    func update(_ sale: Sale) async throws {
        sale.updatedAt = Date()
        // Si la deuda está saldada, marcar como pagada automáticamente
        if sale.status == .debt && sale.isFullyPaid {
            sale.status = .paid
        }
        try context.save()
    }

    func delete(_ sale: Sale) async throws {
        sale.deletedAt = Date()
        sale.updatedAt = Date()
        try context.save()
    }
}

// MARK: - LocalPaymentService
final class LocalPaymentService: PaymentServiceProtocol {
    private let context: ModelContext
    private let saleService: LocalSaleService

    init(context: ModelContext) {
        self.context = context
        self.saleService = LocalSaleService(context: context)
    }

    func fetchAll(saleId: UUID) async throws -> [Payment] {
        // Filtro de sale en memoria: SwiftData no traduce `sale?.id` en #Predicate.
        let descriptor = FetchDescriptor<Payment>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        return try context.fetch(descriptor).filter { $0.sale?.id == saleId }
    }

    func create(sale: Sale, amount: Decimal) async throws -> Payment {
        let payment = Payment(sale: sale, amount: amount)
        context.insert(payment)
        // Verificar si la deuda queda saldada
        try await saleService.update(sale)
        try context.save()
        return payment
    }
}
