import SwiftUI

/// The design's bottom sheet: dim scrim, card with rounded top corners
/// and a drag handle. Content decides its own height.
struct BottomSheet<Content: View>: View {
    @Environment(\.theme) private var theme
    let onClose: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        ZStack(alignment: .bottom) {
            theme.scrim
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)
                .transition(.opacity)

            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 100)
                    .fill(theme.line2)
                    .frame(width: 38, height: 4.5)
                content
            }
            .padding(EdgeInsets(top: 14, leading: 32, bottom: 44, trailing: 32))
            .frame(maxWidth: .infinity)
            .background(
                UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28)
                    .fill(theme.bg)
                    .shadow(color: .black.opacity(0.16), radius: 20, y: -12)
                    .ignoresSafeArea(edges: .bottom)
            )
            .transition(.move(edge: .bottom))
        }
    }
}

/// Chooses which sheet body to show for the current `ui.sheet`.
struct SheetHost: View {
    @EnvironmentObject private var ui: UIState

    var body: some View {
        ZStack(alignment: .bottom) {
            if let sheet = ui.sheet {
                BottomSheet(onClose: { ui.sheet = nil }) {
                    switch sheet {
                    case .addExercise:
                        AddExerciseSheet()
                    case .picker, .lastTime, .day:
                        EmptyView()
                    }
                }
            }
        }
        .animation(.easeOut(duration: 0.25), value: ui.sheet)
    }
}
