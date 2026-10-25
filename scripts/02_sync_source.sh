#!/usr/bin/env bash
set -e

# Resolve directory of this script and the root project directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# LineageOS 24.0 (Android 17) source directory in WSL ext4
LINEAGE_DIR="${LINEAGE_DIR:-$HOME/lineage-24}"

echo "=== Target Directory: $LINEAGE_DIR ==="
mkdir -p "$LINEAGE_DIR"
cd "$LINEAGE_DIR"

export PATH="$HOME/bin:$PATH"

if [ ! -d ".repo" ]; then
    echo "=== Initializing LineageOS 24.0 (Android 17) Source Tree ==="
    echo "Using shallow clone (--depth=1) to conserve disk space and bandwidth..."
    repo init -u https://github.com/LineageOS/android.git -b lineage-24.0 --depth=1 --git-lfs --no-clone-bundle
fi

echo "=== Installing Local Manifest for Motorola Edge (racer) ==="
mkdir -p .repo/local_manifests
cp "$PROJECT_ROOT/manifests/racer.xml" .repo/local_manifests/racer.xml
echo "Copied manifests/racer.xml -> .repo/local_manifests/racer.xml"

echo "=== Syncing Repositories (Parallel) ==="
echo "This will download the LineageOS base, racer device trees, kernel and HALs."
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j"$(nproc)"

echo ""
echo "=== Linking Project Customizations ==="
bash "$PROJECT_ROOT/scripts/03_link_device.sh"

echo ""
echo ">>> Sync complete! Next: run ./scripts/04_extract_blobs.sh <firmware_dump_dir>"
