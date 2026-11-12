# Tasks

## 1. Implementation

- [ ] 1.1 [backend-engineer] Scaffold `apps/api` (go.mod, main.go, server.go with `GET /api/health`); verify `go vet ./...` and `curl localhost:8080/api/health`
- [ ] 1.2 [backend-engineer] Add the bookmark store, `GET` and `POST /api/bookmarks` with URL and title validation; verify `curl -X POST -d '{"url":"x","title":"a"}'` returns 400
- [ ] 1.3 [frontend-engineer] Scaffold `apps/web` (Vite + React + TS, `/api` proxy, npm scripts from Scaffold decisions); verify `npm run typecheck`
- [ ] 1.4 [frontend-engineer] Add `BookmarkList` with empty state, labelled URL and Title inputs, Save button, and role alert errors; verify in the browser at localhost:5173

## 2. Tests

- [ ] 2.1 [test-engineer] Go table tests for every api/bookmarks scenario; verify `go test -race ./...` and one mutation per assertion
- [ ] 2.2 [test-engineer] Vitest setup and tests for every web/bookmark-list scenario; verify `npm test`
- [ ] 2.3 [integration-test-engineer] Playwright config with both web servers, e2e for save and invalid URL, and `.github/workflows/ci.yml`; verify `npm run e2e`

## 3. Review

- [ ] 3.1 [qa-engineer] Check scenarios against code and tests, run `bash scripts/check.sh`, give VERDICT: SHIP or DO-NOT-SHIP
