#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LINEAGE_DIR="${LINEAGE_DIR:-$HOME/lineage-24}"

DEVICE_DIR="$LINEAGE_DIR/device/motorola/racer"
PRODUCT_MK="$DEVICE_DIR/lineage_racer.mk"

if [ ! -d "$DEVICE_DIR" ]; then
    echo "Warning: $DEVICE_DIR does not exist yet. Please run ./scripts/02_sync_source.sh first."
    exit 1
fi

echo "=== Injecting project customizations into $DEVICE_DIR ==="

# The upstream tree already provides lineage_racer; we only layer our tweaks on top of it.
cp -v "$PROJECT_ROOT/device/motorola/racer/custom_settings.mk" "$DEVICE_DIR/custom_settings.mk"

if ! grep -q "custom_settings.mk" "$PRODUCT_MK"; then
    echo "Hooking custom_settings.mk into lineage_racer.mk..."
    printf '\n# Project customizations\n-include device/motorola/racer/custom_settings.mk\n' >> "$PRODUCT_MK"
else
    echo "lineage_racer.mk already includes custom_settings.mk."
fi

# Copy any custom overlays if present
if [ -d "$PROJECT_ROOT/device/motorola/racer/overlay" ]; then
    mkdir -p "$DEVICE_DIR/overlay"
    cp -rv "$PROJECT_ROOT/device/motorola/racer/overlay/"* "$DEVICE_DIR/overlay/"
fi

echo ">>> Device tree customized for lineage_racer!"
