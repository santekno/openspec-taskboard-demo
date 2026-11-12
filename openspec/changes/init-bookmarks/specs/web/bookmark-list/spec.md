# Spec Delta

## Purpose
The home page shows the user's saved links and lets them save a new one with clear feedback.

## ADDED Requirements

### Requirement: Show bookmarks
The home page SHALL show a heading "Bookmarks" and list each bookmark as a link to its URL with its title as the text.

#### Scenario: Empty state
- **WHEN** the API returns no bookmarks
- **THEN** the page shows "No bookmarks yet"

#### Scenario: Bookmarks listed
- **WHEN** the API returns bookmarks
- **THEN** each one is a list item with a link whose text is the title and whose href is the URL

### Requirement: Save bookmark
The home page SHALL let the user save a bookmark with labelled "URL" and "Title" inputs and a "Save" button.

#### Scenario: Bookmark saved
- **WHEN** the user fills URL and Title and presses "Save"
- **THEN** the new bookmark appears at the top of the list and both inputs are cleared

#### Scenario: API rejects the input
- **WHEN** the API responds 400 with an error message
- **THEN** the page shows that message in an element with role alert and keeps the typed text
