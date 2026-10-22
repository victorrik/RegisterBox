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

    init() {
        FontRegistration.registerRubikFonts()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light) // la paleta antd está diseñada para tema claro
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
    @Environment(\.storeService) private var storeService

    @State private var isRestoringStore = false

    var body: some View {
        Group {
            if appState.onboardingComplete {
                if appState.activeStore != nil {
                    MainNavigationView()
                } else {
                    // Onboarding completo pero la tienda aún no se recargó
                    // desde SwiftData (p. ej. tras reiniciar la app).
                    ProgressView("Cargando...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.rbBackground.ignoresSafeArea())
                }
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut(duration: 0.4), value: appState.onboardingComplete)
        .animation(.easeInOut(duration: 0.3), value: appState.activeStore?.id)
        .task { await restoreActiveStoreIfNeeded() }
    }

    /// Recarga la tienda activa desde el servicio si el onboarding ya terminó
    /// y no hay tienda en memoria (estado inicial tras reiniciar la app).
    private func restoreActiveStoreIfNeeded() async {
        guard appState.onboardingComplete,
              appState.activeStore == nil,
              !isRestoringStore,
              let storeService else { return }

        isRestoringStore = true
        defer { isRestoringStore = false }

        if let store = try? await storeService.fetch().first {
            appState.activeStore = store
        } else {
            // No hay tienda persistida: el onboarding quedó marcado como
            // completo sin tienda válida. Reiniciar el onboarding.
            appState.resetOnboarding()
        }
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
