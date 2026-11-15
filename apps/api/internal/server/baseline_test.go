package server

// Characterization tests: they lock the behavior that existed before any
// spec-driven change (openspec/specs/api/health). Do not edit them in a
// feature change; if behavior must change, write a MODIFIED delta first.

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestBaselineHealthIsJSON(t *testing.T) {
	rec := httptest.NewRecorder()
	New().ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/api/health", nil))

	if got := rec.Header().Get("Content-Type"); got != "application/json" {
		t.Fatalf("Content-Type = %q, want application/json", got)
	}
	if got, want := rec.Body.String(), "{\"status\":\"ok\"}\n"; got != want {
		t.Fatalf("body = %q, want %q", got, want)
	}
}

func TestBaselineStatusCodes(t *testing.T) {
	cases := []struct {
		name, method, path string
		want               int
	}{
		{"health ok", http.MethodGet, "/api/health", http.StatusOK},
		{"wrong method", http.MethodPost, "/api/health", http.StatusMethodNotAllowed},
		{"unknown path", http.MethodGet, "/api/unknown", http.StatusNotFound},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			rec := httptest.NewRecorder()
			New().ServeHTTP(rec, httptest.NewRequest(tc.method, tc.path, nil))
			if rec.Code != tc.want {
				t.Fatalf("%s %s = %d, want %d", tc.method, tc.path, rec.Code, tc.want)
			}
		})
	}
}
