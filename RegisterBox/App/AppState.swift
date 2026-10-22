import Foundation
import Observation
import SwiftUI

@Observable
final class AppState {

    // MARK: - Active Store
    var activeStore: Store? {
        didSet { UserDefaults.standard.set(activeStore?.id.uuidString, forKey: "activeStoreId") }
    }

    /// Id de la última tienda activa, para restaurarla al reabrir la app.
    var activeStoreId: UUID? {
        UserDefaults.standard.string(forKey: "activeStoreId").flatMap(UUID.init)
    }

    // MARK: - Onboarding
    // Guardamos en UserDefaults manualmente para que @Observable
    // pueda trackear los cambios y notificar a SwiftUI.
    /// Último paso válido del onboarding (0...3).
    static let maxOnboardingStep = 3

    var onboardingStep: Int = min(max(UserDefaults.standard.integer(forKey: "onboardingStep"), 0), AppState.maxOnboardingStep) {
        didSet {
            // Acotar siempre al rango válido para evitar estados corruptos.
            let clamped = min(max(onboardingStep, 0), AppState.maxOnboardingStep)
            if clamped != onboardingStep {
                onboardingStep = clamped
                return
            }
            UserDefaults.standard.set(onboardingStep, forKey: "onboardingStep")
        }
    }

    var onboardingComplete: Bool = UserDefaults.standard.bool(forKey: "onboardingComplete") {
        didSet { UserDefaults.standard.set(onboardingComplete, forKey: "onboardingComplete") }
    }

    // MARK: - Init
    init() {
        // Si el onboarding no terminó pero el step persistido estaba fuera de
        // rango (estado corrupto de una ejecución previa), reinicia a 0.
        let rawStep = UserDefaults.standard.integer(forKey: "onboardingStep")
        if !onboardingComplete && (rawStep < 0 || rawStep > AppState.maxOnboardingStep) {
            onboardingStep = 0
        }
    }

    // MARK: - Helpers

    /// Avanza al siguiente paso del onboarding (sin superar el máximo).
    func nextOnboardingStep() {
        guard onboardingStep < AppState.maxOnboardingStep else { return }
        onboardingStep += 1
    }

    /// Marca el onboarding como completado.
    func completeOnboarding() {
        onboardingComplete = true
        onboardingStep = AppState.maxOnboardingStep
    }

    /// Reinicia el onboarding (debug / cambio de tienda).
    func resetOnboarding() {
        onboardingComplete = false
        onboardingStep = 0
        activeStore = nil
    }
}
