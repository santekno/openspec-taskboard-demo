#!/usr/bin/env bash
# Creates your own GitHub copy of this repo (all demo/*, greenfield/*, integration/* branches) for a rehearsal
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
for p in demo greenfield integration; do
  git push origin "refs/remotes/upstream/$p/*:refs/heads/$p/*"
done

echo
echo "Your copy: $(git remote get-url origin)"
echo "Branches:  main + $(git ls-remote --heads origin 'demo/*' 'greenfield/*' 'integration/*' | wc -l | tr -d ' ') scenario branches"
echo "Next:      bash scripts/preflight.sh && bash scripts/check.sh"
