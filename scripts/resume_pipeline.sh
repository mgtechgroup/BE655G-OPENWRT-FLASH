#!/usr/bin/env bash
set -e

LOG="/mnt/c/Users/AzielMelek/Downloads/openwrt/build_resume_log.txt"
exec > >(tee "$LOG") 2>&1

echo "=== [$(date)] 1/3: Copying fixed DTS to build env ==="
cp -v /mnt/c/Users/AzielMelek/Downloads/openwrt/target/linux/qualcommbe/dts/ipq9574-be65-5g.dts \
      /home/builder/openwrt/target/linux/qualcommbe/dts/ipq9574-be65-5g.dts
chown builder:builder /home/builder/openwrt/target/linux/qualcommbe/dts/ipq9574-be65-5g.dts

cp -v /mnt/c/Users/AzielMelek/Downloads/openwrt/target/linux/qualcommbe/image/ipq95xx.mk \
      /home/builder/openwrt/target/linux/qualcommbe/image/ipq95xx.mk
chown builder:builder /home/builder/openwrt/target/linux/qualcommbe/image/ipq95xx.mk

echo "=== [$(date)] 2/3: Resuming parallel build ==="
cd /home/builder/openwrt
sudo -u builder make -j$(nproc) world || {
    echo "Parallel build failed, retrying single-threaded for error output..."
    sudo -u builder make -j1 V=s world
}

echo "=== [$(date)] 3/3: Verifying artifacts ==="
IMGDIR="bin/targets/qualcommbe/ipq95xx"
SYSUPGRADE=$(find "$IMGDIR" -name "*tplink_be65-5g*sysupgrade*" 2>/dev/null | head -1)

if [ -n "$SYSUPGRADE" ]; then
    echo "  ✓ Sysupgrade: $SYSUPGRADE"
    ls -lh "$SYSUPGRADE"
    file "$SYSUPGRADE"
    echo "  Copying to C:\\Users\\AzielMelek\\Downloads\\..."
    cp "$SYSUPGRADE" /mnt/c/Users/AzielMelek/Downloads/
    echo "  ✓ Image copied!"
else
    echo "  ✗ Sysupgrade image NOT FOUND!"
    ls -la "$IMGDIR"/ 2>/dev/null || echo "  (output dir missing)"
    exit 1
fi
echo "========================================"
echo " BUILD RESUME COMPLETE!"
echo "========================================"
