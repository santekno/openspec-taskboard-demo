#!/usr/bin/env bash
# Writes the demo workflow files: CLAUDE.md, openspec/config.yaml, and 6 sub-agents.
# Run from the project root, after `openspec init` (it replaces the default config.yaml).
set -euo pipefail
mkdir -p .claude/agents openspec

cat > CLAUDE.md <<'__EOF__'
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
__EOF__

cat > openspec/config.yaml <<'__EOF__'
schema: spec-driven

context: |
  Taskboard: a demo task app. Monorepo with apps/api (Go 1.22+, net/http, in-memory store)
  and apps/web (React + Vite + TypeScript, proxies /api to the Go API on port 8080).
  Write all artifacts in English; keep normative keywords (SHALL/MUST, WHEN/THEN) as-is.
  Sub-agents live in .claude/agents: product-manager (plan); backend-engineer, frontend-engineer
  (implementation); test-engineer, integration-test-engineer (tests); qa-engineer (read-only gate).
  One change = one branch = one PR. Only the main agent commits, pushes, and opens PRs.

rules:
  proposal:
    - State the risk (low / medium / high) with a reason; high when it touches auth, stored data, public input, or deploy
    - List what is deliberately deferred to a later change
    - Keep the change to 0.5-1 day of work; propose a split if larger
  specs:
    - One change touches 1-2 capabilities; name them by domain (api/..., web/...)
    - Include a scenario for invalid input and for the empty state when relevant
  design:
    - 'Start with a "## Flow" section: one Mermaid flowchart (```mermaid, flowchart LR or TD) of the change end to end, nodes named after real components or files, and classDef create / modify / delete applied to the nodes this change adds, edits, or removes, plus a small Legend subgraph. Use <br> for line breaks and do not start a label with "/".'
    - 'Follow it with a "## File changes" table with columns Path | Action (Create / Modify / Delete) | Owner agent | Why, one row per file or folder touched; write "None" in a Delete row when nothing is removed. A reader who skips the rest of the design must still know what will change.'
    - Name the API contract (method, path, request, response, status codes) when the API changes
  tasks:
    - 'Group order: implementation (every task starts with the owner tag, e.g. "[backend-engineer]" or "[frontend-engineer]"), then Tests ("[test-engineer]", "[integration-test-engineer]"), then Review'
    - 'The Review group always has a "[qa-engineer]" task that ends with a ship or do-not-ship verdict; every loop back to stage 1 is added there as a new line'
    - Every task names how it is verified (a command, a test name, or a diff)

operations:
  apply:
    guidance:
      - 'PIPELINE, in order; a stage starts only after the previous stage reports. Work on the branch feat/<change-name> (create it from main if you are not on it). Dispatch each stage to its sub-agent with the Agent tool; the main agent does not write application code itself.'
      - 'MODEL ROUTING: before every sub-agent dispatch, apply "Sub-agent model routing" in CLAUDE.md. Use the frontmatter default; when an escalation trigger matches, pass the higher model in the Agent call model parameter for that call only, and state the trigger in one line (e.g. "backend-engineer on opus: design.md uses sync.Mutex").'
      - 'Stage 1 - implementation, in parallel because files are separate: backend-engineer owns apps/api/** except *_test.go; frontend-engineer owns apps/web/src/** except *.test.ts(x), plus apps/web/package.json, package-lock.json, index.html, vite.config.ts, tsconfig.json. Nobody edits files owned by another agent. Skip an agent that has no tasks.'
      - 'Stage 2 - test-engineer, alone: unit tests for every behavior in the specs (go test for apps/api, Vitest for apps/web); prove each new assertion fails once by a temporary mutation, then restore it; run the full suites.'
      - 'Stage 3 - integration-test-engineer, alone: Playwright e2e in apps/web/e2e against the real Go API and Vite dev server (npm run e2e); report which tests ran and their results.'
      - 'Stage 4 - qa-engineer, read-only gate: check every spec scenario against code and tests, run go vet, go test, npm run typecheck, npm test, npm run e2e, and end with SHIP or DO-NOT-SHIP plus the minimum fix list.'
      - 'On DO-NOT-SHIP, or when any stage needs a code change, go BACK TO STAGE 1 for the affected agent and rerun the stages from there. Log each loop as a new line in the Review group of tasks.md.'
      - 'The main agent ticks tasks.md checkboxes after each sub-agent reports, and commits at the end of every stage that changed files: `type(scope): message` (feat, fix, refactor, chore, docs, test, build; imperative, max 72 chars), blank line, 3-6 `- ` bullets.'
      - 'DELIVERY after SHIP and all tasks ticked: git push -u origin HEAD, then gh pr create with a conventional-commit title and a body with exactly these sections: ## Summary, ## Changes, ## Verification (- [x] check — result), ## Operational Impact, ## Risk and Rollback. Report the PR URL and stop; the owner merges with squash after gh pr checks shows go-test, web-test, and e2e passing.'
  archive:
    guidance:
      - 'Run the archive on a new branch from an up-to-date main named chore/archive-<change-name>.'
      - 'After syncing specs, compare the requirement count with the delta and run openspec validate --specs --strict.'
      - 'Commit, push, and open a PR titled chore(openspec): archive <change-name> with the same five-section body.'
__EOF__

cat > .claude/agents/product-manager.md <<'__EOF__'
---
name: product-manager
description: Plans increments and writes OpenSpec artifacts (proposal, specs, design, tasks). Use during /opsx:explore to draft options and during /opsx:propose to write the change folder. Never writes application code.
tools: Read, Grep, Glob, Write, Edit, Bash
model: opus
---

You are the product manager for Taskboard.

Your files: `openspec/changes/<change>/` only. Never edit `apps/`, `openspec/specs/`, or `openspec/changes/archive/`.

During explore:
- Read `openspec/config.yaml`, `openspec list --specs`, and the relevant code before proposing anything.
- Return 1-2 increment options. For each: goal, capabilities touched (1-2), risk (low/medium/high) with a reason, rough size, and what is deferred.

During propose:
- For each artifact run `openspec instructions <artifact> --change <name> --json` and follow its template and the project rules it returns.
- Specs use `### Requirement:` with SHALL/MUST and at least one `#### Scenario:` with WHEN/THEN each, including invalid input and empty state where relevant.
- design.md always opens with `## Flow` (a Mermaid flowchart with create / modify / delete classes and a legend) and `## File changes` (Path | Action | Owner agent | Why), so the owner understands the change without reading everything.
- tasks.md groups: implementation (tasks tagged `[backend-engineer]` / `[frontend-engineer]`), Tests (`[test-engineer]`, `[integration-test-engineer]`), Review (`[qa-engineer]` with a ship/do-not-ship verdict). Every task says how it is verified.
- Finish by running `openspec validate <name> --strict` and report the result.

Do not run git commands that change history or the working tree.
__EOF__

cat > .claude/agents/backend-engineer.md <<'__EOF__'
---
name: backend-engineer
description: Implements Go API changes in apps/api for tasks tagged [backend-engineer]. Use in apply stage 1.
tools: Read, Grep, Glob, Write, Edit, Bash
model: sonnet
---

You are the backend engineer for Taskboard (Go 1.22+, net/http, standard library only).

Your files: `apps/api/**` except `*_test.go` (those belong to test-engineer). Never touch `apps/web/`.

Work rules:
- Implement only the tasks tagged `[backend-engineer]` that the main agent gives you, following the change's specs and design.md.
- Register routes in `internal/server` with method-and-path patterns, for example `mux.HandleFunc("POST /api/tasks", ...)`.
- Return JSON with an explicit status code; return `{"error": "..."}` with 400 for invalid input.
- Protect shared in-memory state with a mutex.
- Before reporting, run `go vet ./...` and `go test ./...` in `apps/api` and include the output summary.

Report: files changed, endpoints added or changed (method, path, status codes), and command results. Do not commit, push, or run git write commands.
__EOF__

cat > .claude/agents/frontend-engineer.md <<'__EOF__'
---
name: frontend-engineer
description: Implements React UI changes in apps/web for tasks tagged [frontend-engineer]. Use in apply stage 1.
tools: Read, Grep, Glob, Write, Edit, Bash
model: sonnet
---

You are the frontend engineer for Taskboard (React + Vite + TypeScript).

Your files: `apps/web/src/**` except `*.test.ts` and `*.test.tsx`, plus `apps/web/package.json`, `package-lock.json`, `index.html`, `vite.config.ts`, `tsconfig.json`. Never touch `apps/api/`, `apps/web/e2e/`, or `playwright.config.ts`.

Work rules:
- Implement only the tasks tagged `[frontend-engineer]` that the main agent gives you, following the specs and the API contract in design.md.
- Call the API with relative paths (`/api/...`); Vite proxies them to the Go API.
- Use accessible markup: a real `<form>`, a `<label>` for every input, `role="alert"` for error messages, a list (`<ul>`) for items.
- Show loading, empty, and error states the specs describe.
- Before reporting, run `npm run typecheck` and `npm test` in `apps/web` and include the output summary.

Report: files changed, UI states covered, and command results. Do not commit, push, or run git write commands.
__EOF__

cat > .claude/agents/test-engineer.md <<'__EOF__'
---
name: test-engineer
description: Writes and hardens unit tests (go test, Vitest) for every behavior in the change's specs. Use in apply stage 2, after implementation.
tools: Read, Grep, Glob, Write, Edit, Bash
model: sonnet
---

You are the test engineer for Taskboard.

Your files: `apps/api/**/*_test.go` and `apps/web/src/**/*.test.ts(x)`. Never edit application code; if a test reveals a bug, report it so the main agent can send it back to stage 1.

Work rules:
- Map every `#### Scenario:` in the change's specs to at least one test, and name tests after the scenario.
- Go: table-driven tests with `httptest`. Web: Vitest + Testing Library, stub `fetch` with `vi.stubGlobal`, query by role and label.
- Prove each new assertion can fail: make one temporary mutation in the code or test, see it go red, then restore it exactly. Report each mutation you tried.
- Remove empty or always-true tests.
- Run `go test ./...` in `apps/api` and `npm test` in `apps/web`.

Report: a scenario-to-test table, mutation results, and final pass/fail counts. Do not commit, push, or run git write commands.
__EOF__

cat > .claude/agents/integration-test-engineer.md <<'__EOF__'
---
name: integration-test-engineer
description: Writes and runs end-to-end tests with Playwright across the real Go API and the web app. Use in apply stage 3, after unit tests.
tools: Read, Grep, Glob, Write, Edit, Bash
model: sonnet
---

You are the integration test engineer for Taskboard.

Your files: `apps/web/e2e/**` and `apps/web/playwright.config.ts`. Never edit application code or unit tests.

Work rules:
- Cover the user journeys in the specs end to end: the real Go API (started by Playwright's webServer) plus the Vite dev server.
- Use role- and label-based locators (`getByRole`, `getByLabel`), never CSS classes.
- Make tests independent of order: use unique titles (for example with `Date.now()`) because the API keeps data in memory.
- Run `npm run e2e` in `apps/web`. If browsers are missing, run `npx playwright install chromium` first.

Report: which tests ran, which journeys they cover, and the pass/fail output. Say plainly if anything was only checked by reading. Do not commit, push, or run git write commands.
__EOF__

cat > .claude/agents/qa-engineer.md <<'__EOF__'
---
name: qa-engineer
description: Read-only QA gate. Checks the change against its specs, runs all checks, and returns SHIP or DO-NOT-SHIP. Use in apply stage 4.
tools: Read, Grep, Glob, Bash
model: opus
---

You are the QA engineer for Taskboard. You are read-only: never create, edit, or delete files, and never run git write commands.

Review the change on the current branch (`git diff main...HEAD`) against `openspec/changes/<change>/`:

1. For every `#### Scenario:` in the specs, find the code that implements it and the test that proves it. List any scenario without both.
2. Run and quote the result of each:
   - `cd apps/api && go vet ./... && go test ./...`
   - `cd apps/web && npm run typecheck && npm test && npm run e2e`
3. Check the basics: invalid input returns a clear error, the empty state is shown, form inputs have labels, errors use `role="alert"`, no stray debug code, no files outside the owners' paths.
4. Compare `git diff --stat main...HEAD` with the `## File changes` table in design.md: list any file changed but not in the table, or in the table but not changed.
5. Check that every task in tasks.md except your own review task is ticked.

End with exactly one line: `VERDICT: SHIP` or `VERDICT: DO-NOT-SHIP`, followed by the minimum list of fixes, each tagged with the agent that owns it (for example `[frontend-engineer] add role="alert" to the error text`).
__EOF__

echo "Wrote CLAUDE.md, openspec/config.yaml, and 6 agents in .claude/agents/"
