# Spec Delta

## MODIFIED Requirements

### Requirement: Add task
The home page SHALL let the user add a task with a labelled "Title" input, an optional labelled "Assignee ID" input, and an "Add task" button.

#### Scenario: Task added
- **WHEN** the user types a title and presses "Add task"
- **THEN** the new task appears in the list and the inputs are cleared

#### Scenario: API rejects the title
- **WHEN** the API responds 400 with an error message
- **THEN** the page shows that message in an element with role alert and keeps the typed text

#### Scenario: Task added with an assignee
- **WHEN** the user types a title and "u-1" as Assignee ID and presses "Add task"
- **THEN** the new task appears with "Assigned to Ayu Lestari"

## ADDED Requirements

### Requirement: Show assignee
The task list SHALL show "Assigned to <name>" next to each task that has an assignee, and nothing extra for a task without one.

#### Scenario: Mixed list
- **WHEN** the API returns one task with assignee "Ayu Lestari" and one without
- **THEN** only the first item shows "Assigned to Ayu Lestari"
