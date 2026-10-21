import Foundation
import Observation

@Observable
final class CustomersViewModel {

    // MARK: - State
    var customers: [Customer] = []
    var searchText = ""
    var isLoading = false
    var error: String?

    // MARK: - Dependencies
    private let customerService: CustomerServiceProtocol
    private let paymentService: PaymentServiceProtocol
    private let storeId: UUID

    init(
        customerService: CustomerServiceProtocol,
        paymentService: PaymentServiceProtocol,
        storeId: UUID
    ) {
        self.customerService = customerService
        self.paymentService   = paymentService
        self.storeId           = storeId
    }

    // MARK: - Load
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            customers = try await customerService.fetchAll(storeId: storeId)
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Filtering
    var filteredCustomers: [Customer] {
        if searchText.isEmpty { return customers }
        let query = searchText.lowercased()
        return customers.filter {
            $0.name.lowercased().contains(query) ||
            ($0.phone ?? "").lowercased().contains(query)
        }
    }

    // MARK: - CRUD
    func createCustomer(_ customer: Customer) async throws {
        try await customerService.create(customer)
        await load()
    }

    func updateCustomer(_ customer: Customer) async throws {
        try await customerService.update(customer)
        await load()
    }

    func deleteCustomer(_ customer: Customer) async throws {
        try await customerService.delete(customer)
        await load()
    }

    // MARK: - Payments
    func registerPayment(sale: Sale, amount: Decimal) async throws {
        try await paymentService.create(sale: sale, amount: amount)
    }
}
