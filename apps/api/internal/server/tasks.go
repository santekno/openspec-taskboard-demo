package server

import (
	"encoding/json"
	"errors"
	"net/http"
	"strings"
	"sync"
	"unicode/utf8"

	"example.com/taskboard/api/internal/usersauth"
)

const maxTitle = 100

// Assignee is a snapshot of the users-auth user at create time.
type Assignee struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

// Task is a single to-do item.
type Task struct {
	ID       int       `json:"id"`
	Title    string    `json:"title"`
	Done     bool      `json:"done"`
	Assignee *Assignee `json:"assignee,omitempty"`
}

type store struct {
	mu     sync.Mutex
	nextID int
	tasks  []Task
}

func newStore() *store { return &store{nextID: 1, tasks: []Task{}} }

func (s *store) list() []Task {
	s.mu.Lock()
	defer s.mu.Unlock()
	out := make([]Task, len(s.tasks))
	copy(out, s.tasks)
	return out
}

func (s *store) add(title string, a *Assignee) Task {
	s.mu.Lock()
	defer s.mu.Unlock()
	t := Task{ID: s.nextID, Title: title, Assignee: a}
	s.nextID++
	s.tasks = append(s.tasks, t)
	return t
}

func validateTitle(raw string) (string, error) {
	title := strings.TrimSpace(raw)
	if title == "" {
		return "", errors.New("title is required")
	}
	if utf8.RuneCountInString(title) > maxTitle {
		return "", errors.New("title must be at most 100 characters")
	}
	return title, nil
}

func listTasks(s *store) http.HandlerFunc {
	return func(w http.ResponseWriter, _ *http.Request) {
		writeJSON(w, http.StatusOK, s.list())
	}
}

func createTask(s *store, users UserLookup) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var body struct {
			Title      string `json:"title"`
			AssigneeID string `json:"assigneeId"`
		}
		if err := json.NewDecoder(http.MaxBytesReader(w, r.Body, 4096)).Decode(&body); err != nil {
			writeError(w, http.StatusBadRequest, "invalid JSON body")
			return
		}
		title, err := validateTitle(body.Title)
		if err != nil {
			writeError(w, http.StatusBadRequest, err.Error())
			return
		}
		var assignee *Assignee
		if id := strings.TrimSpace(body.AssigneeID); id != "" {
			u, err := users.GetUser(r.Context(), id)
			switch {
			case errors.Is(err, usersauth.ErrNotFound):
				writeError(w, http.StatusBadRequest, "assignee not found")
				return
			case err != nil:
				writeError(w, http.StatusBadGateway, "users-auth unavailable")
				return
			}
			assignee = &Assignee{ID: u.ID, Name: u.Name}
		}
		writeJSON(w, http.StatusCreated, s.add(title, assignee))
	}
}
