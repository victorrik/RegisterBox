import SwiftUI

// MARK: - CustomerDetailSheet
/// Detalle de cliente con compras, deudas y registro de abonos.
struct CustomerDetailSheet: View {
    @Environment(\.dismiss) private var dismiss

    let customer: Customer
    var onEdit: (Customer) -> Void
    var onRegisterPayment: (Sale, Decimal) -> Void

    @State private var showEditSheet = false
    @State private var paymentSale: Sale?

    private var paidSales: [Sale] {
        customer.sales
            .filter { $0.status == .paid && $0.deletedAt == nil }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private var debtSales: [Sale] {
        customer.sales
            .filter { $0.status == .debt && $0.deletedAt == nil }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        VStack(spacing: 0) {
            RBSheetHeader(title: customer.name, subtitle: customer.phone ?? "Sin teléfono") {
                dismiss()
            }
            Divider()

            ScrollView {
                VStack(spacing: Spacing.lg) {

                    // Editar
                    RBButton(title: "Editar cliente", style: .secondary, icon: "pencil") {
                        showEditSheet = true
                    }
                    .padding(.top, Spacing.md)

                    // COMPRAS
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        HStack {
                            Text("Compras")
                                .font(.rbTitle2)
                                .foregroundStyle(Color.rbPrimary)
                            Spacer()
                            Text("Total: \(customer.totalSpent.currencyString)")
                                .font(.rbPriceSmall)
                                .foregroundStyle(Color.rbAccent)
                        }

                        if paidSales.isEmpty {
                            Text("Sin compras registradas")
                                .font(.rbCaption)
                                .foregroundStyle(Color.rbGray)
                        } else {
                            ForEach(paidSales, id: \.id) { sale in
                                SaleRow(sale: sale)
                            }
                        }
                    }

                    Divider()

                    // DEUDAS
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        HStack {
                            Text("Deudas")
                                .font(.rbTitle2)
                                .foregroundStyle(Color.rbPrimary)
                            Spacer()
                            if customer.totalDebt > 0 {
                                Text("Saldo: \(customer.totalDebt.currencyString)")
                                    .font(.rbPriceSmall)
                                    .foregroundStyle(Color.rbDebt)
                            }
                        }

                        if debtSales.isEmpty {
                            Text("Sin deudas pendientes")
                                .font(.rbCaption)
                                .foregroundStyle(Color.rbGray)
                        } else {
                            ForEach(debtSales, id: \.id) { sale in
                                DebtRow(sale: sale) {
                                    paymentSale = sale
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.xxl)
            }
        }
        .background(Color.rbBackground.ignoresSafeArea())
        .sheet(isPresented: $showEditSheet) {
            CustomerFormView(customer: customer) { name, phone in
                customer.name = name
                customer.phone = phone
                onEdit(customer)
            }
        }
        .sheet(item: $paymentSale) { sale in
            PaymentFormSheet(sale: sale) { amount in
                onRegisterPayment(sale, amount)
            }
        }
    }
}

// MARK: - SaleRow (paid)
private struct SaleRow: View {
    let sale: Sale

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(sale.createdAt.shortDate)
                    .font(.rbBody2)
                    .foregroundStyle(Color.rbPrimary)
                Text("\(sale.items.count) artículo(s)")
                    .font(.rbCaption)
                    .foregroundStyle(Color.rbGray)
            }
            Spacer()
            Text(sale.total.currencyString)
                .font(.rbPriceSmall)
                .foregroundStyle(Color.rbAccent)
        }
        .padding(Spacing.sm)
        .background(Color.rbSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
    }
}

// MARK: - DebtRow
private struct DebtRow: View {
    let sale: Sale
    let onRegisterPayment: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xs) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(sale.createdAt.shortDate)
                        .font(.rbBody2)
                        .foregroundStyle(Color.rbPrimary)
                    Text("Total: \(sale.total.currencyString)")
                        .font(.rbCaption)
                        .foregroundStyle(Color.rbGray)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Saldo")
                        .font(.rbMicro)
                        .foregroundStyle(Color.rbGray)
                    Text(sale.remainingBalance.currencyString)
                        .font(.rbPriceSmall)
                        .foregroundStyle(Color.rbDebt)
                }
            }

            HStack {
                Text("Abonado: \(sale.totalPaid.currencyString)")
                    .font(.rbMicro)
                    .foregroundStyle(Color.rbGray)
                Spacer()
                Button {
                    onRegisterPayment()
                } label: {
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: IconSize.sm))
                        Text("Registrar abono")
                            .font(.rbButtonSm)
                    }
                    .foregroundStyle(Color.rbAccent)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Spacing.sm)
        .background(Color.rbSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
    }
}
