import SwiftUI

/// All sessions of one calendar day, shown from the history screen.
struct DayRecapSheet: View {
    @EnvironmentObject private var store: LiftStore
    @Environment(\.theme) private var theme

    let dateKey: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.lift(15))
                Spacer()
                Text(daySessions.count == 1 ? "1 session" : "\(daySessions.count) sessions")
                    .font(.lift(12))
                    .foregroundStyle(theme.faint)
            }
            .padding(.top, 22)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(daySessions) { ses in
                        sessionGroup(ses)
                    }
                }
            }
            .frame(maxHeight: 420)
            .padding(.top, 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func sessionGroup(_ ses: Session) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(ses.time) · \(ses.durationMin) min · \(Format.tons(store.tonnage(ses)))")
                .font(.lift(12))
                .foregroundStyle(theme.faint)
                .padding(.top, 10)
                .padding(.bottom, 2)
            ForEach(Array(ses.entries.enumerated()), id: \.offset) { _, entry in
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.exerciseName(entry.exId))
                        .font(.lift(17))
                    Text(Format.setsLine(entry.sets))
                        .font(.lift(14))
                        .foregroundStyle(theme.mut)
                        .monospacedDigit()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 13)
                .overlay(alignment: .bottom) { theme.line.frame(height: 1) }
            }
        }
        .padding(.top, 6)
        .padding(.bottom, 4)
    }

    private var daySessions: [Session] {
        store.sessions.filter { $0.date == dateKey }
    }

    private var title: String {
        let cal = Calendar.current
        let day = Format.days[cal.component(.weekday, from: DayKey.date(dateKey)) - 1]
        return "\(day), \(Format.shortDate(dateKey))"
    }
}
