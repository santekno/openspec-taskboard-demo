# Tasks

## 1. Implementation

- [x] 1.1 [backend-engineer] Add `internal/usersauth` client with `GetUser`, `ErrNotFound`, `ErrUnavailable`, and a 2 s timeout; verify `go vet ./...`
- [x] 1.2 [backend-engineer] Accept optional `assigneeId` in `POST /api/tasks`, look it up before create, return `assignee`; verify `curl -X POST -d '{"title":"a","assigneeId":"u-404"}'` returns 400
- [x] 1.3 [frontend-engineer] Add the labelled "Assignee ID" input and "Assigned to <name>" in the list; verify `npm run typecheck`
- [ ] 1.4 [main agent] Update `docs/legacy-map.md`: users-auth as an external system, a flow for assigning a task, tests, risks; verify the diagram renders

## 2. Tests

- [ ] 2.1 [test-engineer] Go tests for every api/tasks scenario with a fake `UserLookup`, plus client tests against an httptest fake; verify `go test -race ./...`
- [ ] 2.2 [test-engineer] Vitest tests for the new web/task-list scenarios; verify `npm test`
- [ ] 2.3 [integration-test-engineer] Contract test against the running users-auth, Playwright with three servers, CI `contract` job; verify `bash scripts/check.sh`

## 3. Review

- [ ] 3.1 [qa-engineer] Check scenarios against code and tests, confirm `apps/users-auth` and `contracts/` are unchanged (`git diff --stat main -- apps/users-auth contracts`), run all checks, give VERDICT: SHIP or DO-NOT-SHIP
