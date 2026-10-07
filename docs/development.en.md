# Contributor Guide

Reference guide covering local Docker image builds, direct Docker CLI usage,
mount point configuration, modular GNU Make development, and code quality standards.

---

## 1. Building the Docker Image

The image is based on **Debian 12 Slim** and **Python 3.11**.

### Local Build

Build the local image using GNU Make:

```bash
make docker-build
```

Or invoke the Docker CLI directly:

```bash
docker build -f docker/Dockerfile.debian -t ghcr.io/boardport/edl .
```

The recipe is defined in
[docker/Dockerfile.debian](https://github.com/boardport/edl-container/blob/main/docker/Dockerfile.debian).
It includes:

- System dependencies: `libusb-1.0-0`, `liblzma-dev`, `adb`, `fastboot`, `build-essential`, `git`.
- Upstream `bkerler/edl` with loader databases located at `/opt/edl`.
- The entrypoint script [docker/docker-entrypoint.sh](https://github.com/boardport/edl-container/blob/main/docker/docker-entrypoint.sh).

---

## 2. Environment Variables and Mount Points

### Environment Variables

| Variable | Default | Description |
| :--- | :--- | :--- |
| `EDL_DUMP_UID` | `1000` | Host user UID for automatic ownership correction on generated dumps |
| `EDL_DUMP_GID` | `1000` | Host user GID |
| `EDL_DIR` | `/opt/edl` | Working directory containing the `edl` codebase inside the container |
| `EDL_DUMP_DIR` | `/opt/edl/dumps` | Destination directory for output dumps |

### Volume Mounts

| Host Path | Container Mount Point | Purpose |
| :--- | :--- | :--- |
| `/dev/bus/usb` | `/dev/bus/usb` | Host physical USB bus passthrough (requires `--privileged`) |
| `./dumps` | `/opt/edl/dumps` | Directory for storing partition dumps and logs |
| `./loaders` | `/opt/edl/custom_loaders` | Optional directory for external Firehose loaders |
| `./custom_scripts` | `/docker-entrypoint.d` | Optional initialization scripts (`*.sh`) executed before runtime |

---

## 3. Entrypoint Lifecycle and Hooks

The script `docker-entrypoint.sh` coordinates container runtime:

1. **Initialization Hooks:** If `/docker-entrypoint.d` contains executable `.sh` scripts, they run in alphabetical order.
2. **Command Routing:**
   - Standard shell utilities (`bash`, `sh`, `adb`, `fastboot`, `python`) execute directly.
   - All `edl` subcommands are dispatched to `python /opt/edl/edl.py "$@"`.
3. **Permission Normalization:** On exit, `chown -R "${EDL_DUMP_UID}:${EDL_DUMP_UID}" "$EDL_DUMP_DIR"` ensures
   dump files remain readable and writable by the host user without `sudo`.

---

## 4. Direct Docker CLI Execution (Without GNU Make)

In minimal environments lacking GNU Make, invoke the container directly:

### Read Partition Table (GPT)

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  ghcr.io/boardport/edl printgpt
```

### Dump a Single Partition (boot)

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$(pwd)/dumps:/opt/edl/dumps" \
  -e EDL_DUMP_UID=$(id -u) \
  ghcr.io/boardport/edl r boot dumps/boot.img
```

### Complete Partition Backup

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$(pwd)/dumps:/opt/edl/dumps" \
  -e EDL_DUMP_UID=$(id -u) \
  ghcr.io/boardport/edl rl dumps
```

### Flash Partition Image

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$(pwd)/dumps:/opt/edl/dumps" \
  ghcr.io/boardport/edl w boot dumps/boot_new.img
```

### Interactive Bash Shell

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$(pwd)/dumps:/opt/edl/dumps" \
  ghcr.io/boardport/edl bash
```

---

## 5. GNU Make Framework (.make/)

Automation is organized around a modular Make framework:

- The root [Makefile](https://github.com/boardport/edl-container/blob/main/Makefile) serves as the dispatcher
  and includes modules from `.make/*.mk`. Do not modify the root `Makefile` without explicit instruction.
- The `.make/edl_docker.mk` module handles Docker image builds and checks.
- The `.make/edl.mk` module exposes high-level targets wrapping `docker run`.
- Targets use double-colon rules (`target::`) with trailing `## Description` comments for self-documentation.

Inspect available tasks with `make list` and `make help`.

---

## 6. Code Quality Standards and CI/CD

The repository enforces automated validation checks:

### 6.1. Markdownlint

Documentation is validated via `markdownlint-cli2`:

```bash
npx markdownlint-cli2
```

All contributions must pass with `0 issues in 0 files`.

### 6.2. ShellCheck

All shell scripts are statically analyzed:

```bash
shellcheck docker/docker-entrypoint.sh
```

### 6.3. Continuous Integration (GitHub Actions)

Workflows in `.github/workflows/` automate checks and builds:

- `build_debian.yml`: Multi-architecture builds (`linux/amd64`, `linux/arm64`) published to `ghcr.io/boardport/edl`.
- `markdownlint.yml`: Automatic documentation formatting verification.
- `shellcheck.yml`: Shell script linting.
