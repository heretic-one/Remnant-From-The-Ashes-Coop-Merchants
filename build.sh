#!/usr/bin/env bash
# Builds build/CoopMerchants_P.pak and build/CoopMerchants.zip from the event trees of your own game install.
# Needs: python3, repak, tools/bin/uasset-tool (see setup.sh). GAME = game directory.
set -euo pipefail
R="$(cd "$(dirname "$0")" && pwd)"
GAME="${GAME:-$HOME/.local/share/Steam/steamapps/common/Remnant}"
UA="${UASSET_TOOL:-$R/tools/bin/uasset-tool}"
REPAK="${REPAK:-$(command -v repak || echo "$HOME/.cargo/bin/repak")}"
OUT="$R/build"
TMP="$OUT/tmp"
PAK="$TMP/CoopMerchants_P"

[ -d "$GAME/Remnant/Content/Paks" ] || { echo "Game not found: $GAME (set GAME=/path/to/Remnant)" >&2; exit 1; }
[ -x "$UA" ] || { echo "Missing $UA (run ./setup.sh)" >&2; exit 1; }

rm -rf "$OUT"
mkdir -p "$TMP"

# Extract the trees listed in trees.txt from the game paks.
inc=()
while read -r p; do inc+=(-i "$p.uasset" -i "$p.uexp"); done < "$R/trees.txt"
"$REPAK" unpack -q -o "$TMP/orig" "${inc[@]}" "$GAME"/Remnant/Content/Paks/pakchunk*-WindowsNoEditor.pak

# Patch: a vendor's shop option opens the menu, then ends the conversation.
while read -r p; do
    n="$(basename "$p")"
    mkdir -p "$PAK/$(dirname "$p")"
    "$UA" tojson "$TMP/orig/$p.uasset" "$TMP/$n.json"
    python3 -I "$R/patch_tree.py" "$TMP/$n.json" "$TMP/$n.patched.json" >/dev/null
    "$UA" fromjson "$TMP/$n.patched.json" "$PAK/$p.uasset"
done < "$R/trees.txt"
(cd "$TMP" && "$REPAK" pack --version V8A --mount-point ../../../ CoopMerchants_P >/dev/null)

# Zip in game-dir layout: extract in the game directory.
mkdir -p "$TMP/zip/Remnant/Content/Paks/~mods"
cp "$TMP/CoopMerchants_P.pak" "$OUT/"
cp "$TMP/CoopMerchants_P.pak" "$TMP/zip/Remnant/Content/Paks/~mods/"
(cd "$TMP/zip" && python3 -I -m zipfile -c "$OUT/CoopMerchants.zip" Remnant)

rm -rf "$TMP"
echo "Built: $OUT/CoopMerchants_P.pak $OUT/CoopMerchants.zip"
