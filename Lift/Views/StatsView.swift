import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var store: LiftStore
    @EnvironmentObject private var ui: UIState
    @Environment(\.theme) private var theme

    var body: some View {
        let weeks = store.weeklyStats(count: 8)
        VStack(alignment: .leading, spacing: 0) {
            Text("← home")
                .font(.lift(13))
                .foregroundStyle(theme.faint)
                .onTapGesture { ui.go(.home) }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("stats")
                        .font(.lift(34))
                        .tracking(-1.02)

                    thisWeekBlock(weeks)
                        .padding(.top, 30)
                    sessionsPerWeekBlock(weeks)
                    tonnageBlock(weeks)
                    progressBlock
                    totalsBlock
                }
            }
            .padding(.top, 28)
        }
        .padding(EdgeInsets(top: 80, leading: 32, bottom: 24, trailing: 32))
        .ignoresSafeArea()
    }

    // MARK: - Blocks

    private func thisWeekBlock(_ weeks: [LiftStore.WeekStat]) -> some View {
        let tw = weeks.last!
        return VStack(alignment: .leading, spacing: 8) {
            caption("this week")
            Text("\(tw.count) session\(tw.count == 1 ? "" : "s") · \(Format.tons(tw.tonnage))")
                .font(.lift(26))
                .tracking(-0.52)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 22)
        .overlay(alignment: .top) { theme.line.frame(height: 1) }
    }

    private func sessionsPerWeekBlock(_ weeks: [LiftStore.WeekStat]) -> some View {
        let maxCount = max(1, weeks.map(\.count).max() ?? 1)
        return VStack(alignment: .leading, spacing: 0) {
            caption("sessions / week")
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(Array(weeks.enumerated()), id: \.offset) { i, w in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(i == weeks.count - 1 ? theme.ink : theme.line2)
                        .frame(height: w.count > 0
                               ? CGFloat(w.count) / CGFloat(maxCount) * 56 + 6
                               : 2)
                        .frame(maxWidth: .infinity, alignment: .bottom)
                }
            }
            .frame(height: 64, alignment: .bottom)
            .padding(.top, 16)
            HStack(spacing: 10) {
                ForEach(Array(weeks.enumerated()), id: \.offset) { _, w in
                    Text("\(w.count)")
                        .font(.lift(11))
                        .foregroundStyle(theme.faint)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 8)
            HStack {
                Text(firstWeekLabel(weeks))
                Spacer()
                Text("this week")
            }
            .font(.lift(11))
            .foregroundStyle(theme.faint)
            .padding(.top, 6)
        }
        .padding(.vertical, 22)
        .overlay(alignment: .top) { theme.line.frame(height: 1) }
    }

    private func tonnageBlock(_ weeks: [LiftStore.WeekStat]) -> some View {
        let maxTon = max(1, weeks.map(\.tonnage).max() ?? 1)
        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                caption("tonnage / week")
                Spacer()
                Text("peak \(Format.tons(maxTon))")
                    .font(.lift(12))
                    .foregroundStyle(theme.mut)
            }
            Sparkline(values: weeks.map(\.tonnage), floor: 0)
                .stroke(theme.ink, lineWidth: 1.5)
                .frame(height: 70)
                .padding(.top, 16)
        }
        .padding(.vertical, 22)
        .overlay(alignment: .top) { theme.line.frame(height: 1) }
    }

    private var progressBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            caption("progress — best set")
            ForEach(store.exerciseProgress(), id: \.exercise.id) { p in
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(p.exercise.name)
                            .font(.lift(17))
                            .tracking(-0.17)
                        Text(progressMeta(p))
                            .font(.lift(12))
                            .foregroundStyle(theme.faint)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Sparkline(values: p.history)
                        .stroke(theme.line2, lineWidth: 1.5)
                        .frame(width: 96, height: 30)
                    Text("\(Format.kg(p.best)) kg")
                        .font(.lift(15))
                        .frame(width: 64, alignment: .trailing)
                }
                .padding(.vertical, 15)
                .overlay(alignment: .bottom) { theme.line.frame(height: 1) }
            }
        }
        .padding(.top, 22)
        .padding(.bottom, 8)
        .overlay(alignment: .top) { theme.line.frame(height: 1) }
    }

    private var totalsBlock: some View {
        let sessions = store.sessions
        let setCount = sessions.reduce(0) { $0 + $1.entries.reduce(0) { $0 + $1.sets.count } }
        let avgDur = sessions.isEmpty
            ? 0 : sessions.reduce(0) { $0 + $1.durationMin } / sessions.count
        let streak = store.weekStreak
        let counts = store.exerciseCounts
        let fav = counts.max { $0.value < $1.value }
        return VStack(alignment: .leading, spacing: 11) {
            Text("\(sessions.count) sessions · \(Format.grouped(Int(store.totalKg.rounded()))) kg lifted all-time")
            Text("\(setCount) sets logged · avg \(avgDur) min per session")
            Text("\(streak) week\(streak == 1 ? "" : "s") current streak")
            if let fav {
                Text("most trained: \(store.exerciseName(fav.key)) (\(fav.value)×)")
            }
        }
        .font(.lift(13))
        .foregroundStyle(theme.faint)
        .padding(.top, 22)
        .padding(.bottom, 30)
    }

    // MARK: - Helpers

    private func caption(_ s: String) -> some View {
        Text(s)
            .font(.lift(12))
            .foregroundStyle(theme.faint)
    }

    private func firstWeekLabel(_ weeks: [LiftStore.WeekStat]) -> String {
        guard let first = weeks.first else { return "" }
        let cal = Calendar.current
        let m = Format.months[cal.component(.month, from: first.start) - 1]
        return "\(m) \(cal.component(.day, from: first.start))"
    }

    private func progressMeta(_ p: LiftStore.ExerciseProgress) -> String {
        let sign = p.delta >= 0 ? "+" : ""
        return "\(p.history.count)× · \(sign)\(Format.kg(p.delta)) kg since start"
    }
}

/// Polyline over a value series, scaled to its own min/max like the
/// design's SVG charts.
struct Sparkline: Shape {
    var values: [Double]
    /// Fix the scale floor (e.g. 0 for tonnage); nil scales to the series min.
    var floor: Double?

    init(values: [Double], floor: Double? = nil) {
        self.values = values
        self.floor = floor
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        guard values.count > 1 else {
            if values.count == 1 {
                p.move(to: CGPoint(x: rect.midX - 2, y: rect.midY))
                p.addLine(to: CGPoint(x: rect.midX + 2, y: rect.midY))
            }
            return p
        }
        let lo = floor ?? values.min()!
        let hi = values.max()!
        let span = hi - lo == 0 ? 1 : hi - lo
        let pts = values.enumerated().map { i, v in
            CGPoint(
                x: rect.minX + CGFloat(i) / CGFloat(values.count - 1) * rect.width,
                y: rect.maxY - CGFloat((v - lo) / span) * rect.height
            )
        }
        p.move(to: pts[0])
        for pt in pts.dropFirst() { p.addLine(to: pt) }
        return p
    }
}
