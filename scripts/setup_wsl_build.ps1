# =============================================================================
# OpenWrt Build Environment Setup for TP-Link Deco BE65-5G
# =============================================================================
# Run this script in an ELEVATED (Administrator) PowerShell window.
#
# Usage:
#   1. Right-click PowerShell -> "Run as Administrator"
#   2. Set-ExecutionPolicy -Scope Process Bypass
#   3. C:\Users\AzielMelek\Downloads\openwrt\setup_wsl_build.ps1
# =============================================================================

$ErrorActionPreference = "Stop"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " OpenWrt WSL2 Build Environment Setup" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# ── Step 1: Install Ubuntu 24.04 ──────────────────────────────────────────────
Write-Host "[1/4] Installing Ubuntu 24.04 via WSL2..." -ForegroundColor Yellow
Write-Host "       If prompted, create a UNIX username and password.`n" -ForegroundColor Gray
wsl --install -d Ubuntu-24.04
if ($LASTEXITCODE -ne 0) {
    Write-Host "`nWARNING: wsl --install returned non-zero." -ForegroundColor Red
    Write-Host "If Ubuntu is already installed, continuing anyway..." -ForegroundColor Yellow
}

# Wait for it to be ready
Write-Host "`nWaiting 10s for WSL init..." -ForegroundColor Gray
Start-Sleep -Seconds 10

# Verify the distro is registered
Write-Host "Checking WSL distros:" -ForegroundColor Gray
wsl -l -v

# ── Step 2: Install build dependencies ────────────────────────────────────────
Write-Host "`n[2/4] Installing OpenWrt build dependencies in Ubuntu..." -ForegroundColor Yellow

$depScript = @'
set -e
echo ">>> Updating package lists..."
sudo apt-get update -qq

echo ">>> Installing build deps (this may take a few minutes)..."
sudo apt-get install -y \
    build-essential clang flex bison g++ gawk gcc-multilib \
    gettext git libncurses5-dev libssl-dev python3-setuptools rsync swig \
    unzip zlib1g-dev file wget qemu-utils python3-dev

echo ">>> All dependencies installed successfully!"
'@

wsl -d Ubuntu-24.04 -- bash -c $depScript
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Dependency install failed." -ForegroundColor Red
    exit 1
}

# ── Step 3: Copy source tree to ext4 ──────────────────────────────────────────
Write-Host "`n[3/4] Copying OpenWrt tree to WSL ext4 (~/openwrt)..." -ForegroundColor Yellow
Write-Host "       This avoids slow /mnt/c I/O. May take 5-15 min." -ForegroundColor Gray

$copyScript = @'
set -e
if [ -d ~/openwrt ]; then
    echo ">>> ~/openwrt already exists, removing..."
    rm -rf ~/openwrt
fi
echo ">>> Copying /mnt/c/Users/AzielMelek/Downloads/openwrt -> ~/openwrt ..."
cp -a /mnt/c/Users/AzielMelek/Downloads/openwrt ~/openwrt
echo ">>> Done! Size:"
du -sh ~/openwrt
'@

wsl -d Ubuntu-24.04 -- bash -c $copyScript
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Copy failed." -ForegroundColor Red
    exit 1
}

# ── Step 4: Feeds + config + build ────────────────────────────────────────────
Write-Host "`n[4/4] Running feeds, config, and full build..." -ForegroundColor Yellow
Write-Host "       This is the long step (1-3 hours depending on CPU)." -ForegroundColor Gray

$buildScript = @'
set -e
cd ~/openwrt

echo "============================================"
echo " Step A: Updating feeds"
echo "============================================"
./scripts/feeds update -a
./scripts/feeds install -a

echo "============================================"
echo " Step B: Seeding .config for BE65-5G"
echo "============================================"
cat > .config <<'CONFIGEOF'
CONFIG_TARGET_qualcommbe=y
CONFIG_TARGET_qualcommbe_ipq95xx=y
CONFIG_TARGET_MULTI_PROFILE=y
CONFIG_TARGET_DEVICE_qualcommbe_ipq95xx_DEVICE_tplink_be65-5g=y
CONFIG_TARGET_PER_DEVICE_ROOTFS=y
CONFIGEOF

make defconfig

echo ">>> Config verification:"
grep -c "tplink_be65" .config && echo "  BE65-5G is selected!" || echo "  WARNING: BE65-5G not found in .config!"

echo "============================================"
echo " Step C: Downloading sources (serial)"
echo "============================================"
make -j1 V=s download

echo "============================================"
echo " Step D: Full build (parallel)"
echo "============================================"
NPROC=$(nproc)
echo "  Building with $NPROC threads..."
make -j$NPROC world

echo ""
echo "============================================"
echo " BUILD COMPLETE!"
echo "============================================"

SYSUPGRADE=$(find bin/targets/qualcommbe/ipq95xx/ -name "*tplink_be65-5g*sysupgrade*" 2>/dev/null | head -1)
if [ -n "$SYSUPGRADE" ]; then
    echo ">>> Sysupgrade image: $SYSUPGRADE"
    ls -lh "$SYSUPGRADE"
    file "$SYSUPGRADE"
    echo ""
    echo ">>> Copying to Windows at /mnt/c/Users/AzielMelek/Downloads/"
    cp "$SYSUPGRADE" /mnt/c/Users/AzielMelek/Downloads/
    echo ">>> DONE! Image copied to C:\\Users\\AzielMelek\\Downloads\\"
else
    echo ">>> ERROR: sysupgrade.bin not found! Build may have failed."
    echo ">>> Check: ls bin/targets/qualcommbe/ipq95xx/"
    ls -la bin/targets/qualcommbe/ipq95xx/ 2>/dev/null || echo "(directory does not exist)"
fi
'@

wsl -d Ubuntu-24.04 -- bash -c $buildScript
if ($LASTEXITCODE -ne 0) {
    Write-Host "`nBuild exited with error. Check output above." -ForegroundColor Red
    Write-Host "To debug, run: wsl -d Ubuntu-24.04" -ForegroundColor Yellow
    Write-Host "Then: cd ~/openwrt && make -j1 V=s" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host " ALL DONE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Check C:\Users\AzielMelek\Downloads for the sysupgrade.bin" -ForegroundColor Cyan
