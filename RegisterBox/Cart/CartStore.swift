import Foundation
import Observation

// MARK: - CartItem
struct CartItem: Identifiable, Equatable {
    let id: UUID
    let productId: UUID
    let productName: String
    let priceAtAdd: Decimal
    var quantity: Int
    let maxStock: Int  // límite de stock disponible

    var subtotal: Decimal {
        (priceAtAdd * Decimal(quantity)).rounded2
    }

    init(product: Product, quantity: Int = 1) {
        self.id          = makeUUIDv7()
        self.productId   = product.id
        self.productName = product.name
        self.priceAtAdd  = product.price
        self.quantity    = quantity
        self.maxStock    = product.stock
    }

    /// Indica si se puede agregar más unidades.
    var canIncrement: Bool { quantity < maxStock }
}

// MARK: - CartStore
@Observable
final class CartStore {
    var items: [CartItem] = []
    var note: String = ""
    var selectedCustomer: Customer?

    // MARK: Computed
    var total: Decimal {
        items.reduce(Decimal(0)) { $0 + $1.subtotal }
    }

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var isEmpty: Bool { items.isEmpty }

    // MARK: Actions

    /// Agrega un producto al carrito. Si ya existe, incrementa la cantidad.
    func add(_ product: Product) {
        guard product.stock > 0 else { return }

        if let index = items.firstIndex(where: { $0.productId == product.id }) {
            guard items[index].canIncrement else { return }
            items[index].quantity += 1
        } else {
            items.append(CartItem(product: product))
        }
    }

    /// Incrementa la cantidad de un item.
    func increment(_ item: CartItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }),
              items[index].canIncrement else { return }
        items[index].quantity += 1
    }

    /// Decrementa la cantidad. Si llega a 0, elimina el item.
    func decrement(_ item: CartItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        if items[index].quantity > 1 {
            items[index].quantity -= 1
        } else {
            items.remove(at: index)
        }
    }

    /// Elimina un item del carrito.
    func remove(_ item: CartItem) {
        items.removeAll { $0.id == item.id }
    }

    /// Verifica si un producto ya está en el carrito.
    func quantity(for productId: UUID) -> Int {
        items.first(where: { $0.productId == productId })?.quantity ?? 0
    }

    /// Verifica si el stock de un producto está al límite en el carrito.
    func isAtStockLimit(for productId: UUID) -> Bool {
        guard let item = items.first(where: { $0.productId == productId }) else { return false }
        return !item.canIncrement
    }

    /// Limpia el carrito completamente.
    func clear() {
        items = []
        note = ""
        selectedCustomer = nil
    }
}
