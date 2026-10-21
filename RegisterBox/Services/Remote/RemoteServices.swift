import Foundation

// MARK: - Remote stubs (sin implementar — para Supabase)

final class RemoteStoreService: StoreServiceProtocol {
    func fetch() async throws -> [Store] { [] }
    func create(_ store: Store) async throws {}
    func update(_ store: Store) async throws {}
    func delete(_ store: Store) async throws {}
}

final class RemoteCategoryService: CategoryServiceProtocol {
    func fetchAll(storeId: UUID) async throws -> [Category] { [] }
    func create(_ category: Category) async throws {}
    func update(_ category: Category) async throws {}
    func delete(_ category: Category) async throws {}
}

final class RemoteProductService: ProductServiceProtocol {
    func fetchAll(storeId: UUID) async throws -> [Product] { [] }
    func create(_ product: Product) async throws {}
    func update(_ product: Product) async throws {}
    func delete(_ product: Product) async throws {}
    func adjustStock(product: Product, change: Int, eventType: ProductEventType, saleId: UUID?, note: String?) async throws {}
}

final class RemoteCustomerService: CustomerServiceProtocol {
    func fetchAll(storeId: UUID) async throws -> [Customer] { [] }
    func create(_ customer: Customer) async throws {}
    func update(_ customer: Customer) async throws {}
    func delete(_ customer: Customer) async throws {}
}

final class RemoteSaleService: SaleServiceProtocol {
    func fetchAll(storeId: UUID) async throws -> [Sale] { [] }
    func create(from cart: CartStore, store: Store, status: SaleStatus, change: Decimal) async throws -> Sale {
        fatalError("RemoteSaleService no implementado")
    }
    func update(_ sale: Sale) async throws {}
    func delete(_ sale: Sale) async throws {}
}

final class RemotePaymentService: PaymentServiceProtocol {
    func fetchAll(saleId: UUID) async throws -> [Payment] { [] }
    func create(sale: Sale, amount: Decimal) async throws -> Payment {
        fatalError("RemotePaymentService no implementado")
    }
}
