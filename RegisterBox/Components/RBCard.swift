import SwiftUI

// MARK: - RBCard
/// Contenedor con fondo rbSurface, esquinas redondeadas y sombra estándar.
struct RBCard<Content: View>: View {
    var padding: CGFloat = Spacing.md
    var cornerRadius: CGFloat = Radius.md
    var backgroundColor: Color = .rbSurface
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .rbShadow()
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: Spacing.md) {
        RBCard {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("Producto de ejemplo")
                        .font(.rbProductCard)
                        .foregroundStyle(Color.rbPrimary)
                    Text("$150.00")
                        .font(.rbPrice)
                        .foregroundStyle(Color.rbPrimary)
                }
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.rbAccent)
            }
        }
    }
    .padding(Spacing.md)
    .background(Color.rbBackground)
}
