# api/tasks Specification

## Purpose
HTTP endpoints that let clients list tasks and create a task with a validated title.

## Requirements

### Requirement: List tasks
The API SHALL return all tasks as a JSON array, oldest first, from `GET /api/tasks`.

#### Scenario: No tasks yet
- **WHEN** a client requests GET /api/tasks before any task exists
- **THEN** the API responds 200 with an empty JSON array

#### Scenario: Tasks exist
- **WHEN** two tasks were created
- **THEN** GET /api/tasks responds 200 with both tasks in creation order, each with id, title, and done false

### Requirement: Create task
The API SHALL create a task from `POST /api/tasks` with a JSON body `{"title": string}` and MUST reject invalid titles.

#### Scenario: Valid title
- **WHEN** a client posts `{"title": "  Buy milk  "}`
- **THEN** the API responds 201 with the new task whose title is "Buy milk"

#### Scenario: Empty title
- **WHEN** a client posts a title that is empty after trimming
- **THEN** the API responds 400 with `{"error": "title is required"}`

#### Scenario: Title too long
- **WHEN** a client posts a title longer than 100 characters
- **THEN** the API responds 400 with `{"error": "title must be at most 100 characters"}`
