#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LINEAGE_DIR="${LINEAGE_DIR:-$HOME/lineage-24}"
RELEASES_DIR="$PROJECT_ROOT/releases"

BUILD_VARIANT="${1:-userdebug}" # Default to userdebug, can pass 'user' or 'eng' as argument

echo "================================================="
echo "   Building LineageOS 24.0 (Android 17) for      "
echo "   Motorola Edge (2020) - racer (sm7250)         "
echo "   Variant: lineage_racer-$BUILD_VARIANT         "
echo "================================================="

cd "$LINEAGE_DIR"
mkdir -p "$RELEASES_DIR"

if [ ! -d "vendor/motorola/racer" ]; then
    echo "Error: vendor/motorola/racer is missing. Run ./scripts/04_extract_blobs.sh first."
    exit 1
fi

# Ensure our local customizations are applied
bash "$PROJECT_ROOT/scripts/03_link_device.sh"

# Enable Compiler Cache (ccache) for fast rebuilds
export USE_CCACHE=1
export CCACHE_EXEC=$(which ccache)
export CCACHE_DIR="$HOME/.ccache"
ccache -M 50G
echo "Ccache configured at $CCACHE_DIR (50G maximum size)."

# Initialize Android build environment
echo "=== Loading Build Environment ==="
source build/envsetup.sh

# breakfast resolves the right release config / lunch target for this Android version
echo "=== Selecting Target: breakfast racer $BUILD_VARIANT ==="
breakfast racer "$BUILD_VARIANT"

echo "=== Starting Compilation with $(nproc) Threads ==="
START_TIME=$(date +%s)

# Compile ROM package
mka bacon

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
echo "=== Build finished in $((DURATION / 60)) minutes and $((DURATION % 60)) seconds ==="

# Locate built images and ZIP
OUT_DIR="$LINEAGE_DIR/out/target/product/racer"
if [ -d "$OUT_DIR" ]; then
    echo "=== Copying Flashable ZIP and Images to $RELEASES_DIR ==="

    # Copy ROM zip and checksum
    find "$OUT_DIR" -maxdepth 1 -name "lineage-*.zip" -exec cp -v {} "$RELEASES_DIR/" \;
    find "$OUT_DIR" -maxdepth 1 -name "lineage-*.zip.sha256sum" -exec cp -v {} "$RELEASES_DIR/" \;

    # Copy boot-related images for flashing
    for img in boot.img recovery.img dtbo.img vendor_boot.img vbmeta.img; do
        [ -f "$OUT_DIR/$img" ] && cp -v "$OUT_DIR/$img" "$RELEASES_DIR/$img"
    done

    echo ""
    echo "=========================================================="
    echo " Build artifacts successfully copied to:"
    echo " $RELEASES_DIR"
    echo "=========================================================="
    ls -lh "$RELEASES_DIR"
else
    echo "Error: Output directory $OUT_DIR not found."
    exit 1
fi
