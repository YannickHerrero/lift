import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: LiftStore
    @EnvironmentObject private var ui: UIState
    @Environment(\.theme) private var theme
    @State private var newExercise = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("← home")
                .font(.lift(13))
                .foregroundStyle(theme.faint)
                .onTapGesture { ui.go(.home) }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("settings")
                        .font(.lift(34))
                        .tracking(-1.02)

                    prefRow("theme", options: [
                        option("light", isOn: store.theme == .light) { store.setTheme(.light) },
                        option("dark", isOn: store.theme == .dark) { store.setTheme(.dark) },
                    ])
                    .padding(.top, 30)

                    prefRow("kg step", options: [
                        option("1", isOn: store.prefs.kgStep == 1) { setPref { $0.kgStep = 1 } },
                        option("1.25", isOn: store.prefs.kgStep == 1.25) { setPref { $0.kgStep = 1.25 } },
                        option("2.5", isOn: store.prefs.kgStep == 2.5) { setPref { $0.kgStep = 2.5 } },
                    ])

                    prefRow("max weight", options: [150, 250, 350].map { m in
                        option(String(m), isOn: store.prefs.wheelMaxKg == m) { setPref { $0.wheelMaxKg = m } }
                    })

                    prefRow("auto-start rest timer", options: [
                        option("on", isOn: store.prefs.autoRest) { setPref { $0.autoRest = true } },
                        option("off", isOn: !store.prefs.autoRest) { setPref { $0.autoRest = false } },
                    ])

                    exercisesBlock

                    VStack(alignment: .leading, spacing: 6) {
                        Text("lift. — v1.0")
                        Text("all data is stored on this device.")
                    }
                    .font(.lift(13))
                    .foregroundStyle(theme.faint)
                    .padding(.top, 22)
                    .padding(.bottom, 30)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(alignment: .top) { theme.line.frame(height: 1) }
                }
            }
            .padding(.top, 28)
        }
        .padding(EdgeInsets(top: 80, leading: 32, bottom: 24, trailing: 32))
        .ignoresSafeArea()
    }

    // MARK: - Preference rows

    private struct Option {
        var label: String
        var isOn: Bool
        var tap: () -> Void
    }

    private func option(_ label: String, isOn: Bool, tap: @escaping () -> Void) -> Option {
        Option(label: label, isOn: isOn, tap: tap)
    }

    private func prefRow(_ label: String, options: [Option]) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.lift(15))
            Spacer()
            HStack(alignment: .firstTextBaseline, spacing: 22) {
                ForEach(Array(options.enumerated()), id: \.offset) { _, o in
                    Group {
                        if o.isOn {
                            Text(o.label).underlined(theme.ink)
                        } else {
                            Text(o.label).foregroundStyle(theme.faint)
                        }
                    }
                    .font(.lift(15))
                    .onTapGesture(perform: o.tap)
                }
            }
        }
        .padding(.vertical, 22)
        .overlay(alignment: .top) { theme.line.frame(height: 1) }
    }

    private func setPref(_ change: (inout Prefs) -> Void) {
        var p = store.prefs
        change(&p)
        store.setPrefs(p)
    }

    // MARK: - Exercises

    private var exercisesBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("exercises")
                .font(.lift(12))
                .foregroundStyle(theme.faint)
            let counts = store.exerciseCounts
            ForEach(store.exercises) { ex in
                HStack(alignment: .firstTextBaseline) {
                    Text(ex.name)
                        .font(.lift(17))
                    Spacer()
                    let c = counts[ex.id] ?? 0
                    Text("\(c) session\(c == 1 ? "" : "s")")
                        .font(.lift(12))
                        .foregroundStyle(theme.faint)
                }
                .padding(.vertical, 14)
                .overlay(alignment: .bottom) { theme.line.frame(height: 1) }
            }
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                TextField("new exercise…", text: $newExercise)
                    .font(.lift(15))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.bottom, 6)
                    .overlay(alignment: .bottom) { theme.line2.frame(height: 1) }
                    .onSubmit(addExercise)
                Text("add")
                    .font(.lift(13))
                    .underlined(theme.ink)
                    .onTapGesture(perform: addExercise)
            }
            .padding(.vertical, 16)
        }
        .padding(.top, 22)
        .padding(.bottom, 6)
        .overlay(alignment: .top) { theme.line.frame(height: 1) }
    }

    private func addExercise() {
        let name = newExercise.trimmingCharacters(in: .whitespaces).lowercased()
        if !name.isEmpty && !store.exercises.contains(where: { $0.name == name }) {
            store.createExercise(named: name)
        }
        newExercise = ""
    }
}
