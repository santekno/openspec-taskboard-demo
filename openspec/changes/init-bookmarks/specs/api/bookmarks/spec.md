# Spec Delta

## Purpose
HTTP endpoints that let a client list saved bookmarks and save a new one with a validated URL and title.

## ADDED Requirements

### Requirement: List bookmarks
The API SHALL return all bookmarks from `GET /api/bookmarks` as a JSON array, newest first.

#### Scenario: No bookmarks yet
- **WHEN** a client requests GET /api/bookmarks before anything is saved
- **THEN** the API responds 200 with an empty JSON array

#### Scenario: Newest first
- **WHEN** two bookmarks were saved
- **THEN** GET /api/bookmarks responds 200 with the second one first, each with id, url, and title

### Requirement: Save bookmark
The API SHALL create a bookmark from `POST /api/bookmarks` with a JSON body `{"url": string, "title": string}` and MUST reject invalid input with 400 and `{"error": string}`.

#### Scenario: Valid bookmark
- **WHEN** a client posts `{"url": "https://go.dev", "title": "  Go  "}`
- **THEN** the API responds 201 with the new bookmark whose title is "Go"

#### Scenario: Invalid URL
- **WHEN** a client posts a url that is not an absolute http or https URL
- **THEN** the API responds 400 with `{"error": "url must be an absolute http(s) URL"}`

#### Scenario: Empty title
- **WHEN** a client posts a title that is empty after trimming
- **THEN** the API responds 400 with `{"error": "title is required"}`

#### Scenario: Title too long
- **WHEN** a client posts a title longer than 120 characters
- **THEN** the API responds 400 with `{"error": "title must be at most 120 characters"}`

### Requirement: Health check
The API SHALL answer `GET /api/health` with 200 and `{"status":"ok"}`.

#### Scenario: API is running
- **WHEN** a client requests GET /api/health
- **THEN** the API responds 200 with `{"status":"ok"}`
