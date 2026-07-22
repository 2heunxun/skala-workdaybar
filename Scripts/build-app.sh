#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

APP_NAME="WorkdayBar"
BUILD_DIR="$ROOT_DIR/.build"
APP_BUNDLE="$ROOT_DIR/$APP_NAME.app"

echo "==> Building universal release binary"
swift build -c release --arch arm64 --arch x86_64

BIN_PATH="$BUILD_DIR/apple/Products/Release/$APP_NAME"
if [ ! -f "$BIN_PATH" ]; then
  # Fallback path used when only a single arch triple is produced.
  BIN_PATH="$BUILD_DIR/release/$APP_NAME"
fi

if [ ! -f "$BIN_PATH" ]; then
  echo "error: built binary not found (looked in .build/apple/Products/Release and .build/release)" >&2
  exit 1
fi

echo "==> Assembling $APP_NAME.app"
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$BIN_PATH" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
cp "$ROOT_DIR/Sources/$APP_NAME/Resources/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

# Resources live under Contents/Resources, the standard macOS bundle layout
# (required for a valid code signature -- SwiftPM's generated Bundle.module
# accessor would look at the .app's top level instead, which codesign
# rejects as "unsealed contents present in the bundle root". AppDelegate
# checks Bundle.main first, which resolves correctly here.)
cp "$ROOT_DIR/Sources/$APP_NAME/Resources/default-logo.png" "$APP_BUNDLE/Contents/Resources/default-logo.png"

echo "==> Ad-hoc signing (no Developer ID certificate)"
codesign --force --deep --sign - "$APP_BUNDLE"

echo "==> Done: $APP_BUNDLE"
