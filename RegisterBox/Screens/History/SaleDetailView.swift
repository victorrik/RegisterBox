import SwiftUI

// MARK: - SaleDetailView
/// Detalle de una venta: items, pagos, cambio, saldo. Botón de abono si debt.
struct SaleDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let sale: Sale
    var onRegisterPayment: (Decimal) -> Void

    @State private var showPaymentSheet = false

    var body: some View {
        VStack(spacing: 0) {
            RBSheetHeader(
                title: sale.createdAt.fullDateTime,
                subtitle: sale.status == .paid ? "Pagada" : "En deuda"
            ) {
                dismiss()
            }
            Divider()

            ScrollView {
                VStack(spacing: Spacing.lg) {

                    // Resumen
                    VStack(spacing: Spacing.sm) {
                        HStack {
                            Text("Total")
                                .font(.rbBody)
                                .foregroundStyle(Color.rbGray)
                            Spacer()
                            Text(sale.total.currencyString)
                                .font(.rbPriceLarge)
                                .foregroundStyle(Color.rbAccent)
                        }

                        if sale.change > 0 {
                            HStack {
                                Text("Cambio")
                                    .font(.rbBody2)
                                    .foregroundStyle(Color.rbGray)
                                Spacer()
                                Text(sale.change.currencyString)
                                    .font(.rbPriceSmall)
                                    .foregroundStyle(Color.rbMedium)
                            }
                        }

                        if let customer = sale.customer {
                            HStack {
                                Image(systemName: "person.circle")
                                    .foregroundStyle(Color.rbMedium)
                                Text(customer.name)
                                    .font(.rbBody2)
                                    .foregroundStyle(Color.rbPrimary)
                                Spacer()
                            }
                        }

                        if let note = sale.note {
                            Text(note)
                                .font(.rbCaption)
                                .foregroundStyle(Color.rbGray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(Spacing.sm)
                                .background(Color.rbSurface)
                                .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
                        }
                    }
                    .padding(.top, Spacing.md)

                    // Items
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Artículos")
                            .font(.rbTitle2)
                            .foregroundStyle(Color.rbPrimary)

                        ForEach(sale.items, id: \.id) { item in
                            SaleItemRow(item: item)
                        }
                    }

                    // Pagos
                    if !sale.payments.isEmpty {
                        Divider()
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Abonos")
                                .font(.rbTitle2)
                                .foregroundStyle(Color.rbPrimary)

                            ForEach(sale.payments, id: \.id) { payment in
                                HStack {
                                    Text(payment.createdAt.fullDateTime)
                                        .font(.rbBody2)
                                        .foregroundStyle(Color.rbPrimary)
                                    Spacer()
                                    Text(payment.amount.currencyString)
                                        .font(.rbPriceSmall)
                                        .foregroundStyle(Color.rbAccent)
                                }
                                .padding(Spacing.sm)
                                .background(Color.rbSurface)
                                .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
                            }

                            // Saldo
                            if sale.status == .debt {
                                HStack {
                                    Text("Saldo pendiente")
                                        .font(.rbBody2)
                                        .foregroundStyle(Color.rbDebt)
                                    Spacer()
                                    Text(sale.remainingBalance.currencyString)
                                        .font(.rbPriceLarge)
                                        .foregroundStyle(Color.rbDebt)
                                }
                                .padding(.horizontal, Spacing.xxs)
                            }
                        }
                    }

                    // Registrar abono
                    if sale.status == .debt {
                        RBButton(title: "Registrar abono", style: .accent, icon: "dollarsign.circle") {
                            showPaymentSheet = true
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.xxl)
            }
        }
        .background(Color.rbBackground.ignoresSafeArea())
        .sheet(isPresented: $showPaymentSheet) {
            PaymentFormSheet(sale: sale) { amount in
                onRegisterPayment(amount)
            }
        }
    }
}

// MARK: - SaleItemRow
private struct SaleItemRow: View {
    let item: SaleItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.productName)
                    .font(.rbBody2)
                    .foregroundStyle(Color.rbPrimary)
                Text("\(item.priceAtSale.currencyString) × \(item.quantity)")
                    .font(.rbCaption)
                    .foregroundStyle(Color.rbGray)
            }
            Spacer()
            Text(item.subtotal.currencyString)
                .font(.rbPriceSmall)
                .foregroundStyle(Color.rbAccent)
        }
        .padding(Spacing.sm)
        .background(Color.rbSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
    }
}
