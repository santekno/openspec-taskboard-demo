# web/task-list Specification

## Purpose
The home page shows the user's tasks and lets them add a new task with clear feedback.

## Requirements

### Requirement: Show tasks
The home page SHALL list the tasks returned by the API.

#### Scenario: Empty state
- **WHEN** the API returns no tasks
- **THEN** the page shows "No tasks yet"

#### Scenario: Tasks listed
- **WHEN** the API returns tasks
- **THEN** each task title is shown as an item in a list

### Requirement: Add task
The home page SHALL let the user add a task with a labelled "Title" input and an "Add task" button.

#### Scenario: Task added
- **WHEN** the user types a title and presses "Add task"
- **THEN** the new task appears in the list and the input is cleared

#### Scenario: API rejects the title
- **WHEN** the API responds 400 with an error message
- **THEN** the page shows that message in an element with role alert and keeps the typed text
