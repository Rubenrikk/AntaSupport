import Foundation

/// A reusable command template. Placeholders use `{{name}}` or `{{name:default}}`.
/// `category` groups snippets in the sidebar; `cage` marks whether the snippet
/// must run in the cage.
struct Snippet: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var template: String
    var category: String = "General"
    var cage: Bool = false
    var tags: [String] = []
    /// Optional tip shown in the fill-in popup, e.g. a keyboard shortcut for the tool being run.
    var note: String = ""
    /// When true and the template has no placeholders, running the snippet
    /// skips the fill-in popup (there'd be nothing to fill in or preview
    /// anyway) and executes it immediately.
    var skipConfirmation: Bool = false
    /// Snapshot of `name`/`template`/`category`/`tags`/`cage`/`note` as of the
    /// last time `SnippetStore` auto-synced this row from `Snippet.defaults`.
    /// `nil` for snippets the user created themselves. Used to tell "still
    /// exactly what we last installed" (safe to silently update to a newer
    /// default) from "the user has edited this since" (their edit wins) —
    /// see `SnippetStore.syncDefaults()`.
    var syncedName: String? = nil
    var syncedTemplate: String? = nil
    var syncedCategory: String? = nil
    var syncedTags: [String]? = nil
    var syncedCage: Bool? = nil
    var syncedNote: String? = nil

    init(id: UUID = UUID(),
         name: String,
         template: String,
         category: String = "General",
         cage: Bool = false,
         tags: [String] = [],
         note: String = "",
         skipConfirmation: Bool = false,
         syncedName: String? = nil,
         syncedTemplate: String? = nil,
         syncedCategory: String? = nil,
         syncedTags: [String]? = nil,
         syncedCage: Bool? = nil,
         syncedNote: String? = nil) {
        self.id = id
        self.name = name
        self.template = template
        self.category = category
        self.cage = cage
        self.tags = tags
        self.note = note
        self.skipConfirmation = skipConfirmation
        self.syncedName = syncedName
        self.syncedTemplate = syncedTemplate
        self.syncedCategory = syncedCategory
        self.syncedTags = syncedTags
        self.syncedCage = syncedCage
        self.syncedNote = syncedNote
    }

    // Resilient decoding so older saved files (missing any field added since) still load.
    enum CodingKeys: String, CodingKey {
        case id, name, template, category, cage, tags, note, skipConfirmation
        case syncedName, syncedTemplate, syncedCategory, syncedTags, syncedCage, syncedNote
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try c.decodeIfPresent(String.self, forKey: .name) ?? ""
        template = try c.decodeIfPresent(String.self, forKey: .template) ?? ""
        category = try c.decodeIfPresent(String.self, forKey: .category) ?? "General"
        cage = try c.decodeIfPresent(Bool.self, forKey: .cage) ?? false
        tags = try c.decodeIfPresent([String].self, forKey: .tags) ?? []
        note = try c.decodeIfPresent(String.self, forKey: .note) ?? ""
        skipConfirmation = try c.decodeIfPresent(Bool.self, forKey: .skipConfirmation) ?? false
        syncedName = try c.decodeIfPresent(String.self, forKey: .syncedName)
        syncedTemplate = try c.decodeIfPresent(String.self, forKey: .syncedTemplate)
        syncedCategory = try c.decodeIfPresent(String.self, forKey: .syncedCategory)
        syncedTags = try c.decodeIfPresent([String].self, forKey: .syncedTags)
        syncedCage = try c.decodeIfPresent(Bool.self, forKey: .syncedCage)
        syncedNote = try c.decodeIfPresent(String.self, forKey: .syncedNote)
    }
}
