# Taskboard

Demo project for Spec-Driven Development with OpenSpec and Claude Code sub-agents.

- `apps/api`  Go 1.22+ HTTP API (port 8080)
- `apps/web`  React + Vite (port 5173, proxies `/api` to 8080)

Run locally:

    (cd apps/api && go run .)
    (cd apps/web && npm run dev)

Checks:

    (cd apps/api && go vet ./... && go test ./...)
    (cd apps/web && npm run typecheck && npm test && npm run e2e)
