---
name: 'Bug Report'
about: 'Report a bug or problem with the EDL container, USB communication, or flashing'
title: '[BUG] '
labels: 'bug'
assignees: ''
---

## Description

Provide a clear and concise description of the bug.

## Affected Area

Select all that apply:

- [ ] Docker build / image packaging (`Dockerfile.debian`, dependencies)
- [ ] Container Entrypoint & Permissions (`docker-entrypoint.sh`, UID/GID mapping)
- [ ] Hardware USB Communication (`/dev/bus/usb`, `qcserial` driver, udev rules)
- [ ] EDL Protocol Operations (Sahara / Firehose handshake, memory dumps, partition flashing)
- [ ] Make Tooling (`.make/`, `Makefile`)
- [ ] Documentation / Metadata (`README.md`, `.github/`)

## Hardware & Environment Details

- **Device Model:** [e.g. OpenStick UFI001B / DragonBoard 410c / ZTE MF910]
- **Qualcomm SoC:** [e.g. MSM8916 / MSM8909 / MSM8937 / other]
- **Firehose Loader used:** [e.g. built-in auto-detection or custom programmer filename]
- **Host OS & Architecture:** [e.g. Ubuntu 24.04 x86_64 / Raspberry Pi OS aarch64]
- **Docker version (`docker --version`):**
- **USB Vendor:Product ID (`lsusb` in 9008 mode):** [e.g. `05c6:9008`]

## Command Executed

Specify the exact command executed:

```bash
make edl-printgpt
# or: docker run --rm -it --privileged --net=host -v /dev/bus/usb:/dev/bus/usb ghcr.io/boardport/edl printgpt
```

## Steps to Reproduce

1. Connect target device in EDL mode (9008)
2. Run command '...'
3. See error output '...'

## Expected Behavior

A clear description of what you expected to happen.

## Actual Behavior

A clear description of what occurred, including error output.

## Terminal Logs & Output

```text
Paste raw terminal logs or python stack traces here
```
