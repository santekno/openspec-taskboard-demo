#!/usr/bin/env bash
# Runs every check CI runs. Usage: bash scripts/check.sh [--no-e2e]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "== go vet + go test -race"
(cd "$ROOT/apps/api" && go vet ./... && go test -race ./...)

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
