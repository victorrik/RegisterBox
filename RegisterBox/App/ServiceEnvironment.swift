import SwiftUI

// MARK: - Service Environment Keys
// Permite inyectar los servicios vía .environment(\.xService, ...)
// y consumirlos en vistas/ViewModels con @Environment(\.xService).

// MARK: StoreService
private struct StoreServiceKey: EnvironmentKey {
    static let defaultValue: StoreServiceProtocol? = nil
}
extension EnvironmentValues {
    var storeService: StoreServiceProtocol? {
        get { self[StoreServiceKey.self] }
        set { self[StoreServiceKey.self] = newValue }
    }
}

// MARK: CategoryService
private struct CategoryServiceKey: EnvironmentKey {
    static let defaultValue: CategoryServiceProtocol? = nil
}
extension EnvironmentValues {
    var categoryService: CategoryServiceProtocol? {
        get { self[CategoryServiceKey.self] }
        set { self[CategoryServiceKey.self] = newValue }
    }
}

// MARK: ProductService
private struct ProductServiceKey: EnvironmentKey {
    static let defaultValue: ProductServiceProtocol? = nil
}
extension EnvironmentValues {
    var productService: ProductServiceProtocol? {
        get { self[ProductServiceKey.self] }
        set { self[ProductServiceKey.self] = newValue }
    }
}

// MARK: CustomerService
private struct CustomerServiceKey: EnvironmentKey {
    static let defaultValue: CustomerServiceProtocol? = nil
}
extension EnvironmentValues {
    var customerService: CustomerServiceProtocol? {
        get { self[CustomerServiceKey.self] }
        set { self[CustomerServiceKey.self] = newValue }
    }
}

// MARK: SaleService
private struct SaleServiceKey: EnvironmentKey {
    static let defaultValue: SaleServiceProtocol? = nil
}
extension EnvironmentValues {
    var saleService: SaleServiceProtocol? {
        get { self[SaleServiceKey.self] }
        set { self[SaleServiceKey.self] = newValue }
    }
}

// MARK: PaymentService
private struct PaymentServiceKey: EnvironmentKey {
    static let defaultValue: PaymentServiceProtocol? = nil
}
extension EnvironmentValues {
    var paymentService: PaymentServiceProtocol? {
        get { self[PaymentServiceKey.self] }
        set { self[PaymentServiceKey.self] = newValue }
    }
}
