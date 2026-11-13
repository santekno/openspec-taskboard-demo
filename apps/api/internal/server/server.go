// Package server wires the HTTP routes of the Taskboard API.
package server

import (
	"context"
	"encoding/json"
	"net/http"
	"os"

	"example.com/taskboard/api/internal/usersauth"
)

// UserLookup is the one users-auth call the server needs; tests pass a fake.
type UserLookup interface {
	GetUser(ctx context.Context, id string) (usersauth.User, error)
}

// New returns the API handler with a fresh task store and a users-auth client
// for USERS_AUTH_URL (default http://localhost:8081).
func New() http.Handler {
	base := os.Getenv("USERS_AUTH_URL")
	if base == "" {
		base = "http://localhost:8081"
	}
	return NewWith(usersauth.New(base))
}

// NewWith returns the API handler using the given user lookup.
func NewWith(users UserLookup) http.Handler {
	s := newStore()
	mux := http.NewServeMux()
	mux.HandleFunc("GET /api/health", health)
	mux.HandleFunc("GET /api/tasks", listTasks(s))
	mux.HandleFunc("POST /api/tasks", createTask(s, users))
	return mux
}

func health(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func writeError(w http.ResponseWriter, status int, msg string) {
	writeJSON(w, status, map[string]string{"error": msg})
}
