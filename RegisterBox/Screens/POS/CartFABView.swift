import SwiftUI

// MARK: - CartFABView
/// Botón flotante con badge de cantidad de items en el carrito.
struct CartFABView: View {
    let itemCount: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(Color.rbAccent)
                    .frame(width: 56, height: 56)
                    .rbShadow(opacity: 0.25, radius: 12)
                    .overlay {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(.white)
                    }

                if itemCount > 0 {
                    Text("\(itemCount)")
                        .font(.rbLabel)
                        .foregroundStyle(.white)
                        .frame(minWidth: 20, minHeight: 20)
                        .padding(.horizontal, 4)
                        .background(Color.rbWarning)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.white, lineWidth: 2))
                        .offset(x: 6, y: -6)
                }
            }
            .frame(width: 56, height: 56)
        }
        .buttonStyle(.plain)
    }
}
