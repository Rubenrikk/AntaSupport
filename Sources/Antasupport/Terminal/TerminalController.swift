import SwiftUI
import AppKit
import SwiftTerm

/// Owns the embedded terminal view + its shell process, and exposes `run(_:)`
/// so snippets can inject a fully-assembled command and execute it.
///
/// One instance backs one terminal tab in `TerminalSessionStore`.
final class TerminalController: ObservableObject, Identifiable {
    let id = UUID()
    @Published var title: String
    /// True while a server login sequence (see `runLoginSequence`) is still
    /// connecting. The pane shows a loading overlay instead of the raw
    /// ssh/antasupport/login chatter while this is true.
    @Published var isConnecting = false
    let terminalView: LocalProcessTerminalView
    private var started = false

    /// Arbitrary, unregistered OSC code used purely as a private "I'm ready"
    /// signal between `runLoginSequence`'s trailing `printf` and this
    /// controller — it's never printed to the screen (OSC sequences are
    /// control data, consumed by the terminal parser) and never reaches the
    /// remote shell's own state, so it can't collide with anything real.
    private static let readyOscCode = 7770

    init(title: String = "Terminal") {
        self.title = title
        terminalView = LocalProcessTerminalView(frame: .zero)
        terminalView.processDelegate = self
        terminalView.font = TerminalController.preferredFont()
        terminalView.terminal.registerOscHandler(code: Self.readyOscCode) { [weak self] _ in
            DispatchQueue.main.async { self?.isConnecting = false }
        }
    }

    /// Shell prompts (Starship, Powerlevel10k, Oh My Zsh…) often draw glyphs
    /// from a "Nerd Font" that plain Menlo doesn't contain, which shows up as
    /// tofu boxes. Use one if the user already has it installed; otherwise
    /// fall back to Menlo, which SwiftTerm uses by default anyway.
    private static func preferredFont(size: CGFloat = 13.5) -> NSFont {
        let nerdFontFamilies = [
            "MesloLGS NF", "Hack Nerd Font", "FiraCode Nerd Font",
            "JetBrainsMono Nerd Font", "CaskaydiaCove Nerd Font", "SauceCodePro Nerd Font"
        ]
        let installed = Set(NSFontManager.shared.availableFontFamilies)
        for family in nerdFontFamilies where installed.contains(family) {
            if let font = NSFont(name: family, size: size) {
                return font
            }
        }
        return NSFont(name: "Menlo", size: size) ?? NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
    }

    /// Spawns the user's login shell exactly once.
    func startIfNeeded() {
        guard !started else { return }
        started = true

        let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        let shellName = (shell as NSString).lastPathComponent
        // Leading "-" makes it a login shell so ~/.zprofile etc. are loaded.
        terminalView.startProcess(executable: shell,
                                  args: [],
                                  environment: nil,
                                  execName: "-\(shellName)")
    }

    /// Types `command` into the shell and presses return.
    func run(_ command: String) {
        startIfNeeded()
        terminalView.send(txt: command + "\r")
        terminalView.window?.makeFirstResponder(terminalView)
    }

    /// Types each command in turn, pressing return after every one — e.g. a
    /// jump-host login followed by a further SSH hop and a trailing `clear`.
    /// Each hop reads from the same pty stdin, so queueing the whole chain up
    /// front works the same way pasting multiple lines into a terminal does:
    /// every command waits in the input buffer until the program that's
    /// currently running is ready to read it.
    ///
    /// The pane stays hidden behind a loading overlay (`isConnecting`) until
    /// the sequence has actually finished — otherwise the ssh banners,
    /// antasupport startup chatter and intermediate prompts all flash by
    /// before settling on the clean prompt `clear` leaves behind. Detection
    /// works by appending an invisible marker after the caller's commands: a
    /// `printf` that emits a private OSC escape sequence, caught by the
    /// handler registered in `init`. That sequence is pure control data, so
    /// it's never shown on screen and can't collide with real output. A
    /// timeout reveals the pane regardless, so a failed or interactive
    /// (password-prompting) login never leaves the user staring at a
    /// spinner forever.
    func runLoginSequence(_ commands: [String]) {
        startIfNeeded()
        isConnecting = true

        // Chained onto the last command with && rather than sent as its own
        // line: a separate line would make the shell print an extra empty
        // prompt after it (one for `clear`, one for the marker), leaving two
        // blank prompts stacked once the pane is revealed instead of one.
        var sequence = commands
        let ready = "printf '\\033]\(Self.readyOscCode);ready\\007'"
        if sequence.isEmpty {
            sequence = [ready]
        } else {
            sequence[sequence.count - 1] += " && \(ready)"
        }
        terminalView.send(txt: sequence.map { $0 + "\r" }.joined())
        terminalView.window?.makeFirstResponder(terminalView)

        DispatchQueue.main.asyncAfter(deadline: .now() + 12) { [weak self] in
            self?.isConnecting = false
        }
    }

    /// Ends the shell process backing this tab (and everything it launched,
    /// e.g. an open SSH hop), used when the tab is closed.
    func terminate() {
        terminalView.terminate()
    }

    /// Recovers from a stuck "alternate screen" state.
    ///
    /// SwiftTerm forwards scroll-wheel input as up/down-arrow keypresses while
    /// the terminal thinks a full-screen program (less, top, ncdu, vim…) is
    /// active, so the mouse wheel can be used to navigate it. If such a
    /// program on the remote end doesn't exit cleanly — a dropped SSH
    /// connection, a killed pager — the terminal can get left flagged as
    /// still being in that mode, and scrolling keeps sending arrow keys even
    /// back at a plain prompt. Feeding the "exit alternate screen" escape
    /// sequence (DECRST 1049) locally flips that flag back off and restores
    /// the normal buffer exactly as it was, without touching the shell
    /// process or clearing any visible output.
    func fixStuckScrolling() {
        terminalView.terminal.feed(text: "\u{1b}[?1049l")
    }
}

extension TerminalController: LocalProcessTerminalViewDelegate {
    func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {}
    func setTerminalTitle(source: LocalProcessTerminalView, title: String) {}
    func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}
    func processTerminated(source: TerminalView, exitCode: Int32?) {}
}

/// Bridges the AppKit terminal view into SwiftUI. The view is retained by the
/// controller so SwiftUI re-renders never tear down the running shell.
///
/// The terminal is hosted inside a plain container instead of being handed
/// straight to SwiftUI, and sized via `autoresizingMask` rather than Auto
/// Layout constraints. SwiftTerm reflows its own grid on resize; letting
/// SwiftUI's constraint engine *also* manage that same view's frame caused a
/// crash deep in AppKit when the sidebar column was hidden/shown (an abrupt,
/// large width change during NavigationSplitView's collapse animation).
struct TerminalViewRepresentable: NSViewRepresentable {
    @ObservedObject var controller: TerminalController

    func makeNSView(context: Context) -> NSView {
        controller.startIfNeeded()
        let container = NSView()
        controller.terminalView.autoresizingMask = [.width, .height]
        controller.terminalView.frame = container.bounds
        container.addSubview(controller.terminalView)
        return container
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
