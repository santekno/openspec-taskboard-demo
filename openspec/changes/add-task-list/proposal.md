# Proposal: Add task list

## Why

The Taskboard home page only shows the API health status. Users cannot see or add tasks yet, which is the core job of the app.

Risk: **medium**. It adds public input (a task title) and a new page interaction, but no auth, no persistent storage, and no deploy change.

## What Changes

- Add an in-memory task API: `GET /api/tasks` lists tasks, `POST /api/tasks` creates one.
- Validate the title: required after trimming, at most 100 characters; invalid input returns 400.
- Show the task list on the home page with an "Add task" form, an empty state, and error messages.

Deferred to a later change: marking a task done, deleting tasks, and persistent storage.

## Capabilities

### New Capabilities
- `api/tasks`: HTTP endpoints to list and create tasks, with title validation
- `web/task-list`: home page list of tasks with a form to add one

### Modified Capabilities
- (none)

## Impact

`apps/api/internal/server` (new routes and store), `apps/web/src` (task list UI), new unit and e2e tests. No new dependencies.
