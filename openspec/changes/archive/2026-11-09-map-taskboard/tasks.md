# Tasks

## 1. Map

- [x] 1.1 [product-manager] Read apps/api, apps/web, CI, and scripts read-only; report structure, entry points, flows, tests, and risks with file references; verify every claim names a file
- [x] 1.2 [main agent] Write `docs/legacy-map.md` from the report with one Mermaid diagram per flow; verify the diagrams render (GitHub preview)
- [x] 1.3 [main agent] Add "read docs/legacy-map.md first" to `openspec/config.yaml` context; verify `openspec validate --all --strict`

## 2. Review

- [x] 2.1 [qa-engineer] Check each component, flow, and test claim against the code, confirm only `docs/` and `openspec/` changed (`git diff --stat main`), give VERDICT: SHIP or DO-NOT-SHIP
