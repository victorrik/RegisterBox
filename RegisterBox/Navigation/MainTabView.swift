import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            Tab("POS", systemImage: "storefront", value: 0) {
                POSView()
            }

            Tab("Inventario", systemImage: "archivebox", value: 1) {
                InventoryView()
            }

            Tab("Clientes", systemImage: "person.2", value: 2) {
                CustomersView()
            }

            Tab("Historial", systemImage: "clock", value: 3) {
                SalesHistoryView()
            }

            Tab("Ajustes", systemImage: "gearshape", value: 4) {
                SettingsView()
            }
        }
        .tint(Color.rbAccent)
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
        .environment(CartStore())
}
