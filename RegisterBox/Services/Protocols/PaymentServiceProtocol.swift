import Foundation

protocol PaymentServiceProtocol {
    func fetchAll(saleId: UUID) async throws -> [Payment]
    func create(sale: Sale, amount: Decimal) async throws -> Payment
}
