import Foundation

extension Date {

    /// Fecha y hora completa: "20 oct 2026, 10:45 PM"
    var fullDateTime: String {
        formatted(date: .abbreviated, time: .shortened)
    }

    /// Solo fecha: "20 oct 2026"
    var shortDate: String {
        formatted(date: .abbreviated, time: .omitted)
    }

    /// Solo hora: "10:45 PM"
    var shortTime: String {
        formatted(date: .omitted, time: .shortened)
    }

    /// Relativo: "hace 2 horas", "ayer", "hace 3 días"
    var relative: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Verifica si la fecha es hoy.
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Verifica si la fecha es ayer.
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    /// Inicio del día actual (para queries de historial).
    static var startOfToday: Date {
        Calendar.current.startOfDay(for: Date())
    }
}
