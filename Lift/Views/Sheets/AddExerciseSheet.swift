import SwiftUI

struct AddExerciseSheet: View {
    @EnvironmentObject private var store: LiftStore
    @EnvironmentObject private var ui: UIState
    @Environment(\.theme) private var theme
    @State private var search = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("add exercise")
                .font(.lift(15))
                .padding(.top, 22)

            TextField("search or type a new one…", text: $search)
                .font(.lift(16))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(theme.fill, in: RoundedRectangle(cornerRadius: 14))
                .padding(.top, 16)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(options) { ex in
                        optionRow(ex)
                    }
                    if showCreate {
                        Text("+ create \"\(query)\"")
                            .font(.lift(15))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 2)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                let ex = store.createExercise(named: query)
                                store.addEntry(exId: ex.id)
                                ui.sheet = nil
                            }
                    }
                }
            }
            .frame(maxHeight: 300)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func optionRow(_ ex: Exercise) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(ex.name)
                .font(.lift(17))
            Spacer()
            Text(meta(ex))
                .font(.lift(12))
                .foregroundStyle(theme.faint)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 2)
        .overlay(alignment: .bottom) { theme.line.frame(height: 1) }
        .contentShape(Rectangle())
        .onTapGesture {
            store.addEntry(exId: ex.id)
            ui.sheet = nil
        }
    }

    private var query: String {
        search.trimmingCharacters(in: .whitespaces).lowercased()
    }

    private var options: [Exercise] {
        query.isEmpty ? store.exercises : store.exercises.filter { $0.name.contains(query) }
    }

    private var showCreate: Bool {
        !query.isEmpty && !store.exercises.contains { $0.name == query }
    }

    private func meta(_ ex: Exercise) -> String {
        guard let last = store.lastEntries(exId: ex.id, limit: 1).first?.sets.last else {
            return "new"
        }
        return "last: \(Format.kg(last.kg)) kg × \(last.reps)"
    }
}
