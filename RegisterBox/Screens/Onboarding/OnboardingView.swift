import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            Color.rbBackground.ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { hideKeyboard() }
            stepView
        }
        .animation(.easeInOut(duration: 0.3), value: appState.onboardingStep)
    }

    @ViewBuilder
    private var stepView: some View {
        switch appState.onboardingStep {
        case 0: Step1WelcomeView()
        case 1: Step2InfoView()
        case 2: Step3CategoriesView()
        case 3: Step4ProductsView()
        default: Step1WelcomeView()
        }
    }
}
