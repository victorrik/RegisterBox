import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            Tab("POS", systemImage: "storefront", value: 0) {
                Text("POS — próximamente")
                    .font(.rbTitle)
                    .foregroundStyle(Color.rbGray)
            }

            Tab("Inventario", systemImage: "archivebox", value: 1) {
                Text("Inventario — próximamente")
                    .font(.rbTitle)
                    .foregroundStyle(Color.rbGray)
            }

            Tab("Clientes", systemImage: "person.2", value: 2) {
                Text("Clientes — próximamente")
                    .font(.rbTitle)
                    .foregroundStyle(Color.rbGray)
            }

            Tab("Historial", systemImage: "clock", value: 3) {
                Text("Historial — próximamente")
                    .font(.rbTitle)
                    .foregroundStyle(Color.rbGray)
            }

            Tab("Ajustes", systemImage: "gearshape", value: 4) {
                Text("Ajustes — próximamente")
                    .font(.rbTitle)
                    .foregroundStyle(Color.rbGray)
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
