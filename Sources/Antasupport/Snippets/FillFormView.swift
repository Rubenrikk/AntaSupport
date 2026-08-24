import SwiftUI

/// Presents one text field per placeholder, shows a live preview of the final
/// command, and runs it on submit.
struct FillFormView: View {
    let snippet: Snippet
    var onRun: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var recentValues: RecentValuesStore
    @EnvironmentObject private var store: SnippetStore
    @State private var values: [String: String] = [:]
    @State private var skipConfirmation = false
    @FocusState private var focusedField: String?

    private var placeholders: [Placeholder] {
        TemplateParser.placeholders(in: snippet.template)
    }
    private var preview: String {
        TemplateParser.fill(snippet.template, with: values)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "terminal.fill")
                    .foregroundStyle(AppTheme.accent)
                Text(snippet.name.isEmpty ? "Snippet uitvoeren" : snippet.name)
                    .font(.title3.weight(.semibold))
                if snippet.cage {
                    CageBadge()
                        .help("Deze moet in de cage draaien")
                }
            }

            if !snippet.note.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                        .font(.callout)
                    Text(snippet.note)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.yellow.opacity(0.1)))
            }

            if placeholders.isEmpty {
                Text("Geen velden om in te vullen — klaar om te draaien.")
                    .foregroundStyle(.secondary)
                Toggle("Niet meer vragen bij dit snippet", isOn: $skipConfirmation)
                    .help("Voert het commando voortaan direct uit, zonder dit venster nog te tonen. Terug te zetten via de snippet-editor.")
            } else {
                Form {
                    ForEach(placeholders) { p in
                        let binding = Binding(
                            get: { values[p.name] ?? p.defaultValue },
                            set: { values[p.name] = $0 }
                        )
                        if p.isFlag {
                            let flagBinding = Binding(
                                get: { (values[p.name] ?? "") == p.defaultValue },
                                set: { values[p.name] = $0 ? p.defaultValue : "" }
                            )
                            Toggle(p.name, isOn: flagBinding)
                        } else if p.options.isEmpty {
                            TextField(p.name, text: binding)
                                .focused($focusedField, equals: p.name)
                        } else {
                            Picker(p.name, selection: binding) {
                                ForEach(p.options, id: \.value) { option in
                                    Text(option.label).tag(option.value)
                                }
                            }
                        }
                    }
                }
            }

            GroupBox {
                Text(preview.isEmpty ? " " : preview)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } label: {
                Label("Preview", systemImage: "eye")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            HStack {
                Spacer()
                Button("Annuleren") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Uitvoeren") {
                    recentValues.remember(values)
                    if skipConfirmation != snippet.skipConfirmation {
                        var updated = snippet
                        updated.skipConfirmation = skipConfirmation
                        store.upsert(updated)
                    }
                    onRun(preview)
                }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 460)
        .onAppear {
            skipConfirmation = snippet.skipConfirmation
            for p in placeholders where values[p.name] == nil {
                if p.isFlag {
                    // Flags are opt-in safety toggles (e.g. --skip-plugins) —
                    // always start unchecked, never restore a remembered value.
                    values[p.name] = ""
                } else if let remembered = recentValues.value(for: p.name),
                   p.options.isEmpty || p.options.contains(where: { $0.value == remembered }) {
                    // Prefer the last value typed anywhere for a field with this
                    // name, but only if it's a valid choice for a picker field.
                    values[p.name] = remembered
                } else {
                    values[p.name] = p.defaultValue
                }
            }
            // Focus the first free-text field so a keyboard-driven user can
            // start typing the moment the sheet appears, without first
            // having to click into it.
            focusedField = placeholders.first(where: { $0.options.isEmpty && !$0.isFlag })?.name
        }
    }
}
