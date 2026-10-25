# Motorola Edge (2020) — LineageOS 24.0 (Android 17) Bringup

Project workspace for building and customizing **LineageOS 24.0 (Android 17)** for the **Motorola Edge (2020)** (codename: **`racer`** / Snapdragon 765G / `sm7250`).

Uses the upstream LineageOS `lineage-24.0` device, common, kernel and HAL trees, plus a thin layer of local tweaks.

> **Status:** scaffold only. Nothing has been synced or built yet, and the trees are untested on this setup.
> Known blockers: proprietary blobs must be extracted from stock firmware (see step 3), and the build wants far more RAM than WSL's default.

---

## 📁 Project Architecture

Edit and version-control from Windows; compile inside WSL2 ext4 storage for speed:

```
motorolaEdge_ROM/
├── device/
│   └── motorola/
│       └── racer/
│           └── custom_settings.mk    # Local tweaks, hooked into upstream lineage_racer.mk
├── manifests/
│   └── racer.xml                     # Local manifest: device, common, sm8250 kernel, HALs
├── scripts/
│   ├── 01_setup_env.sh               # Install packages, repo tool, git identity, swap
│   ├── 02_sync_source.sh             # Shallow-sync LineageOS 24.0 + racer trees
│   ├── 03_link_device.sh             # Inject custom_settings.mk into the device tree
│   ├── 04_extract_blobs.sh           # Extract proprietary blobs from a stock firmware dump
│   ├── 05_build.sh                   # breakfast racer, mka bacon, export to releases/
│   └── run_wsl.cmd                   # Windows helper to launch WSL scripts
└── releases/                         # Output folder for compiled ROM .zip & images
```

---

## 🧰 Before You Start

* **RAM:** Android 17 builds want 32 GB+. WSL defaults to half of host RAM (7.5 GB seen here). Raise it in `%UserProfile%\.wslconfig`, then run `wsl --shutdown`:
  ```ini
  [wsl2]
  memory=24GB
  swap=32GB
  ```
  `01_setup_env.sh` also creates a swapfile (`SWAP_GB`, default 32) if RAM + swap is below that.
* **Disk:** ~200 GB free on the WSL ext4 disk for the shallow source tree, `out/` and ccache.
* **Stock firmware:** download the Motorola Edge (racer) stock Android 11 firmware (the trees' `proprietary-files.txt` target build `RPDS31.Q4U-39-26-14-13`) and unpack it somewhere WSL can read.

---

## 🚀 Step-by-Step Build Instructions

Run these from **PowerShell / Command Prompt** in this folder, or directly in your **Ubuntu WSL terminal** (`bash scripts/<name>`).

### 1. Install Build Dependencies & Setup Environment
```powershell
.\scripts\run_wsl.cmd 01_setup_env.sh
```

### 2. Shallow Sync LineageOS 24.0 & Motorola Dependencies
Initializes the source in `~/lineage-24` (override with `LINEAGE_DIR`) using `--depth=1`, installs `manifests/racer.xml`, syncs, then runs step 3's linking:
```powershell
.\scripts\run_wsl.cmd 02_sync_source.sh
```

### 3. Extract Proprietary Blobs
The Muppets vendor repos only have a stale `lineage-20` branch, so blobs are generated locally into `vendor/motorola/`:
```powershell
.\scripts\run_wsl.cmd 04_extract_blobs.sh /path/to/stock_firmware_dump
```
(Omit the path to pull from a device over adb, which is awkward under WSL.)

### 4. Customize Your ROM
Edit `device/motorola/racer/custom_settings.mk`; `03_link_device.sh` (run automatically before each build) copies it into the tree and includes it from `lineage_racer.mk`. The properties in it are untested starting points.

### 5. Compile the ROM
Configures `ccache` (50 GB) and builds with `breakfast racer` + `mka bacon`. The flashable `lineage-*.zip` and boot images are copied into `releases/`:
```powershell
.\scripts\run_wsl.cmd 05_build.sh
```
For a `user` build: `.\scripts\run_wsl.cmd 05_build.sh user`

---

## ⚙️ Repositories & Upstream Sources

| Component | Upstream / Provider | Branch |
| :--- | :--- | :--- |
| **ROM Base** | [LineageOS/android](https://github.com/LineageOS/android) | `lineage-24.0` |
| **Device Tree** | [android_device_motorola_racer](https://github.com/LineageOS/android_device_motorola_racer) | `lineage-24.0` |
| **Common Tree** | [android_device_motorola_sm7250-common](https://github.com/LineageOS/android_device_motorola_sm7250-common) | `lineage-24.0` |
| **Kernel Source** | [android_kernel_motorola_sm8250](https://github.com/LineageOS/android_kernel_motorola_sm8250) | `lineage-24.0` |
| **Motorola HALs** | [android_hardware_motorola](https://github.com/LineageOS/android_hardware_motorola) | `lineage-24.0` |
| **Timekeep HAL** | [android_hardware_sony_timekeep](https://github.com/LineageOS/android_hardware_sony_timekeep) | `lineage-24.0` |
| **Vendor Blobs** | Extracted locally from stock firmware (no current upstream branch) | n/a |
