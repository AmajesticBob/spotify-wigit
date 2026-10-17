#!/bin/bash
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "============================================================"
echo "Starting Widgit & Spotify Bridge Verification"
echo "============================================================"

# Ensure cache directories exist
mkdir -p .cache/modules .build/DerivedData

export SWIFT_MODULE_CACHE_PATH="$PROJECT_ROOT/.cache/modules"
export CLANG_MODULE_CACHE_PATH="$PROJECT_ROOT/.cache/modules"

echo ""
echo "[Step 1/6] Building Swift package (BridgeKit + Harness)..."
swift build --disable-sandbox
echo "✓ Swift package build passed."

echo ""
echo "[Step 2/6] Running Swift XCTest suite..."
dot_clean .build/out/Products/Debug/SpotifyBridgeKitTests.xctest 2>/dev/null || true
xattr -cr .build/out/Products/Debug/SpotifyBridgeKitTests.xctest 2>/dev/null || true
/usr/bin/codesign --force --sign - --timestamp=none --generate-entitlement-der .build/out/Products/Debug/SpotifyBridgeKitTests.xctest 2>/dev/null || true
swift test --disable-sandbox --skip-build
echo "✓ Swift XCTest suite passed."

echo ""
echo "[Step 3/6] Running Spotify Harness verification suite..."
swift run --disable-sandbox SpotifyHarness --verify
echo "✓ Verification suite passed."

echo ""
echo "[Step 4/6] Testing Spotify Harness status query..."
swift run --disable-sandbox SpotifyHarness --status
echo "✓ Status query passed."

echo ""
echo "[Step 5/6] Testing Spotify Harness JSON output..."
swift run --disable-sandbox SpotifyHarness --json | grep '"status"'
echo "✓ JSON output formatted correctly."

echo ""
echo "[Step 6/6] Building macOS Host App & Widget Extension via xcodebuild..."
python3 scripts/generate_xcodeproj.py
xcodebuild -project SpotifyWidget.xcodeproj \
           -scheme SpotifyWidgetApp \
           -derivedDataPath .build/DerivedData \
           CODE_SIGNING_ALLOWED=NO \
           build

APP_PATH=".build/DerivedData/Build/Products/Debug/Widgit.app"
EXT_PATH="$APP_PATH/Contents/PlugIns/SpotifyWidgetExtension.appex"

if [ -d "$APP_PATH" ] && [ -d "$EXT_PATH" ]; then
    echo "✓ Widgit.app successfully built with embedded SpotifyWidgetExtension.appex"
else
    echo "✗ Error: Expected app or extension bundle was not generated"
    exit 1
fi

echo ""
echo "============================================================"
echo "ALL BUILD AND VERIFICATION CHECKS COMPLETED SUCCESSFULLY!"
echo "============================================================"
