# Proposal: Initialize Bookmarks (walking skeleton)

## Why

Bookmarks exists only as a vision in `openspec/config.yaml`. Before building features we need the smallest slice that runs end to end (browser → Vite → Go API → store → back) with tests and CI, so every later change is a small delta on a working system.

Risk: **medium**. It accepts public input (URL and title) and creates the CI pipeline, but has no auth, no persistent storage, and no deploy.

## What Changes

- Scaffold `apps/api` (Go 1.22+, net/http) with `GET /api/health`, `GET /api/bookmarks`, and `POST /api/bookmarks`.
- Validate input: URL must be an absolute http(s) URL; title is required after trimming, at most 120 characters.
- Scaffold `apps/web` (React + Vite + TypeScript) with a `BookmarkList` page: list newest first, empty state, and a save form.
- Unit tests, Playwright e2e, and a GitHub Actions workflow with go-test, web-test, e2e.

Deferred to a later change: tags, search, delete, duplicate detection, persistent storage, login.

## Capabilities

### New Capabilities
- `api/bookmarks`: list and create bookmarks with URL and title validation
- `web/bookmark-list`: home page that lists bookmarks and saves a new one

### Modified Capabilities
- (none; `openspec/specs/` is empty)

## Impact

Creates `apps/api`, `apps/web`, `.github/workflows/ci.yml`. New dependencies: React, Vite, Vitest, Testing Library, Playwright (dev).
