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

                    // Selector de modo
                    HStack(spacing: Spacing.xs) {
                        modeButton(.paid, title: "Pagado", icon: "checkmark.circle.fill")
                        modeButton(.debt, title: "En deuda", icon: "clock.fill")
                    }
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
                CustomerPickerSheet(customers: viewModel.customers) { customer in
                    cartStore.selectedCustomer = customer
                }
            }
        }
    }

    // MARK: - Mode Button
    @ViewBuilder
    private func modeButton(_ mode: POSViewModel.CheckoutMode, title: String, icon: String) -> some View {
        Button {
            viewModel.checkoutMode = mode
        } label: {
            VStack(spacing: Spacing.xxs) {
                Image(systemName: icon)
                    .font(.system(size: IconSize.lg))
                Text(title)
                    .font(.rbButtonSm)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
            .background(viewModel.checkoutMode == mode ? Color.rbAccent.opacity(0.1) : Color.rbSurface)
            .foregroundStyle(viewModel.checkoutMode == mode ? Color.rbAccent : Color.rbMedium)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .strokeBorder(viewModel.checkoutMode == mode ? Color.rbAccent : Color.clear, lineWidth: 2)
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
                text: Binding(
                    get: { String(format: "%.2f", NSDecimalNumber(decimal: viewModel.amountReceived).doubleValue) },
                    set: { viewModel.amountReceived = Decimal(string: $0) ?? 0 }
                ),
                keyboardType: .decimalPad,
                icon: "dollarsign.circle"
            )
            .padding(.horizontal, Spacing.md)

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
