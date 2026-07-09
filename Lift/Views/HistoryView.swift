import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: LiftStore
    @EnvironmentObject private var ui: UIState
    @Environment(\.theme) private var theme

    @State private var year: Int
    @State private var month: Int

    init() {
        let now = Date()
        _year = State(initialValue: Calendar.current.component(.year, from: now))
        _month = State(initialValue: Calendar.current.component(.month, from: now))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("← home")
                .font(.lift(13))
                .foregroundStyle(theme.faint)
                .onTapGesture { ui.go(.home) }

            Text("history")
                .font(.lift(34))
                .tracking(-1.02)
                .padding(.top, 28)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(Format.monthsFull[month - 1]) \(String(year))")
                    .font(.lift(17))
                Spacer()
                Text("‹")
                    .font(.lift(18))
                    .foregroundStyle(theme.mut)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: prevMonth)
                Text("›")
                    .font(.lift(18))
                    .foregroundStyle(theme.mut)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: nextMonth)
            }
            .padding(.top, 34)

            calendarGrid
                .padding(.top, 18)

            Spacer()

            Text(summary)
                .font(.lift(13))
                .foregroundStyle(theme.faint)
        }
        .padding(EdgeInsets(top: 80, leading: 32, bottom: 48, trailing: 32))
        .ignoresSafeArea()
    }

    // MARK: - Calendar

    private var calendarGrid: some View {
        let cols = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
        return LazyVGrid(columns: cols, spacing: 2) {
            ForEach(Array("mtwtfss".enumerated()), id: \.offset) { _, c in
                Text(String(c))
                    .font(.lift(11))
                    .foregroundStyle(theme.faint)
                    .padding(.bottom, 8)
            }
            ForEach(0..<leadingBlanks, id: \.self) { _ in
                Color.clear.frame(height: 46)
            }
            ForEach(1...daysInMonth, id: \.self) { d in
                dayCell(d)
            }
        }
    }

    private func dayCell(_ d: Int) -> some View {
        let key = String(format: "%04d-%02d-%02d", year, month, d)
        let sessions = sessionsByDate[key] ?? []
        let isToday = key == DayKey.from(Date())
        return Text("\(d)")
            .font(.lift(15))
            .foregroundStyle(!sessions.isEmpty || isToday ? theme.ink : theme.mut)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .overlay {
                if isToday {
                    Circle().stroke(theme.line2, lineWidth: 1)
                }
            }
            .overlay(alignment: .bottom) {
                if !sessions.isEmpty {
                    Circle()
                        .fill(theme.ink)
                        .frame(width: 4, height: 4)
                        .padding(.bottom, 5)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if !sessions.isEmpty { ui.sheet = .day(dateKey: key) }
            }
    }

    // MARK: - Derived

    private var sessionsByDate: [String: [Session]] {
        Dictionary(grouping: store.sessions, by: \.date)
    }

    private var daysInMonth: Int {
        let cal = Calendar.current
        let first = cal.date(from: DateComponents(year: year, month: month, day: 1))!
        return cal.range(of: .day, in: .month, for: first)!.count
    }

    /// Blank cells before day 1 in a Monday-first week.
    private var leadingBlanks: Int {
        let cal = Calendar.current
        let first = cal.date(from: DateComponents(year: year, month: month, day: 1))!
        return (cal.component(.weekday, from: first) + 5) % 7
    }

    private var summary: String {
        let count = store.sessions.filter {
            let c = DayKey.components($0.date)
            return c.year == year && c.month == month
        }.count
        return "\(count) session\(count == 1 ? "" : "s") in \(Format.monthsFull[month - 1])"
    }

    private func prevMonth() {
        if month == 1 { month = 12; year -= 1 } else { month -= 1 }
    }

    private func nextMonth() {
        if month == 12 { month = 1; year += 1 } else { month += 1 }
    }
}
