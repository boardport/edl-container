# Quick Start and Host Setup

Step-by-step instructions for preparing the host workstation, configuring udev rules,
resolving kernel driver conflicts, triggering Qualcomm EDL Mode (9008), and verifying device connectivity.

---

## 1. Host Preparation (USB Access Permissions)

To interface directly with the physical USB bus without running commands via `sudo`, configure udev rules and user groups.

### 1.1. Creating the udev Rule

Create `/etc/udev/rules.d/51-edl.rules`:

```udev
# Qualcomm Snapdragon Emergency Download Mode (9008)
SUBSYSTEM=="usb", ATTR{idVendor}=="05c6", ATTR{idProduct}=="9008", MODE="0666", GROUP="plugdev"
```

Verify that your current user is assigned to the `plugdev` group:

```bash
sudo usermod -aG plugdev "$USER"
```

Reload and apply the rules:

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

### 1.2. Resolving qcserial Driver Conflicts

By default, the Linux kernel binds Qualcomm chips in EDL mode to the `qcserial` driver,
creating virtual serial ports (`/dev/ttyUSB0`) and blocking bulk endpoint access for `libusb`.

Unload the module prior to operation:

```bash
sudo rmmod qcserial
```

To permanently prevent the driver from binding to EDL devices:

```bash
echo "blacklist qcserial" | sudo tee /etc/modprobe.d/blacklist-qcserial.conf
```

---

## 2. Triggering Qualcomm EDL Mode

The target hardware must register on the USB bus with vendor/product ID `05c6:9008`.

### Software Methods (Functional Boot Stages)

- **Via ADB (From Running Android or Linux):**

  ```bash
  make edl-reboot-adb
  # Direct call: adb reboot edl
  ```

- **Via Fastboot (From Bootloader Mode):**

  ```bash
  make edl-reboot-fastboot
  # Direct call: fastboot oem edl or fastboot reboot-edl
  ```

### Hardware Methods (USB Modems and Dongles: MSM8916 / MSM8909)

1. Disconnect the device from the USB port.
2. If the PCB includes a physical push button, hold it down.
3. If no button is present, locate the **EDL Test Points** on the board and short them to ground (GND) using tweezers.
4. While keeping the contacts shorted, plug the hardware into a USB port.
5. Release the short circuit after 2–3 seconds.

### Hardware Methods (Smartphones and Tablets)

- Power off the unit, hold the recovery button combination (typically `Volume Up` + `Volume Down`), and insert the USB cable.
- Alternatively, use an **EDL Cable** (Deep Flash Cable) with an integrated switch that pulls the D+ data line to ground during power-up.

---

## 3. Verifying Connection on Host

Confirm that the kernel detects the device in service mode:

```bash
lsusb | grep 05c6:9008
```

Expected kernel output:

```text
Bus 001 Device 014: ID 05c6:9008 Qualcomm, Inc. Gobi Wireless Modem (QDL mode)
```

Monitor system events in the kernel log:

```bash
dmesg | tail -n 20
```

---

## 4. Initial Communication Test

With the hardware connected in EDL mode, query the partition table (GPT):

```bash
make edl-printgpt
```

During a successful handshake, the utility will:

1. Perform the Sahara protocol handshake.
2. Select and upload a compatible Firehose programmer into RAM.
3. Establish the Firehose XML session.
4. Print the storage partition layout (LUN0, LUN1, etc.).

To inspect storage hardware parameters (eMMC/UFS type, sector count, block sizes):

```bash
make edl-storageinfo
```
