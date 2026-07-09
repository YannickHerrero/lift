import SwiftUI

struct PickerSheet: View {
    @EnvironmentObject private var store: LiftStore
    @EnvironmentObject private var ui: UIState
    @Environment(\.theme) private var theme

    let entryIndex: Int
    let field: PickerField

    @State private var selected: Int?

    private let rowHeight: CGFloat = 44
    private let wheelHeight: CGFloat = 220

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(field == .kg ? "weight" : "reps")
                    .font(.lift(15))
                Spacer()
                Text(meta)
                    .font(.lift(12))
                    .foregroundStyle(theme.faint)
            }
            .padding(.top, 22)

            wheel
                .padding(.top, 8)

            Text("done")
                .font(.lift(16))
                .foregroundStyle(theme.bg)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(theme.ink, in: Capsule())
                .contentShape(Capsule())
                .padding(.top, 16)
                .onTapGesture(perform: done)
        }
        .onAppear {
            let values = values
            let current = currentValue
            selected = values.firstIndex { $0 >= current } ?? values.count - 1
        }
    }

    private var wheel: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(Array(values.enumerated()), id: \.offset) { i, v in
                    let d = abs(i - (selected ?? 0))
                    Text(label(v))
                        .font(.lift(d == 0 ? 28 : d == 1 ? 20 : 17))
                        .monospacedDigit()
                        .opacity(d == 0 ? 1 : d == 1 ? 0.4 : d == 2 ? 0.18 : 0.08)
                        .frame(maxWidth: .infinity)
                        .frame(height: rowHeight)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.15)) { selected = i }
                        }
                        .id(i)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $selected, anchor: .center)
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.vertical, (wheelHeight - rowHeight) / 2, for: .scrollContent)
        .frame(height: wheelHeight)
        .overlay {
            // Center selection band.
            VStack(spacing: rowHeight) {
                theme.line.frame(height: 1)
                theme.line.frame(height: 1)
            }
            .allowsHitTesting(false)
        }
        .overlay(alignment: .top) {
            LinearGradient(colors: [theme.bg, theme.bg.opacity(0)],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 56)
                .allowsHitTesting(false)
        }
        .overlay(alignment: .bottom) {
            LinearGradient(colors: [theme.bg.opacity(0), theme.bg],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: 56)
                .allowsHitTesting(false)
        }
    }

    // MARK: - Values

    private var values: [Double] {
        if field == .kg {
            let step = store.prefs.kgStep
            let max = Double(store.prefs.wheelMaxKg)
            return Array(stride(from: 0, through: max + 0.001, by: step))
                .map { ($0 * 100).rounded() / 100 }
        }
        return (1...50).map(Double.init)
    }

    private func label(_ v: Double) -> String {
        field == .kg ? Format.kg(v) : String(Int(v))
    }

    private var currentValue: Double {
        guard let e = store.active?.entries[safe: entryIndex] else { return 0 }
        return field == .kg ? e.pKg : Double(e.pReps)
    }

    private var meta: String {
        guard let e = store.active?.entries[safe: entryIndex] else { return "" }
        return "set \(e.sets.count + 1) · \(store.exerciseName(e.exId))"
    }

    private func done() {
        if let i = selected, let v = values[safe: i] {
            if field == .kg {
                store.updateEntry(entryIndex, kg: v)
            } else {
                store.updateEntry(entryIndex, reps: Int(v))
            }
        }
        ui.sheet = nil
    }
}

extension Array {
    subscript(safe i: Int) -> Element? {
        indices.contains(i) ? self[i] : nil
    }
}
