import Foundation
import CoreText
import UIKit

// MARK: - FontRegistration
/// Registra las fuentes Rubik bundleadas en runtime.
/// Evita modificar el Info.plist generado automáticamente por Xcode.
enum FontRegistration {

    static func registerRubikFonts() {
        let fontNames = [
            "Rubik-Light", "Rubik-Regular", "Rubik-Medium",
            "Rubik-SemiBold", "Rubik-Bold", "Rubik-ExtraBold", "Rubik-Black"
        ]

        for name in fontNames {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                print("⚠️ Font not found in bundle: \(name).ttf")
                continue
            }

            var error: Unmanaged<CFError>?
            let success = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)

            if !success {
                print("⚠️ Failed to register font \(name): \(error?.takeUnretainedValue().localizedDescription ?? "unknown error")")
            }
        }
    }
}
