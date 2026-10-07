# Project Passport and Operational Guidelines for AI Agents: EDL Container

> **Project:** BoardPort — EDL Container  
> **Organization:** [BoardPort](https://github.com/boardport) | **Repository:** `boardport/edl-container`  
> **Upstream:** [bkerler/edl](https://github.com/bkerler/edl) (Bjoern Kerler, MIT License)  
> **Knowledge Base & Specifications:** [docs/overview.en.md](./docs/overview.en.md) |  
> [docs/architecture.en.md](./docs/architecture.en.md) | [docs/development.en.md](./docs/development.en.md)  

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

## 2. Knowledge Base and Technical Contracts (`docs/`)

The [`docs/`](./docs/) directory serves as the **authoritative technical source of truth** for the project.
All architectural, environmental, and hardware interaction decisions must strictly adhere to the documented specifications:

- **Mandatory Compliance:**
  - Architecture boundaries, execution lifecycles, and isolation models are defined in [`docs/architecture.en.md`](./docs/architecture.en.md).
  - Docker specifications, environment variables (`EDL_DUMP_UID`), hooks, and volume mounts — [`docs/development.en.md`](./docs/development.en.md).
  - Operational workflows, backups, flashing, and troubleshooting — [`docs/workflows.en.md`](./docs/workflows.en.md).
  - Host preparation, udev rules, and EDL mode entry — [`docs/quickstart.en.md`](./docs/quickstart.en.md).
  Agents are prohibited from implementing conflicting solutions.
- **Mandatory Synchronous Updates:** Any codebase changes affecting behavior (variables, runtime flags, entrypoint logic,
  Make targets) require immediate synchronous updates across corresponding documents in `docs/`.
- **Mirrored Bilingualism:** Documentation in `docs/` is strictly maintained in pairs: `*.en.md` (English) and `*.ru.md` (Russian).
- **Static Wiki Requirements (Fumadocs/VitePress):**
  - Relative paths leading outside the directory (`../`) are strictly prohibited. All references to repository files must use
    full GitHub URLs (`https://github.com/boardport/edl-container/blob/main/...`).
  - Do not introduce manual navigation headers ("Related Sections", breadcrumbs) or language badges in document bodies —
    sidebars, breadcrumbs, and pagination are handled automatically by the wiki engine.

---

## 3. Make Tooling (Shared Framework)

The `.make/` directory and root `Makefile` serve as a modular, reusable task runner abstracted from the project code:

- **Root [`Makefile`](./Makefile):** Acts as a shared orchestrator whose sole role is importing modules from `.make/*.mk`.
  Modifying the root `Makefile` is STRICTLY FORBIDDEN without explicit user instruction such as: `"Modify this file"`.
- **Modules `.make/*.mk`:** All development targets are grouped into modular `mk` files. All targets must use double-colon
  syntax (`target::`) and include `## Description` annotations for self-documentation.
- **Target Inspection:** Available commands are inspected via `make list` and `make help`.

---

## 4. Docker Project Context

- **Authoritative Environment Specification:** Container internals, multi-arch builds, runtime environment variables,
  and volume mount points are formally specified in [`docs/architecture.en.md`](./docs/architecture.en.md) and
  [`docs/development.en.md`](./docs/development.en.md). Local directory context is provided in [`docker/README.md`](./docker/README.md).
- **Command Execution Isolation:** All Qualcomm/EDL interactions must execute strictly inside Docker containers via
  `docker run ...` or Make targets `make edl-*`.
  Installing dependencies and invoking utilities directly on the host is prohibited.

---

## 5. Markdown Documentation Standards

- **Formatting Rules:** Syntax and formatting constraints are governed by `.editorconfig` and `.markdownlint-cli2.jsonc`.
- **Mandatory Lint Command:** `npx markdownlint-cli2` (must return `0 issues in 0 files` prior to concluding work).
- **Style and Conciseness:** Documentation must remain objective, technically accurate, and free of marketing fluff or tautologies.
- **Clarity of Presentation:** Public documents must remain simple, approachable, and provide clear step-by-step guidance.

---

## 6. Git and GitHub Standards (`.github/`)

- Organizational policies, issue templates, PR descriptions, and CI processes reside in [`.github/`](./.github/).
- Commit message standards and git templates are governed by the `.github/` context and agent-specific instructions.
- Creating Git commits is allowed **only upon direct user confirmation**.
