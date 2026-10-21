import SwiftUI
import SwiftData

@main
struct MyApp: App {

    // MARK: - SwiftData Container
    let container: ModelContainer = {
        let schema = Schema([
            Store.self,
            Category.self,
            Product.self,
            ProductHistory.self,
            Customer.self,
            Sale.self,
            SaleItem.self,
            Payment.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("No se pudo crear el ModelContainer: \(error)")
        }
    }()

    // MARK: - Global State
    @State private var appState = AppState()
    @State private var cartStore = CartStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(container)
                .environment(appState)
                .environment(cartStore)
                .environment(\.storeService,    LocalStoreService(context: container.mainContext))
                .environment(\.categoryService, LocalCategoryService(context: container.mainContext))
                .environment(\.productService,  LocalProductService(context: container.mainContext))
                .environment(\.customerService, LocalCustomerService(context: container.mainContext))
                .environment(\.saleService,     LocalSaleService(context: container.mainContext))
                .environment(\.paymentService,  LocalPaymentService(context: container.mainContext))
        }
    }
}

// MARK: - RootView
/// Decide si mostrar Onboarding o la app principal.
struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if appState.onboardingComplete {
                MainNavigationView()
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut(duration: 0.4), value: appState.onboardingComplete)
    }
}

// MARK: - MainNavigationView
/// Selecciona entre TabView (iPhone) y SplitView (iPad).
struct MainNavigationView: View {
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            MainSplitView()
        } else {
            MainTabView()
        }
    }
}
