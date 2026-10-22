import SwiftUI

// MARK: - CheckoutView
/// Flujo de cobro: Pagado (monto recibido → cambio) o En deuda (cliente → confirmar).
struct CheckoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: POSViewModel
    let cartStore: CartStore
    var onSuccess: () -> Void

    @State private var showCustomerPicker = false
    @State private var errorMessage: String?
    @State private var amountText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {

                    // Resumen
                    VStack(spacing: Spacing.xs) {
                        Text("Total a cobrar")
                            .font(.rbCaption)
                            .foregroundStyle(Color.rbGray)

                        Text(cartStore.total.currencyString)
                            .font(.rbDisplay)
                            .foregroundStyle(Color.rbAccent)

                        Text("\(cartStore.itemCount) artículo(s)")
                            .font(.rbCaption)
                            .foregroundStyle(Color.rbGray)
                    }
                    .padding(.top, Spacing.lg)

                    // Checkbox de deuda
                    debtCheckbox
                        .padding(.horizontal, Spacing.md)

                    // Contenido según modo
                    switch viewModel.checkoutMode {
                    case .paid:
                        paidSection
                    case .debt:
                        debtSection
                    }

                    // Error
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.rbCaption)
                            .foregroundStyle(Color.rbError)
                            .padding(.horizontal, Spacing.md)
                    }

                    // Confirmar
                    RBButton(
                        title: "Confirmar venta",
                        style: .accent,
                        icon: "checkmark",
                        isLoading: viewModel.isProcessing,
                        isDisabled: !viewModel.canCheckout
                    ) {
                        Task { await confirmSale() }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, Spacing.xxl)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .simultaneousGesture(TapGesture().onEnded { hideKeyboard() })
            .navigationTitle("Cobrar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(Color.rbGray)
                }
            }
            .background(Color.rbBackground.ignoresSafeArea())
            .sheet(isPresented: $showCustomerPicker) {
                CustomerPickerSheet(
                    customers: viewModel.customers,
                    onSelect: { customer in cartStore.selectedCustomer = customer },
                    onCreate: { name, phone in
                        try await viewModel.createCustomer(name: name, phone: phone)
                    }
                )
            }
        }
    }

    // MARK: - Debt Checkbox
    private var isDebt: Bool { viewModel.checkoutMode == .debt }

    private var debtCheckbox: some View {
        Button {
            viewModel.checkoutMode = isDebt ? .paid : .debt
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: isDebt ? "checkmark.square.fill" : "square")
                    .font(.system(size: IconSize.lg))
                    .foregroundStyle(isDebt ? Color.rbAccent : Color.rbGray)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Marcar como deuda")
                        .font(.rbButtonSm)
                        .foregroundStyle(Color.rbPrimary)
                    Text(isDebt ? "Se registrará como pendiente de pago" : "Se registrará como pagada")
                        .font(.rbCaption)
                        .foregroundStyle(Color.rbGray)
                }
                Spacer()
            }
            .padding(Spacing.md)
            .background(Color.rbSurface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .strokeBorder(isDebt ? Color.rbAccent : Color.rbLighterGray, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Paid Section
    private var paidSection: some View {
        VStack(spacing: Spacing.md) {
            RBTextField(
                label: "Monto recibido",
                placeholder: "0.00",
                text: $amountText,
                keyboardType: .decimalPad,
                icon: "dollarsign.circle"
            )
            .padding(.horizontal, Spacing.md)
            .onChange(of: amountText) { _, newValue in
                viewModel.amountReceived = Decimal(string: newValue.replacingOccurrences(of: ",", with: ".")) ?? 0
            }

            if viewModel.amountReceived > 0 {
                HStack {
                    Text("Cambio")
                        .font(.rbBody)
                        .foregroundStyle(Color.rbGray)
                    Spacer()
                    Text(viewModel.change.currencyString)
                        .font(.rbPriceLarge)
                        .foregroundStyle(viewModel.change >= 0 ? Color.rbPrimary : Color.rbError)
                }
                .padding(.horizontal, Spacing.md)
            }
        }
    }

    // MARK: - Debt Section
    private var debtSection: some View {
        VStack(spacing: Spacing.md) {
            if let customer = cartStore.selectedCustomer {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: IconSize.xl))
                        .foregroundStyle(Color.rbAccent)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(customer.name)
                            .font(.rbBody)
                            .foregroundStyle(Color.rbPrimary)
                        if let phone = customer.phone {
                            Text(phone)
                                .font(.rbCaption)
                                .foregroundStyle(Color.rbGray)
                        }
                    }

                    Spacer()

                    Button("Cambiar") { showCustomerPicker = true }
                        .font(.rbButtonSm)
                        .foregroundStyle(Color.rbAccent)
                }
                .padding(Spacing.md)
                .background(Color.rbSurface)
                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            } else {
                Button {
                    showCustomerPicker = true
                } label: {
                    VStack(spacing: Spacing.xs) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: IconSize.lg))
                        Text("Seleccionar cliente")
                            .font(.rbButtonSm)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.lg)
                    .background(Color.rbSurface)
                    .foregroundStyle(Color.rbAccent)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Confirm
    private func confirmSale() async {
        errorMessage = nil
        do {
            _ = try await viewModel.checkout()
            dismiss()
            onSuccess()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
