import Foundation

/// Persists snippets as JSON in ~/Library/Application Support/Antasupport/snippets.json.
final class SnippetStore: ObservableObject {
    @Published var snippets: [Snippet] = []

    private let url: URL

    init() {
        let fm = FileManager.default
        let support = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let base = support.appendingPathComponent("Antasupport", isDirectory: true)
        try? fm.createDirectory(at: base, withIntermediateDirectories: true)
        url = base.appendingPathComponent("snippets.json")

        load()
    }

    /// Maps category names from before a rename straight to their current
    /// name (skipping any in-between spelling), so snippet lists saved by an
    /// older version of the app pick up renames instead of showing up as
    /// unrecognized "custom" categories (which sort alphabetically after all
    /// the known ones instead of in their intended spot — see
    /// `Snippet.categoryOrder`).
    private static let categoryRenames: [String: String] = [
        "BabySSH: Basis": "Inloggen",
        "BabySSH: Cage": "Inloggen",
        "BabySSH: Inloggen": "Inloggen",
        "BabySSH: Domeinen": "Afsluiten & deblokkeren",
        "BabySSH: Domein afsluiten & deblokkeren": "Afsluiten & deblokkeren",
        "Domein afsluiten & deblokkeren": "Afsluiten & deblokkeren",
        "BabySSH: Malware & Spam": "Malware & Spam scannen",
        "BabySSH: Malware & Spam scannen": "Malware & Spam scannen",
        "BabySSH: WordPress": "WordPress verify-checksums",
        "BabySSH: WordPress verify-checksums": "WordPress verify-checksums",
        "BabySSH: Mail": "Mail",
        "BabySSH: Schijfruimte": "Schijfruimte",
        "BabySSH: Logs": "Logs",
        "BabySSH: Firewall": "Firewall",
        "BabySSH: Hostingpakket": "Hostingpakket",
        "BabySSH: Backup transfer": "Backup transfer",
        "BabySSH: DNS": "DNS",
        "BabySSH: Snapshots": "Snapshots",
        "BabySSH: Bestandsrechten": "Bestandsrechten",
        "BabySSH: Database": "Database",
        "BabySSH: Bot-traffic": "Bot-traffic",
        "BabySSH: Systeem": "Systeem",
        "BabySSH: Screen & Tmux": "Screen & Tmux",
        "BabySSH: Reseller": "Reseller",
        "BabySSH: Redis": "Redis",
        "BabySSH: Nextcloud": "Nextcloud",
    ]

    /// Maps `{{placeholder}}` names from before a rename to their current
    /// name, so templates saved by an older version of the app (e.g. the
    /// "Inloggen op de cage van gebruiker" snippet, which used to use
    /// `{{gebruikersnaam}}` where every other deb-account field uses
    /// `{{debuser}}`) share their remembered value (`RecentValuesStore` keys
    /// by placeholder name) instead of keeping their own stale, orphaned one.
    private static let placeholderRenames: [String: String] = [
        "gebruikersnaam": "debuser",
    ]

    private static func migrateTemplate(_ template: String) -> String {
        var result = template
        for (old, new) in placeholderRenames {
            result = result.replacingOccurrences(of: "{{\(old)", with: "{{\(new)")
        }
        return result
    }

    /// Defaults that were removed or split into others (e.g. one snippet
    /// turning into two). Key: the exact `(name, template)` as it used to
    /// ship; value: the replacement defaults' ids. Only removes the old row
    /// when the user's saved copy still matches byte-for-byte — an edited
    /// copy is left in place, untouched, alongside the new replacements.
    private static let retiredDefaults: [(oldName: String, oldTemplate: String, replacementIDs: [UUID])] = [
        (
            oldName: "Plugins & thema uitzetten (huidige map)",
            oldTemplate: "wp plugin deactivate --all && wp theme activate {{theme:twentytwentyfour}}",
            replacementIDs: [
                UUID(uuidString: "A0DD568B-E439-47A9-87AD-B77C3666877B")!,
                UUID(uuidString: "3003D292-0119-40FB-9039-D8F0F8BC2172")!,
            ]
        ),
    ]

    func load() {
        guard
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode([Snippet].self, from: data)
        else {
            snippets = Snippet.defaults.map(Self.markSynced)
            save()
            return
        }
        var migrated = false
        snippets = decoded.map { snippet in
            var updated = snippet
            // Category/placeholder renames apply unconditionally to every
            // snippet (including the user's own), so if this row's synced
            // snapshot was tracking the pre-rename value, carry the rename
            // over onto the snapshot too — otherwise the rename alone would
            // make the row look user-edited and permanently block it from
            // ever picking up a future default sync.
            if let renamedCategory = Self.categoryRenames[snippet.category] {
                updated.category = renamedCategory
                if updated.syncedCategory == snippet.category {
                    updated.syncedCategory = renamedCategory
                }
                migrated = true
            }
            let migratedTemplate = Self.migrateTemplate(snippet.template)
            if migratedTemplate != snippet.template {
                updated.template = migratedTemplate
                if updated.syncedTemplate == snippet.template {
                    updated.syncedTemplate = migratedTemplate
                }
                migrated = true
            }
            return updated
        }
        if syncDefaults() { migrated = true }
        if migrated { save() }
    }

    private static func markSynced(_ snippet: Snippet) -> Snippet {
        var s = snippet
        s.syncedName = snippet.name
        s.syncedTemplate = snippet.template
        s.syncedCategory = snippet.category
        s.syncedTags = snippet.tags
        s.syncedCage = snippet.cage
        s.syncedNote = snippet.note
        return s
    }

    /// True if every tracked field of `snippet` still matches `def` exactly.
    private static func matchesDefaultContent(_ snippet: Snippet, _ def: Snippet) -> Bool {
        snippet.template == def.template
            && snippet.category == def.category
            && snippet.tags == def.tags
            && snippet.cage == def.cage
            && snippet.note == def.note
    }

    /// Bridges installs saved before defaults had stable ids. Matches purely
    /// on `name` (defaults all have unique names) so it also catches a
    /// default the user has since customized — not just pristine copies —
    /// which matters because the *next* step only appends a default when its
    /// id is nowhere in the list: without this, every default a user ever
    /// edited would reappear a second time, fresh and duplicated, right next
    /// to their edited copy.
    ///
    /// A row whose fields still match exactly gets marked as synced (so
    /// future default changes keep auto-applying to it); a row that differs
    /// in any tracked field adopts the id but is left un-synced, since a
    /// mismatch could mean either "the user edited this" or "this default's
    /// content changed in some older release before this system existed" —
    /// both are treated the same way here: hands off, it's now the user's own.
    private func adoptStableIDs() -> Bool {
        var changed = false
        for def in Snippet.defaults {
            guard !snippets.contains(where: { $0.id == def.id }) else { continue }
            guard let idx = snippets.firstIndex(where: { $0.syncedTemplate == nil && $0.name == def.name }) else { continue }
            snippets[idx].id = def.id
            changed = true
            if Self.matchesDefaultContent(snippets[idx], def) {
                snippets[idx].syncedName = def.name
                snippets[idx].syncedTemplate = def.template
                snippets[idx].syncedCategory = def.category
                snippets[idx].syncedTags = def.tags
                snippets[idx].syncedCage = def.cage
                snippets[idx].syncedNote = def.note
            }
        }
        return changed
    }

    /// Removes any retired default the user never edited (see
    /// `retiredDefaults`); an edited copy is left in place.
    private func applyRetiredDefaults() -> Bool {
        var changed = false
        for retired in Self.retiredDefaults {
            if let idx = snippets.firstIndex(where: { $0.name == retired.oldName && $0.template == retired.oldTemplate }) {
                snippets.remove(at: idx)
                changed = true
            }
        }
        return changed
    }

    /// Brings the saved list in line with `Snippet.defaults`: adds new
    /// defaults the user doesn't have yet, and refreshes any default the user
    /// hasn't edited since it was last synced. A default the user *has*
    /// edited — any of name/template/category/tags/cage/note no longer
    /// matches the snapshot from the last sync — is left alone entirely,
    /// field for field: their customization wins.
    private func syncDefaults() -> Bool {
        var changed = applyRetiredDefaults()
        if adoptStableIDs() { changed = true }
        for def in Snippet.defaults {
            if let idx = snippets.firstIndex(where: { $0.id == def.id }) {
                let untouched = snippets[idx].syncedName == snippets[idx].name
                    && snippets[idx].syncedTemplate == snippets[idx].template
                    && snippets[idx].syncedCategory == snippets[idx].category
                    && snippets[idx].syncedTags == snippets[idx].tags
                    && snippets[idx].syncedCage == snippets[idx].cage
                    && snippets[idx].syncedNote == snippets[idx].note
                if untouched, snippets[idx].name != def.name || !Self.matchesDefaultContent(snippets[idx], def) {
                    snippets[idx].name = def.name
                    snippets[idx].template = def.template
                    snippets[idx].category = def.category
                    snippets[idx].tags = def.tags
                    snippets[idx].cage = def.cage
                    snippets[idx].note = def.note
                    snippets[idx].syncedName = def.name
                    snippets[idx].syncedTemplate = def.template
                    snippets[idx].syncedCategory = def.category
                    snippets[idx].syncedTags = def.tags
                    snippets[idx].syncedCage = def.cage
                    snippets[idx].syncedNote = def.note
                    changed = true
                }
            } else {
                snippets.append(Self.markSynced(def))
                changed = true
            }
        }
        return changed
    }

    /// Overwrites the current list with the built-in defaults.
    func resetToDefaults() {
        snippets = Snippet.defaults.map(Self.markSynced)
        save()
    }

    /// Existing category names, sorted — used to suggest categories in the editor.
    var categories: [String] {
        Array(Set(snippets.map { $0.category })).sorted()
    }

    func save() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? encoder.encode(snippets) {
            try? data.write(to: url, options: .atomic)
        }
    }

    func upsert(_ snippet: Snippet) {
        if let idx = snippets.firstIndex(where: { $0.id == snippet.id }) {
            snippets[idx] = snippet
        } else {
            snippets.append(snippet)
        }
        save()
    }

    func delete(_ snippet: Snippet) {
        snippets.removeAll { $0.id == snippet.id }
        save()
    }
}
