# Operational Workflows and Troubleshooting

Practical guide for standard Qualcomm EDL (9008) operations:
partition backup acquisition, image flashing, Firehose loader selection,
unbricking damaged boot chains, and fault isolation.

---

## 1. Storage Diagnostics and Inspection

Verify hardware communication stability prior to attempting data transfers:

```bash
# Read partition table (GPT)
make edl-printgpt

# Query flash memory geometry (eMMC / UFS / NAND)
make edl-storageinfo

# Check Secure Boot enforcement and public key status
make edl secureboot
```

A successful GPT printout confirms that the Sahara handshake and Firehose XML layers are functional.

---

## 2. Backup Operations

All dumped images and partition files are saved to the local `dumps/` directory in the repository root.

### 2.1. Dumping an Individual Partition

To extract a specific partition (kernel, secondary bootloader, modem baseband), specify the partition name and destination:

```bash
# Save boot partition to dumps/boot.img
make edl-r boot dumps/boot.img

# Save secondary bootloader (aboot)
make edl-r aboot dumps/aboot.img
```

### 2.2. Full Partition Backup

Before flashing experimental kernels or modified bootloaders, capture a complete backup of all partitions:

```bash
make edl-rl
```

The command parses the GPT and sequentially extracts each partition into `dumps/` using its partition label.

### 2.3. Sector-by-Sector Raw Flash Image

To dump the entire physical memory space into a single raw disk image (including MBR, GPT, and hidden sectors):

```bash
make edl-rf dumps/full_flash.bin
```

---

## 3. Partition Flashing and Erasing

> **Warning:** Writing invalid payloads to early boot partitions (`sbl1`, `xbl`, `tz`, `rpm`, `aboot`)
> can break the boot sequence. Always create a backup of the target partition before overwriting it!

### 3.1. Flashing an Image to a Partition

```bash
# Flash modified kernel to the boot partition
make edl-w boot dumps/boot_new.img

# Flash a new root filesystem
make edl-w rootfs dumps/rootfs_custom.img
```

### 3.2. Erasing a Partition

Useful for resetting user data, clearing damaged caches, or preparing storage for repartitioning:

```bash
# Erase userdata partition
make edl-erase userdata

# Erase cache partition
make edl-erase cache
```

---

## 4. Working with Firehose Loaders

The tool includes an embedded database of programmers (`Loaders/`) that are selected
automatically based on chipset hardware identifiers (HWID, PK Hash).

### Using External / Custom Loaders

If automatic detection fails for a particular board revision or vendor-signed target:

1. Place the loader binary (e.g., `prog_emmc_firehose_8916.mbn`) in your workspace.
2. Pass the `--loader` option via `MAKEARGS`:

```bash
make edl-printgpt MAKEARGS="--loader=loaders/prog_emmc_firehose_8916.mbn"
```

Or extract a partition using a specified loader:

```bash
make edl-r boot dumps/boot.img MAKEARGS="--loader=loaders/prog_emmc_firehose_8916.mbn"
```

---

## 5. Power Management and Reset

Once maintenance is complete, reboot the device directly over the USB bus:

```bash
# Reboot device into normal operating system
make edl-reset

# Perform a warm reboot back into EDL mode
make edl-reset-edl
```

Warm resets are especially convenient when debugging without repeatedly unplugging physical USB cables.

---

## 6. Unbricking and Troubleshooting

### Stuck on Sahara Handshake ("Hello packet failed / Timeout")

- **Cause 1: Port captured by `qcserial`.**
  Inspect `dmesg | grep ttyUSB`. If a serial port is registered by the kernel, unload the module: `sudo rmmod qcserial`.
- **Cause 2: Chipset stuck in intermediate state.**
  Execute `make edl-reset-edl`. If unresponsive, disconnect all power sources for 5 seconds.
- **Cause 3: Insufficient USB bus power.**
  Connect directly to motherboard rear USB ports; avoid unpowered USB hubs.

### Digital Signature Rejection (Secure Boot / Sahara Command NACK)

- **Cause:** Hardware Secure Boot is enforced (eFuses blown), and the selected Firehose programmer
  is not signed by the vendor's private OEM key.
- **Solution:** Extract an authentic OEM-signed programmer (MBN/ELF) from the vendor's factory firmware
  and provide it via `--loader=...`.

### "Permission denied" Accessing Dumps on Host

- **Cause:** The container was invoked directly without UID mapping, creating files owned by `root`.
- **Solution:** Make targets provide `-e EDL_DUMP_UID=$(id -u)` automatically.
  If files were already generated as root, restore ownership on the host:
  `sudo chown -R $USER:$USER dumps/`.
