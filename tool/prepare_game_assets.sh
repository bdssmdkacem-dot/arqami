#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="${RUNNER_TEMP:-/tmp}/arqami-game-assets"
rm -rf "$TMP"
mkdir -p "$TMP/tiny-town" "$TMP/characters" "$TMP/ui" "$TMP/audio"
mkdir -p "$ROOT/assets/game/backgrounds" "$ROOT/assets/game/characters" "$ROOT/assets/game/ui" "$ROOT/assets/game/rewards" "$ROOT/assets/game/effects" "$ROOT/assets/game/sounds"

fetch_zip() {
  local url="$1" out="$2"
  curl -fsSL --retry 3 --retry-delay 2 "$url" -o "$out"
}

# Kenney assets are CC0. These OpenGameArt mirrors contain the Kenney packs.
fetch_zip "https://opengameart.org/sites/default/files/kenney_tiny-town.zip" "$TMP/tiny-town.zip"
unzip -q "$TMP/tiny-town.zip" -d "$TMP/tiny-town"
TILE="$(find "$TMP/tiny-town" -type f -iname 'tile_0001.png' | head -n 1)"
[[ -n "$TILE" ]] || { echo "Tiny Town tile_0001.png was not found" >&2; exit 1; }
cp "$TILE" "$ROOT/assets/game/backgrounds/tile_0001.png"

fetch_zip "https://opengameart.org/sites/default/files/Roguelike%20Characters%20pack.zip" "$TMP/characters.zip"
unzip -q "$TMP/characters.zip" -d "$TMP/characters"
CHARACTER="$(find "$TMP/characters" -type f -iname 'roguelikeChar_transparent.png' | head -n 1)"
[[ -n "$CHARACTER" ]] || { echo "Roguelike character spritesheet was not found" >&2; exit 1; }
cp "$CHARACTER" "$ROOT/assets/game/characters/roguelikeChar_transparent.png"

# UI Pack: select stable PNGs by semantic filename, rather than committing
# the complete pack to the application bundle.
fetch_zip "https://opengameart.org/sites/default/files/kenney_ui-pack.zip" "$TMP/ui.zip"
unzip -q "$TMP/ui.zip" -d "$TMP/ui"
UI_BUTTON="$(find "$TMP/ui" -type f -iname '*button*' -iname '*.png' | sort | head -n 1)"
UI_PANEL="$(find "$TMP/ui" -type f \( -iname '*panel*' -o -iname '*window*' \) -iname '*.png' | sort | head -n 1)"
[[ -n "$UI_BUTTON" ]] || { echo "Kenney UI button PNG was not found" >&2; exit 1; }
[[ -n "$UI_PANEL" ]] || { echo "Kenney UI panel/window PNG was not found" >&2; exit 1; }
cp "$UI_BUTTON" "$ROOT/assets/game/ui/kenney_button.png"
cp "$UI_PANEL" "$ROOT/assets/game/ui/kenney_panel.png"

# UI Audio: pick short click/confirm assets when present. The build fails if
# the selected pack is unexpectedly missing, preventing a silent fallback.
fetch_zip "https://opengameart.org/sites/default/files/kenney_ui-audio.zip" "$TMP/audio.zip"
unzip -q "$TMP/audio.zip" -d "$TMP/audio"
CLICK="$(find "$TMP/audio" -type f \( -iname '*click*' -o -iname '*tap*' \) \( -iname '*.ogg' -o -iname '*.wav' \) | sort | head -n 1)"
CONFIRM="$(find "$TMP/audio" -type f \( -iname '*confirm*' -o -iname '*success*' -o -iname '*select*' \) \( -iname '*.ogg' -o -iname '*.wav' \) | sort | head -n 1)"
[[ -n "$CLICK" ]] || { echo "Kenney UI click audio was not found" >&2; exit 1; }
[[ -n "$CONFIRM" ]] || CONFIRM="$CLICK"
cp "$CLICK" "$ROOT/assets/game/sounds/tap.wav"
cp "$CONFIRM" "$ROOT/assets/game/sounds/success.wav"

# A tiny generated JSON is intentionally avoided: only real CC0 binaries are
# copied into the Flutter asset tree.
printf 'Prepared Arqami game assets:\n'
printf '  %s\n' "$ROOT/assets/game/backgrounds/tile_0001.png"
printf '  %s\n' "$ROOT/assets/game/characters/roguelikeChar_transparent.png"
printf '  %s\n' "$ROOT/assets/game/ui/kenney_button.png"
printf '  %s\n' "$ROOT/assets/game/ui/kenney_panel.png"
printf '  %s\n' "$ROOT/assets/game/sounds/tap.wav"
printf '  %s\n' "$ROOT/assets/game/sounds/success.wav"
