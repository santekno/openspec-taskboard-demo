// Package server wires the HTTP routes of the Bookmarks API.
package server

import (
	"encoding/json"
	"net/http"
)

// New returns the API handler with all routes registered and a fresh store.
func New() http.Handler {
	s := newStore()
	mux := http.NewServeMux()
	mux.HandleFunc("GET /api/health", health)
	mux.HandleFunc("GET /api/bookmarks", listBookmarks(s))
	mux.HandleFunc("POST /api/bookmarks", saveBookmark(s))
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
