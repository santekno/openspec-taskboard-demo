# Proposal: Baseline the existing Taskboard

## Why

Taskboard already runs in production-like form (a health endpoint and a home page), but `openspec/specs/` is empty. Without a baseline, the first feature change would describe the old behavior as if it were new, and nobody could tell what must stay the same. This change records what the code does **today**, as-is, before any feature work. It takes its scope from section 8 (capability candidates) of `docs/legacy-map.md`, written in the previous increment `map-taskboard`.

Risk: **low**. No application code changes; only specs and characterization tests are added.

## What Changes

- Record the current behavior as specs: `GET /api/health` and the home page health status.
- Add characterization tests that lock that behavior (separate files, so later changes do not conflict with them).
- No behavior changes. Anything that looks like a bug is written down as-is and deferred.

Deferred to a later change: every feature (task list, auth, persistence) and any fix to current behavior.

## Capabilities

### New Capabilities
- `api/health`: the health check endpoint as it behaves today
- `web/home`: the home page heading and API status line as they behave today

### Modified Capabilities
- (none)

## Impact

`openspec/specs/` gains two capabilities after archive. New test files only: `apps/api/internal/server/baseline_test.go`, `apps/web/src/App.baseline.test.tsx`. No runtime code, dependency, or deploy change.
