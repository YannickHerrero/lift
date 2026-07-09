import Foundation

#if DEBUG
// Demo seed used to eyeball the UI against the design mock. Activated by
// launching with "-seed-demo"; never runs in release builds.
extension LiftStore {
    static var shouldSeedDemo: Bool {
        ProcessInfo.processInfo.arguments.contains("-seed-demo")
    }

    /// Roughly two months of plausible training history, deterministic so
    /// screenshots are reproducible.
    func seedDemoData() {
        let base = ["e0": 42.5, "e1": 67.5, "e2": 22, "e3": 105, "e4": 85]
        let step = ["e0": 2.5, "e1": 2.5, "e2": 2, "e3": 5, "e4": 5]
        let reps0 = ["e0": 10, "e1": 8, "e2": 10, "e3": 5, "e4": 6]
        let plan: [(Int, [String])] = [(0, ["e1", "e2"]), (2, ["e0", "e3"]), (4, ["e4", "e0"])]
        func rnd(_ n: Double) -> Double {
            let x = sin(n * 127.1 + 13.7) * 43758.545
            return x - x.rounded(.down)
        }

        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let monday = Self.weekStart(of: today, calendar: cal)
        var out: [Session] = []
        var sid = 0
        for w in stride(from: 9, through: 0, by: -1) {
            for (pi, p) in plan.enumerated() {
                let d = cal.date(byAdding: .day, value: -w * 7 + p.0, to: monday)!
                if d >= today { continue }
                if rnd(Double(w * 10 + pi)) < 0.16 { continue }
                let prog = Double((9 - w) / 3)
                let entries = p.1.enumerated().map { ei, id -> SessionEntry in
                    let bump = rnd(Double(w * 7 + pi * 3 + ei)) < 0.3 ? step[id]! : 0
                    let kg = base[id]! + prog * step[id]! + bump
                    let rep = reps0[id]!
                    let sets = (0..<3).map { s in
                        WorkoutSet(kg: kg,
                                   reps: s == 2 && rnd(Double(w + pi + ei + s)) < 0.5
                                       ? max(1, rep - 2) : rep)
                    }
                    return SessionEntry(exId: id, sets: sets)
                }
                let hour = 17 + Int(rnd(Double(w + pi)) * 3)
                let minute = 10 + Int(rnd(Double(w * 2 + pi)) * 49)
                out.append(Session(
                    id: "s\(sid)", date: DayKey.from(d),
                    time: "\(hour):" + String(format: "%02d", minute),
                    durationMin: 36 + Int(rnd(Double(w * 3 + pi)) * 18),
                    entries: entries
                ))
                sid += 1
            }
        }
        sessions = out
        saveData()
    }
}
#endif
