#!/usr/bin/env bash
set -e

# Usage: 04_extract_blobs.sh [path_to_firmware_dump]
#   path_to_firmware_dump  Directory (or OTA zip) of stock firmware. Omit to pull from a
#                          connected device over adb (hard from WSL; a dump is easier).
# The racer trees' proprietary-files.txt are based on stock Android 11 (RPDS31.Q4U-39-26-14-13).

LINEAGE_DIR="${LINEAGE_DIR:-$HOME/lineage-24}"
DUMP_SRC="$1"

for dev in racer sm7250-common; do
    if [ ! -f "$LINEAGE_DIR/device/motorola/$dev/extract-files.py" ]; then
        echo "Error: $LINEAGE_DIR/device/motorola/$dev/extract-files.py not found. Run 02_sync_source.sh first."
        exit 1
    fi
done

if [ -n "$DUMP_SRC" ] && [ ! -e "$DUMP_SRC" ]; then
    echo "Error: firmware dump '$DUMP_SRC' does not exist."
    exit 1
fi

cd "$LINEAGE_DIR/device/motorola/racer"

echo "=== Extracting proprietary blobs into vendor/motorola/{racer,sm7250-common} ==="
if [ -n "$DUMP_SRC" ]; then
    python3 ./extract-files.py "$(realpath "$DUMP_SRC")"
else
    python3 ./extract-files.py
fi

for d in racer sm7250-common; do
    if [ ! -d "$LINEAGE_DIR/vendor/motorola/$d" ]; then
        echo "Error: vendor/motorola/$d was not generated. Check the extractor output above."
        exit 1
    fi
done

echo ""
echo ">>> Blobs ready! Next: run ./scripts/05_build.sh"
