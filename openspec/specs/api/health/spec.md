# api/health Specification

## Purpose
The health check endpoint and the API's default response to unknown routes, as they behaved before any spec-driven change.

## Requirements

### Requirement: Health check
The API SHALL answer `GET /api/health` with status 200 and the JSON body `{"status":"ok"}` and the header `Content-Type: application/json`.

#### Scenario: API is running
- **WHEN** a client requests GET /api/health
- **THEN** the API responds 200 with `{"status":"ok"}` as application/json

#### Scenario: Wrong method
- **WHEN** a client sends POST /api/health
- **THEN** the API responds 405 Method Not Allowed

### Requirement: Unknown routes
The API SHALL respond 404 to any path that has no registered route.

#### Scenario: Unknown path
- **WHEN** a client requests GET /api/unknown
- **THEN** the API responds 404
