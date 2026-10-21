import Foundation

protocol CustomerServiceProtocol {
    func fetchAll(storeId: UUID) async throws -> [Customer]
    func create(_ customer: Customer) async throws
    func update(_ customer: Customer) async throws
    func delete(_ customer: Customer) async throws
}
