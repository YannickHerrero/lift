import Foundation

struct Exercise: Codable, Identifiable, Equatable {
    var id: String
    var name: String
}

struct WorkoutSet: Codable, Equatable {
    var kg: Double
    var reps: Int
}

struct SessionEntry: Codable, Equatable {
    var exId: String
    var sets: [WorkoutSet]
}

struct Session: Codable, Identifiable, Equatable {
    var id: String
    /// Day key in "yyyy-MM-dd" form, local calendar.
    var date: String
    /// Start time in "H:mm" form.
    var time: String
    var durationMin: Int
    var entries: [SessionEntry]
}

enum AppTheme: String, Codable {
    case light, dark
}

struct Prefs: Codable, Equatable {
    var kgStep: Double = 2.5
    var wheelMaxKg: Int = 250
    var autoRest: Bool = false
}

/// An in-progress session. Persisted separately so it survives relaunch.
struct ActiveSession: Codable, Equatable {
    struct Entry: Codable, Equatable {
        var exId: String
        var sets: [WorkoutSet]
        /// Pending values shown in the kg / reps input cells.
        var pKg: Double
        var pReps: Int
    }

    var startedAt: Date
    var entries: [Entry]
    var restStart: Date?
}

enum DayKey {
    static func from(_ date: Date, calendar: Calendar = .current) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year!, c.month!, c.day!)
    }

    static func components(_ key: String) -> (year: Int, month: Int, day: Int) {
        let p = key.split(separator: "-").compactMap { Int($0) }
        return (p[0], p[1], p[2])
    }

    static func date(_ key: String, calendar: Calendar = .current) -> Date {
        let c = components(key)
        return calendar.date(from: DateComponents(year: c.year, month: c.month, day: c.day))!
    }
}
