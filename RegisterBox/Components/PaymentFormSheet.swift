import SwiftUI

// MARK: - PaymentFormSheet
/// Form de abono reutilizable. Usado en Clientes e Historial.
struct PaymentFormSheet: View {
    @Environment(\.dismiss) private var dismiss

    let sale: Sale
    var onConfirm: (Decimal) -> Void

    @State private var amount = ""
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {

                    // Saldo pendiente
                    VStack(spacing: Spacing.xs) {
                        Text("Saldo pendiente")
                            .font(.rbCaption)
                            .foregroundStyle(Color.rbGray)

                        Text(sale.remainingBalance.currencyString)
                            .font(.rbPriceLarge)
                            .foregroundStyle(Color.rbDebt)

                        Text("Total: \(sale.total.currencyString) · Abonado: \(sale.totalPaid.currencyString)")
                            .font(.rbMicro)
                            .foregroundStyle(Color.rbGray)
                    }
                    .padding(.top, Spacing.xl)

                    RBTextField(
                        label: "Monto del abono",
                        placeholder: "0.00",
                        text: $amount,
                        keyboardType: .decimalPad,
                        icon: "dollarsign.circle"
                    )

                    if let error {
                        Text(error)
                            .font(.rbCaption)
                            .foregroundStyle(Color.rbError)
                    }

                    RBButton(title: "Registrar abono", style: .accent, icon: "checkmark") {
                        confirm()
                    }
                    .padding(.bottom, Spacing.xxl)
                }
                .padding(.horizontal, Spacing.md)
            }
            .scrollDismissesKeyboard(.interactively)
            .simultaneousGesture(TapGesture().onEnded { hideKeyboard() })
            .navigationTitle("Registrar abono")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(Color.rbGray)
                }
            }
            .background(Color.rbBackground.ignoresSafeArea())
        }
    }

    private func confirm() {
        let value = Decimal(string: amount) ?? 0
        if value <= 0 {
            error = "Ingresa un monto válido"
            return
        }
        if value > sale.remainingBalance {
            error = "El monto no puede superar el saldo pendiente"
            return
        }
        onConfirm(value)
        dismiss()
    }
}
