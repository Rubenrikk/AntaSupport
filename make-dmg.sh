#!/usr/bin/env bash
#
# Packages build/Antasupport.app into a distributable .dmg with a
# drag-to-Applications shortcut — the classic macOS installer look.
# Run:  bash make-dmg.sh
#
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="Antasupport"
APP_PATH="build/$APP_NAME.app"
DMG_PATH="build/$APP_NAME.dmg"
STAGING="build/.dmg-staging"

echo "▸ (Opnieuw) bouwen…"
bash build-app.sh

echo "▸ Dmg-inhoud voorbereiden…"
rm -rf "$STAGING" "$DMG_PATH"
mkdir -p "$STAGING"
cp -R "$APP_PATH" "$STAGING/"
ln -s /Applications "$STAGING/Applications"
cat > "$STAGING/Lees mij.txt" <<'EOF'
Antasupport openen — "kan niet gescand worden op malware"?
============================================================

Deze app is alleen ad-hoc/lokaal gesigneerd (geen Apple Developer ID,
niet genotariseerd). Na het kopiëren/versturen zet macOS er een
quarantine-vlag op, waardoor Gatekeeper de eerste keer een waarschuwing
toont ("kan niet worden geopend omdat Apple de app niet kan controleren
op malware" of iets vergelijkbaars). Zo los je dat op:

1. Sleep Antasupport.app naar de Applications-snelkoppeling in dit venster.
2. Open Finder → Applications, en klik met de RECHTERMUISKNOP
   (of ctrl+klik) op Antasupport → kies "Open". Bevestig in het
   pop-upvenster nogmaals met "Open". Dit hoeft maar één keer.
3. Werkt dat niet? Ga naar Systeeminstellingen → Privacy & Beveiliging,
   scroll naar beneden — daar staat een melding over de geblokkeerde
   app met een knop "Open toch".
4. Als laatste redmiddel, via Terminal:
   xattr -cr /Applications/Antasupport.app
   en daarna gewoon dubbelklikken.

Na de eerste keer opent de app voortaan gewoon via dubbelklik.
EOF

echo "▸ Disk image bouwen…"
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGING" -ov -format UDZO "$DMG_PATH"

rm -rf "$STAGING"

echo ""
echo "✅ Klaar: $DMG_PATH"
echo "   Stuur dit ene bestand naar je collega. Bij openen zien ze het app-icoon"
echo "   naast een Applications-snelkoppeling — slepen erop = installeren."
echo ""
echo "   Let op: de app is alleen ad-hoc/lokaal gesigneerd (geen Apple Developer ID,"
echo "   niet genotariseerd). Na het kopiëren/versturen zet macOS er een quarantine-"
echo "   vlag op, dus je collega moet de EERSTE keer rechtsklikken → 'Open' om de"
echo "   Gatekeeper-waarschuwing te negeren — daarna werkt het gewoon via dubbelklik."
