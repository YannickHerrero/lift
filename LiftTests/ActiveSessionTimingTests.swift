import XCTest
@testable import Lift

final class ActiveSessionTimingTests: XCTestCase {
    private let start = Date(timeIntervalSinceReferenceDate: 1_000_000)

    func testTimerPausesFifteenMinutesAfterLastActivity() {
        let session = ActiveSession(
            startedAt: start, entries: [], restStart: nil,
            lastActivityAt: start
        )

        XCTAssertEqual(session.elapsed(at: minutes(10)), 10 * 60, accuracy: 0.001)
        XCTAssertFalse(session.isPaused(at: minutes(10)))
        XCTAssertEqual(session.elapsed(at: minutes(20)), 15 * 60, accuracy: 0.001)
        XCTAssertTrue(session.isPaused(at: minutes(20)))
    }

    func testActivityExtendsTheInactivityDeadline() {
        var session = ActiveSession(
            startedAt: start, entries: [], restStart: nil,
            lastActivityAt: start
        )

        session.recordActivity(at: minutes(10))

        XCTAssertEqual(session.elapsed(at: minutes(20)), 20 * 60, accuracy: 0.001)
        XCTAssertFalse(session.isPaused(at: minutes(20)))
        XCTAssertEqual(session.elapsed(at: minutes(30)), 25 * 60, accuracy: 0.001)
        XCTAssertTrue(session.isPaused(at: minutes(30)))
    }

    func testActivityResumesTimerWithoutCountingExcessInactivity() {
        var session = ActiveSession(
            startedAt: start, entries: [], restStart: nil,
            lastActivityAt: start
        )

        session.recordActivity(at: minutes(20))
        XCTAssertEqual(session.elapsed(at: minutes(20)), 15 * 60, accuracy: 0.001)

        XCTAssertEqual(session.elapsed(at: minutes(25)), 20 * 60, accuracy: 0.001)
        XCTAssertEqual(session.elapsed(at: minutes(50)), 30 * 60, accuracy: 0.001)

        session.recordActivity(at: minutes(50))
        XCTAssertEqual(session.elapsed(at: minutes(50)), 30 * 60, accuracy: 0.001)
        XCTAssertEqual(session.elapsed(at: minutes(55)), 35 * 60, accuracy: 0.001)
    }

    func testLegacyActiveSessionDecodesWithTimingDefaults() throws {
        struct LegacyActiveSession: Codable {
            var startedAt: Date
            var entries: [ActiveSession.Entry]
            var restStart: Date?
        }

        let data = try JSONEncoder().encode(LegacyActiveSession(
            startedAt: start, entries: [], restStart: nil
        ))
        let session = try JSONDecoder().decode(ActiveSession.self, from: data)

        XCTAssertNil(session.lastActivityAt)
        XCTAssertNil(session.pausedDuration)
        XCTAssertEqual(session.elapsed(at: minutes(20)), 15 * 60, accuracy: 0.001)
    }

    private func minutes(_ value: Int) -> Date {
        start.addingTimeInterval(TimeInterval(value * 60))
    }
}
