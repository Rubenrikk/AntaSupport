import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: SnippetStore
    @EnvironmentObject var sessions: TerminalSessionStore
    @EnvironmentObject var appState: AppState

    @State private var fillTarget: Snippet?
    @State private var editorTarget: Snippet?

    var body: some View {
        // Plain HSplitView instead of NavigationSplitView: the latter's
        // collapsible sidebar column (NSSplitViewItem's show/hide animation)
        // fights SwiftTerm's own grid-size snapping and reliably crashes
        // AppKit's constraint solver — both via the toggle button *and* by
        // dragging the divider past its minimum. HSplitView has no such
        // collapse transition, so a hard minWidth here is enough to make the
        // sidebar resizable without ever letting it disappear.
        NavigationStack {
            HSplitView {
                SnippetSidebar(
                    onRun: runOrConfirm,
                    onEdit: { editorTarget = $0 }
                )
                .frame(minWidth: 220, idealWidth: 280, maxWidth: 400)

                TerminalPane()
                    .frame(minWidth: 400, maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        // Fill-in form for a snippet's placeholders, then run it.
        .sheet(item: $fillTarget) { snippet in
            FillFormView(snippet: snippet) { command in
                sessions.run(command)
                fillTarget = nil
            }
        }
        // Create / edit a snippet.
        .sheet(item: $editorTarget) { snippet in
            SnippetEditor(snippet: snippet) { updated in
                store.upsert(updated)
                editorTarget = nil
            }
        }
        // Help & uitleg.
        .sheet(isPresented: $appState.showHelp) {
            HelpView()
        }
        // Cmd+K command palette.
        .sheet(isPresented: $appState.showPalette) {
            CommandPalette { snippet in
                appState.showPalette = false
                if canRunWithoutConfirmation(snippet) {
                    sessions.run(snippet.template)
                } else {
                    // Defer so the first sheet finishes dismissing before the next appears.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        fillTarget = snippet
                    }
                }
            }
        }
        // Cmd+N new snippet.
        .onChange(of: appState.newSnippet) {
            if appState.newSnippet {
                editorTarget = Snippet(name: "", template: "")
                appState.newSnippet = false
            }
        }
        // Reset to defaults (confirmation).
        .alert("Snippets terugzetten naar standaard?", isPresented: $appState.confirmReset) {
            Button("Annuleren", role: .cancel) {}
            Button("Terugzetten", role: .destructive) { store.resetToDefaults() }
        } message: {
            Text("Dit overschrijft je huidige snippetlijst met de ingebouwde standaardset.")
        }
    }

    /// A snippet with no placeholders has nothing to fill in or preview, so
    /// once the user has ticked "niet meer vragen" for it once, running it
    /// again can skip straight past the fill-in popup.
    private func canRunWithoutConfirmation(_ snippet: Snippet) -> Bool {
        snippet.skipConfirmation && TemplateParser.placeholders(in: snippet.template).isEmpty
    }

    private func runOrConfirm(_ snippet: Snippet) {
        if canRunWithoutConfirmation(snippet) {
            sessions.run(snippet.template)
        } else {
            fillTarget = snippet
        }
    }
}

struct TerminalPane: View {
    @EnvironmentObject var sessions: TerminalSessionStore
    @State private var serverPromptShown = false
    @State private var serverNumberInput = ""

    var body: some View {
        VStack(spacing: 0) {
            if sessions.sessions.isEmpty {
                startScreen
            } else {
                addBar
                // Every open session sits side by side as its own resizable
                // split-view pane, always visible — instead of tabs that hide
                // all but one, which made it easy to forget a session was still
                // open (e.g. a cage login left mid-command on another pane).
                HSplitView {
                    ForEach(sessions.sessions) { session in
                        TerminalPaneItem(
                            session: session,
                            isActive: session.id == sessions.selectedID,
                            onActivate: { sessions.selectedID = session.id },
                            onClose: { sessions.close(session.id) }
                        )
                        .frame(minWidth: 360)
                    }
                }
                .padding(16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle("Antasupport")
    }

    /// Shown instead of a pane when no terminal is open yet — on first
    /// launch, and again if every pane has been closed — so the app never
    /// silently spawns a shell the user didn't ask for.
    private var startScreen: some View {
        VStack(spacing: 16) {
            Image(systemName: "terminal.fill")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text("Nog geen terminalscherm open")
                .font(.title3.weight(.semibold))
            Text("Kies hieronder waarmee je wilt beginnen.")
                .font(.callout)
                .foregroundStyle(.secondary)
            HStack(spacing: 12) {
                Button {
                    sessions.addLocal()
                } label: {
                    Label("Lokaal terminal scherm", systemImage: "desktopcomputer")
                        .frame(minWidth: 170)
                }
                .keyboardShortcut("t", modifiers: .command)

                Button {
                    serverNumberInput = ""
                    serverPromptShown = true
                } label: {
                    Label("Server scherm…", systemImage: "server.rack")
                        .frame(minWidth: 170)
                }
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .popover(isPresented: $serverPromptShown) {
            ServerLoginPrompt(number: $serverNumberInput) { number in
                sessions.addServer(number: number)
                serverPromptShown = false
            }
        }
    }

    private var addBar: some View {
        HStack {
            Spacer()
            Menu {
                Button("Lokaal terminal scherm") { sessions.addLocal() }
                Button("Server scherm…") {
                    serverNumberInput = ""
                    serverPromptShown = true
                }
            } label: {
                Label("Nieuw scherm", systemImage: "plus")
                    .font(.system(size: 12, weight: .semibold))
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            .popover(isPresented: $serverPromptShown) {
                ServerLoginPrompt(number: $serverNumberInput) { number in
                    sessions.addServer(number: number)
                    serverPromptShown = false
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }
}

/// One always-visible split-view pane: a small title bar (name + close)
/// above the terminal itself. Tapping anywhere in the pane makes it the
/// active one — the target for snippets run from the sidebar/palette —
/// without stealing the click from the terminal underneath, so typing and
/// text selection inside it keep working normally.
private struct TerminalPaneItem: View {
    @ObservedObject var session: TerminalController
    let isActive: Bool
    let onActivate: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Text(session.title)
                    .font(.callout.weight(.semibold))
                    .lineLimit(1)
                    .foregroundStyle(isActive ? AppTheme.accent : .primary)
                Spacer(minLength: 8)
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .frame(width: 16, height: 16)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .help("Scherm sluiten")
                .accessibilityLabel("Scherm sluiten")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isActive ? AppTheme.accent.opacity(0.14) : Color.primary.opacity(0.04))

            ZStack {
                TerminalViewRepresentable(controller: session)
                if session.isConnecting {
                    ConnectingOverlay()
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(isActive ? AppTheme.accent.opacity(0.5) : Color.primary.opacity(0.08),
                              lineWidth: isActive ? 1.5 : 1)
        )
        .contentShape(Rectangle())
        .simultaneousGesture(TapGesture().onEnded(onActivate))
    }
}

/// Covers the terminal while a server login sequence is still connecting
/// (see `TerminalController.runLoginSequence`), so the ssh/antasupport
/// startup chatter never flashes on screen — only the clean prompt `clear`
/// leaves behind, once it's ready.
private struct ConnectingOverlay: View {
    var body: some View {
        VStack(spacing: 10) {
            ProgressView()
                .controlSize(.small)
            Text("Verbinden met server…")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

/// Popup asking which server to log into for a new "server scherm" tab.
private struct ServerLoginPrompt: View {
    @Binding var number: String
    var onConfirm: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    private var isValid: Bool {
        !number.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Inloggen op server")
                .font(.headline)
            Text("Logt in op ssh2.nl, start antasupport en logt daarna in op de opgegeven server.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            TextField("Servernummer (bv. 199 of s199)", text: $number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 240)
                .onSubmit(submit)
            HStack {
                Spacer()
                Button("Annuleren") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Inloggen") { submit() }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                    .disabled(!isValid)
            }
        }
        .padding(16)
        .frame(width: 300)
    }

    private func submit() {
        guard isValid else { return }
        onConfirm(number)
    }
}
