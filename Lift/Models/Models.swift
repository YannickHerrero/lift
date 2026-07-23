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
    var kgStep: Double = 1
    var wheelMaxKg: Int = 250
    var autoRest: Bool = false

    var weightPickerValues: [Double] {
        guard kgStep > 0, wheelMaxKg >= 0 else { return [] }
        return Array(stride(from: 0, through: Double(wheelMaxKg) + 0.001, by: kgStep))
            .map { ($0 * 100).rounded() / 100 }
    }
}

/// An in-progress session. Persisted separately so it survives relaunch.
struct ActiveSession: Codable, Equatable {
    static let inactivityLimit: TimeInterval = 15 * 60

    struct Entry: Codable, Equatable {
        var exId: String
        var sets: [WorkoutSet]
        /// Pending values shown in the kg / reps input cells.
        var pKg: Double
        var pReps: Int
        /// Optional so active sessions saved by older app versions still decode.
        var isDone: Bool?

        init(exId: String, sets: [WorkoutSet], pKg: Double, pReps: Int,
             isDone: Bool? = false) {
            self.exId = exId
            self.sets = sets
            self.pKg = pKg
            self.pReps = pReps
            self.isDone = isDone
        }

        var done: Bool { isDone == true }
    }

    var startedAt: Date
    var entries: [Entry]
    var restStart: Date?
    /// Optional so active sessions saved by older app versions still decode.
    var lastActivityAt: Date?
    /// Time beyond an inactivity deadline, excluded from the session duration.
    var pausedDuration: TimeInterval?

    init(startedAt: Date, entries: [Entry], restStart: Date?,
         lastActivityAt: Date? = nil, pausedDuration: TimeInterval? = 0) {
        self.startedAt = startedAt
        self.entries = entries
        self.restStart = restStart
        self.lastActivityAt = lastActivityAt
        self.pausedDuration = pausedDuration
    }

    func elapsed(at date: Date) -> TimeInterval {
        let activity = lastActivityAt ?? startedAt
        let deadline = activity.addingTimeInterval(Self.inactivityLimit)
        let end = min(date, deadline)
        return max(0, end.timeIntervalSince(startedAt) - (pausedDuration ?? 0))
    }

    func isPaused(at date: Date) -> Bool {
        date >= (lastActivityAt ?? startedAt).addingTimeInterval(Self.inactivityLimit)
    }

    mutating func recordActivity(at date: Date) {
        let previousActivity = lastActivityAt ?? startedAt
        let deadline = previousActivity.addingTimeInterval(Self.inactivityLimit)
        if date > deadline {
            pausedDuration = (pausedDuration ?? 0) + date.timeIntervalSince(deadline)
        }
        if date > previousActivity {
            lastActivityAt = date
        }
    }
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
