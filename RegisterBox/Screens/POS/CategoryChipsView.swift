import SwiftUI

// MARK: - CategoryChipsView
/// Chips horizontales de categoría con color. Incluye "Todos" como primera opción.
struct CategoryChipsView: View {
    let categories: [Category]
    @Binding var selectedCategory: Category?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                Chip(
                    title: "Todos",
                    color: Color.rbMedium,
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }

                ForEach(categories) { category in
                    Chip(
                        title: category.name,
                        color: Color(hex: category.color),
                        isSelected: selectedCategory?.id == category.id
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
        }
    }

    // MARK: - Chip
    private struct Chip: View {
        let title: String
        let color: Color
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.rbLabel)
                    .foregroundStyle(isSelected ? .white : color)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(isSelected ? color : color.opacity(0.12))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}
