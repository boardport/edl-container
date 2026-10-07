# 🐳 Docker Context: `docker/`

This directory contains configuration files for building, configuring, and executing the isolated Docker container
for [bkerler/edl](https://github.com/bkerler/edl).

---

## 📁 Directory Layout

```text
docker/
├── .gitignore              # Local build exclusions
├── Dockerfile.debian       # Multi-arch production image recipe (Debian 12 Slim, Python 3.11)
├── README.md               # Docker context guide (English)
├── README_RU.md            # Docker context guide (Russian)
└── docker-entrypoint.sh    # Entrypoint orchestrator: /docker-entrypoint.d/ hooks and UID/GID normalization
```

---

## ⚡ Build and Run Summary

### Build the Image

```bash
make docker-build
# or directly via Docker CLI:
docker build -f docker/Dockerfile.debian -t ghcr.io/boardport/edl .
```

### Direct Docker CLI Invocation (Without GNU Make)

```bash
docker run --rm -it \
  --privileged \
  --net=host \
  -v /dev/bus/usb:/dev/bus/usb \
  -v "$(pwd)/dumps:/opt/edl/dumps" \
  -e EDL_DUMP_UID=$(id -u) \
  ghcr.io/boardport/edl printgpt
```

---

## 📚 Detailed Documentation

Comprehensive container runtime specifications and guides are located in the project documentation:

- 💻 **[Developer Guide and Docker Runtime](../docs/development.en.md)** — exhaustive reference for environment variables
  (`EDL_DUMP_UID`), volume mounts, entrypoint hooks, and Docker CLI one-liners.
- 🏛️ **[Container Architecture](../docs/architecture.en.md)** — container lifecycle, image layers, and USB passthrough.
- 🛠️ **[Workflows](../docs/workflows.en.md)** — partition dumping, flashing procedures, and unbricking.
