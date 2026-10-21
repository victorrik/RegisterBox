import Foundation

protocol SaleServiceProtocol {
    func fetchAll(storeId: UUID) async throws -> [Sale]
    func create(from cart: CartStore, store: Store, status: SaleStatus, change: Decimal) async throws -> Sale
    func update(_ sale: Sale) async throws
    func delete(_ sale: Sale) async throws
}
