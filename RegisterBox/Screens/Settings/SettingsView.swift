import SwiftUI

// MARK: - SettingsView
/// Pantalla de ajustes: editar tienda y gestionar categorías.
struct SettingsView: View {
    @Environment(\.storeService) private var storeService
    @Environment(\.categoryService) private var categoryService
    @Environment(AppState.self) private var appState

    @State private var viewModel: SettingsViewModel?
    @State private var showStoreForm = false
    @State private var showCategoryForm = false
    @State private var editingCategory: Category?

    var body: some View {
        Group {
            if let vm = viewModel {
                content(vm)
            } else {
                ProgressView("Cargando...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.rbBackground.ignoresSafeArea())
            }
        }
        .task {
            guard viewModel == nil,
                  let store = appState.activeStore,
                  let ss = storeService,
                  let cs = categoryService else { return }
            let vm = SettingsViewModel(
                storeService: ss,
                categoryService: cs,
                storeId: store.id
            )
            viewModel = vm
            await vm.load()
        }
    }

    // MARK: - Content
    @ViewBuilder
    private func content(_ vm: SettingsViewModel) -> some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {

                    // Sección tienda
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Tienda")
                            .font(.rbTitle2)
                            .foregroundStyle(Color.rbPrimary)

                        RBCard {
                            HStack(spacing: Spacing.sm) {
                                if let logoURL = appState.activeStore?.logo, let url = URL(string: logoURL) {
                                    AsyncImage(url: url) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        Circle().fill(Color.rbLighterGray)
                                    }
                                    .frame(width: 48, height: 48)
                                    .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color.rbLighterGray)
                                        .frame(width: 48, height: 48)
                                        .overlay {
                                            Image(systemName: "storefront")
                                                .foregroundStyle(Color.rbGray)
                                        }
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(appState.activeStore?.name ?? "Sin nombre")
                                        .font(.rbBody)
                                        .foregroundStyle(Color.rbPrimary)
                                    if let logo = appState.activeStore?.logo, !logo.isEmpty {
                                        Text("Logo configurado")
                                            .font(.rbCaption)
                                            .foregroundStyle(Color.rbGray)
                                    }
                                }

                                Spacer()

                                Button {
                                    showStoreForm = true
                                } label: {
                                    Image(systemName: "pencil")
                                        .font(.system(size: IconSize.sm))
                                        .foregroundStyle(Color.rbAccent)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Sección categorías
                    CategoriesView(
                        categories: vm.categories,
                        productCount: { cat in vm.productCount(for: cat) },
                        onCreate: { showCategoryForm = true },
                        onEdit: { cat in editingCategory = cat },
                        onDelete: { cat in
                            Task { try? await vm.deleteCategory(cat) }
                        }
                    )
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.xxl)
            }
            .navigationTitle("Ajustes")
            .background(Color.rbBackground.ignoresSafeArea())
            .sheet(isPresented: $showStoreForm) {
                if let store = appState.activeStore {
                    StoreFormView(store: store) { updated in
                        Task { try? await vm.updateStore(updated) }
                    }
                }
            }
            .sheet(isPresented: $showCategoryForm) {
                CategoryFormView(category: nil) { name, color, image in
                    let cat = Category(name: name, color: color, image: image, store: appState.activeStore)
                    Task { try? await vm.createCategory(cat) }
                }
            }
            .sheet(item: $editingCategory) { cat in
                CategoryFormView(category: cat) { name, color, image in
                    cat.name = name
                    cat.color = color
                    cat.image = image
                    Task { try? await vm.updateCategory(cat) }
                }
            }
        }
    }
}
