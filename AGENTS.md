# Project Passport and Operational Guidelines for AI Agents: EDL Container

> **Project:** BoardPort — EDL Container  
> **Organization:** [BoardPort](https://github.com/boardport) | **Repository:** `boardport/edl-container`  
> **Upstream:** [bkerler/edl](https://github.com/bkerler/edl) (Bjoern Kerler, MIT License)  
> **Target Image:** `ghcr.io/boardport/edl` | **Packaging License:** [MIT](./LICENSE)  
> **Architecture Specification:** [ARCHITECTURE.md](./ARCHITECTURE.md) / [ARCHITECTURE_RU.md](./ARCHITECTURE_RU.md)  

---

## 1. AI Context Organization

The root [`AGENTS.md`](./AGENTS.md) and [`AGENTS_RU.md`](./AGENTS_RU.md) files serve as the authoritative baseline guidelines for all AI assistants.
Developers directly control, isolate, and customize secondary context for their specific tools:

- **Specialized Directories (`.(gemini|claude|cursor|continue|qwen|etc)/`):** Individual context for specific AI assistants
  (prompts, skills, reports, session dumps). These directories are isolated and excluded from git indexing (`.gitignore`).
- **Context Routing Files:** Navigation and indexing within specialized directories are organized via
  `.{ai}/README(_RU).md` or `.{ai}/AGENTS(_RU).md`. Specialized instructions complement the root guidelines and take precedence within their own context.
- **`.aiignore` File:** Defines resources strictly excluded from background indexing and scanning
  (memory dumps, raw firmware images, temporary caches). Agents may only access these files upon explicit user instruction.

---

## 2. Make Tooling (Shared Framework)

The `.make/` directory and root `Makefile` serve as a modular, reusable task runner abstracted from the project code:

- **Root [`Makefile`](./Makefile):** Acts as a shared orchestrator whose sole role is importing modules from `.make/*.mk`.
  Modifying the root `Makefile` is STRICTLY FORBIDDEN without explicit user instruction such as: `"Modify this file"`.
- **Modules `.make/*.mk`:** All development targets are grouped into modular `mk` files. All targets must use double-colon
  syntax (`target::`) and include `## Description` annotations for self-documentation.
- **Target Inspection:** Available commands are inspected via `make list` and `make help`.

---

## 3. Docker Project Context

- **Environment Specification:** Image architecture, entrypoint flow, and containerization rules are documented in [`docker/README.md`](./docker/README.md).
- **Command Execution Isolation:** All Qualcomm/EDL interactions must execute strictly inside Docker containers via
  `docker run ...` or Make targets `make edl-*`.
  Installing dependencies and invoking utilities directly on the host is prohibited.

---

## 4. Markdown Documentation Standards

- **Formatting Rules:** Syntax and formatting constraints are governed by `.editorconfig` and `.markdownlint-cli2.jsonc`.
- **Mandatory Lint Command:** `npx markdownlint-cli2` (must return `0 issues in 0 files` prior to concluding work).
- **Mirrored Bilingualism:** All public user documentation is maintained in parallel (`*.md` in English and `*_RU.md` in Russian).
- **Styling and Emoji:** Emojis are permitted but reserved primarily for public (user-facing) documentation.
- **Clarity of Presentation:** Public documents must remain simple, approachable, and provide clear step-by-step guidance.

---

## 5. Git and GitHub Standards (`.github/`)

- Organizational policies, issue templates, PR descriptions, and CI processes reside in [`.github/`](./.github/).
- Commit message standards and git templates are governed by the `.github/` context and agent-specific instructions.
- Creating Git commits is allowed **only upon direct user confirmation**.
