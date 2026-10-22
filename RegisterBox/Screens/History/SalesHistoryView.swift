import SwiftUI

// MARK: - SalesHistoryView
/// Lista de ventas con filtros (status, cliente) y acceso al detalle.
struct SalesHistoryView: View {
    @Environment(\.saleService) private var saleService
    @Environment(\.paymentService) private var paymentService
    @Environment(AppState.self) private var appState

    @State private var viewModel: HistoryViewModel?
    @State private var selectedSale: Sale?
    @State private var showDateSheet = false

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
                  let ss = saleService,
                  let pay = paymentService else { return }
            let vm = HistoryViewModel(
                saleService: ss,
                paymentService: pay,
                storeId: store.id
            )
            viewModel = vm
            await vm.load()
        }
        .onAppear {
            // Recarga al volver al tab para reflejar ventas recién creadas en POS.
            if let viewModel {
                Task { await viewModel.load() }
            }
        }
    }

    // MARK: - Content
    @ViewBuilder
    private func content(_ vm: HistoryViewModel) -> some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filtros en una sola línea
                filterBar(vm)

                // Lista
                if vm.filteredSales.isEmpty {
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: IconSize.xl))
                            .foregroundStyle(Color.rbGray)
                        Text("No hay ventas registradas")
                            .font(.rbBody)
                            .foregroundStyle(Color.rbGray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(vm.filteredSales, id: \.id) { sale in
                            Button {
                                selectedSale = sale
                            } label: {
                                HistorySaleRow(sale: sale)
                            }
                            .buttonStyle(.plain)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: Spacing.xxs, leading: Spacing.md, bottom: Spacing.xxs, trailing: Spacing.md))
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Historial")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.rbBackground.ignoresSafeArea())
            .sheet(item: $selectedSale) { sale in
                SaleDetailView(
                    sale: sale,
                    onRegisterPayment: { amount in
                        Task { try? await vm.registerPayment(sale: sale, amount: amount) }
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showDateSheet) {
                dateSheet(vm)
            }
        }
    }

    // MARK: - Filter Bar (una sola línea)
    @ViewBuilder
    private func filterBar(_ vm: HistoryViewModel) -> some View {
        HStack(spacing: Spacing.xs) {
            // Tipo
            Menu {
                Picker("Tipo", selection: Binding(
                    get: { vm.statusFilter },
                    set: { vm.statusFilter = $0 }
                )) {
                    Text("Todos").tag(SaleStatus?.none)
                    Text("Pagados").tag(SaleStatus?.some(.paid))
                    Text("Deudas").tag(SaleStatus?.some(.debt))
                }
            } label: {
                filterPill(
                    title: statusLabel(vm.statusFilter),
                    isActive: vm.statusFilter != nil,
                    systemImage: "line.3.horizontal.decrease"
                )
            }

            // Fecha
            Button {
                showDateSheet = true
            } label: {
                filterPill(
                    title: vm.dateFilter.map { $0.shortDate } ?? "Fecha",
                    isActive: vm.dateFilter != nil,
                    systemImage: "calendar"
                )
            }
            .buttonStyle(.plain)

            // Cliente
            Menu {
                Picker("Cliente", selection: Binding(
                    get: { vm.customerFilter?.id },
                    set: { id in vm.customerFilter = vm.customersInSales.first { $0.id == id } }
                )) {
                    Text("Todos").tag(UUID?.none)
                    ForEach(vm.customersInSales) { customer in
                        Text(customer.name).tag(UUID?.some(customer.id))
                    }
                }
            } label: {
                filterPill(
                    title: vm.customerFilter?.name ?? "Cliente",
                    isActive: vm.customerFilter != nil,
                    systemImage: "person"
                )
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }

    private func statusLabel(_ status: SaleStatus?) -> String {
        switch status {
        case .none:  return "Tipo"
        case .paid:  return "Pagados"
        case .debt:  return "Deudas"
        }
    }

    private func filterPill(title: String, isActive: Bool, systemImage: String) -> some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: systemImage)
                .font(.system(size: 11, weight: .semibold))
            Text(title)
                .font(.rbLabel)
                .lineLimit(1)
        }
        .foregroundStyle(isActive ? .white : Color.rbMedium)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(isActive ? Color.rbAccent : Color.rbSurface)
        .clipShape(Capsule())
        .overlay(
            Capsule().strokeBorder(isActive ? Color.clear : Color.rbLighterGray, lineWidth: 1)
        )
    }

    // MARK: - Date Sheet
    @ViewBuilder
    private func dateSheet(_ vm: HistoryViewModel) -> some View {
        NavigationStack {
            VStack(spacing: Spacing.lg) {
                DatePicker(
                    "Día",
                    selection: Binding(
                        get: { vm.dateFilter ?? Date() },
                        set: { vm.dateFilter = $0 }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)

                if vm.dateFilter != nil {
                    RBButton(title: "Quitar filtro de fecha", style: .secondary, icon: "xmark") {
                        vm.dateFilter = nil
                        showDateSheet = false
                    }
                }
            }
            .padding(Spacing.md)
            .navigationTitle("Filtrar por fecha")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { showDateSheet = false }
                        .foregroundStyle(Color.rbAccent)
                }
            }
            .background(Color.rbBackground.ignoresSafeArea())
        }
        .presentationDetents([.medium])
    }
}

// MARK: - HistorySaleRow
private struct HistorySaleRow: View {
    let sale: Sale

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Icon
            Circle()
                .fill(sale.status == .paid ? Color.rbAccent.opacity(0.12) : Color.rbDebt.opacity(0.12))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: sale.status == .paid ? "checkmark.circle.fill" : "clock.fill")
                        .font(.system(size: IconSize.md))
                        .foregroundStyle(sale.status == .paid ? Color.rbAccent : Color.rbDebt)
                }

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(sale.createdAt.shortDate)
                    .font(.rbBody2)
                    .foregroundStyle(Color.rbPrimary)
                if let customer = sale.customer {
                    Text(customer.name)
                        .font(.rbCaption)
                        .foregroundStyle(Color.rbGray)
                } else {
                    Text("\(sale.items.count) artículo(s)")
                        .font(.rbCaption)
                        .foregroundStyle(Color.rbGray)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(sale.total.currencyString)
                    .font(.rbPriceSmall)
                    .foregroundStyle(Color.rbAccent)

                if sale.status == .debt {
                    Text("Saldo: \(sale.remainingBalance.currencyString)")
                        .font(.rbMicro)
                        .foregroundStyle(Color.rbDebt)
                }
            }
        }
        .padding(Spacing.sm)
        .background(Color.rbSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .rbShadow()
    }
}
