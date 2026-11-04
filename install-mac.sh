#!/bin/bash
# Instalador de SG-Client para macOS SIN avisos de seguridad.
#
# Por qué no salta Gatekeeper: macOS solo marca como "descargado de internet"
# (cuarentena) lo que baja un NAVEGADOR. Lo que baja `curl` no lleva la marca,
# así que la app abre directo sin el "no se puede verificar al desarrollador".
#
# Uso (en la app Terminal):
#   curl -fsSL https://raw.githubusercontent.com/MinecraftFacricModsSG/SG-Client-Releases/main/install-mac.sh | bash
# (subí este archivo a la raíz del repo SG-Client-Releases)

set -euo pipefail

REPO="MinecraftFacricModsSG/SG-Client-Releases"

# hw.optional.arm64 = 1 en Apple Silicon, incluso si Terminal corre bajo Rosetta
if [ "$(sysctl -n hw.optional.arm64 2>/dev/null || echo 0)" = "1" ]; then
  FILE="SG-Client-arm64.zip"
else
  FILE="SG-Client-x64.zip"
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Descargando SG-Client ($FILE)…"
curl -fL --progress-bar "https://github.com/$REPO/releases/latest/download/$FILE" -o "$TMP/$FILE"

ditto -x -k "$TMP/$FILE" "$TMP/out"
APP="$(ls -d "$TMP"/out/*.app | head -n1)"
[ -d "$APP" ] || { echo "El zip no trae ninguna .app"; exit 1; }

DEST_DIR="/Applications"
[ -w "$DEST_DIR" ] || { DEST_DIR="$HOME/Applications"; mkdir -p "$DEST_DIR"; }
DEST="$DEST_DIR/$(basename "$APP")"

pkill -x SG-Client 2>/dev/null || true
rm -rf "$DEST"
ditto "$APP" "$DEST"
xattr -cr "$DEST" 2>/dev/null || true

echo "Listo: $DEST"
open "$DEST"
