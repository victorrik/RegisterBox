import Foundation

protocol ProductServiceProtocol {
    func fetchAll(storeId: UUID) async throws -> [Product]
    func create(_ product: Product) async throws
    func update(_ product: Product) async throws
    func delete(_ product: Product) async throws
    func adjustStock(
        product: Product,
        change: Int,
        eventType: ProductEventType,
        saleId: UUID?,
        note: String?
    ) async throws
}
