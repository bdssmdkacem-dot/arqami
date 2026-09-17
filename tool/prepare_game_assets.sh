#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="${RUNNER_TEMP:-/tmp}/arqami-game-assets"
rm -rf "$TMP"
mkdir -p "$TMP/tiny-town" "$TMP/characters"
mkdir -p "$ROOT/assets/game/backgrounds" "$ROOT/assets/game/characters"

# Kenney assets are CC0. The OpenGameArt mirrors below are the Kenney-uploaded
# distribution files; we extract only the files actually used by Arqami.
curl -fsSL --retry 3 \
  "https://opengameart.org/sites/default/files/kenney_tiny-town.zip" \
  -o "$TMP/tiny-town.zip"
unzip -q "$TMP/tiny-town.zip" -d "$TMP/tiny-town"

TILE="$(find "$TMP/tiny-town" -type f -iname 'tile_0001.png' | head -n 1)"
if [[ -z "$TILE" ]]; then
  echo "Tiny Town tile_0001.png was not found" >&2
  exit 1
fi
cp "$TILE" "$ROOT/assets/game/backgrounds/tile_0001.png"

curl -fsSL --retry 3 \
  "https://opengameart.org/sites/default/files/Roguelike%20Characters%20pack.zip" \
  -o "$TMP/characters.zip"
unzip -q "$TMP/characters.zip" -d "$TMP/characters"

CHARACTER="$(find "$TMP/characters" -type f -iname 'roguelikeChar_transparent.png' | head -n 1)"
if [[ -z "$CHARACTER" ]]; then
  echo "Roguelike character spritesheet was not found" >&2
  exit 1
fi
cp "$CHARACTER" "$ROOT/assets/game/characters/roguelikeChar_transparent.png"

printf 'Prepared Arqami game assets:\n'
printf '  %s\n' "$ROOT/assets/game/backgrounds/tile_0001.png"
printf '  %s\n' "$ROOT/assets/game/characters/roguelikeChar_transparent.png"
