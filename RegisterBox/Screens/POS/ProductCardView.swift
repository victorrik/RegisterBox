import SwiftUI

// MARK: - ProductCardView
/// Card horizontal de producto: imagen izquierda, info derecha.
/// Deshabilitada si stock == 0. Muestra badge de cantidad en carrito si aplica.
struct ProductCardView: View {
    let product: Product
    var cartQuantity: Int = 0
    var isAtStockLimit: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
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

                // Indicador carrito
                if cartQuantity > 0 {
                    VStack(spacing: 2) {
                        Text("\(cartQuantity)")
                            .font(.rbLabel)
                            .foregroundStyle(.white)
                            .frame(width: 24, height: 24)
                            .background(isAtStockLimit ? Color.rbError : Color.rbAccent)
                            .clipShape(Circle())

                        if isAtStockLimit {
                            Text("Máx")
                                .font(.rbMicro)
                                .foregroundStyle(Color.rbError)
                        }
                    }
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
            .rbShadow()
            .opacity(product.isOutOfStock ? 0.55 : 1)
        }
        .disabled(product.isOutOfStock)
        .buttonStyle(.plain)
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
