import SwiftUI

/// Header reutilizable para los pasos del onboarding.
struct OnboardingProgressHeader: View {
    let step: Int
    let total: Int
    let title: String

    @Environment(AppState.self) private var appState

    private var progress: Double {
        Double(step) / Double(total)
    }

    var body: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                Button {
                    appState.onboardingStep = max(0, appState.onboardingStep - 1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: IconSize.md, weight: .semibold))
                        .foregroundStyle(Color.rbMedium)
                        .padding(Spacing.xs)
                        .background(Color.rbBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Spacer()

                Text("Paso \(step) de \(total)")
                    .font(.rbCaption)
                    .foregroundStyle(Color.rbGray)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.sm)

            // Barra de progreso
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: Radius.full)
                        .fill(Color.rbLighterGray)
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: Radius.full)
                        .fill(Color.rbAccent)
                        .frame(width: geo.size.width * progress, height: 4)
                        .animation(.easeInOut, value: progress)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, Spacing.md)

            Text(title)
                .font(.rbTitle)
                .foregroundStyle(Color.rbPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.xs)
        }
        .background(Color.rbBackground)
    }
}
