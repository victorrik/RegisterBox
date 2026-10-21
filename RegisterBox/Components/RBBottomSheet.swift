import SwiftUI

// MARK: - RBBottomSheet
/// Sheet presentable desde cualquier vista con altura configurable.
/// Uso:
/// ```swift
/// .rbBottomSheet(isPresented: $showSheet) {
///     MiContenido()
/// }
/// ```

struct RBBottomSheet<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var detents: Set<PresentationDetent> = [.medium, .large]
    var showDragIndicator: Bool = true
    var backgroundColor: Color = .rbWhite
    @ViewBuilder let sheetContent: () -> SheetContent

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                sheetContent()
                    .presentationDetents(detents)
                    .presentationDragIndicator(showDragIndicator ? .visible : .hidden)
                    .presentationBackground(backgroundColor)
                    .presentationCornerRadius(Radius.xl)
            }
    }
}

// MARK: - View Extension
extension View {
    func rbBottomSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        detents: Set<PresentationDetent> = [.medium, .large],
        showDragIndicator: Bool = true,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        modifier(RBBottomSheet(
            isPresented: isPresented,
            detents: detents,
            showDragIndicator: showDragIndicator,
            sheetContent: content
        ))
    }
}

// MARK: - RBSheetHeader
/// Header estándar para bottom sheets con título y botón de cierre.
struct RBSheetHeader: View {
    let title: String
    var subtitle: String? = nil
    var onClose: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(title)
                    .font(.rbTitle2)
                    .foregroundStyle(Color.rbPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.rbCaption)
                        .foregroundStyle(Color.rbGray)
                }
            }
            Spacer()
            if let onClose {
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
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.sm)
        .padding(.bottom, Spacing.xs)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var show = true

    Color.rbBackground
        .ignoresSafeArea()
        .rbBottomSheet(isPresented: $show, detents: [.medium]) {
            VStack(spacing: 0) {
                RBSheetHeader(title: "Detalle del producto", subtitle: "SKU: PRD-001") {
                    show = false
                }
                Divider()
                ScrollView {
                    VStack(spacing: Spacing.md) {
                        Text("Contenido del sheet")
                            .font(.rbBody)
                            .foregroundStyle(Color.rbGray)
                    }
                    .padding(Spacing.md)
                }
            }
        }
}
