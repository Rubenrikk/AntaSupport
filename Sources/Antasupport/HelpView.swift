import SwiftUI

/// In-app help sheet explaining how the app works: adding snippets,
/// placeholder syntax, running commands, the cage, and terminal panes.
/// Opened via the "?" toolbar button, ⌘? or Snippets ▸ Help & uitleg…
struct HelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundStyle(AppTheme.accent)
                Text("Help & uitleg")
                    .font(.title2.weight(.semibold))
                Spacer()
                Button("Sluiten") { dismiss() }
                    .keyboardShortcut(.cancelAction)
            }
            .padding(20)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HelpSection(title: "Een snippet toevoegen", icon: "plus.circle.fill") {
                        Text("Klik op de + rechtsboven in de sidebar (of ⌘N). Vul een naam, categorie en het command-template in. Tags en een notitie zijn optioneel — de notitie wordt getoond in het invulvenster vlak voordat je het commando uitvoert.")
                    }

                    HelpSection(title: "Placeholders in het template", icon: "curlybraces") {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Gebruik dubbele accolades voor velden die je vóór het uitvoeren invult:")
                            placeholderExample("{{naam}}", "een leeg tekstveld")
                            placeholderExample("{{naam:default}}", "een tekstveld met een standaardwaarde")
                            placeholderExample("{{naam:choice:optie1|optie2}}", "een keuzelijst")
                            placeholderExample("{{naam:flag:tekst}}", "een checkbox — voegt \"tekst\" toe als aangevinkt, anders niets")
                            Text("Bij het uitvoeren krijg je een venster met één veld per placeholder en een live preview van het uiteindelijke commando.")
                        }
                    }

                    HelpSection(title: "Een snippet uitvoeren", icon: "play.circle.fill") {
                        Text("Klik op een snippet in de sidebar, of gebruik ⌘K voor het commandopalet om er snel één te zoeken. Heeft het snippet geen placeholders, dan kun je in het invulvenster \"Niet meer vragen\" aanzetten zodat het voortaan direct uitvoert, zonder dat venster nog te tonen.")
                    }

                    HelpSection(title: "De cage", icon: "lock.shield.fill") {
                        Text("Een oranje CAGE-label betekent dat dat commando in de cage moet draaien; snippets zonder label juist niet. Of een snippet in de cage moet, stel je in bij het bewerken ervan (\"Moet in de cage draaien\").")
                    }

                    HelpSection(title: "Categorieën", icon: "folder.fill") {
                        Text("Snippets zijn gegroepeerd per categorie. Klik op een categorie-koptekst om die in of uit te klappen — handig zodra je veel categorieën hebt. Het aantal achter de naam telt hoeveel snippets erin zitten. Zoeken doorzoekt naam, commando, categorie en tags tegelijk.")
                    }

                    HelpSection(title: "Terminalschermen", icon: "terminal.fill") {
                        Text("Rechtsboven in het terminalpaneel open je met \"Nieuw scherm\" een lokaal terminalscherm (⌘T) of een serverscherm, dat via ssh2.nl inlogt op de opgegeven server. Klik op een scherm om het actief te maken — dat is waar snippets naartoe worden gestuurd. Scrollen vastgelopen na less/top/ncdu? Gebruik ⌘⇧R om dat te herstellen.")
                    }

                    HelpSection(title: "Bewerken & verwijderen", icon: "square.and.pencil") {
                        Text("Rechtsklik op een snippet voor Uitvoeren, Bewerken of Verwijderen. Verwijderen vraagt om bevestiging en kan niet ongedaan worden gemaakt.")
                    }
                }
                .padding(20)
            }
        }
        .frame(width: 520, height: 560)
    }

    private func placeholderExample(_ code: String, _ explanation: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(code)
                .font(.system(.caption, design: .monospaced).weight(.medium))
                .foregroundStyle(AppTheme.accent)
            Text("— \(explanation)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct HelpSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(AppTheme.accent)
            content
                .font(.callout)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
