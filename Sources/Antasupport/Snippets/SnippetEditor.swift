import SwiftUI

/// Create or edit a snippet.
struct SnippetEditor: View {
    @EnvironmentObject var store: SnippetStore
    @State private var draft: Snippet
    @State private var tagsText: String
    var onSave: (Snippet) -> Void

    @Environment(\.dismiss) private var dismiss

    init(snippet: Snippet, onSave: @escaping (Snippet) -> Void) {
        _draft = State(initialValue: snippet)
        _tagsText = State(initialValue: snippet.tags.joined(separator: ", "))
        self.onSave = onSave
    }

    private var isValid: Bool {
        !draft.name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !draft.template.trimmingCharacters(in: .whitespaces).isEmpty &&
        !draft.category.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "square.and.pencil")
                    .foregroundStyle(AppTheme.accent)
                Text(draft.name.isEmpty ? "Nieuw snippet" : "Snippet bewerken")
                    .font(.title3.weight(.semibold))
            }

            Form {
                TextField("Naam", text: $draft.name)

                HStack {
                    TextField("Categorie", text: $draft.category)
                    if !store.categories.isEmpty {
                        Menu {
                            ForEach(store.categories, id: \.self) { cat in
                                Button(cat) { draft.category = cat }
                            }
                        } label: {
                            Image(systemName: "chevron.down")
                        }
                        .menuStyle(.borderlessButton)
                        .fixedSize()
                        .help("Bestaande categorie kiezen")
                    }
                }

                TextField("Tags (komma-gescheiden)", text: $tagsText)

                TextField("Notitie (optioneel, getoond in de invulpop-up)", text: $draft.note)

                Toggle("Moet in de cage draaien", isOn: $draft.cage)

                if TemplateParser.placeholders(in: draft.template).isEmpty {
                    Toggle("Niet meer vragen bij dit snippet", isOn: $draft.skipConfirmation)
                        .help("Voert het commando voortaan direct uit vanuit de lijst, zonder eerst een venster te tonen.")
                }
            }

            Text("Commando-template")
                .font(.subheadline)
            TextEditor(text: $draft.template)
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 120)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(.secondary.opacity(0.3)))

            Text("Gebruik {{naam}}, {{naam:default}}, {{naam:choice:optie1|optie2}} of {{naam:flag:tekst}} (checkbox) voor waarden die je invult vóór het uitvoeren.")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Spacer()
                Button("Annuleren") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Bewaren") {
                    draft.tags = tagsText
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespaces) }
                        .filter { !$0.isEmpty }
                    onSave(draft)
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .disabled(!isValid)
            }
        }
        .padding(20)
        .frame(width: 520)
    }
}
