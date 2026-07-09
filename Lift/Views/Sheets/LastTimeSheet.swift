import SwiftUI

/// Recent history for one exercise, shown from the session screen.
struct LastTimeSheet: View {
    @EnvironmentObject private var store: LiftStore
    @Environment(\.theme) private var theme

    let exId: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(store.exerciseName(exId))
                    .font(.lift(15))
                Spacer()
                Text("last sessions")
                    .font(.lift(12))
                    .foregroundStyle(theme.faint)
            }
            .padding(.top, 22)

            VStack(spacing: 0) {
                ForEach(Array(store.lastEntries(exId: exId, limit: 4).enumerated()),
                        id: \.offset) { _, row in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(Format.relativeDate(row.date))
                            .font(.lift(12))
                            .foregroundStyle(theme.faint)
                        Text(Format.setsLine(row.sets))
                            .font(.lift(18))
                            .monospacedDigit()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 16)
                    .overlay(alignment: .bottom) { theme.line.frame(height: 1) }
                }
            }
            .padding(.top, 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
