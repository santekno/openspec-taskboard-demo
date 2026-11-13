# Spec Delta

## Purpose
The parts of the existing users-auth service (owned by the Identity team) that Taskboard relies on. Recorded as-is from `contracts/users-auth.openapi.yaml`; Taskboard never changes this behavior, it only consumes it.

## ADDED Requirements

### Requirement: Get user by id
users-auth SHALL answer `GET /users/{id}` with 200 and a JSON object `{"id", "name", "email"}` for a known id, and with 404 and `{"error": "user not found"}` for an unknown id.

#### Scenario: Known user
- **WHEN** Taskboard requests GET /users/u-1
- **THEN** users-auth responds 200 with id "u-1" and a non-empty name

#### Scenario: Unknown user
- **WHEN** Taskboard requests GET /users/u-404
- **THEN** users-auth responds 404 with `{"error": "user not found"}`
