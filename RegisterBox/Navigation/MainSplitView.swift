import SwiftUI

struct MainSplitView: View {
    @State private var selectedItem: SidebarItem? = .pos

    enum SidebarItem: String, CaseIterable, Identifiable {
        case pos        = "POS"
        case inventory  = "Inventario"
        case customers  = "Clientes"
        case history    = "Historial"
        case settings   = "Ajustes"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .pos:       return "storefront"
            case .inventory: return "archivebox"
            case .customers: return "person.2"
            case .history:   return "clock"
            case .settings:  return "gearshape"
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            List(SidebarItem.allCases, selection: $selectedItem) { item in
                Label(item.rawValue, systemImage: item.icon)
                    .font(.rbBody)
                    .foregroundStyle(Color.rbPrimary)
                    .tag(item)
            }
            .listStyle(.sidebar)
            .navigationTitle("RegisterBox")
            .tint(Color.rbAccent)
        } detail: {
            switch selectedItem {
            case .pos:
                Text("POS — próximamente")
                    .font(.rbTitle).foregroundStyle(Color.rbGray)
            case .inventory:
                Text("Inventario — próximamente")
                    .font(.rbTitle).foregroundStyle(Color.rbGray)
            case .customers:
                Text("Clientes — próximamente")
                    .font(.rbTitle).foregroundStyle(Color.rbGray)
            case .history:
                Text("Historial — próximamente")
                    .font(.rbTitle).foregroundStyle(Color.rbGray)
            case .settings:
                Text("Ajustes — próximamente")
                    .font(.rbTitle).foregroundStyle(Color.rbGray)
            case nil:
                Text("Selecciona una sección")
                    .font(.rbTitle).foregroundStyle(Color.rbGray)
            }
        }
        .tint(Color.rbAccent)
    }
}

#Preview {
    MainSplitView()
        .environment(AppState())
        .environment(CartStore())
}
