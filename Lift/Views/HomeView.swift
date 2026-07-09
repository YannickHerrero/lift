import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: LiftStore
    @EnvironmentObject private var ui: UIState
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("lift.")
                    .font(.lift(15))
                    .tracking(0.3)
                Spacer()
                Text("settings")
                    .font(.lift(13))
                    .foregroundStyle(theme.faint)
                    .onTapGesture { ui.go(.settings) }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(dateLine)
                Text(lastLine)
            }
            .font(.lift(13))
            .foregroundStyle(theme.faint)
            .padding(.top, 56)

            Spacer()

            menuRow(startLabel, arrow: "→", primary: true) {
                if store.active == nil {
                    store.startSession()
                    ui.screen = .session
                    ui.sheet = .addExercise
                } else {
                    ui.go(.session)
                }
            }
            menuRow("history", arrow: "→", primary: false) { ui.go(.history) }
            menuRow("stats", arrow: "→", primary: false) { ui.go(.stats) }
                .overlay(alignment: .bottom) { theme.line.frame(height: 1) }

            Spacer()

            Text(totalsLine)
                .font(.lift(13))
                .foregroundStyle(theme.faint)
        }
        .padding(EdgeInsets(top: 86, leading: 32, bottom: 48, trailing: 32))
        .ignoresSafeArea()
    }

    private func menuRow(_ label: String, arrow: String, primary: Bool,
                         action: @escaping () -> Void) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.lift(40))
                .tracking(-1.2)
                .foregroundStyle(primary ? theme.ink : theme.mut)
            Spacer()
            Text(arrow)
                .font(.lift(22))
                .foregroundStyle(primary ? theme.ink : theme.line2)
        }
        .padding(.vertical, 30)
        .contentShape(Rectangle())
        .overlay(alignment: .top) { theme.line.frame(height: 1) }
        .onTapGesture(perform: action)
    }

    private var startLabel: String {
        store.active == nil ? "start session" : "resume session"
    }

    private var dateLine: String {
        let now = Date()
        let cal = Calendar.current
        let day = Format.days[cal.component(.weekday, from: now) - 1]
        let month = Format.months[cal.component(.month, from: now) - 1]
        return "\(day), \(month) \(cal.component(.day, from: now))"
    }

    private var lastLine: String {
        guard let last = store.sessions.last else { return "no sessions yet" }
        return "last session \(Format.relativeDate(last.date)) · \(last.durationMin) min"
    }

    private var totalsLine: String {
        "\(store.sessions.count) sessions · \(Format.grouped(Int(store.totalKg.rounded()))) kg lifted"
    }
}
