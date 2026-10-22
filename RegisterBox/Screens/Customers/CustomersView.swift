import SwiftUI

// MARK: - CustomersView
/// Lista de clientes con buscador. Tap → detalle con compras, deudas y abonos.
struct CustomersView: View {
    @Environment(\.customerService) private var customerService
    @Environment(\.paymentService) private var paymentService
    @Environment(AppState.self) private var appState

    @State private var viewModel: CustomersViewModel?
    @State private var showAddSheet = false
    @State private var selectedCustomer: Customer?

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
                  let cus = customerService,
                  let pay = paymentService else { return }
            let vm = CustomersViewModel(
                customerService: cus,
                paymentService: pay,
                storeId: store.id
            )
            viewModel = vm
            await vm.load()
        }
    }

    // MARK: - Content
    @ViewBuilder
    private func content(_ vm: CustomersViewModel) -> some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Buscador
                RBTextField(
                    label: "",
                    placeholder: "Buscar cliente...",
                    text: Binding(
                        get: { vm.searchText },
                        set: { vm.searchText = $0 }
                    ),
                    icon: "magnifyingglass"
                )
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.md)

                // Lista
                if vm.filteredCustomers.isEmpty {
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: IconSize.xl))
                            .foregroundStyle(Color.rbGray)
                        Text("No hay clientes")
                            .font(.rbBody)
                            .foregroundStyle(Color.rbGray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(vm.filteredCustomers) { customer in
                            Button {
                                selectedCustomer = customer
                            } label: {
                                CustomerRow(customer: customer)
                            }
                            .buttonStyle(.plain)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: Spacing.xxs, leading: Spacing.md, bottom: Spacing.xxs, trailing: Spacing.md))
                        }
                    }
                    .listStyle(.plain)
                    .scrollDismissesKeyboard(.immediately)
                }
            }
            .contentShape(Rectangle())
            .simultaneousGesture(TapGesture().onEnded { hideKeyboard() })
            .navigationTitle("Clientes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: IconSize.md, weight: .semibold))
                            .foregroundStyle(Color.rbAccent)
                    }
                }
            }
            .background(Color.rbBackground.ignoresSafeArea())
            .sheet(isPresented: $showAddSheet) {
                CustomerFormView(customer: nil) { name, phone in
                    let customer = Customer(
                        name: name,
                        phone: phone,
                        store: appState.activeStore
                    )
                    Task { try? await vm.createCustomer(customer) }
                }
            }
            .sheet(item: $selectedCustomer) { customer in
                CustomerDetailSheet(
                    customer: customer,
                    onEdit: { updated in
                        Task { try? await vm.updateCustomer(updated) }
                    },
                    onRegisterPayment: { sale, amount in
                        Task { try? await vm.registerPayment(sale: sale, amount: amount) }
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
}

// MARK: - CustomerRow
private struct CustomerRow: View {
    let customer: Customer

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: IconSize.xl))
                .foregroundStyle(Color.rbMedium)

            VStack(alignment: .leading, spacing: 2) {
                Text(customer.name)
                    .font(.rbProductCard)
                    .foregroundStyle(Color.rbPrimary)
                if let phone = customer.phone {
                    Text(phone)
                        .font(.rbCaption)
                        .foregroundStyle(Color.rbGray)
                }
            }

            Spacer()

            if customer.totalDebt > 0 {
                RBBadge(text: "Deuda: \(customer.totalDebt.currencyString)", style: .debt, icon: "clock")
            }
        }
        .padding(Spacing.sm)
        .background(Color.rbSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md)
                .strokeBorder(Color.rbLighterGray, lineWidth: 1)
        )
    }
}
