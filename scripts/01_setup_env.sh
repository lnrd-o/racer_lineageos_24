#!/usr/bin/env bash
set -e

SUDO_CMD=""
if [ "$(id -u)" -ne 0 ]; then
    SUDO_CMD="sudo"
fi

# Swapfile size (GB). Android 17 links need far more than the 8 GB used for Android 14;
# override with SWAP_GB=<n> if disk space is tight.
SWAP_GB="${SWAP_GB:-32}"

echo "=== [1/4] Installing Build Packages and Dependencies ==="
# LineageOS 24.0 uses the prebuilt JDK from the source tree, so no host JDK is needed.
$SUDO_CMD apt-get update
$SUDO_CMD apt-get install -y \
    adb fastboot autoconf automake axel bc bison build-essential ccache cmake curl \
    expat flex g++ g++-multilib gawk gcc gcc-multilib git git-lfs gnupg gperf htop \
    imagemagick lib32ncurses-dev lib32readline-dev lib32z1-dev libc6-dev libcap-dev \
    libelf-dev libexpat1-dev libgmp-dev liblz4-tool libmpc-dev libmpfr-dev \
    libncurses-dev libsdl1.2-dev libssl-dev libtool libxml2 libxml2-utils lzop \
    maven ncftp ncurses-dev patch patchelf pkg-config pngcrush pngquant python3 \
    python3-pip python-is-python3 re2c rsync schedtool squashfs-tools subversion \
    tar texinfo unzip w3m xsltproc zip zlib1g-dev
# Needed by tools/extract-utils (blob extraction)
$SUDO_CMD apt-get install -y python3-protobuf || true

echo "=== [2/4] Installing Google Repo Tool ==="
mkdir -p ~/bin
if [ ! -f ~/bin/repo ]; then
    curl -s https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
    chmod a+x ~/bin/repo
fi

# Ensure ~/bin is in PATH in ~/.bashrc
if ! grep -q 'PATH="$HOME/bin:$PATH"' ~/.bashrc; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
fi
export PATH="$HOME/bin:$PATH"

echo "=== [3/4] Checking Git Identity ==="
GIT_USER=$(git config --global user.name || true)
GIT_EMAIL=$(git config --global user.email || true)

if [ -z "$GIT_USER" ]; then
    read -p "Enter your Git Name (for commit authorship): " INPUT_NAME
    git config --global user.name "${INPUT_NAME:-Leonardo}"
fi

if [ -z "$GIT_EMAIL" ]; then
    read -p "Enter your Git Email: " INPUT_EMAIL
    git config --global user.email "${INPUT_EMAIL:-leonardo@example.com}"
fi

echo "=== [4/4] Checking Memory & System Swap ==="
git config --global color.ui auto

TOTAL_RAM_MB=$(free -m | awk '/Mem:/ {print $2}')
CURRENT_SWAP=$(free -m | awk '/Swap:/ {print $2}')
echo "RAM: ${TOTAL_RAM_MB} MB, swap: ${CURRENT_SWAP} MB"
if [ "$TOTAL_RAM_MB" -lt 24000 ]; then
    echo "WARNING: Android 17 builds want 32 GB+ of RAM. Raise the WSL limit in"
    echo "         %UserProfile%\\.wslconfig ([wsl2] memory=...) then run 'wsl --shutdown'."
fi

if [ "$((TOTAL_RAM_MB + CURRENT_SWAP))" -lt "$((SWAP_GB * 1024))" ]; then
    echo "Creating ${SWAP_GB}GB swapfile to reduce build out-of-memory kills..."
    if [ ! -f /swapfile ]; then
        $SUDO_CMD fallocate -l "${SWAP_GB}G" /swapfile || $SUDO_CMD dd if=/dev/zero of=/swapfile bs=1M count=$((SWAP_GB * 1024))
        $SUDO_CMD chmod 600 /swapfile
        $SUDO_CMD mkswap /swapfile
        $SUDO_CMD swapon /swapfile
        echo '/swapfile none swap sw 0 0' | $SUDO_CMD tee -a /etc/fstab
    else
        echo "/swapfile already exists; leaving it as is."
    fi
fi

echo ""
echo ">>> Environment setup complete! Next: run ./scripts/02_sync_source.sh"
