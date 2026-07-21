import Foundation
import Combine

enum Screen {
    case home, session, history, stats, settings
}

enum PickerField {
    case kg, reps
}

enum ActiveSheet: Equatable {
    case picker(entryIndex: Int, field: PickerField)
    case addExercise
    case editExercise(entryIndex: Int)
    case lastTime(exId: String)
    case day(dateKey: String)
}

/// Which screen is showing and which bottom sheet (if any) is open.
final class UIState: ObservableObject {
    @Published var screen: Screen = .home
    @Published var sheet: ActiveSheet?

    func go(_ s: Screen) {
        screen = s
        sheet = nil
    }
}
