# Taskboard · OpenSpec + Claude Code sub-agents demo

Workshop repo for **Spec-Driven Development with OpenSpec**. One small change
(`add-task-list`) goes from an idea to a merged PR, built by six Claude Code
sub-agents working as a pipeline:

| Sub-agent | Job | Default model |
| --- | --- | --- |
| product-manager | Explore options, write proposal, specs, design, tasks | opus |
| backend-engineer | Go API in `apps/api` | sonnet |
| frontend-engineer | React UI in `apps/web/src` | sonnet |
| test-engineer | Unit tests, one per spec scenario | sonnet |
| integration-test-engineer | Playwright e2e across the real API and browser | sonnet |
| qa-engineer | Read-only gate: `SHIP` or `DO-NOT-SHIP` | opus |

The app is deliberately tiny: a Go 1.22+ `net/http` API (port 8080) and a
React + Vite web app (port 5173, proxies `/api`). `main` only has a health
check, so the demo has something real to build.

## Before the demo

Requirements: Node.js ≥ 22.12, Go ≥ 1.22, Git, GitHub CLI (logged in),
Claude Code (logged in), OpenSpec 1.16.x.

```bash
npm install -g @fission-ai/openspec@latest
git clone https://github.com/santekno/openspec-taskboard-demo.git
cd openspec-taskboard-demo
bash scripts/preflight.sh                  # tools, gh login, model-routing env
(cd apps/web && npm ci && npx playwright install chromium)
bash scripts/check.sh                       # go test, vitest, typecheck, e2e
```

The demo pushes branches, opens PRs, and merges into `main`, so run it in **your
own copy**, not in this repo. One command creates it (private by default) with
`main` and all `demo/*` branches, and keeps this repo as `upstream`:

```bash
bash scripts/make-workspace.sh taskboard-demo        # add --public to make it public
```

Make a fresh copy (another name) for each rehearsal, so the live run starts from a clean `main`.

Optional, to stop permission prompts during the live run (machine-only, git-ignored):

```bash
mkdir -p .claude && cp scripts/settings.local.example.json .claude/settings.local.json
```

`CLAUDE_CODE_SUBAGENT_MODEL` must be **unset**, otherwise it overrides every
agent's model and the routing below does nothing.

## Demo flow

| Step | What you run | Fallback branch |
| --- | --- | --- |
| 1. Init OpenSpec | `openspec init --tools claude` | |
| 2–3. Sub-agents + workflow | `bash scripts/setup-agents.sh` (CLAUDE.md, `openspec/config.yaml`, 6 agents) | `demo/ready` |
| 4. Explore | `/opsx:explore I want users to see and add tasks on the Taskboard home page…` | |
| 5. Propose | `git switch -c feat/add-task-list` then `/opsx:propose add-task-list` | `demo/after-propose` |
| 6. Apply | `/clear` then `/opsx:apply add-task-list` (4 stages + QA loop) | `demo/after-apply` |
| 7. PR | The apply guidance ends with `gh pr create`; then `gh pr checks --watch` | |
| 8. Archive | `/opsx:archive add-task-list` on `chore/archive-add-task-list` | `demo/after-archive` |

If a live step stalls, jump to the next safe point and keep going:

```bash
git switch -c demo-live origin/demo/after-propose   # or demo/ready, demo/after-apply, demo/after-archive
```

Skipping ahead to `demo/after-apply` mid-demo? Push it as the PR branch: `git push -u origin demo-live:feat/add-task-list`, then `gh pr create --fill`.

What each fallback branch contains:

- `demo/ready`: `main` + `openspec init --tools claude` + `scripts/setup-agents.sh`.
- `demo/after-propose`: + `openspec/changes/add-task-list/` (proposal, 2 delta specs, design with a Mermaid flow and file-change table, tasks tagged by agent). Passes `openspec validate --strict`.
- `demo/after-apply`: + reference implementation and tests (`GET`/`POST /api/tasks`, `TaskList` UI, unit tests, e2e), all tasks checked.
- `demo/after-archive`: change archived, `openspec/specs/api/tasks` and `openspec/specs/web/task-list` created.

## Model routing

Defaults live in each agent's frontmatter (`model:`). Before every dispatch the
main agent checks the triggers in `CLAUDE.md` and, if one matches, passes a
higher model for that single call only:

| Sub-agent | Escalate to | When |
| --- | --- | --- |
| product-manager | fable | proposal sent back twice, or 3+ capabilities |
| backend-engineer | opus | concurrency (`sync.Mutex`, goroutines, channels) or a repeated fix |
| frontend-engineer | opus | bug not reproduced, or a second loop |
| test-engineer | opus | not reproduced, or concurrency / `-race` tests |
| integration-test-engineer | opus | flaky e2e after one retry |
| qa-engineer | fable | high-risk proposal or diff |

In this change `design.md` uses `sync.Mutex`, so backend-engineer runs on Opus.

## Layout

```
apps/api/                  Go API (go vet, go test -race)
apps/web/                  React + Vite (typecheck, vitest, playwright)
.github/workflows/ci.yml   go-test, web-test, e2e
scripts/setup-agents.sh    writes CLAUDE.md, openspec/config.yaml, .claude/agents/*.md
scripts/check.sh           every CI check locally (--no-e2e to skip Playwright)
scripts/preflight.sh       presenter-laptop checks
scripts/make-workspace.sh  your own GitHub copy with all demo/* branches
```

## Commands cheat sheet

```bash
openspec list                                  # active changes and task progress
openspec status --change add-task-list         # which artifacts are done
openspec validate add-task-list --strict       # validate one change
openspec instructions apply --change add-task-list --json   # what the agent receives
openspec validate --specs --strict             # after archive
```

Presenter: Ihsan Arif Rahman · [santekno.com](https://santekno.com)
