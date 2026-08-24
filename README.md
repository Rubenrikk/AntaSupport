# Antasupport

A tiny native macOS app that combines a **local terminal** with a **snippet manager**.
Pick a saved command template, fill in the `{{placeholders}}`, and the fully
assembled command runs straight away in the embedded terminal.

No runtime dependencies to install — the only building block, the terminal
emulator [SwiftTerm](https://github.com/migueldeicaza/SwiftTerm), is pulled in
automatically by Swift Package Manager the first time you build.

## Privacy & data

Everything runs locally — nothing is shared with third parties.

- **Terminal:** runs your own local shell (`$SHELL`) through a pty, exactly like
  Terminal.app. Whatever you type or run via a snippet goes straight to that
  local shell process. If a snippet does an `ssh` to a server, that's your own
  explicit action — the app itself never calls out anywhere on its own.
- **Snippets:** stored purely as local JSON at
  `~/Library/Application Support/Antasupport/snippets.json`. No account, no
  cloud sync, no backend.
- **No analytics, telemetry, or crash-reporting SDK** is built into the app.
- **The only network activity, ever:** Swift Package Manager fetches the
  SwiftTerm source from GitHub once, the first time you *build* the app — not
  at runtime.
- macOS' own crash reporter (the "quit unexpectedly" dialog) only sends
  anything to Apple if you click **Report…** yourself — that's a system
  feature, not something the app does.

## Requirements

- macOS 13 (Ventura) or newer
- Xcode 15+ (free from the Mac App Store) — needed once, to build the app

## Build a double-clickable app (recommended)

From Terminal, inside the project folder (the one with `Package.swift`):

```bash
bash build-app.sh
```

This compiles the app and assembles a real macOS bundle at `build/Antasupport.app`.
Drag it into `/Applications` and double-click to launch. The first time, macOS
may warn it's from an unidentified developer (the app is ad-hoc signed locally) —
**right-click the app → Open** once, and it runs normally afterwards.

### "Can't be opened because Apple could not check it for malicious software"

If you send the `.app` (or the `.dmg` from `make-dmg.sh`) to someone else, macOS
may show a stricter Gatekeeper warning instead of the usual one, because the app
is only ad-hoc/locally signed — no Apple Developer ID, not notarized. Copying or
downloading the file makes macOS tag it with a quarantine flag. To open it:

1. **Right-click (or ctrl+click) the app → Open**, then confirm **Open** again
   in the popup. Needed only the first time.
2. If that doesn't show up: **System Settings → Privacy & Security**, scroll
   down — there's a notice about the blocked app with an **"Open Anyway"** button.
3. Last resort, via Terminal: `xattr -cr /Applications/Antasupport.app`, then
   double-click normally.

After the first successful launch, double-clicking works from then on. The
`.dmg` built by `make-dmg.sh` includes a `Lees mij.txt` with this same explanation
(in Dutch) for anyone you send it to.

## Or run from Xcode (for development)

1. Open **Xcode → File → Open…** and select the project folder (the one with
   `Package.swift`). Xcode opens it as a Swift package and resolves SwiftTerm.
2. Pick the **My Mac** run destination and press **⌘R**.

Either way, a window opens with the snippet list on the left and a live terminal
on the right, already running your login shell (`$SHELL`).

## How to use

- **Run a snippet:** click it in the sidebar (or open the palette with **⌘K**).
  A small form appears with one field per placeholder; defaults are pre-filled.
  Press **Run** and the command is typed into the terminal and executed.
- **Command palette:** **⌘K** → type to filter → click to fill & run.
- **New snippet:** the **+** button in the sidebar, or **⌘N**.
- **Edit / delete:** right-click a snippet.

## Categories & the cage

- Snippets are grouped by **category** in the sidebar (Git, Docker, Netwerk, …).
- Each snippet has a **cage** flag. Cage snippets show a 🔒 badge and a warning in
  the run form. Use the **Alle / In cage / Buiten cage** filter above the list to
  narrow down. Today the cage flag is a label + filter — if you want it to
  actually *wrap* the command (e.g. run it through a `cage …` prefix or a
  container), tell me what that wrapper is and I'll hook it into `run(_:)`.
- The **help text** above the list is editable — click the ✏️ to write your own
  explanation of when something must go in the cage. It's saved automatically.

## Adding your own standard snippets

Edit `Sources/Antasupport/Models/DefaultSnippets.swift` — one `Snippet(...)` line per
command, grouped under `category:` headings, with `cage: true/false`. Then choose
**Snippets → Reset to Default Snippets** in the menu to load them (this overwrites
the current list, with a confirmation prompt). When you send me your full list,
this is the file it goes into.

### Template syntax

```
git commit -m "{{message}}"
git checkout -b {{branch:feature/}}
ping -c {{count:5}} {{host:8.8.8.8}}
```

- `{{name}}` — a required field, empty by default.
- `{{name:default}}` — a field pre-filled with `default`.
- Repeat the same `{{name}}` and it's filled from one field.

Snippets are stored as plain JSON at
`~/Library/Application Support/Antasupport/snippets.json` — easy to back up, edit,
or sync yourself.

## Project layout

```
Sources/Antasupport/
  AntasupportApp.swift          App entry point + menu shortcuts
  ContentView.swift          Split view: sidebar + terminal, sheet wiring
  Models/
    Snippet.swift            The snippet model (name, template, category, cage, tags)
    DefaultSnippets.swift    The built-in standard snippets, grouped per category
    SnippetStore.swift       JSON load/save + reset-to-defaults
  Terminal/
    TerminalController.swift  Owns the shell process; run(_:) sends commands
  Snippets/
    TemplateParser.swift     {{placeholder}} parsing & substitution
    SnippetSidebar.swift     List + search + context menu
    SnippetEditor.swift      Create/edit form
    FillFormView.swift       Fill placeholders + live preview + Run
  Palette/
    CommandPalette.swift     ⌘K quick launcher
```

## Turning it into a double-clickable .app (optional)

Running from Xcode (⌘R) is the simplest workflow. If you later want a standalone
app in `/Applications` with its own icon, create a new **macOS App** target in
Xcode, drag these `Sources/Antasupport` files into it, and add the SwiftTerm package
via **File → Add Package Dependencies…** — the code is unchanged.

## Note on the one API call to double-check

`TerminalController.run(_:)` sends input with `terminalView.send(txt:)`. If your
SwiftTerm version names it differently, the alternative is
`terminalView.send(data: Array((command + "\r").utf8)[...])`.
