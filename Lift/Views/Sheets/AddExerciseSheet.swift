import SwiftUI

struct AddExerciseSheet: View {
    @EnvironmentObject private var store: LiftStore
    @EnvironmentObject private var ui: UIState
    @Environment(\.theme) private var theme
    @State private var search = ""
    @State private var showRemoveConfirmation = false

    let entryIndex: Int?

    init(entryIndex: Int? = nil) {
        self.entryIndex = entryIndex
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(entryIndex == nil ? "add exercise" : "edit exercise")
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
                                select(ex)
                            }
                    }
                }
            }
            .frame(maxHeight: 300)
            .padding(.top, 8)

            if entryIndex != nil {
                Text("remove exercise")
                    .font(.lift(13))
                    .foregroundStyle(theme.faint)
                    .underlined(theme.faint)
                    .padding(.top, 18)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: requestRemoval)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .alert("remove exercise?", isPresented: $showRemoveConfirmation) {
            Button("cancel", role: .cancel) {}
            Button("remove", role: .destructive, action: remove)
        } message: {
            Text("its logged sets will be removed from this session.")
        }
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
        .onTapGesture { select(ex) }
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
        if let entryIndex,
           store.active?.entries[safe: entryIndex]?.exId == ex.id {
            return "current"
        }
        guard let last = store.lastEntries(exId: ex.id, limit: 1).first?.sets.last else {
            return "new"
        }
        return "last: \(Format.kg(last.kg)) kg × \(last.reps)"
    }

    private func select(_ ex: Exercise) {
        if let entryIndex {
            store.replaceEntry(entryIndex, with: ex.id)
        } else {
            store.addEntry(exId: ex.id)
        }
        ui.sheet = nil
    }

    private func requestRemoval() {
        guard let entryIndex,
              let entry = store.active?.entries[safe: entryIndex] else { return }
        if entry.sets.isEmpty {
            remove()
        } else {
            showRemoveConfirmation = true
        }
    }

    private func remove() {
        guard let entryIndex else { return }
        store.removeEntry(entryIndex)
        ui.sheet = nil
    }
}
