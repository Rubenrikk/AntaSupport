import SwiftUI

struct SnippetSidebar: View {
    @EnvironmentObject var store: SnippetStore
    @EnvironmentObject var appState: AppState
    @State private var search = ""
    @State private var pendingDelete: Snippet?
    // Collapsed categories persist across launches as a "|"-joined list of
    // names (category names never contain "|") — simpler than teaching
    // AppStorage to hold a Set/Codable value for what's a small, one-off bit
    // of UI state.
    @AppStorage("collapsedCategories") private var collapsedCategoriesRaw = ""

    var onRun: (Snippet) -> Void
    var onEdit: (Snippet) -> Void

    private static let helpText = "Snippets met een oranje CAGE-label moeten in de cage draaien; de rest niet."

    private var visible: [Snippet] {
        store.snippets.filter { s in
            search.isEmpty ||
                s.name.localizedCaseInsensitiveContains(search) ||
                s.template.localizedCaseInsensitiveContains(search) ||
                s.category.localizedCaseInsensitiveContains(search) ||
                s.tags.contains { $0.localizedCaseInsensitiveContains(search) }
        }
    }

    /// Categories in `Snippet.categoryOrder`'s order; any custom category not
    /// in that list (e.g. user-added) sorts alphabetically after it.
    private var categories: [String] {
        let present = Set(visible.map { $0.category })
        let known = Snippet.categoryOrder.filter { present.contains($0) }
        let custom = present.subtracting(Snippet.categoryOrder).sorted()
        return known + custom
    }

    private func isExpanded(_ category: String) -> Binding<Bool> {
        Binding(
            get: { !collapsedCategoriesRaw.split(separator: "|").map(String.init).contains(category) },
            set: { expanded in
                var collapsed = Set(collapsedCategoriesRaw.split(separator: "|").map(String.init))
                if expanded { collapsed.remove(category) } else { collapsed.insert(category) }
                collapsedCategoriesRaw = collapsed.sorted().joined(separator: "|")
            }
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            helpBanner

            if visible.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(categories, id: \.self) { category in
                            let snippets = visible.filter { $0.category == category }
                            CategoryCard(
                                name: category,
                                snippets: snippets,
                                isExpanded: isExpanded(category),
                                onRun: onRun,
                                onEdit: onEdit,
                                onDelete: { pendingDelete = $0 }
                            )
                        }
                    }
                    .padding(10)
                }
                // Matches the rest of the window chrome (same background the
                // terminal pane sits on) instead of `.underPageBackgroundColor`,
                // whose flat, fairly dark gray fought with the white category
                // cards rather than just quietly sitting behind them.
                .background(Color(nsColor: .windowBackgroundColor))
            }
        }
        .searchable(text: $search, prompt: "Zoek snippets")
        .toolbar {
            ToolbarItem {
                Button {
                    appState.showHelp = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }
                .help("Help & uitleg")
                .accessibilityLabel("Help & uitleg")
            }
            ToolbarItem {
                Button {
                    onEdit(Snippet(name: "", template: ""))
                } label: {
                    Image(systemName: "plus")
                }
                .help("Nieuw snippet (⌘N)")
                .accessibilityLabel("Nieuw snippet")
            }
        }
        .alert(item: $pendingDelete) { snippet in
            Alert(
                title: Text("\"\(snippet.name.isEmpty ? "Naamloos" : snippet.name)\" verwijderen?"),
                message: Text("Dit kan niet ongedaan worden gemaakt."),
                primaryButton: .destructive(Text("Verwijderen")) { store.delete(snippet) },
                secondaryButton: .cancel(Text("Annuleren"))
            )
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text(search.isEmpty ? "Geen snippets" : "Geen snippets gevonden voor \u{201C}\(search)\u{201D}")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var helpBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lock.shield.fill")
                .foregroundStyle(AppTheme.accent)
                .font(.callout)
            Text(Self.helpText)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(AppTheme.accent.opacity(0.09)))
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .padding(.bottom, 2)
    }
}

/// One category as its own card: a plain, opaque surface (rather than the
/// sidebar's default translucent gray) so each category visibly separates
/// from the next instead of every row bleeding into one uniform gray field.
/// Header is tappable to collapse/expand; rows inside are divided by hairline
/// separators instead of each getting its own background.
private struct CategoryCard: View {
    let name: String
    let snippets: [Snippet]
    @Binding var isExpanded: Bool
    var onRun: (Snippet) -> Void
    var onEdit: (Snippet) -> Void
    var onDelete: (Snippet) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: name.categorySymbol)
                        .foregroundStyle(AppTheme.accent)
                        .frame(width: 18)
                    Text(name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Spacer(minLength: 8)
                    Text("\(snippets.count)")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(name), \(snippets.count) snippets, \(isExpanded ? "ingeklapt" : "uitgeklapt")")

            if isExpanded {
                separator
                VStack(spacing: 0) {
                    ForEach(Array(snippets.enumerated()), id: \.element.id) { index, snippet in
                        SnippetRow(snippet: snippet) { onRun(snippet) }
                            .contextMenu {
                                Button("Uitvoeren…") { onRun(snippet) }
                                Button("Bewerken…") { onEdit(snippet) }
                                Divider()
                                Button("Verwijderen…", role: .destructive) { onDelete(snippet) }
                            }
                        if index < snippets.count - 1 {
                            separator
                        }
                    }
                }
            }
        }
        .background(Color(nsColor: .textBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }

    /// A plain `Divider()` reads as an almost-invisible hairline on top of an
    /// opaque card background — too faint to actually separate rows. A fixed,
    /// slightly-darker full-width rule reads clearly at a glance instead.
    private var separator: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.12))
            .frame(height: 1)
    }
}

private struct SnippetRow: View {
    let snippet: Snippet
    var onRun: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: onRun) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(snippet.name.isEmpty ? "Naamloos" : snippet.name)
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.primary)
                        if snippet.cage {
                            CageBadge()
                                .help("Moet in de cage draaien")
                        }
                    }
                    Text(snippet.template)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                Image(systemName: "play.circle.fill")
                    .font(.title3)
                    .foregroundStyle(AppTheme.accent)
                    .opacity(hovering ? 1 : 0.45)
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 12)
            .background(hovering ? Color.primary.opacity(0.05) : .clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
    }
}
