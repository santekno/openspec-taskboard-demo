#!/usr/bin/env bash
# Runs every check CI runs. Usage: bash scripts/check.sh [--no-e2e]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "== go vet + go test -race"
(cd "$ROOT/apps/api" && go vet ./... && go test -race ./...)

if [ -d "$ROOT/apps/users-auth" ]; then
  echo "== users-auth tests + contract test"
  (cd "$ROOT/apps/users-auth" && go test ./...)
  if curl -sf localhost:8081/health >/dev/null 2>&1; then
    (cd "$ROOT/apps/api" && USERS_AUTH_URL=http://localhost:8081 go test -count=1 -run Contract ./internal/usersauth/)
  else
    (cd "$ROOT/apps/users-auth" && go build -o "$ROOT/.users-auth.bin" .)
    "$ROOT/.users-auth.bin" & UA_PID=$!
    trap 'kill $UA_PID 2>/dev/null; rm -f "$ROOT/.users-auth.bin"' EXIT
    for _ in $(seq 1 30); do curl -sf localhost:8081/health >/dev/null && break; sleep 0.3; done
    (cd "$ROOT/apps/api" && USERS_AUTH_URL=http://localhost:8081 go test -count=1 -run Contract ./internal/usersauth/)
    kill $UA_PID 2>/dev/null; rm -f "$ROOT/.users-auth.bin"; trap - EXIT
  fi
fi

echo "== web typecheck + unit tests"
(cd "$ROOT/apps/web" && npm run --silent typecheck && npm test --silent)

if [ "${1:-}" != "--no-e2e" ]; then
  echo "== e2e (Playwright)"
  (cd "$ROOT/apps/web" && npm run --silent e2e)
fi

if [ -d "$ROOT/openspec" ] && command -v openspec >/dev/null; then
  echo "== openspec validate"
  (cd "$ROOT" && OPENSPEC_TELEMETRY=0 openspec validate --all --strict)
fi
echo "All checks passed."
