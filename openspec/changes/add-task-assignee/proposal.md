# Proposal: Assign a task to a user from users-auth

## Why

Teams want to know who owns a task. Users already live in the company's **users-auth** service (Identity team); Taskboard must not keep its own user list. So a task stores only an `assigneeId`, and Taskboard checks it against users-auth when the task is created.

Risk: **high**. It adds a runtime dependency on another team's service (network failure, contract drift) and touches user data (names). No auth flow, no stored data change beyond one field, no deploy change.

## What Changes

- Record the parts of the users-auth contract Taskboard relies on as a spec (`ext/users-auth`), as-is. Taskboard does not change users-auth.
- `POST /api/tasks` accepts an optional `assigneeId`; the API looks the user up in users-auth: unknown id → 400, users-auth down or slow → 502, found → the task carries `assignee {id, name}`.
- The Add task form gets an optional "Assignee ID" input; a listed task shows "Assigned to <name>".
- A contract test runs Taskboard's users-auth client against the real (mock) service, and e2e runs across all three processes.

Deferred to a later change: picking a user from a list (users-auth has no list endpoint yet), reassigning, logging in with `POST /auth/verify`, caching user names.

## Capabilities

### New Capabilities
- `ext/users-auth`: the users-auth endpoints Taskboard consumes, recorded as-is from `contracts/users-auth.openapi.yaml`

### Modified Capabilities
- `api/tasks`: create task accepts an optional assignee validated through users-auth
- `web/task-list`: add an optional assignee and show the assignee's name

Three capabilities, but `ext/users-auth` only records an existing contract; per CLAUDE.md routing, product-manager may escalate (3+ capabilities) and qa-engineer reviews a high-risk diff.

## Impact

`apps/api` (new `internal/usersauth` client, task handler), `apps/web/src/TaskList.tsx`, tests, `playwright.config.ts` (third web server), CI (contract job). Config: `USERS_AUTH_URL` (default `http://localhost:8081`). `apps/users-auth` and `contracts/` are **not** modified.
