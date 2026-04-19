# BE655G OPENWRT FLASH

OpenWrt port and deployment pipeline for the **TP-Link Deco BE65-5G** (Qualcomm IPQ9574 "AL02-C11" Wi-Fi 7 Router).

This repository contains the verified device-tree source, image makefile patches, and a complete automated Windows/WSL2 build pipeline to compile a fully working `sysupgrade.bin` for the TP-Link Deco BE65-5G. 

## Supported Hardware

- **SoC:** Qualcomm IPQ9574 (Quad-Core A73 @ 2.2GHz)
- **Wi-Fi:** Offloaded QCN9224 PCIe radios (Wi-Fi 7)
- **Ethernet:** Integrated PPE + QCA8084 quad-port PHY package (QSGMII)
- **Storage:** Dual-bank QSPI NAND (60MB per bank)

## Repository Structure

- `device-support/ipq9574-be65-5g.dts`: The parsed OpenWrt device-tree file. Contains fixes overriding the upstream kernel syntax errors and missing header macros for the QCA8084 clock controllers.
- `device-support/ipq95xx.mk`: The fixed target recipe that provisions the UBI Fit image layout tailored exactly to the vendor layout (4.7MB Kernel, 35MB rootfs on 128k blocksize partitions), omitting invalid `ath11k` references.
- `scripts/setup_wsl_build.ps1`: An automated pipeline script that bootstraps a pure Ubuntu 24.04 WSL2 environment, mitigates file I/O bottlenecks by syncing the OpenWrt tree into a native EXT4 overlay, and initiates the multi-threaded compilation logic safely for Windows hosts.
- `scripts/resume_pipeline.sh`: A shell script run from within WSL to securely patch files into the cross-compiler tree and resume any failed package or DTB builds in parallel.

## Automated Local Build (Windows WSL2)

You can clone this repository and compile the source directly on Windows using our built-in orchestration scripts:

1. Right-click and execute `setup_wsl_build.ps1` with PowerShell inside your Windows environment. This handles dependency resolution, toolchain compilation, and user elevation policies magically.
2. The compiled firmware will be extracted to your host `Downloads` directory as `.bin`.

## Image Flashing

Our pipeline generates standard `sysupgrade` packages aligned to the OEM UBI logic:
```
openwrt-qualcommbe-ipq95xx-tplink_be65-5g-squashfs-sysupgrade.bin
```

1. Accessible from TP-Link's default Bootloader recovery web interface.
2. Direct CLI drop-in via `ubiformat /dev/mtdX` or `/sbin/sysupgrade` if transitioning from an existing OpenWrt drop.

> **Note:** IPQ9574 is a host network processor. Its Wi-Fi depends heavily on binary Qualcomm ATH12K firmware provided for QCN9224 PCIe radios.

---
*Maintained by mgtechgroup | Automated via AI Builder*
