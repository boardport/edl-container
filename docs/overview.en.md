# Introduction and Purpose

A containerized environment for low-level Qualcomm chipset operations in
**Emergency Download Mode (EDL / 9008)** powered by the open-source utility [bkerler/edl](https://github.com/bkerler/edl).

The tool addresses a key engineering requirement: delivering a reproducible, isolated runtime pre-packaged with
all necessary drivers, system libraries, and Qualcomm Firehose programmers without polluting the host operating system.

---

## Context and Engineering Challenges

When porting mainline Linux kernels, open bootloaders (such as U-Boot or LK2nd), and modern distributions
to custom or aging hardware, developers frequently encounter targets lacking functional recovery interfaces:

- **USB Modems and Dongles:** Stick form-factor hardware based on Qualcomm MSM8916, MSM8909, and MSM8937
  (OpenStick family, UFI modems, and clones).
- **Previous-generation Mobile Devices:** Snapdragon-powered smartphones and tablets abandoned on obsolete vendor firmwares.
- **Single Board Computers:** Development and industrial hardware kits (DragonBoard 410c, Inforce platforms).
- **Embedded IoT Units:** Telematics devices and IoT gateways with soldered eMMC or NAND storage.

Kernel and bootloader experiments frequently lead to bricked devices where early boot fails before fastboot or ADB can start.
In these situations, Qualcomm Emergency Download Mode remains the sole reliable interface for unbricking and memory inspection.

---

## The Qualcomm EDL Boot Chain (9008)

The **EDL (9008)** service mode is embedded within the Primary Boot Loader (PBL) located in the immutable ROM
of Qualcomm Application Processors.

When secondary boot stages are corrupt or when dedicated hardware test points are grounded at power-on,
the PBL initializes USB with hardware ID `05c6:9008`.

```text
[ ROM: Primary Boot Loader (PBL) ]
               │
               ▼  Sahara Protocol (USB Bulk)
[ Transfer Firehose Loader (.mbn/.elf) into RAM ]
               │
               ▼  Firehose Protocol (XML over USB)
[ Direct eMMC / UFS / NAND flash access ]
```

Communication proceeds through two distinct protocol stages:

1. **Sahara Protocol:** Low-level hardware handshake. The PBL requests a programmer binary from the host.
   The host sends a matching loader (`.mbn` or `.elf`), which the PBL authenticates (if Secure Boot is enforced)
   and executes within internal SRAM or DRAM.
2. **Firehose Protocol:** The active loader assumes control of the USB bus and exposes a high-throughput
   XML interface for sector reading, verification, partition writing, and flash block erasing.

---

## Why Containerization

While [bkerler/edl](https://github.com/bkerler/edl) is a capable tool, running it directly on workstations
introduces recurring friction:

- **Dependency Matrix:** Requires specific Python versions, native C compiler toolchains for cryptographic libraries, `libusb`, and `liblzma-dev`.
- **File Ownership Collisions:** Executing USB communication tools with root privileges causes dump files to be locked under `root`.
- **Tooling Fragmentation:** Full debugging cycles require auxiliary utilities (`adb`, `fastboot`) that may not match system packages.
- **Portability:** Discrepancies between host Linux distributions affect how kernel drivers claim EDL endpoints.

The container consolidates dependencies, drivers, and an up-to-date programmer database into a single image,
automatically normalizing generated file ownership (`UID:GID`) to match the unprivileged host user.
