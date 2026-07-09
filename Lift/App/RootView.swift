import SwiftUI

struct RootView: View {
    @StateObject private var store = LiftStore()
    @StateObject private var ui = UIState()

    var body: some View {
        let theme = Theme.forAppTheme(store.theme)
        ZStack {
            theme.bg.ignoresSafeArea()
            switch ui.screen {
            case .home: HomeView()
            case .session: SessionView()
            case .history: HistoryView()
            case .stats: StatsView()
            case .settings: SettingsView()
            }
            SheetHost()
        }
        .environmentObject(store)
        .environmentObject(ui)
        .environment(\.theme, theme)
        .font(.lift(15))
        .foregroundStyle(theme.ink)
        .preferredColorScheme(store.theme == .dark ? .dark : .light)
        .onAppear {
            // A session left running survives relaunch.
            if store.active != nil { ui.screen = .session }
            #if DEBUG
            DebugLaunch.apply(store: store, ui: ui)
            #endif
        }
    }
}
