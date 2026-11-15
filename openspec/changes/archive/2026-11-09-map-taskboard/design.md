# Design

## Flow

```mermaid
flowchart LR
    CODE["apps/api + apps/web<br>.github/workflows<br>(read-only)"] --> PM["product-manager<br>reads code, reports<br>structure + flows"]
    PM --> MAP["docs/legacy-map.md<br>structure, flows,<br>risks, capability candidates"]
    MAP --> CFG["openspec/config.yaml<br>context: read the map first"]
    MAP --> QA["qa-engineer<br>checks the map against the code"]
    MAP -.-> NEXT["next: baseline-taskboard<br>specs from capability candidates"]

    subgraph Legend
        LC["Create"]:::create
        LM["Modify"]:::modify
        LD["Delete"]:::delete
    end

    classDef create fill:#dcfce7,stroke:#16a34a,color:#14532d
    classDef modify fill:#fef3c7,stroke:#d97706,color:#78350f
    classDef delete fill:#fee2e2,stroke:#dc2626,color:#7f1d1d
    class MAP create
    class CFG modify
```

## File changes

| Path | Action | Owner agent | Why |
| --- | --- | --- | --- |
| `docs/legacy-map.md` | Create | product-manager (report) → main agent (writes) | The shared map of the code as it is |
| `openspec/config.yaml` | Modify | main agent | `context` tells agents to read the map first |
| Application code, tests, specs | None | — | A map never changes behavior |
| None | Delete | — | Nothing is removed |

## Decisions

- **Map, not specs.** The map describes structure and flows in prose and diagrams; behavior goes into specs in the baseline change. Mixing them makes both stale.
- **Living document.** `docs/legacy-map.md` is updated whenever a change alters structure or a flow; it is not archived.
- **Every claim points at a file.** Each component and flow names the file and function it comes from, so the map can be checked.
- Fixed sections: Structure, Entry points, Components, Flows, Dependencies, Tests, Risks and refactor candidates, Capability candidates.
