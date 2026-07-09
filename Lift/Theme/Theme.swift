import SwiftUI

/// Design palette, one-to-one with the mock's CSS variables.
struct Theme {
    var bg: Color
    var ink: Color
    var mut: Color
    var faint: Color
    var line: Color
    var line2: Color
    var fill: Color
    var scrim: Color

    static let light = Theme(
        bg: Color(hex: 0xFAFAF8),
        ink: Color(hex: 0x1A1A18),
        mut: Color(hex: 0x8F8D86),
        faint: Color(hex: 0xB0AEA8),
        line: Color(hex: 0xE4E2DC),
        line2: Color(hex: 0xD8D6CF),
        fill: Color(hex: 0xF1F0EC),
        scrim: Color(hex: 0x1A1A18).opacity(0.25)
    )

    static let dark = Theme(
        bg: Color(hex: 0x161614),
        ink: Color(hex: 0xF0EFE9),
        mut: Color(hex: 0x8B897F),
        faint: Color(hex: 0x6B695F),
        line: Color(hex: 0x2B2B27),
        line2: Color(hex: 0x3D3D37),
        fill: Color(hex: 0x232320),
        scrim: Color.black.opacity(0.55)
    )

    static func forAppTheme(_ t: AppTheme) -> Theme {
        t == .dark ? .dark : .light
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

private struct ThemeKey: EnvironmentKey {
    static let defaultValue = Theme.light
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

extension Font {
    /// The design is set in Helvetica throughout.
    static func lift(_ size: CGFloat) -> Font {
        .custom("Helvetica", size: size)
    }
}
