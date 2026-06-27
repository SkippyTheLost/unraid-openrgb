#!/bin/bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
VERSION=${VERSION:-2026.06.28.9}
APPIMAGE_URL=${APPIMAGE_URL:-https://codeberg.org/OpenRGB/OpenRGB/releases/download/release_candidate_1.0rc2/OpenRGB_1.0rc2_x86_64_0fca93e.AppImage}
LOGO_URL=${LOGO_URL:-https://raw.githubusercontent.com/CalcProgrammer1/OpenRGB/master/qt/org.openrgb.OpenRGB.png}
STAGE="$ROOT/.build/openrgb"
DIST="$ROOT/dist"
APPIMAGE="$ROOT/.build/openrgb.AppImage"

grep -q "<!ENTITY version   \"$VERSION\">" "$ROOT/openrgb.plg" || {
  echo "VERSION $VERSION does not match openrgb.plg"
  exit 1
}

rm -rf "$STAGE"
mkdir -p "$STAGE/images" "$DIST" "$(dirname "$APPIMAGE")"
cp -a "$ROOT/source/usr/local/emhttp/plugins/openrgb/." "$STAGE/"

curl -fL --retry 3 --connect-timeout 20 -o "$APPIMAGE" "$APPIMAGE_URL"
chmod 755 "$APPIMAGE"
(
  cd "$ROOT/.build"
  rm -rf squashfs-root
  "$APPIMAGE" --appimage-extract >/dev/null
)
mv "$ROOT/.build/squashfs-root" "$STAGE/runtime"

curl -fL --retry 3 --connect-timeout 20 -o "$STAGE/images/openrgb.png" "$LOGO_URL"
cp "$STAGE/images/openrgb.png" "$STAGE/openrgb.png"
chmod 755 "$STAGE/runtime/AppRun" "$STAGE/scripts/openrgbctl" "$STAGE/event/started"
printf '%s\n' "$VERSION" > "$STAGE/VERSION"

tar -C "$ROOT/.build" -czf "$DIST/openrgb-$VERSION.tgz" openrgb
md5sum "$DIST/openrgb-$VERSION.tgz"
