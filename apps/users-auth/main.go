// users-auth is a stand-in for the company's existing users and auth service.
// In the workshop it plays the "system that already exists": Taskboard must
// integrate with it, but must not change it. Contract: contracts/users-auth.openapi.yaml.
package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strings"
)

type user struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Email string `json:"email"`
}

var users = map[string]user{
	"u-1": {ID: "u-1", Name: "Ayu Lestari", Email: "ayu@example.com"},
	"u-2": {ID: "u-2", Name: "Budi Santoso", Email: "budi@example.com"},
	"u-3": {ID: "u-3", Name: "Citra Dewi", Email: "citra@example.com"},
}

// tokens maps demo bearer tokens to user ids.
var tokens = map[string]string{"demo-token-ayu": "u-1", "demo-token-budi": "u-2"}

func handler() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /users/{id}", func(w http.ResponseWriter, r *http.Request) {
		u, ok := users[r.PathValue("id")]
		if !ok {
			writeJSON(w, http.StatusNotFound, map[string]string{"error": "user not found"})
			return
		}
		writeJSON(w, http.StatusOK, u)
	})
	mux.HandleFunc("POST /auth/verify", func(w http.ResponseWriter, r *http.Request) {
		var body struct {
			Token string `json:"token"`
		}
		_ = json.NewDecoder(r.Body).Decode(&body)
		id, ok := tokens[strings.TrimSpace(body.Token)]
		if !ok {
			writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "invalid token"})
			return
		}
		writeJSON(w, http.StatusOK, map[string]string{"userId": id})
	})
	mux.HandleFunc("GET /health", func(w http.ResponseWriter, _ *http.Request) {
		writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
	})
	return mux
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func main() {
	addr := ":8081"
	if p := os.Getenv("PORT"); p != "" {
		addr = ":" + p
	}
	log.Printf("users-auth (mock) listening on %s", addr)
	log.Fatal(http.ListenAndServe(addr, handler()))
}
