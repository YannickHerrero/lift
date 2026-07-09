import Foundation

// Aggregations backing the stats screen.
extension LiftStore {
    struct WeekStat {
        var start: Date
        var count: Int
        var tonnage: Double
    }

    struct ExerciseProgress {
        var exercise: Exercise
        /// Best set weight per session, chronological.
        var history: [Double]
        var best: Double { history.max() ?? 0 }
        var delta: Double { (history.last ?? 0) - (history.first ?? 0) }
    }

    static func weekStart(of date: Date, calendar: Calendar = .current) -> Date {
        let day = calendar.startOfDay(for: date)
        let back = (calendar.component(.weekday, from: day) + 5) % 7
        return calendar.date(byAdding: .day, value: -back, to: day)!
    }

    /// The last `count` weeks (Monday-first), oldest first, ending with the
    /// current week.
    func weeklyStats(count: Int) -> [WeekStat] {
        let cal = Calendar.current
        let thisMonday = Self.weekStart(of: Date(), calendar: cal)
        return (0..<count).reversed().map { back in
            let ws = cal.date(byAdding: .day, value: -back * 7, to: thisMonday)!
            let we = cal.date(byAdding: .day, value: 7, to: ws)!
            let inWeek = sessions.filter {
                let d = DayKey.date($0.date, calendar: cal)
                return d >= ws && d < we
            }
            return WeekStat(start: ws,
                            count: inWeek.count,
                            tonnage: inWeek.reduce(0) { $0 + tonnage($1) })
        }
    }

    /// Exercises that have logged sets, sorted by name.
    func exerciseProgress() -> [ExerciseProgress] {
        exercises.compactMap { ex in
            var hist: [Double] = []
            for s in sessions {
                if let en = s.entries.first(where: { $0.exId == ex.id }),
                   let top = en.sets.map(\.kg).max() {
                    hist.append(top)
                }
            }
            return hist.isEmpty ? nil : ExerciseProgress(exercise: ex, history: hist)
        }
        .sorted { $0.exercise.name < $1.exercise.name }
    }

    /// Weeks with a session counting back from the current week; the current
    /// week doesn't break the streak if it's still empty.
    var weekStreak: Int {
        let weeks = weeklyStats(count: 8)
        var streak = 0
        for (i, w) in weeks.enumerated().reversed() {
            if w.count > 0 { streak += 1 }
            else if i == weeks.count - 1 { continue }
            else { break }
        }
        return streak
    }
}
