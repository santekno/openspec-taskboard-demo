# Tasks

## 1. Implementation

- [x] 1.1 [backend-engineer] Add the in-memory task store and `GET /api/tasks`; verify with `go vet ./...` and `curl localhost:8080/api/tasks` returning `[]`
- [x] 1.2 [backend-engineer] Add `POST /api/tasks` with title trimming and validation; verify `curl -X POST -d '{"title":""}'` returns 400
- [x] 1.3 [frontend-engineer] Show the task list with the "No tasks yet" empty state; verify `npm run typecheck`
- [x] 1.4 [frontend-engineer] Add the labelled "Title" form with "Add task" and a role alert error; verify in the browser at localhost:5173

## 2. Tests

- [ ] 2.1 [test-engineer] Go table tests for every api/tasks scenario; verify `go test ./...` and one mutation per assertion
- [ ] 2.2 [test-engineer] Vitest tests for every web/task-list scenario; verify `npm test`
- [ ] 2.3 [integration-test-engineer] Playwright e2e: add a task and see it listed, see the error for an empty title; verify `npm run e2e`

## 3. Review

- [ ] 3.1 [qa-engineer] Check scenarios against code and tests, run all checks, give VERDICT: SHIP or DO-NOT-SHIP
