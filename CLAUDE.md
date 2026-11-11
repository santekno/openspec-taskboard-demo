# Taskboard

Demo project for Spec-Driven Development with OpenSpec and Claude Code sub-agents.
Apply and archive rules live in `openspec/config.yaml` (`operations`); artifact rules in `rules`.
This file holds what config.yaml cannot: explore and propose behavior.

## Layout

- `apps/api` Go API, `go test ./...`
- `apps/web` React + Vite, `npm run typecheck`, `npm test`, `npm run e2e`

## Sub-agents

| Agent | Role | Writes | Model |
| --- | --- | --- | --- |
| product-manager | OpenSpec artifacts | `openspec/changes/<change>/` | opus |
| backend-engineer | Go API | `apps/api/**` except `*_test.go` | sonnet |
| frontend-engineer | React UI | `apps/web/src/**` except tests, web config files | sonnet |
| test-engineer | Unit tests | `*_test.go`, `*.test.ts(x)` | sonnet |
| integration-test-engineer | Playwright e2e | `apps/web/e2e/`, `playwright.config.ts` | sonnet |
| qa-engineer | Read-only gate | nothing | opus |

## Sub-agent model routing

Every sub-agent has a default `model` in its frontmatter. Before each dispatch, the main agent
checks the escalation triggers below and, if one matches, passes the higher model in the Agent
call's `model` parameter. Do not ask the owner; decide from the plan, the diff, and the task.

### Defaults (frontmatter)

| Sub-agent | Default |
| --- | --- |
| product-manager | opus |
| backend-engineer | sonnet |
| frontend-engineer | sonnet |
| test-engineer | sonnet |
| integration-test-engineer | sonnet |
| qa-engineer | opus |

### How to detect a risky change

Before dispatching, run:

```bash
git diff --name-only main...HEAD
git diff main...HEAD | grep -iE 'sync\.Mutex|go func|chan |password|token|secret|auth|migration'
grep -iE 'mutex|goroutine|concurren|risk: \*\*high' openspec/changes/<change>/{proposal,design,tasks}.md
```

### Escalation triggers

| Sub-agent | Escalate to | When |
| --- | --- | --- |
| product-manager | fable | The owner sent the proposal back twice, or the change spans 3+ capabilities |
| backend-engineer | opus | The task or design touches shared state or concurrency (mutex, goroutines, channels), or QA sends the same backend fix back a second time |
| frontend-engineer | opus | A browser-state bug was not reproduced after the first attempt, or QA sends the same UI fix back a second time |
| test-engineer | opus | A bug was not reproduced after the first attempt, or the tests cover concurrency (`go test -race`) |
| integration-test-engineer | opus | An e2e test is flaky (fails, then passes on rerun) after the first attempt |
| qa-engineer | fable | The proposal risk is high, or the diff matches the risky-change grep above |

### Rules

- Never set `model: fable` in frontmatter. Fable is the slowest and heaviest on usage limits; it is escalation-only.
- Escalate per call only. Do not keep the higher model for later calls unless they also match a trigger.
- When escalating, state the trigger in one line in the handoff, e.g. "backend-engineer on opus: design.md uses sync.Mutex".
- `CLAUDE_CODE_SUBAGENT_MODEL` must be unset; if set, it overrides every frontmatter default and per-call model.
- Small fixes outside /opsx:apply (single file, no trigger): do the work in the main session, then dispatch only test-engineer and qa-engineer at their defaults.

## Explore (/opsx:explore)

- Read-only. Read `openspec list`, `openspec/config.yaml`, and the code before discussing.
- Ask the product-manager sub-agent to draft 1-2 increment options with risk and capabilities touched.
- One question to the owner per turn. When the decision is clear, offer `/opsx:propose`; never write files without permission.

## Propose (/opsx:propose)

- Delegate artifact drafting to the product-manager sub-agent; it follows `openspec instructions <artifact>`.
- Finish with `openspec validate <change> --strict` and stop for owner review. Do not start apply.

## Git

- Only the main agent commits, pushes, and opens PRs. Sub-agents never run git write commands.
