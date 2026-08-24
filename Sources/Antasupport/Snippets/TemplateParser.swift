import Foundation

/// One selectable entry in a `{{name:choice:...}}` field: what's shown
/// (`label`) versus what actually gets substituted into the command
/// (`value`). Plain segments (no `=`) use the same text for both.
struct ChoiceOption: Hashable {
    let label: String
    let value: String
}

/// One `{{name}}` / `{{name:default}}` field found in a template.
/// `{{name:choice:opt1|opt2|...}}` produces a fixed selection instead of a
/// free-text field, with the first option as the default. A segment can be
/// `label=value` (e.g. `Globaal=`) to show a friendlier name than the literal
/// value substituted into the command.
/// `{{name:flag:text}}` produces a checkbox instead of a field: unchecked by
/// default, substituting `text` when checked and an empty string otherwise —
/// for optional flags like `--skip-plugins` that only apply in edge cases.
struct Placeholder: Identifiable, Hashable {
    let name: String
    let defaultValue: String
    let options: [ChoiceOption]
    var isFlag: Bool = false
    var id: String { name }
}

enum TemplateParser {
    // {{ name }}  or  {{ name : default }}
    private static let pattern = #"\{\{\s*([^}:]+?)\s*(?::\s*([^}]*?)\s*)?\}\}"#

    /// Unique placeholders in the order they first appear.
    static func placeholders(in template: String) -> [Placeholder] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let ns = template as NSString
        let matches = regex.matches(in: template, range: NSRange(location: 0, length: ns.length))

        var seen = Set<String>()
        var result: [Placeholder] = []
        for m in matches {
            let name = ns.substring(with: m.range(at: 1)).trimmingCharacters(in: .whitespaces)
            guard !name.isEmpty, !seen.contains(name) else { continue }
            seen.insert(name)

            var def = ""
            if m.range(at: 2).location != NSNotFound {
                def = ns.substring(with: m.range(at: 2))
            }

            var options: [ChoiceOption] = []
            var isFlag = false
            if def.hasPrefix("choice:") {
                // split(separator:) drops empty trailing segments, so an
                // empty last option (e.g. "choice:@ns1|@ns2|") would vanish;
                // splitting on indices keeps it.
                let raw = def.dropFirst("choice:".count)
                options = raw.split(separator: "|", omittingEmptySubsequences: false).map { segment in
                    if let eq = segment.firstIndex(of: "=") {
                        return ChoiceOption(label: String(segment[segment.startIndex..<eq]),
                                             value: String(segment[segment.index(after: eq)...]))
                    }
                    let s = String(segment)
                    return ChoiceOption(label: s, value: s)
                }
                def = options.first?.value ?? ""
            } else if def.hasPrefix("flag:") {
                isFlag = true
                def = String(def.dropFirst("flag:".count))
            }
            result.append(Placeholder(name: name, defaultValue: def, options: options, isFlag: isFlag))
        }
        return result
    }

    /// Substitutes every placeholder with the supplied value (empty string if missing).
    static func fill(_ template: String, with values: [String: String]) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return template }
        let ns = template as NSString
        let matches = regex.matches(in: template, range: NSRange(location: 0, length: ns.length))

        let out = NSMutableString(string: template)
        // Replace back-to-front so earlier ranges stay valid.
        for m in matches.reversed() {
            let name = ns.substring(with: m.range(at: 1)).trimmingCharacters(in: .whitespaces)
            let value = values[name] ?? ""
            out.replaceCharacters(in: m.range(at: 0), with: value)
        }
        return out as String
    }
}
