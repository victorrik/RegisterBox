import Foundation

protocol CategoryServiceProtocol {
    func fetchAll(storeId: UUID) async throws -> [Category]
    func create(_ category: Category) async throws
    func update(_ category: Category) async throws
    func delete(_ category: Category) async throws
}
