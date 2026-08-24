import SwiftUI

/// Cmd+K quick launcher: type to filter, click to fill & run.
struct CommandPalette: View {
    @EnvironmentObject var store: SnippetStore
    var onSelect: (Snippet) -> Void

    @State private var query = ""
    @FocusState private var searchFocused: Bool

    private var results: [Snippet] {
        guard !query.isEmpty else { return store.snippets }
        return store.snippets.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.template.localizedCaseInsensitiveContains(query) ||
            $0.tags.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Zoek een snippet…", text: $query)
                    .textFieldStyle(.plain)
                    .font(.title3)
                    .focused($searchFocused)
            }
            .padding()

            Divider()

            if results.isEmpty {
                Text("Geen snippets gevonden voor \u{201C}\(query)\u{201D}")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(24)
            } else {
                List(results) { snippet in
                    Button {
                        onSelect(snippet)
                    } label: {
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(snippet.name).fontWeight(.medium)
                                    if snippet.cage { CageBadge() }
                                }
                                Text(snippet.template)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer(minLength: 8)
                            Image(systemName: "play.circle.fill")
                                .foregroundStyle(AppTheme.accent)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.sidebar)
            }
        }
        .frame(width: 560, height: 400)
        .onAppear { searchFocused = true }
    }
}
