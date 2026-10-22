import Foundation
import Observation

@Observable
final class HistoryViewModel {

    // MARK: - State
    var sales: [Sale] = []
    var statusFilter: SaleStatus?
    var customerFilter: Customer?
    /// Si está presente, solo se muestran las ventas de ese día. Si es nil, todas.
    var dateFilter: Date?
    var isLoading = false
    var error: String?

    // MARK: - Dependencies
    private let saleService: SaleServiceProtocol
    private let paymentService: PaymentServiceProtocol
    private let storeId: UUID

    init(
        saleService: SaleServiceProtocol,
        paymentService: PaymentServiceProtocol,
        storeId: UUID
    ) {
        self.saleService    = saleService
        self.paymentService = paymentService
        self.storeId        = storeId
    }

    // MARK: - Load
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            sales = try await saleService.fetchAll(storeId: storeId)
        } catch {
            self.error = error.localizedDescription
        }
    }

    /// Clientes únicos presentes en las ventas, para el filtro por cliente.
    var customersInSales: [Customer] {
        var seen = Set<UUID>()
        return sales.compactMap(\.customer).filter { seen.insert($0.id).inserted }
    }

    // MARK: - Filtering
    var filteredSales: [Sale] {
        var result = sales
        if let statusFilter {
            result = result.filter { $0.status == statusFilter }
        }
        if let customerFilter {
            result = result.filter { $0.customer?.id == customerFilter.id }
        }
        if let dateFilter {
            result = result.filter { Calendar.current.isDate($0.createdAt, inSameDayAs: dateFilter) }
        }
        return result
    }

    // MARK: - Payments
    func registerPayment(sale: Sale, amount: Decimal) async throws {
        try await paymentService.create(sale: sale, amount: amount)
        await load()
    }
}
