import Foundation

/// Owns every open terminal tab and tracks which one is currently shown.
/// Starts with no tabs open — the user picks "local" or "server" from the
/// terminal pane's start screen — and every tab, including the last one,
/// can be closed again, which brings that start screen back.
final class TerminalSessionStore: ObservableObject {
    @Published private(set) var sessions: [TerminalController] = []
    @Published var selectedID: TerminalController.ID?

    init() {}

    var selected: TerminalController? {
        sessions.first { $0.id == selectedID }
    }

    /// Opens a plain local shell tab.
    @discardableResult
    func addLocal() -> TerminalController {
        let session = TerminalController(title: "Terminal")
        sessions.append(session)
        selectedID = session.id
        return session
    }

    /// Opens a tab that logs into the jump host, starts antasupport, logs
    /// into the given server (e.g. "199" or "s199"), then clears the screen
    /// so the pane settles on a clean prompt instead of the login banners.
    @discardableResult
    func addServer(number: String) -> TerminalController {
        let trimmed = number.trimmingCharacters(in: .whitespaces)
        let host = trimmed.lowercased().hasPrefix("s") ? trimmed : "s\(trimmed)"
        let session = TerminalController(title: host)
        sessions.append(session)
        selectedID = session.id
        session.runLoginSequence(["ssh ssh2.nl", "antasupport", "ssh \(host)", "clear"])
        return session
    }

    /// Runs a command on the currently selected tab, opening a local tab
    /// first if every tab was closed.
    func run(_ command: String) {
        let target = selected ?? addLocal()
        target.run(command)
    }

    /// Closes a tab, terminating its shell. Closing the last one leaves
    /// `sessions` empty, which brings back the terminal pane's start screen.
    func close(_ id: TerminalController.ID) {
        guard let index = sessions.firstIndex(where: { $0.id == id }) else { return }
        sessions[index].terminate()
        sessions.remove(at: index)
        if selectedID == id {
            selectedID = sessions.isEmpty ? nil : sessions[min(index, sessions.count - 1)].id
        }
    }
}
