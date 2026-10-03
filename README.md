# 📦 BoardPort — EDL Container

[![Docker Build](https://github.com/boardport/edl-container/actions/workflows/build_debian.yml/badge.svg)](https://github.com/boardport/edl-container/actions/workflows/build_debian.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
[![Upstream: bkerler/edl](https://img.shields.io/badge/Upstream-bkerler%2Fedl-orange.svg)](https://github.com/bkerler/edl)
[![Project: BoardPort](https://img.shields.io/badge/Project-BoardPort-green.svg)](https://github.com/boardport)

Ready-to-use Docker container for [EDL (Qualcomm Emergency Download Tool)](https://github.com/bkerler/edl) by B. Kerler.

This repository is part of the **[BoardPort](https://github.com/boardport)** ecosystem, providing an isolated runtime
with all required drivers, native libraries, and loaders for seamless workflows via straightforward Make commands.

> 🤖 **Note for AI Assistants:** Autonomous AI agents and LLM assistants must review project guidelines
> in [AGENTS.md](./AGENTS.md) before performing tasks in this repository.

---

## 🎯 About the Project and BoardPort Ecosystem

The primary mission of **BoardPort** is porting modern Linux distributions, mainline kernels, lightweight operating systems,
and tailored firmware to legacy, forgotten, or unsupported devices:

- 📶 **Budget 4G/LTE USB modems and routers** (Qualcomm MSM8916, MSM8909, MSM8937 dongles — OpenStick family, UFI, and derivatives).
- 📱 **Smartphones and tablets** powered by legacy Qualcomm Snapdragon platforms.
- 🧩 **Development boards** and single-board computers (DragonBoard 410c, Inforce, and industrial modules).
- 📟 **IoT hardware and telematics units** requiring low-level unbricking, partition extraction, or transitions to mainline Linux.

Within this ecosystem, **EDL Container** delivers a reliable, reproducible interface
for device communication over the **Qualcomm 9008 (EDL)** emergency download protocol without polluting host dependencies.

---

## ⚡ Quick Start Workflow

Low-level Qualcomm hardware operations follow four concise steps:

### Step 1. Prepare the Host (USB Permissions)

Configure a udev rule to allow the container direct access to the USB bus. Create `/etc/udev/rules.d/51-edl.rules`:

```udev
# Qualcomm Snapdragon EDL Mode (9008)
SUBSYSTEM=="usb", ATTR{idVendor}=="05c6", ATTR{idProduct}=="9008", MODE="0666", GROUP="plugdev"
```

Apply the new rule:

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

> ⚠️ **Kernel Driver Conflict (`qcserial`):** If the Linux kernel automatically claims the device as a serial port
> (`/dev/ttyUSB*`), unload the driver so `libusb` can claim the bulk endpoints:
>
> ```bash
> sudo rmmod qcserial
> ```

---

### Step 2. Put Device into EDL Mode and Connect to PC

Boot your board, USB modem, or phone into Qualcomm Emergency Download mode (9008) and connect it to your PC:

- **Software triggers (when device boots):**
  - From running Android: `make edl-reboot-adb` (executes `adb reboot edl`).
  - From Bootloader / Fastboot: `make edl-reboot-fastboot`.
- **USB modems and dongles (MSM8916 / MSM8909):**
  - Hold the physical boot button while plugging into a USB port.
  - Or bridge the EDL Test Points with tweezers while connecting power.
- **Smartphones and tablets:**
  - Hold hardware button combinations (typically `Vol+` & `Vol-`) and attach the USB cable while powered off.
  - Or use a specialized EDL / Deep Flash Cable.

---

### Step 3. Verify Connection

Confirm that the device is detected on the USB bus with vendor/product ID `05c6:9008`:

```bash
lsusb | grep 05c6:9008
```

Verify communication and read the partition table:

```bash
make edl-printgpt
```

---

### Step 4. Run Desired Operations

Perform backups, dump individual partitions, or flash firmware using simple `make edl-*` targets.

---

## 🛠️ Essential Commands (Make Automation)

All verbose `docker run` flags, USB device pass-through, and host file permissions are fully automated.

### 🔍 Diagnostics and Inspection

```bash
# Print partition table (GPT)
make edl-printgpt

# Print storage hardware information (eMMC / UFS, block/sector geometry)
make edl-storageinfo

# Run arbitrary bkerler/edl command (or display built-in reference help)
make edl
make edl secureboot
```

### 💾 Backup and Extraction

```bash
# Dump ALL partitions to the local dumps/ directory
make edl-rl

# Dump a single partition (e.g., boot to dumps/boot.img)
make edl-r boot dumps/boot.img

# Sector-by-sector full raw flash dump (Full Disk Image)
make edl-rf dumps/full_flash.bin
```

### ⚡ Flashing and Erasing

```bash
# Flash a prepared image to a partition
make edl-w boot dumps/boot_new.img

# Erase a partition (e.g., userdata)
make edl-erase userdata
```

### 🔄 Power Management and Rebooting

```bash
# Reboot device into normal system
make edl-reset

# Warm reset back into EDL mode
make edl-reset-edl
```

### 💻 Interactive Environment and Custom Loaders

```bash
# Launch interactive container shell (includes adb, fastboot, and utilities)
make edl-sh

# Pass a custom Firehose loader (when auto-detection is not available)
make edl-printgpt --loader=loaders/prog_emmc_firehose_8916.mbn
```

---

## 🐳 Running via Docker CLI (Without Make)

If GNU Make is not installed or when running in CI/CD automation pipelines,
you can invoke the image directly via standard Docker CLI:

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$(pwd)/dumps:/opt/edl/dumps" \
  -e EDL_DUMP_UID=$(id -u) \
  ghcr.io/boardport/edl printgpt
```

Detailed documentation on container configuration, environment variables (`EDL_DUMP_UID`, `EDL_DUMP_GID`),
mount points, and CLI recipes is available in **[docker/README.md](./docker/README.md)**.

---

## 📚 Project Documentation Hub

- 🐳 **[Docker Context Guide](./docker/README.md)** — image architecture, volume mounts, environment variables, and standalone CLI usage.
- 🏛️ **[Architecture Specification](./ARCHITECTURE.md)** — container internals, build lifecycle, and layer design.
- 🤖 **[AI Guidelines & Agents Context](./AGENTS.md)** — protocols, conventions, and context for autonomous AI agents.
- 🤝 **[Contributing Guide](./.github/CONTRIBUTING.md)** — commit conventions, PR workflows, and developer guidelines.
- 🔒 **[Security Policy](./.github/SECURITY.md)** — vulnerability disclosure procedures and base image maintenance.

---

## 📄 License & Acknowledgments

- Containerization scripts, Make automation, documentation, and supporting files are released under the
  **[MIT License](./LICENSE)**.
- This project packages [edl](https://github.com/bkerler/edl), created by **Bjoern Kerler** (also **MIT License**).
  Sincere gratitude to the author for invaluable contributions to the Qualcomm reverse-engineering and modding community.
