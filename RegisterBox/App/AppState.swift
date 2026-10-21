import Foundation
import Observation
import SwiftUI

@Observable
final class AppState {

    // MARK: - Active Store
    var activeStore: Store?

    // MARK: - Onboarding
    // Guardamos en UserDefaults manualmente para que @Observable
    // pueda trackear los cambios y notificar a SwiftUI.
    var onboardingStep: Int = UserDefaults.standard.integer(forKey: "onboardingStep") {
        didSet { UserDefaults.standard.set(onboardingStep, forKey: "onboardingStep") }
    }

    var onboardingComplete: Bool = UserDefaults.standard.bool(forKey: "onboardingComplete") {
        didSet { UserDefaults.standard.set(onboardingComplete, forKey: "onboardingComplete") }
    }

    // MARK: - Init
    init() {}

    // MARK: - Helpers

    /// Avanza al siguiente paso del onboarding.
    func nextOnboardingStep() {
        onboardingStep += 1
    }

    /// Marca el onboarding como completado.
    func completeOnboarding() {
        onboardingComplete = true
        onboardingStep = 4
    }

    /// Reinicia el onboarding (debug / cambio de tienda).
    func resetOnboarding() {
        onboardingComplete = false
        onboardingStep = 0
        activeStore = nil
    }
}
