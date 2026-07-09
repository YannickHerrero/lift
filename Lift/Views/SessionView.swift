import SwiftUI

struct SessionView: View {
    @EnvironmentObject private var store: LiftStore
    @EnvironmentObject private var ui: UIState
    @Environment(\.theme) private var theme

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            content(now: context.date)
        }
    }

    private func content(now: Date) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("← session · \(elapsed(now))")
                    .font(.lift(13))
                    .foregroundStyle(theme.faint)
                    .onTapGesture { ui.go(.home) }
                Spacer()
                Text(finishLabel)
                    .font(.lift(13))
                    .underlined(theme.ink)
                    .onTapGesture {
                        store.finishSession()
                        ui.go(.home)
                    }
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    if let act = store.active {
                        ForEach(Array(act.entries.enumerated()), id: \.offset) { i, entry in
                            entryBlock(i, entry)
                                .padding(.bottom, 28)
                        }
                    }
                    Text("+ add exercise")
                        .font(.lift(15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 20)
                        .overlay(alignment: .top) { theme.line.frame(height: 1) }
                        .contentShape(Rectangle())
                        .onTapGesture { ui.sheet = .addExercise }
                }
            }
            .padding(.top, 30)

            restBar(now: now)
        }
        .padding(EdgeInsets(top: 80, leading: 32, bottom: 40, trailing: 32))
        .ignoresSafeArea()
    }

    // MARK: - Exercise entry

    private func entryBlock(_ i: Int, _ entry: ActiveSession.Entry) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(store.exerciseName(entry.exId))
                    .font(.lift(26))
                    .tracking(-0.52)
                Spacer()
                if !store.lastEntries(exId: entry.exId, limit: 1).isEmpty {
                    Text("last time →")
                        .font(.lift(12))
                        .foregroundStyle(theme.faint)
                        .padding(.vertical, 4)
                        .onTapGesture { ui.sheet = .lastTime(exId: entry.exId) }
                }
            }

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(entry.sets.enumerated()), id: \.offset) { si, set in
                    doneSetRow(i, si, set)
                }
                activeSetRow(i, entry)
            }
            .padding(.top, 12)
        }
    }

    private func doneSetRow(_ i: Int, _ si: Int, _ set: WorkoutSet) -> some View {
        HStack(spacing: 0) {
            Text("\(si + 1)")
                .font(.lift(13))
                .foregroundStyle(theme.faint)
                .frame(width: 26, alignment: .leading)
            Text("\(Format.kg(set.kg)) kg × \(set.reps)")
                .font(.lift(19))
                .foregroundStyle(theme.mut)
            Spacer()
            Text("×")
                .font(.lift(15))
                .foregroundStyle(theme.faint)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .contentShape(Rectangle())
                .onTapGesture { store.removeSet(i, si) }
        }
        .padding(.vertical, 13)
        .overlay(alignment: .top) { theme.line.frame(height: 1) }
    }

    private func activeSetRow(_ i: Int, _ entry: ActiveSession.Entry) -> some View {
        HStack(spacing: 12) {
            Text("\(entry.sets.count + 1)")
                .font(.lift(13))
                .frame(width: 26, alignment: .leading)

            valueCell(Format.kg(entry.pKg), unit: "kg") {
                ui.sheet = .picker(entryIndex: i, field: .kg)
            }
            valueCell("\(entry.pReps)", unit: "reps") {
                ui.sheet = .picker(entryIndex: i, field: .reps)
            }

            Checkmark()
                .stroke(theme.ink, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                .frame(width: 15, height: 12)
                .frame(width: 46, height: 46)
                .overlay(Circle().stroke(theme.ink, lineWidth: 1))
                .contentShape(Circle())
                .onTapGesture { store.confirmSet(i) }
        }
        .padding(.top, 14)
        .padding(.bottom, 2)
        .overlay(alignment: .top) { theme.line.frame(height: 1) }
    }

    private func valueCell(_ value: String, unit: String, tap: @escaping () -> Void) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.lift(25))
                .tracking(-0.5)
            Text(unit)
                .font(.lift(11))
                .foregroundStyle(theme.faint)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 13)
        .padding(.horizontal, 14)
        .background(theme.fill, in: RoundedRectangle(cornerRadius: 14))
        .onTapGesture(perform: tap)
    }

    // MARK: - Rest timer

    private func restBar(now: Date) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(store.active?.restStart == nil ? "rest — tap to start" : "resting — tap to stop")
                .font(.lift(13))
                .foregroundStyle(theme.faint)
            Spacer()
            Text(restLabel(now))
                .font(.lift(40))
                .tracking(-0.8)
                .monospacedDigit()
        }
        .padding(.top, 16)
        .overlay(alignment: .top) { theme.ink.frame(height: 1) }
        .contentShape(Rectangle())
        .onTapGesture { store.toggleRest() }
    }

    private func elapsed(_ now: Date) -> String {
        guard let act = store.active else { return "0:00" }
        return Format.clock(now.timeIntervalSince(act.startedAt))
    }

    private func restLabel(_ now: Date) -> String {
        guard let rest = store.active?.restStart else { return "0:00" }
        return Format.clock(now.timeIntervalSince(rest))
    }

    private var finishLabel: String {
        let any = store.active?.entries.contains { !$0.sets.isEmpty } ?? false
        return any ? "finish" : "discard"
    }
}

/// The design's 15×12 check stroke.
struct Checkmark: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX + rect.width * 0.0, y: rect.minY + rect.height * 0.5))
        p.addLine(to: CGPoint(x: rect.minX + rect.width * 0.35, y: rect.maxY - rect.height * 0.08))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return p
    }
}

extension View {
    /// The design's underlined tap targets (border-bottom, 1px gap).
    func underlined(_ color: Color) -> some View {
        self.padding(.bottom, 1)
            .overlay(alignment: .bottom) { color.frame(height: 1) }
    }
}
