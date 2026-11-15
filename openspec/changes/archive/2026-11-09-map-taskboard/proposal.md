# Proposal: Map the existing Taskboard code

## Why

Taskboard already runs, but nobody has written down how it is built: which modules exist, how a request flows, what is tested, and what looks risky. Before we baseline its behavior as specs, or plan any refactor, we need one shared map that people and agents can read. This is increment 1 for any existing product.

Risk: **low**. Documentation only. No application code, tests, or specs change (`skip_specs: true`).

## What Changes

- Add `docs/legacy-map.md`: structure, entry points, components, flows (Mermaid), dependencies, test coverage, risks and refactor candidates, and the capability candidates for the baseline.
- Point `openspec/config.yaml` `context` at the map, so every later explore and propose reads it first.

Deferred to a later change: the baseline specs and characterization tests (`baseline-taskboard`), and every refactor listed in the map.

## Capabilities

### New Capabilities
- (none; this change is documentation only)

### Modified Capabilities
- (none)

## Impact

New `docs/legacy-map.md`; one line in `openspec/config.yaml` `context`. Nothing else.
