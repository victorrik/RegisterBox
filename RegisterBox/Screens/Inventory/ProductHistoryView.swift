import SwiftUI

// MARK: - ProductHistoryView
/// Lista cronológica de eventos de stock de un producto.
struct ProductHistoryView: View {
    let history: [ProductHistory]

    var body: some View {
        if history.isEmpty {
            VStack(spacing: Spacing.sm) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: IconSize.xl))
                    .foregroundStyle(Color.rbGray)
                Text("Sin historial de movimientos")
                    .font(.rbBody)
                    .foregroundStyle(Color.rbGray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                VStack(spacing: Spacing.xs) {
                    ForEach(history, id: \.id) { entry in
                        HistoryRow(entry: entry)
                    }
                }
                .padding(Spacing.md)
            }
        }
    }
}

// MARK: - HistoryRow
private struct HistoryRow: View {
    let entry: ProductHistory

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Icono según tipo
            iconView

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.eventDescription)
                    .font(.rbBody2)
                    .foregroundStyle(Color.rbPrimary)

                Text(entry.createdAt.fullDateTime)
                    .font(.rbCaption)
                    .foregroundStyle(Color.rbGray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(entry.stockBefore) → \(entry.stockAfter)")
                    .font(.rbCaption)
                    .foregroundStyle(Color.rbMedium)

                if let note = entry.note {
                    Text(note)
                        .font(.rbMicro)
                        .foregroundStyle(Color.rbGray)
                }
            }
        }
        .padding(Spacing.sm)
        .background(Color.rbSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
    }

    @ViewBuilder
    private var iconView: some View {
        Circle()
            .fill(iconColor.opacity(0.12))
            .frame(width: 36, height: 36)
            .overlay {
                Image(systemName: iconSystemName)
                    .font(.system(size: IconSize.sm))
                    .foregroundStyle(iconColor)
            }
    }

    private var iconColor: Color {
        switch entry.eventType {
        case .stockUpdate:   return .rbAccent
        case .sale:          return .rbError
        case .saleCancelled: return .rbWarning
        }
    }

    private var iconSystemName: String {
        switch entry.eventType {
        case .stockUpdate:   return "arrow.up.arrow.down"
        case .sale:          return "cart.fill"
        case .saleCancelled: return "arrow.uturn.backward"
        }
    }
}
