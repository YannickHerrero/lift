import Foundation

enum Format {
    static let months = ["jan", "feb", "mar", "apr", "may", "jun",
                         "jul", "aug", "sep", "oct", "nov", "dec"]
    static let monthsFull = ["january", "february", "march", "april", "may", "june",
                             "july", "august", "september", "october", "november", "december"]
    /// Indexed by Calendar weekday (1 = sunday).
    static let days = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]

    /// "82.5" / "80" — trims trailing zeros, max two decimals.
    static func kg(_ k: Double) -> String {
        let r = (k * 100).rounded() / 100
        if r == r.rounded() { return String(Int(r)) }
        let s = String(format: "%.2f", r)
        return s.hasSuffix("0") ? String(s.dropLast()) : s
    }

    /// "m:ss", rolling to "h:mm:ss" past an hour.
    static func clock(_ interval: TimeInterval) -> String {
        let s = max(0, Int(interval))
        let m = s / 60
        let ss = String(format: "%02d", s % 60)
        if m >= 60 {
            return "\(m / 60):" + String(format: "%02d", m % 60) + ":" + ss
        }
        return "\(m):\(ss)"
    }

    /// "jul 9" from a day key.
    static func shortDate(_ key: String) -> String {
        let c = DayKey.components(key)
        return "\(months[c.month - 1]) \(c.day)"
    }

    /// "today" / "yesterday" / "3 days ago" / "jun 24".
    static func relativeDate(_ key: String, today: Date = Date()) -> String {
        let cal = Calendar.current
        let start = cal.startOfDay(for: today)
        let day = DayKey.date(key, calendar: cal)
        let diff = cal.dateComponents([.day], from: day, to: start).day ?? 0
        if diff <= 0 { return "today" }
        if diff == 1 { return "yesterday" }
        if diff < 7 { return "\(diff) days ago" }
        return shortDate(key)
    }

    /// "80×8 · 80×8 · 82.5×6"
    static func setsLine(_ sets: [WorkoutSet]) -> String {
        sets.map { "\(kg($0.kg))×\($0.reps)" }.joined(separator: " · ")
    }

    /// "12,345" grouped integer.
    static func grouped(_ n: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        f.locale = Locale(identifier: "en_US")
        return f.string(from: NSNumber(value: n)) ?? String(n)
    }

    /// Tonnage in metric tons with one decimal, e.g. "4.3 t".
    static func tons(_ kg: Double) -> String {
        let t = (kg / 100).rounded() / 10
        if t == t.rounded() { return "\(Int(t)) t" }
        return "\(t) t"
    }
}
