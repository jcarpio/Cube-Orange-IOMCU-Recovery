#!/usr/bin/env bash
set -euo pipefail

# Run this script from the ORIGINAL PX4 checkout on the Builder Ubuntu VM.
# Example: bash /path/to/documentation-repo/scripts/export_build_c.sh
PX4_ROOT="${PX4_ROOT:-$HOME/orange_cube_rover_firmware/px4-rover}"
DOC_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIRST="b377a2093b"
LAST="2092c87c6aed28e0c45580f0b061c2994d2923e7"
cd "$PX4_ROOT"
git rev-parse --verify "$FIRST^{commit}" >/dev/null
git rev-parse --verify "$LAST^{commit}" >/dev/null
if [[ "$(git rev-parse "$LAST")" != "$LAST" ]]; then
  echo "Unexpected Build C commit identity" >&2
  exit 1
fi
mkdir -p "$DOC_ROOT/patches" "$DOC_ROOT/firmware" "$DOC_ROOT/evidence"
# Safety: only remove files produced by this script, not other user files.
find "$DOC_ROOT/patches" -maxdepth 1 -name '000[12]-*.patch' -print -delete
git format-patch -2 "$LAST" -o "$DOC_ROOT/patches"
git diff "${FIRST}^" "$LAST" > "$DOC_ROOT/patches/build-c-complete.diff"
{
  echo "Export date: $(date -Iseconds)"
  echo "PX4 source: $PX4_ROOT"
  echo "Build C commit: $(git rev-parse "$LAST")"
  echo "Base commit: $(git rev-parse "${FIRST}^")"
  echo "Git status:"; git status --short
  echo "Changed paths:"; git show --pretty='' --name-only "$LAST"
} > "$DOC_ROOT/evidence/export-provenance.txt"
FW="$PX4_ROOT/build/cubepilot_cubeorange_rover/cubepilot_cubeorange_rover.px4"
if [[ -f "$FW" ]]; then
  cp "$FW" "$DOC_ROOT/firmware/cubepilot_cubeorange_rover_build_c.px4"
  sha256sum "$DOC_ROOT/firmware/cubepilot_cubeorange_rover_build_c.px4" > "$DOC_ROOT/firmware/SHA256SUMS.txt"
  python3 - "$FW" > "$DOC_ROOT/firmware/firmware-metadata.txt" <<'PY2'
import json,sys
with open(sys.argv[1],encoding='utf-8') as f: fw=json.load(f)
for key in ('board_id','image_size','git_hash'):
    print(f'{key}: {fw.get(key)}')
PY2
  if ! grep -q "git_hash: $LAST" "$DOC_ROOT/firmware/firmware-metadata.txt"; then
    echo "WARNING: Firmware git_hash differs from expected Build C commit! Review before publication." >&2
  fi
else
  echo "Firmware binary missing: $FW. Source patches were exported only." >&2
fi
echo "Export completed in $DOC_ROOT"
echo "Review patch files, git status, firmware metadata, privacy, and licensing before publication."
