# 🐳 Docker Context and Directory Guide: `docker/`

This directory provides configuration files for building, configuring, and executing the isolated container
for the [bkerler/edl](https://github.com/bkerler/edl) utility.

This document is intended for engineers who need to understand image architecture, configure runtime environment parameters,
or execute the container directly using the Docker CLI (e.g., in CI/CD pipelines or automated workflows without GNU Make).

---

## 1. Directory Contents

| File | Description |
| :--- | :--- |
| `Dockerfile.debian` | Production image build recipe based on Debian 12 (Bookworm) Slim and Python 3.11 |
| `docker-entrypoint.sh` | Container entrypoint script managing initialization hooks and permission normalization |
| `.gitignore` | Local volume and artifact exclusions (dump directories, runtime caches) |

---

## 2. Image Architecture and Build

- **Base Distribution:** `python:3.11-slim` (Debian 12 Bookworm).
- **Multi-Architecture Support:** `linux/amd64` (standard x86_64 hosts/servers) and `linux/arm64` (Apple Silicon, ARM64 single-board computers).
- **System Dependencies:** `libusb-1.0-0`, `liblzma-dev`, `adb`, `fastboot`, `git`, `build-essential`.
- **Upstream:** Clones `bkerler/edl` pinned to a stable release tag with recursive submodule initialization (`Loaders`).
- **Local Image Build:**

  ```bash
  make docker-build
  # or directly using docker build
  docker build -f docker/Dockerfile.debian -t ghcr.io/boardport/edl .
  ```

---

## 3. Environment Variables

| Variable | Default | Description |
| :--- | :--- | :--- |
| `EDL_DUMP_UID` | `1000` | Host user UID for automatically fixing file ownership on generated dumps |
| `EDL_DUMP_GID` | `1000` | Host group GID for dumped files ownership |
| `EDL_DIR` | `/opt/edl` | Working directory containing the `edl` codebase inside the container |
| `EDL_DUMP_DIR` | `/opt/edl/dumps` | Default output directory for partition dumps and logs |

---

## 4. Volume Mounts

| Host Path | Container Mount Point | Purpose |
| :--- | :--- | :--- |
| `/dev/bus/usb` | `/dev/bus/usb` | Direct access to host USB subsystem (requires `--privileged`) |
| `./dumps` | `/opt/edl/dumps` | Directory for partition dumps, firmware images, and logs |
| `./loaders` | `/opt/edl/custom_loaders` | Optional directory for external/custom Firehose programmers |
| `./custom_scripts` | `/docker-entrypoint.d` | Optional initialization scripts (`*.sh`) executed prior to `edl` startup |

---

## 5. Entrypoint and Permissions Model (`docker-entrypoint.sh`)

Upon container startup, the entrypoint script executes the following stages:

1. **Initialization Hooks:** Executes any `.sh` scripts located in `/docker-entrypoint.d/` (if mounted).
2. **Command Routing:**
   - If the invoked command matches a system binary (`bash`, `sh`, `adb`, `fastboot`), it is executed directly.
   - For all other invocations, arguments are forwarded to the primary CLI runner: `python3 /opt/edl/edl.py "$@"`.
3. **Permissions Normalization:** Following command completion, the entrypoint runs `chown -R "${EDL_DUMP_UID}:${EDL_DUMP_GID}" "$EDL_DUMP_DIR"`.
   This ensures that all generated dumps on the host system are owned by the active user rather than `root`.

---

## 6. Direct Docker CLI Examples

If GNU Make is not installed in your environment, all operations can be performed directly via `docker run`:

### Reading Partition Table (GPT)

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  ghcr.io/boardport/edl printgpt
```

### Dumping a Single Partition (e.g., boot)

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$(pwd)/dumps:/opt/edl/dumps" \
  -e EDL_DUMP_UID=$(id -u) \
  ghcr.io/boardport/edl r boot dumps/boot.img
```

### Full Backup of All Partitions (Raw Backup)

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$(pwd)/dumps:/opt/edl/dumps" \
  -e EDL_DUMP_UID=$(id -u) \
  ghcr.io/boardport/edl rl dumps
```

### Flashing an Image to a Partition

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$(pwd)/dumps:/opt/edl/dumps" \
  ghcr.io/boardport/edl w boot dumps/boot_new.img
```

### Erasing a Partition

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  ghcr.io/boardport/edl e userdata
```

### Using an External Firehose Programmer

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$(pwd)/loaders:/opt/edl/custom_loaders" \
  ghcr.io/boardport/edl --loader=/opt/edl/custom_loaders/prog_emmc_firehose_8916.mbn printgpt
```

### Interactive Command Shell

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$(pwd)/dumps:/opt/edl/dumps" \
  ghcr.io/boardport/edl bash
```
