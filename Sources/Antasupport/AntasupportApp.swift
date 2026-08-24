import SwiftUI

/// Small shared UI state used to drive menu-triggered actions (keyboard shortcuts).
final class AppState: ObservableObject {
    @Published var showPalette = false
    @Published var newSnippet = false
    @Published var confirmReset = false
    @Published var showHelp = false
}

@main
struct AntasupportApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var store = SnippetStore()
    @StateObject private var sessions = TerminalSessionStore()
    @StateObject private var recentValues = RecentValuesStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(store)
                .environmentObject(sessions)
                .environmentObject(recentValues)
                .frame(minWidth: 900, minHeight: 560)
                .tint(AppTheme.accent)
        }
        .commands {
            CommandMenu("Snippets") {
                Button("Commandopalet…") { appState.showPalette = true }
                    .keyboardShortcut("k", modifiers: .command)
                Button("Nieuw snippet…") { appState.newSnippet = true }
                    .keyboardShortcut("n", modifiers: .command)
                Divider()
                Button("Terugzetten naar standaard snippets…") { appState.confirmReset = true }
                Divider()
                Button("Help & uitleg…") { appState.showHelp = true }
                    .keyboardShortcut("?", modifiers: .command)
            }
            CommandMenu("Terminal") {
                Button("Nieuw lokaal terminal scherm") { sessions.addLocal() }
                    .keyboardShortcut("t", modifiers: .command)
                Divider()
                Button("Scrollen herstellen (vastgelopen na less/top/ncdu)") {
                    sessions.selected?.fixStuckScrolling()
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])
            }
        }
    }
}
