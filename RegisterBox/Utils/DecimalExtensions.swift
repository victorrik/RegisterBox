import Foundation

extension Decimal {

    /// Formatea el valor como moneda usando el locale del dispositivo.
    var currencyString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: self as NSDecimalNumber) ?? "$0.00"
    }

    /// Redondea a 2 decimales (útil para precios y subtotales).
    var rounded2: Decimal {
        var result = Decimal()
        var value = self
        NSDecimalRound(&result, &value, 2, .plain)
        return result
    }

    /// Convierte a Double para uso en cálculos intermedios.
    var doubleValue: Double {
        (self as NSDecimalNumber).doubleValue
    }
}
