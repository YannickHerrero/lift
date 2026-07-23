import XCTest
@testable import Lift

final class WeightPickerValuesTests: XCTestCase {
    func testDefaultPreferenceUsesOneKilogramSteps() {
        var prefs = Prefs()
        prefs.wheelMaxKg = 3

        XCTAssertEqual(prefs.kgStep, 1)
        XCTAssertEqual(prefs.weightPickerValues, [0, 1, 2, 3])
    }

    func testFractionalStepOptionsRemainSupported() {
        var prefs = Prefs()
        prefs.kgStep = 1.25
        prefs.wheelMaxKg = 5

        XCTAssertEqual(prefs.weightPickerValues, [0, 1.25, 2.5, 3.75, 5])
    }
}
