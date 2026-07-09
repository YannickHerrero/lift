import Foundation

#if DEBUG
/// Debug-only launch arguments to drive the app into a given state for
/// screenshot verification, e.g.:
///   -seed-demo -screen stats -theme dark -sheet picker-kg
enum DebugLaunch {
    static func value(after flag: String) -> String? {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: flag), args.indices.contains(i + 1) else { return nil }
        return args[i + 1]
    }

    static func apply(store: LiftStore, ui: UIState) {
        if LiftStore.shouldSeedDemo { store.seedDemoData() }

        if let t = value(after: "-theme") {
            store.setTheme(t == "dark" ? .dark : .light)
        }

        if let s = value(after: "-screen") {
            switch s {
            case "session":
                // A mid-workout state like the design mock: two sets done,
                // a third pending.
                store.startSession()
                store.addEntry(exId: "e1")
                store.updateEntry(0, kg: 80, reps: 8)
                store.confirmSet(0)
                store.confirmSet(0)
                store.updateEntry(0, kg: 82.5, reps: 6)
                store.addEntry(exId: "e4")
                ui.screen = .session
            case "history": ui.screen = .history
            case "stats": ui.screen = .stats
            case "settings": ui.screen = .settings
            default: break
            }
        }

        if let s = value(after: "-sheet") {
            switch s {
            case "addex": ui.sheet = .addExercise
            case "picker-kg": ui.sheet = .picker(entryIndex: 0, field: .kg)
            case "picker-reps": ui.sheet = .picker(entryIndex: 0, field: .reps)
            case "last": ui.sheet = .lastTime(exId: "e1")
            case "day":
                if let d = store.sessions.last?.date { ui.sheet = .day(dateKey: d) }
            default: break
            }
        }
    }
}
#endif
