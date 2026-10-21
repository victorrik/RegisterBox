import SwiftUI

// MARK: - SalesHistoryView
/// Lista de ventas con filtros (status, cliente) y acceso al detalle.
struct SalesHistoryView: View {
    @Environment(\.saleService) private var saleService
    @Environment(\.paymentService) private var paymentService
    @Environment(AppState.self) private var appState

    @State private var viewModel: HistoryViewModel?
    @State private var selectedSale: Sale?

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
    }

    // MARK: - Content
    @ViewBuilder
    private func content(_ vm: HistoryViewModel) -> some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filtro de status
                statusFilter(vm)

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
            .background(Color.rbBackground.ignoresSafeArea())
            .sheet(item: $selectedSale) { sale in
                SaleDetailView(
                    sale: sale,
                    onRegisterPayment: { amount in
                        Task { try? await vm.registerPayment(sale: sale, amount: amount) }
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Status Filter
    @ViewBuilder
    private func statusFilter(_ vm: HistoryViewModel) -> some View {
        HStack(spacing: Spacing.xs) {
            filterChip("Todos", isSelected: vm.statusFilter == nil) {
                vm.statusFilter = nil
            }
            filterChip("Pagados", isSelected: vm.statusFilter == .paid) {
                vm.statusFilter = .paid
            }
            filterChip("Deudas", isSelected: vm.statusFilter == .debt) {
                vm.statusFilter = .debt
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.sm)
        .padding(.bottom, Spacing.xs)
    }

    private func filterChip(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.rbLabel)
                .foregroundStyle(isSelected ? .white : Color.rbMedium)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
                .background(isSelected ? Color.rbAccent : Color.rbSurface)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
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
