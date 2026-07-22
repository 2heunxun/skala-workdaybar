#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

APP_NAME="WorkdayBar"
APP_BUNDLE="$ROOT_DIR/$APP_NAME.app"
DMG_PATH="$ROOT_DIR/$APP_NAME.dmg"
STAGING_DIR="$ROOT_DIR/.dmg-staging"

if [ ! -d "$APP_BUNDLE" ]; then
  echo "error: $APP_BUNDLE not found. Run Scripts/build-app.sh first." >&2
  exit 1
fi

echo "==> Staging DMG contents"
rm -rf "$STAGING_DIR" "$DMG_PATH"
mkdir -p "$STAGING_DIR"
cp -R "$APP_BUNDLE" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

echo "==> Creating $DMG_PATH"
hdiutil create -volname "$APP_NAME" \
  -srcfolder "$STAGING_DIR" \
  -ov -format UDZO \
  "$DMG_PATH"

rm -rf "$STAGING_DIR"

echo "==> Done: $DMG_PATH"
