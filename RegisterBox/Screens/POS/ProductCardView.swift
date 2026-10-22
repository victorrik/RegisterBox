import SwiftUI

// MARK: - ProductCardView
/// Card horizontal de producto: imagen izquierda, info derecha.
/// Deshabilitada si stock == 0. Muestra badge de cantidad en carrito si aplica.
struct ProductCardView: View {
    let product: Product
    var cartQuantity: Int = 0
    var isAtStockLimit: Bool = false
    let onTap: () -> Void
    var onIncrement: () -> Void = {}
    var onDecrement: () -> Void = {}

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Imagen
            productImage
                .frame(width: 56, height: 56)

            // Info
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(product.name)
                    .font(.rbProductCard)
                    .foregroundStyle(product.isOutOfStock ? Color.rbGray : Color.rbPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(product.price.currencyString)
                    .font(.rbPrice)
                    .foregroundStyle(product.isOutOfStock ? Color.rbGray : Color.rbAccent)
            }

            Spacer(minLength: 0)

            // Controles carrito
            if cartQuantity > 0 {
                stepper
            } else if product.isOutOfStock {
                Text("Agotado")
                    .font(.rbMicro)
                    .foregroundStyle(Color.rbGray)
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, 2)
                    .background(Color.rbLighterGray)
                    .clipShape(Capsule())
            }
        }
        .padding(Spacing.sm)
        .background(Color.rbSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md)
                .strokeBorder(Color.rbLighterGray, lineWidth: 1)
        )
        .opacity(product.isOutOfStock ? 0.55 : 1)
        // La card completa agrega solo cuando aún no está en el carrito.
        .contentShape(Rectangle())
        .onTapGesture { if cartQuantity == 0 { onTap() } }
        .allowsHitTesting(!product.isOutOfStock)
    }

    // MARK: - Stepper (− / basura, cantidad, +)
    private var stepper: some View {
        HStack(spacing: Spacing.xs) {
            Button(action: onDecrement) {
                Image(systemName: cartQuantity == 1 ? "trash" : "minus")
                    .font(.system(size: IconSize.sm, weight: .semibold))
                    .foregroundStyle(cartQuantity == 1 ? Color.rbError : Color.rbAccent)
                    .frame(width: 32, height: 32)
                    .background(Color.rbBackground)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Text("\(cartQuantity)")
                .font(.rbLabel)
                .foregroundStyle(isAtStockLimit ? Color.rbError : Color.rbPrimary)
                .frame(minWidth: 20)

            Button(action: onIncrement) {
                Image(systemName: "plus")
                    .font(.system(size: IconSize.sm, weight: .semibold))
                    .foregroundStyle(isAtStockLimit ? Color.rbLightGray : Color.rbAccent)
                    .frame(width: 32, height: 32)
                    .background(Color.rbBackground)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(isAtStockLimit)
        }
    }

    // MARK: - Image
    @ViewBuilder
    private var productImage: some View {
        if let imageURL = product.image, let url = URL(string: imageURL) {
            AsyncImage(url: url) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                placeholderImage
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
        } else {
            placeholderImage
        }
    }

    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: Radius.sm)
            .fill(Color.rbLighterGray)
            .overlay {
                Image(systemName: "photo")
                    .font(.system(size: IconSize.md))
                    .foregroundStyle(Color.rbGray)
            }
    }
}
