import Foundation

// Active-session workflow: start, log sets, rest, finish.
extension LiftStore {
    func startSession() {
        guard active == nil else { return }
        active = ActiveSession(startedAt: Date(), entries: [], restStart: nil)
        saveActive()
    }

    /// Records the session if any set was confirmed, otherwise discards it.
    func finishSession() {
        guard let act = active else { return }
        let entries = act.entries
            .filter { !$0.sets.isEmpty }
            .map { SessionEntry(exId: $0.exId, sets: $0.sets) }
        if !entries.isEmpty {
            let cal = Calendar.current
            let h = cal.component(.hour, from: act.startedAt)
            let m = cal.component(.minute, from: act.startedAt)
            let ses = Session(
                id: "s\(Int(Date().timeIntervalSince1970 * 1000))",
                date: DayKey.from(act.startedAt),
                time: "\(h):" + String(format: "%02d", m),
                durationMin: max(1, Int((Date().timeIntervalSince(act.startedAt) / 60).rounded())),
                entries: entries
            )
            sessions.append(ses)
            sessions.sort { $0.date < $1.date }
            saveData()
        }
        active = nil
        saveActive()
    }

    /// Adds an exercise to the running session, pre-filling pending kg/reps
    /// from its most recent logged set.
    func addEntry(exId: String) {
        guard var act = active else { return }
        let last = lastEntries(exId: exId, limit: 1).first?.sets.last
        act.entries.append(ActiveSession.Entry(
            exId: exId, sets: [],
            pKg: last?.kg ?? 20, pReps: last?.reps ?? 8
        ))
        active = act
        saveActive()
    }

    func updateEntry(_ i: Int, kg: Double? = nil, reps: Int? = nil) {
        guard var act = active, act.entries.indices.contains(i) else { return }
        if let kg { act.entries[i].pKg = kg }
        if let reps { act.entries[i].pReps = reps }
        active = act
        saveActive()
    }

    func confirmSet(_ i: Int) {
        guard var act = active, act.entries.indices.contains(i) else { return }
        let e = act.entries[i]
        act.entries[i].sets.append(WorkoutSet(kg: e.pKg, reps: e.pReps))
        if prefs.autoRest { act.restStart = Date() }
        active = act
        saveActive()
    }

    func removeSet(_ i: Int, _ si: Int) {
        guard var act = active,
              act.entries.indices.contains(i),
              act.entries[i].sets.indices.contains(si) else { return }
        act.entries[i].sets.remove(at: si)
        active = act
        saveActive()
    }

    func toggleRest() {
        guard var act = active else { return }
        act.restStart = act.restStart == nil ? Date() : nil
        active = act
        saveActive()
    }
}
