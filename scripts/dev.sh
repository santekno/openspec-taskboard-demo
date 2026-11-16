#!/usr/bin/env bash
# Runs the whole app locally with one command:
#   API (Go) on :8080, web (Vite) on :5173, and users-auth on :8081 when the branch has it.
# Logs are prefixed with [api] [web] [users-auth]. Ctrl+C stops everything.
# Usage: bash scripts/dev.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ ! -d "$ROOT/apps/api" ]; then
  echo "No apps/ on this branch yet (greenfield start). Run /opsx:apply first."
  exit 1
fi

for port in 8080 5173 $([ -d "$ROOT/apps/users-auth" ] && echo 8081); do
  if (exec 3<>"/dev/tcp/127.0.0.1/$port") 2>/dev/null; then
    echo "Port $port is already in use. Stop that process first."
    exit 1
  fi
done

if [ ! -d "$ROOT/apps/web/node_modules" ]; then
  echo "== installing web dependencies (npm ci)"
  (cd "$ROOT/apps/web" && npm ci)
fi

# Stop every child (go run, the compiled binary, vite) when this script exits.
trap 'trap - INT TERM EXIT; kill 0 2>/dev/null' INT TERM EXIT

start() {
  local name=$1 dir=$2; shift 2
  (cd "$ROOT/$dir" && exec "$@") 2>&1 | sed -u "s/^/[$name] /" &
}

wait_for() {
  for _ in $(seq 1 60); do
    curl -sf "$1" >/dev/null 2>&1 && return 0
    sleep 1
  done
  echo "Timed out waiting for $1"; return 1
}

if [ -d "$ROOT/apps/users-auth" ]; then
  start users-auth apps/users-auth go run .
  wait_for http://localhost:8081/health
fi
start api apps/api go run .
start web apps/web npm run dev
wait_for http://localhost:8080/api/health
wait_for http://localhost:5173/

echo
echo "  Web   http://localhost:5173"
echo "  API   http://localhost:8080/api/health"
[ -d "$ROOT/apps/users-auth" ] && echo "  Users http://localhost:8081/users/u-1"
echo "  Ctrl+C stops everything."
echo
wait
