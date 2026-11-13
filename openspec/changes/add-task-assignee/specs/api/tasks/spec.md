# Spec Delta

## MODIFIED Requirements

### Requirement: Create task
The API SHALL create a task from `POST /api/tasks` with a JSON body `{"title": string, "assigneeId"?: string}` and MUST reject invalid titles. When `assigneeId` is present and not empty, the API MUST look the user up in users-auth before creating the task and SHALL return the task with `"assignee": {"id", "name"}`.

#### Scenario: Valid title
- **WHEN** a client posts `{"title": "  Buy milk  "}`
- **THEN** the API responds 201 with the new task whose title is "Buy milk" and no assignee

#### Scenario: Empty title
- **WHEN** a client posts a title that is empty after trimming
- **THEN** the API responds 400 with `{"error": "title is required"}`

#### Scenario: Title too long
- **WHEN** a client posts a title longer than 100 characters
- **THEN** the API responds 400 with `{"error": "title must be at most 100 characters"}`

#### Scenario: Known assignee
- **WHEN** a client posts `{"title": "Buy milk", "assigneeId": "u-1"}` and users-auth knows u-1 as "Ayu Lestari"
- **THEN** the API responds 201 with `"assignee": {"id": "u-1", "name": "Ayu Lestari"}`

#### Scenario: Unknown assignee
- **WHEN** a client posts an assigneeId that users-auth answers with 404
- **THEN** the API responds 400 with `{"error": "assignee not found"}` and no task is created

## ADDED Requirements

### Requirement: users-auth unavailable
The API MUST NOT create a task when the assignee cannot be checked, and SHALL respond 502 with `{"error": "users-auth unavailable"}` when users-auth fails, answers with an unexpected status, or takes longer than 2 seconds.

#### Scenario: users-auth is down
- **WHEN** a client posts an assigneeId and users-auth cannot be reached
- **THEN** the API responds 502 with `{"error": "users-auth unavailable"}` and GET /api/tasks does not include the task

#### Scenario: No assignee needs no users-auth
- **WHEN** users-auth is down and a client posts a task without assigneeId
- **THEN** the API responds 201
