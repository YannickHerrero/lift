import XCTest
@testable import Lift

final class ActiveSessionEntryTests: XCTestCase {
    func testNewEntryStartsOpenAndDoneStateRoundTrips() throws {
        var entry = ActiveSession.Entry(
            exId: "bench", sets: [], pKg: 80, pReps: 8
        )
        XCTAssertFalse(entry.done)

        entry.isDone = true
        let data = try JSONEncoder().encode(entry)
        let decoded = try JSONDecoder().decode(ActiveSession.Entry.self, from: data)

        XCTAssertTrue(decoded.done)
    }

    func testLegacyEntryDecodesAsOpen() throws {
        struct LegacyEntry: Codable {
            var exId: String
            var sets: [WorkoutSet]
            var pKg: Double
            var pReps: Int
        }

        let data = try JSONEncoder().encode(LegacyEntry(
            exId: "squat", sets: [], pKg: 100, pReps: 5
        ))
        let entry = try JSONDecoder().decode(ActiveSession.Entry.self, from: data)

        XCTAssertFalse(entry.done)
        XCTAssertNil(entry.isDone)
    }
}
