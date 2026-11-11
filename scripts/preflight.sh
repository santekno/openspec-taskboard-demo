#!/usr/bin/env bash
# Checks the presenter laptop before the demo. Usage: bash scripts/preflight.sh
set -uo pipefail
ok=1
need() { if command -v "$1" >/dev/null; then printf '  ✓ %-9s %s\n' "$1" "$($1 $2 2>&1 | head -1)"; else printf '  ✗ %-9s missing\n' "$1"; ok=0; fi; }

echo "Tools:"
need node --version
need go version
need git --version
need gh --version
need openspec --version
need claude --version

node_ver="$(node -p 'process.versions.node' 2>/dev/null || echo 0)"
node -e 'const [a,b]=process.versions.node.split(".").map(Number);process.exit(a>22||(a===22&&b>=12)?0:1)' 2>/dev/null \
  || { echo "  ✗ Node $node_ver: OpenSpec 1.16 needs >= 22.12"; ok=0; }

echo "GitHub:"
gh auth status >/dev/null 2>&1 && echo "  ✓ gh logged in" || { echo "  ✗ run: gh auth login"; ok=0; }

echo "Model routing:"
if [ -n "${CLAUDE_CODE_SUBAGENT_MODEL:-}" ]; then
  echo "  ✗ CLAUDE_CODE_SUBAGENT_MODEL=$CLAUDE_CODE_SUBAGENT_MODEL overrides every agent model; run: unset CLAUDE_CODE_SUBAGENT_MODEL"; ok=0
else
  echo "  ✓ CLAUDE_CODE_SUBAGENT_MODEL is unset"
fi

[ "$ok" = 1 ] && echo "Ready for the demo." || { echo "Fix the items marked ✗."; exit 1; }
