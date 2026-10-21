import Foundation

protocol StoreServiceProtocol {
    func fetch() async throws -> [Store]
    func create(_ store: Store) async throws
    func update(_ store: Store) async throws
    func delete(_ store: Store) async throws
}
