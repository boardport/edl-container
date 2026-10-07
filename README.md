# 📦 BoardPort — EDL Container

[![Docker Build](https://github.com/boardport/edl-container/actions/workflows/build_debian.yml/badge.svg)](https://github.com/boardport/edl-container/actions/workflows/build_debian.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
[![Upstream: bkerler/edl](https://img.shields.io/badge/Upstream-bkerler%2Fedl-orange.svg)](https://github.com/bkerler/edl)
[![Project: BoardPort](https://img.shields.io/badge/Project-BoardPort-green.svg)](https://github.com/boardport)

Production-ready Docker container for the [EDL (Qualcomm Emergency Download Tool)](https://github.com/bkerler/edl) utility by B. Kerler.

This repository is part of the **[BoardPort](https://github.com/boardport)** ecosystem, providing an isolated runtime
pre-equipped with drivers, libraries, and Firehose programmers accessible via intuitive Make targets.

> 🤖 **Notice for AI Assistants:** Before working on tasks in this project, please review the standards in [AGENTS.md](./AGENTS.md).

---

## 🎯 About the BoardPort Ecosystem

The **BoardPort** initiative aims to port modern Linux distributions, mainline kernels, lightweight operating systems,
and custom bootloaders to forgotten or unsupported hardware:

- 📶 **Chinese 4G/LTE USB Modems and Routers** (Qualcomm MSM8916, MSM8909, MSM8937 dongles — OpenStick family, UFI boards, etc.).
- 📱 **Legacy Smartphones and Tablets** powered by Qualcomm Snapdragon platforms.
- 🧩 **Development Boards** (DragonBoard 410c, Inforce kits, industrial single-board computers).
- 📟 **IoT and Telematics Modules** requiring partition recovery, dumping, or migration to mainline Linux.

Within this ecosystem, **EDL Container** establishes a reliable, reproducible interface with devices
via **Qualcomm Emergency Download Mode (EDL / 9008)** without cluttering host systems with dependencies.

---

## 📚 Project Documentation

All technical specifications, host configuration guides, and operational workflows are organized in **[`docs/`](./docs/)**:

| Document | Description |
| :--- | :--- |
| 📖 **[Project Overview](./docs/overview.en.md)** | BoardPort ecosystem, Qualcomm EDL (9008) fundamentals, Sahara and Firehose |
| ⚡ **[Quick Start](./docs/quickstart.en.md)** | Host setup, udev rules, `qcserial` unloading, hardware test points, and software triggers |
| 🛠️ **[Workflows](./docs/workflows.en.md)** | Partition backups, raw flash dumps, image flashing, external loaders, and unbricking |
| 🏛️ **[System Architecture](./docs/architecture.en.md)** | Container architecture, layer design, security model, and USB passthrough |
| 💻 **[Contributor Guide](./docs/development.en.md)** | Local builds, direct Docker CLI usage without Make, environment variables, and CI/CD |

---

## 📄 License and Acknowledgments

- Containerization scripts, Make automation, documentation, and tooling are licensed under the
  **[MIT License](./LICENSE)**.
- Packaging [bkerler/edl](https://github.com/bkerler/edl) by **Bjoern Kerler** (also **MIT License**).
  Sincere thanks to the author for invaluable contributions to the Qualcomm reverse-engineering community.
