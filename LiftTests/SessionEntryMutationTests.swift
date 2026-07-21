import XCTest
@testable import Lift

final class SessionEntryMutationTests: XCTestCase {
    private let start = Date(timeIntervalSinceReferenceDate: 2_000_000)

    func testReplacingExercisePreservesItsSetData() {
        let store = LiftStore()
        defer { clearActiveSession(in: store) }
        let original = ActiveSession.Entry(
            exId: "wrong", sets: [WorkoutSet(kg: 82.5, reps: 6)],
            pKg: 85, pReps: 5, isDone: true
        )
        store.active = ActiveSession(
            startedAt: start, entries: [original], restStart: nil,
            lastActivityAt: start
        )

        store.replaceEntry(0, with: "correct", at: minutes(1))

        let replaced = store.active?.entries.first
        XCTAssertEqual(replaced?.exId, "correct")
        XCTAssertEqual(replaced?.sets, original.sets)
        XCTAssertEqual(replaced?.pKg, original.pKg)
        XCTAssertEqual(replaced?.pReps, original.pReps)
        XCTAssertEqual(replaced?.done, true)
        XCTAssertEqual(store.active?.lastActivityAt, minutes(1))
    }

    func testRemovingExerciseOnlyRemovesSelectedEntry() {
        let store = LiftStore()
        defer { clearActiveSession(in: store) }
        store.active = ActiveSession(
            startedAt: start,
            entries: [
                ActiveSession.Entry(exId: "keep", sets: [], pKg: 20, pReps: 8),
                ActiveSession.Entry(exId: "remove", sets: [], pKg: 40, pReps: 6)
            ],
            restStart: nil,
            lastActivityAt: start
        )

        store.removeEntry(1, at: minutes(2))

        XCTAssertEqual(store.active?.entries.map(\.exId), ["keep"])
        XCTAssertEqual(store.active?.lastActivityAt, minutes(2))
    }

    private func clearActiveSession(in store: LiftStore) {
        store.active = nil
        store.saveActive()
    }

    private func minutes(_ value: Int) -> Date {
        start.addingTimeInterval(TimeInterval(value * 60))
    }
}
