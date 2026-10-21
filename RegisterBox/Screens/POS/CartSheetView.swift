import SwiftUI

// MARK: - CartContent
/// Contenido compartido del carrito: items, nota, total, botón cobrar.
/// Usado por CartSheetView (iPhone) y CartSidePanelView (iPad).
struct CartContent: View {
    let cartStore: CartStore
    let onCheckout: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if cartStore.isEmpty {
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "cart")
                        .font(.system(size: IconSize.xl))
                        .foregroundStyle(Color.rbGray)
                    Text("El carrito está vacío")
                        .font(.rbBody)
                        .foregroundStyle(Color.rbGray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Lista de items
                ScrollView {
                    VStack(spacing: Spacing.xs) {
                        ForEach(cartStore.items) { item in
                            CartItemRow(item: item, cartStore: cartStore)
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.sm)
                }

                // Nota
                RBTextField(
                    label: "Nota",
                    placeholder: "Nota de la venta (opcional)",
                    text: Binding(
                        get: { cartStore.note },
                        set: { cartStore.note = $0 }
                    )
                )
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.sm)

                Divider()
                    .padding(.vertical, Spacing.sm)

                // Total y cobrar
                VStack(spacing: Spacing.sm) {
                    HStack {
                        Text("Total")
                            .font(.rbTitle2)
                            .foregroundStyle(Color.rbPrimary)
                        Spacer()
                        Text(cartStore.total.currencyString)
                            .font(.rbPriceLarge)
                            .foregroundStyle(Color.rbAccent)
                    }
                    .padding(.horizontal, Spacing.md)

                    RBButton(title: "Cobrar", style: .accent, icon: "creditcard") {
                        onCheckout()
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, Spacing.md)
                }
            }
        }
    }
}

// MARK: - CartItemRow
private struct CartItemRow: View {
    let item: CartItem
    let cartStore: CartStore

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(item.productName)
                    .font(.rbProductCard)
                    .foregroundStyle(Color.rbPrimary)
                Text(item.priceAtAdd.currencyString)
                    .font(.rbCaption)
                    .foregroundStyle(Color.rbGray)
            }

            Spacer()

            // Controles de cantidad
            HStack(spacing: Spacing.xs) {
                Button {
                    cartStore.decrement(item)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.rbMedium)
                }
                .buttonStyle(.plain)

                Text("\(item.quantity)")
                    .font(.rbButton)
                    .foregroundStyle(Color.rbPrimary)
                    .frame(minWidth: 28)

                Button {
                    cartStore.increment(item)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(item.canIncrement ? Color.rbAccent : Color.rbLightGray)
                }
                .disabled(!item.canIncrement)
                .buttonStyle(.plain)
            }

            // Subtotal
            Text(item.subtotal.currencyString)
                .font(.rbPriceSmall)
                .foregroundStyle(Color.rbPrimary)
                .frame(minWidth: 60, alignment: .trailing)
        }
        .padding(Spacing.sm)
        .background(Color.rbSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
    }
}

// MARK: - CartSheetView
/// Carrito en bottom sheet para iPhone.
struct CartSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CartStore.self) private var cartStore
    let onCheckout: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            RBSheetHeader(
                title: "Carrito",
                subtitle: "\(cartStore.itemCount) artículo(s)"
            ) {
                dismiss()
            }
            Divider()
            CartContent(cartStore: cartStore, onCheckout: {
                dismiss()
                onCheckout()
            })
        }
    }
}

// MARK: - CartSidePanelView
/// Carrito en panel lateral derecho para iPad.
struct CartSidePanelView: View {
    let cartStore: CartStore
    let onClose: () -> Void
    let onCheckout: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Carrito")
                    .font(.rbTitle2)
                    .foregroundStyle(Color.rbPrimary)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: IconSize.sm, weight: .semibold))
                        .foregroundStyle(Color.rbMedium)
                        .padding(Spacing.xs)
                        .background(Color.rbBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xs)

            Divider()

            CartContent(cartStore: cartStore, onCheckout: onCheckout)
        }
        .frame(maxWidth: 360)
        .background(Color.rbWhite)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .rbShadow(opacity: 0.15, radius: 16)
    }
}
