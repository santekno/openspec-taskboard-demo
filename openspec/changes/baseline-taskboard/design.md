# Design: Baseline the existing Taskboard

## Flow

```mermaid
flowchart LR
  code["docs/legacy-map.md<br>flows + capability candidates"] --> explore["/opsx:propose<br>scope from section 8"]
  explore --> specs["specs/api/health<br>specs/web/home<br>(ADDED, as-is)"]
  specs --> tests["baseline_test.go<br>App.baseline.test.tsx"]
  tests --> archive["openspec archive<br>→ openspec/specs/"]

  subgraph Legend
    c[create]:::create
    m[modify]:::modify
    d[delete]:::delete
  end
  class specs,tests,archive create
  classDef create fill:#ECFDF5,stroke:#047857,color:#065F46
  classDef modify fill:#EEF3FF,stroke:#1A4CFF,color:#0A3BD8
  classDef delete fill:#FEF2F2,stroke:#B91C1C,color:#991B1B
```

## File changes

| Path | Action | Owner agent | Why |
| --- | --- | --- | --- |
| `openspec/changes/baseline-taskboard/**` | Create | product-manager | Proposal and as-is specs |
| `apps/api/internal/server/baseline_test.go` | Create | test-engineer | Lock health, 405, and 404 behavior |
| `apps/web/src/App.baseline.test.tsx` | Create | test-engineer | Lock checking / ok / unreachable states |
| Application code | None | — | A baseline never changes behavior |
| Delete | None | — | Nothing is removed |

## Decisions

- **Specs describe what the code does, not what it should do.** If a test written from the spec fails, the spec is wrong, not the code.
- **Characterization tests live in their own files** so the feature changes that follow can edit `server_test.go` and `App.test.tsx` without touching the baseline.
- No API contract changes.
