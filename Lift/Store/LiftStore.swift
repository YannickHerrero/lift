import Foundation
import Combine

/// Single source of truth. Everything is persisted as JSON in the app's
/// Documents directory — fully local, no sync.
final class LiftStore: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var sessions: [Session] = []
    @Published var theme: AppTheme = .light
    @Published var prefs = Prefs()
    @Published var active: ActiveSession?

    private struct DataFile: Codable {
        var theme: AppTheme
        var exercises: [Exercise]
        var sessions: [Session]
        var prefs: Prefs
    }

    private static var docs: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    private static var dataURL: URL { docs.appendingPathComponent("lift-data.json") }
    private static var activeURL: URL { docs.appendingPathComponent("lift-active.json") }

    init() {
        load()
    }

    // MARK: - Persistence

    private func load() {
        if let d = try? Data(contentsOf: Self.dataURL),
           let f = try? JSONDecoder().decode(DataFile.self, from: d) {
            theme = f.theme
            exercises = f.exercises
            sessions = f.sessions
            prefs = f.prefs
        } else {
            exercises = ["vertical row", "bench press", "dumbbell press", "deadlift", "squat"]
                .enumerated().map { Exercise(id: "e\($0.offset)", name: $0.element) }
        }
        if let d = try? Data(contentsOf: Self.activeURL),
           let a = try? JSONDecoder().decode(ActiveSession.self, from: d) {
            active = a
        }
    }

    func saveData() {
        let f = DataFile(theme: theme, exercises: exercises, sessions: sessions, prefs: prefs)
        if let d = try? JSONEncoder().encode(f) {
            try? d.write(to: Self.dataURL, options: .atomic)
        }
    }

    func saveActive() {
        if let a = active, let d = try? JSONEncoder().encode(a) {
            try? d.write(to: Self.activeURL, options: .atomic)
        } else {
            try? FileManager.default.removeItem(at: Self.activeURL)
        }
    }

    // MARK: - Lookups

    func exerciseName(_ id: String) -> String {
        exercises.first { $0.id == id }?.name ?? "?"
    }

    /// Most recent past entries for an exercise, newest first.
    func lastEntries(exId: String, limit: Int) -> [(date: String, sets: [WorkoutSet])] {
        var out: [(String, [WorkoutSet])] = []
        for s in sessions.reversed() {
            if let en = s.entries.first(where: { $0.exId == exId }) {
                out.append((s.date, en.sets))
                if out.count >= limit { break }
            }
        }
        return out
    }

    func tonnage(_ s: Session) -> Double {
        s.entries.reduce(0) { acc, e in
            acc + e.sets.reduce(0) { $0 + $1.kg * Double($1.reps) }
        }
    }

    var totalKg: Double { sessions.reduce(0) { $0 + tonnage($1) } }

    /// Times each exercise appears across sessions.
    var exerciseCounts: [String: Int] {
        var c: [String: Int] = [:]
        for s in sessions {
            for e in s.entries { c[e.exId, default: 0] += 1 }
        }
        return c
    }

    // MARK: - Mutations

    @discardableResult
    func createExercise(named name: String) -> Exercise {
        let ex = Exercise(id: "e\(Int(Date().timeIntervalSince1970 * 1000))",
                          name: name.trimmingCharacters(in: .whitespaces).lowercased())
        exercises.append(ex)
        saveData()
        return ex
    }

    func setTheme(_ t: AppTheme) {
        theme = t
        saveData()
    }

    func setPrefs(_ p: Prefs) {
        prefs = p
        saveData()
    }
}
