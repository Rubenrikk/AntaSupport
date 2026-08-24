#!/usr/bin/env bash
#
# Builds Antasupport into a real, double-clickable macOS .app bundle.
# No Xcode project needed — only the Swift toolchain (ships with Xcode or the
# Command Line Tools). Run:  bash build-app.sh
#
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="Antasupport"
BUNDLE_ID="com.antasupport.app"
CONFIG="release"

echo "▸ Compiling ($CONFIG)…"
swift build -c "$CONFIG"

BIN_DIR="$(swift build -c "$CONFIG" --show-bin-path)"
BIN_PATH="$BIN_DIR/$APP_NAME"

APP_DIR="build/$APP_NAME.app"
MACOS_DIR="$APP_DIR/Contents/MacOS"
RES_DIR="$APP_DIR/Contents/Resources"

echo "▸ Assembling ${APP_DIR}…"
rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RES_DIR"
cp "$BIN_PATH" "$MACOS_DIR/$APP_NAME"

ICON_FILE=""
if [ -f "applet.icns" ]; then
    cp "applet.icns" "$RES_DIR/AppIcon.icns"
    # Strip resource-fork/quarantine metadata the source .icns carries —
    # codesign refuses to sign a bundle containing it ("... detritus not allowed").
    xattr -c "$RES_DIR/AppIcon.icns"
    ICON_FILE="<key>CFBundleIconFile</key><string>AppIcon</string>"
fi

cat > "$APP_DIR/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>$APP_NAME</string>
    <key>CFBundleDisplayName</key><string>$APP_NAME</string>
    <key>CFBundleIdentifier</key><string>$BUNDLE_ID</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleExecutable</key><string>$APP_NAME</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>LSMinimumSystemVersion</key><string>14.0</string>
    <key>NSHighResolutionCapable</key><true/>
    <key>NSPrincipalClass</key><string>NSApplication</string>
    $ICON_FILE
</dict>
</plist>
PLIST

echo "▸ Ad-hoc code signing…"
codesign --force --deep --sign - "$APP_DIR"

echo ""
echo "✅ Klaar: $APP_DIR"
echo "   Openen:            open \"$APP_DIR\""
echo "   Installeren:       sleep het .app-bestand naar /Applications"
echo ""
echo "   Eerste keer openen? Rechtsklik op de app → 'Open' (ad-hoc gesigneerd)."
