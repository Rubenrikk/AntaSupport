import Foundation

/// Remembers the last value typed into each named placeholder (e.g. `debuser`,
/// `domein`, `server`), so filling in one snippet pre-fills the same field the
/// next time any snippet uses a placeholder with that name.
final class RecentValuesStore: ObservableObject {
    private static let key = "recentPlaceholderValues"

    @Published private var values: [String: String]

    init() {
        values = UserDefaults.standard.dictionary(forKey: Self.key) as? [String: String] ?? [:]
    }

    func value(for name: String) -> String? {
        values[name]
    }

    func remember(_ newValues: [String: String]) {
        for (name, value) in newValues where !value.isEmpty {
            values[name] = value
        }
        UserDefaults.standard.set(values, forKey: Self.key)
    }
}
