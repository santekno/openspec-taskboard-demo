## ADDED Requirements

### Requirement: Home page heading
The home page SHALL show a level-1 heading "Taskboard".

#### Scenario: Page loads
- **WHEN** a user opens the home page
- **THEN** the heading "Taskboard" is visible

### Requirement: API status line
The home page SHALL show the API health as "API: <status>", starting with "API: checking…", and MUST show "API: unreachable" when the health request fails.

#### Scenario: API healthy
- **WHEN** GET /api/health returns `{"status":"ok"}`
- **THEN** the page shows "API: ok"

#### Scenario: Before the response
- **WHEN** the health request has not answered yet
- **THEN** the page shows "API: checking…"

#### Scenario: API down
- **WHEN** the health request fails or returns a non-2xx status
- **THEN** the page shows "API: unreachable"
