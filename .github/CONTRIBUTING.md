# Contributing to BoardPort — EDL Container

Thank you for your interest in contributing to **BoardPort — EDL Container**!
This repository provides an isolated, production-grade Docker container and automation toolkit for the
[bkerler/edl](https://github.com/bkerler/edl) Qualcomm Emergency Download mode utility.

---

## How to Contribute

### 1. Reporting Bugs

- Before opening a new issue, search existing [GitHub Issues](https://github.com/boardport/edl-container/issues) to avoid duplicates.
- Use the **[Bug Report Template](./ISSUE_TEMPLATE/bug_report.md)**.
- Include your target device model, Qualcomm SoC, Firehose programmer, operating system, Docker version, and command terminal logs.

### 2. Suggesting Device Support & Enhancements

- Propose new device configurations, Firehose loaders, or automation features using the
  **[Feature Request Template](./ISSUE_TEMPLATE/feature_request.md)**.
- Review existing architectural boundaries in [ARCHITECTURE.md](../ARCHITECTURE.md).

### 3. Submitting Pull Requests

- Fork the repository and create a feature/fix branch from `main`.
- Keep changes atomic, focused, and well-documented.
- Maintain mirrored bilingual documentation (`*.md` and `*_RU.md`).
- Follow the Conventional Commits specification (e.g., `feat:`, `fix:`, `docs:`, `chore:`).
- Use the **[Pull Request Template](./PULL_REQUEST_TEMPLATE/pull_request_template.md)**.

---

## Development & Architecture Standards

### 1. Docker & Containerization Guidelines

- **Multi-Architecture Support:** Any changes to `docker/Dockerfile.debian` must build successfully for both
  `linux/amd64` and `linux/arm64`.
- **Permission Normalization:** All file generation workflows must preserve user ownership on host filesystems
  via `chown -R "${EDL_DUMP_UID:-1000}:"` in `docker/docker-entrypoint.sh`.
- **Command Forwarding:** Entrypoint scripts must transparently forward arguments to `/opt/edl/edl.py` while supporting
  pre-execution hooks located in `/docker-entrypoint.d/*.sh`.

### 2. Make Tooling Standards

- **Root Makefile Orchestration:** The root `Makefile` is a shared orchestrator. Do not add targets directly to it.
- **Double-Colon Syntax:** Every target in `.make/*.mk` must use double-colon syntax (`target::`) for modularity.
- **Self-Documenting Annotations:** Public targets must include a concise description following `##`.

```makefile
.PHONY: \
  edl-printgpt

edl-printgpt:: ## Read and print GPT partition table from connected device
  @$(EDL_DOCKER_RUN) printgpt
```

### 3. Documentation Standards

- All public documentation must be formatted according to `.editorconfig` and `.markdownlint-cli2.jsonc`.
- Text lines must not exceed 150 characters (`MD013`).

---

## Local Verification

Before submitting a Pull Request, run the following verification steps:

```bash
# Verify Make commands listing
make help
make list

# Verify shell script syntax
bash -n docker/docker-entrypoint.sh

# Verify Markdown documentation linting
npx markdownlint-cli2

# Test container build locally
make docker-build
```

---

## Contact & Support

If you have questions or need assistance, contact the maintainers at **BoardPort Team <boardport@proton.me>**
or open an issue on [GitHub Issues](https://github.com/boardport/edl-container/issues).
