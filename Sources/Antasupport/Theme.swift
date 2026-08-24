import SwiftUI

/// Shared visual constants so the app reads as one design instead of a pile
/// of default SwiftUI controls.
enum AppTheme {
    static let accent = Color(red: 0.36, green: 0.42, blue: 0.98)
}

extension String {
    /// SF Symbol used as a category icon in the sidebar. Covers every
    /// category in `Snippet.categoryOrder` plus a few generic fallbacks for
    /// custom user categories; anything unmatched gets a plain terminal icon.
    var categorySymbol: String {
        switch self.lowercased() {
        case "inloggen": return "key.fill"
        case "afsluiten & deblokkeren": return "network.slash"
        case "malware & spam scannen": return "ladybug.fill"
        case "wordpress verify-checksums": return "checkmark.seal.fill"
        case "mail": return "envelope.fill"
        case "schijfruimte": return "internaldrive.fill"
        case "logs": return "doc.text.fill"
        case "firewall": return "flame.fill"
        case "hostingpakket": return "cube.box.fill"
        case "backup transfer": return "externaldrive.fill.badge.timemachine"
        case "dns": return "network"
        case "snapshots": return "camera.fill"
        case "bestandsrechten": return "lock.doc.fill"
        case "database": return "cylinder.fill"
        case "bot-traffic": return "ant.fill"
        case "screen & tmux": return "square.split.2x2.fill"
        case "reseller": return "person.2.fill"
        case "redis": return "bolt.fill"
        case "nextcloud": return "cloud.fill"
        case "systeem", "system": return "gearshape.fill"
        case "git": return "arrow.triangle.branch"
        case "docker": return "shippingbox.fill"
        case "netwerk", "network": return "network"
        case "bestanden", "files": return "folder.fill"
        case "web": return "globe"
        default: return "terminal.fill"
        }
    }
}

/// Small orange pill marking a snippet that must run in the cage.
///
/// Uses a solid (non-tinted) fill rather than a low-opacity one: opacity over
/// the adaptive window background measured under ~1.8:1 contrast in light
/// mode (orange text on near-white), well short of WCAG's 4.5:1 minimum for
/// a badge that flags operationally risky commands. A fixed dark-orange fill
/// with white text holds ~5:1 in both appearances since it no longer blends
/// with the surrounding background color.
struct CageBadge: View {
    var body: some View {
        Text("cage")
            .font(.system(size: 9, weight: .bold))
            .textCase(.uppercase)
            .padding(.horizontal, 5)
            .padding(.vertical, 1.5)
            .background(Capsule().fill(Color(red: 0.72, green: 0.30, blue: 0.0)))
            .foregroundStyle(.white)
            .accessibilityLabel("cage")
    }
}
