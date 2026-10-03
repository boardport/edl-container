## Description

Provide a clear and concise description of the changes proposed in this Pull Request.

## Affected Components

- [ ] Docker Environment (`Dockerfile.debian`, dependencies)
- [ ] Entrypoint & Scripting (`docker-entrypoint.sh`, UID/GID normalization)
- [ ] Device Support & Hardware Quirks (Loaders, udev rules)
- [ ] Make Tooling (`.make/*.mk`)
- [ ] AI Agent Context & Skills (`.ai/`, `AGENTS.md`)
- [ ] GitHub Infrastructure & CI (`.github/`)
- [ ] Documentation (`README.md`, `ARCHITECTURE.md`)

## Type of Change

- [ ] New device support or Firehose loader
- [ ] Bug fix / recipe correction
- [ ] Performance / image size optimization
- [ ] Documentation update
- [ ] Refactoring / code cleanup
- [ ] Breaking change

## Quality Checklist

- [ ] Local container build succeeds (`make docker-build`).
- [ ] Multi-architecture compatibility (`linux/amd64`, `linux/arm64`) is preserved.
- [ ] Shell script syntax is verified (`bash -n docker/docker-entrypoint.sh`).
- [ ] Root `Makefile` is untouched (all targets added to `.make/*.mk` with `::` syntax).
- [ ] Markdown linting passes: `npx markdownlint-cli2` returns 0 issues.
- [ ] Mirrored documentation (`*.md` and `*_RU.md`) is synchronized.
- [ ] Tested with target device in Qualcomm EDL (9008) mode (if applicable).

## Related Issues

Closes #[Issue Number]
