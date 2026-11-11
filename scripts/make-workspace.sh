#!/usr/bin/env bash
# Creates your own GitHub copy of this repo (all demo/* branches included) for a rehearsal
# or the live demo, so PRs and merges never touch santekno/openspec-taskboard-demo.
# Usage: bash scripts/make-workspace.sh [repo-name] [--public]   (default: taskboard-demo, private)
set -euo pipefail
NAME="${1:-taskboard-demo}"
VIS="--private"; [ "${2:-}" = "--public" ] && VIS="--public"
cd "$(dirname "$0")/.."

if ! git remote get-url upstream >/dev/null 2>&1; then
  git remote rename origin upstream
fi
git fetch -q upstream
git switch -q main

gh repo create "$NAME" "$VIS" --source . --remote origin
git push -u origin main
git push origin 'refs/remotes/upstream/demo/*:refs/heads/demo/*'

echo
echo "Your copy: $(git remote get-url origin)"
echo "Branches:  main + $(git ls-remote --heads origin 'demo/*' | wc -l | tr -d ' ') demo/* fallback branches"
echo "Next:      bash scripts/preflight.sh && bash scripts/check.sh"
