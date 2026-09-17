#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="${RUNNER_TEMP:-/tmp}/arqami-game-assets"
rm -rf "$TMP"
mkdir -p "$TMP/tiny-town" "$TMP/characters" "$TMP/ui" "$TMP/icons" "$TMP/audio"
mkdir -p "$ROOT/assets/game/backgrounds" "$ROOT/assets/game/characters" "$ROOT/assets/game/ui" "$ROOT/assets/game/numbers" "$ROOT/assets/game/rewards" "$ROOT/assets/game/effects" "$ROOT/assets/game/sounds"

fetch_zip() {
  local url="$1" out="$2"
  curl -fsSL --retry 3 --retry-delay 2 "$url" -o "$out"
}

first_match() {
  find "$1" -type f ${2:-} -print -quit
}

# All selected packs are Kenney CC0 assets.
fetch_zip "https://opengameart.org/sites/default/files/kenney_tiny-town.zip" "$TMP/tiny-town.zip"
unzip -q "$TMP/tiny-town.zip" -d "$TMP/tiny-town"
TILE="$(find "$TMP/tiny-town" -type f -iname 'tile_0001.png' -print -quit)"
[[ -n "$TILE" ]] || { echo "Tiny Town tile_0001.png was not found" >&2; exit 1; }
cp "$TILE" "$ROOT/assets/game/backgrounds/tile_0001.png"

fetch_zip "https://opengameart.org/sites/default/files/Roguelike%20Characters%20pack.zip" "$TMP/characters.zip"
unzip -q "$TMP/characters.zip" -d "$TMP/characters"
CHARACTER="$(find "$TMP/characters" -type f -iname 'roguelikeChar_transparent.png' -print -quit)"
[[ -n "$CHARACTER" ]] || { echo "Roguelike character spritesheet was not found" >&2; exit 1; }
cp "$CHARACTER" "$ROOT/assets/game/characters/roguelikeChar_transparent.png"

fetch_zip "https://opengameart.org/sites/default/files/kenney_ui-pack.zip" "$TMP/ui.zip"
unzip -q "$TMP/ui.zip" -d "$TMP/ui"
UI_BUTTON="$(find "$TMP/ui" -type f -iname '*button*' -iname '*.png' -print -quit)"
[[ -n "$UI_BUTTON" ]] || { echo "Kenney UI button PNG was not found" >&2; exit 1; }

# The current UI Pack does not guarantee semantic panel/window filenames.
# Prefer those names, then use a deterministic UI sprite as the panel texture.
UI_PANEL="$(find "$TMP/ui" -type f -iname '*panel*' -iname '*.png' -print -quit)"
if [[ -z "$UI_PANEL" ]]; then
  UI_PANEL="$(find "$TMP/ui" -type f -iname '*window*' -iname '*.png' -print -quit)"
fi
if [[ -z "$UI_PANEL" ]]; then
  UI_PANEL="$(find "$TMP/ui" -type f -iname '*.png' -print | while IFS= read -r f; do
    case "$(basename "$f")" in
      *bar*|*square*|*button*) printf '%s\n' "$f"; break ;;
    esac
  done)"
fi
if [[ -z "$UI_PANEL" ]]; then
  UI_PANEL="$(find "$TMP/ui" -type f -iname '*.png' -print -quit)"
fi
[[ -n "$UI_PANEL" ]] || { echo "Kenney UI sprite for panel background was not found" >&2; exit 1; }
cp "$UI_BUTTON" "$ROOT/assets/game/ui/kenney_button.png"
cp "$UI_PANEL" "$ROOT/assets/game/ui/kenney_panel.png"

# Kenney Game Icons includes star, trophy, lock and checkmark icons.
fetch_zip "https://opengameart.org/sites/default/files/Kenney_gameIcons.zip" "$TMP/icons.zip"
unzip -q "$TMP/icons.zip" -d "$TMP/icons"
copy_icon() {
  local name="$1" target="$2"
  local found
  found="$(find "$TMP/icons" -type f -iname "${name}*.png" -print -quit)"
  if [[ -z "$found" ]]; then
    found="$(find "$TMP/icons" -type f -iname "*${name}*.png" -print -quit)"
  fi
  [[ -n "$found" ]] || { echo "Kenney icon matching ${name}*.png was not found" >&2; exit 1; }
  cp "$found" "$target"
}
copy_icon "star" "$ROOT/assets/game/rewards/star.png"
copy_icon "trophy" "$ROOT/assets/game/rewards/trophy.png"
copy_icon "lock" "$ROOT/assets/game/rewards/lock.png"
copy_icon "checkmark" "$ROOT/assets/game/rewards/checkmark.png"

# Kenney UI Audio is CC0. Use the maintained public mirror because it exposes
# the original UI pack as individual WAV files, which is deterministic in CI.
fetch_zip "https://github.com/Calinou/kenney-ui-audio/archive/refs/heads/master.zip" "$TMP/audio.zip"
unzip -q "$TMP/audio.zip" -d "$TMP/audio"
CLICK="$(find "$TMP/audio" -type f -iname '*.wav' -print -quit)"
[[ -n "$CLICK" ]] || { echo "Kenney UI Audio WAV was not found" >&2; exit 1; }
cp "$CLICK" "$ROOT/assets/game/sounds/tap.wav"
SECOND="$(find "$TMP/audio" -type f -iname '*.wav' -print | sed -n '2p')"
[[ -n "$SECOND" ]] && cp "$SECOND" "$ROOT/assets/game/sounds/success.wav" || cp "$CLICK" "$ROOT/assets/game/sounds/success.wav"

printf 'Prepared Arqami game assets:\n'
find "$ROOT/assets/game" -type f -print | sort
