package server

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func do(t *testing.T, h http.Handler, method, path, body string) *httptest.ResponseRecorder {
	t.Helper()
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, httptest.NewRequest(method, path, strings.NewReader(body)))
	return rec
}

func TestListTasks_NoTasksYet(t *testing.T) {
	rec := do(t, New(), http.MethodGet, "/api/tasks", "")
	if rec.Code != http.StatusOK || strings.TrimSpace(rec.Body.String()) != "[]" {
		t.Fatalf("got %d %q, want 200 []", rec.Code, rec.Body.String())
	}
}

func TestListTasks_TasksExistInOrder(t *testing.T) {
	h := New()
	do(t, h, http.MethodPost, "/api/tasks", `{"title":"first"}`)
	do(t, h, http.MethodPost, "/api/tasks", `{"title":"second"}`)
	var got []Task
	if err := json.Unmarshal(do(t, h, http.MethodGet, "/api/tasks", "").Body.Bytes(), &got); err != nil {
		t.Fatal(err)
	}
	if len(got) != 2 || got[0].Title != "first" || got[1].Title != "second" || got[0].Done || got[0].ID == got[1].ID {
		t.Fatalf("got %+v", got)
	}
}

func TestCreateTask(t *testing.T) {
	cases := []struct {
		name, body, wantBody string
		wantCode             int
	}{
		{"valid title is trimmed", `{"title":"  Buy milk  "}`, `"title":"Buy milk"`, http.StatusCreated},
		{"empty title", `{"title":"   "}`, `"error":"title is required"`, http.StatusBadRequest},
		{"title too long", `{"title":"` + strings.Repeat("a", 101) + `"}`, `"error":"title must be at most 100 characters"`, http.StatusBadRequest},
		{"exactly 100 characters", `{"title":"` + strings.Repeat("a", 100) + `"}`, `"done":false`, http.StatusCreated},
		{"invalid json", `{`, `"error":"invalid JSON body"`, http.StatusBadRequest},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			rec := do(t, New(), http.MethodPost, "/api/tasks", tc.body)
			if rec.Code != tc.wantCode || !strings.Contains(rec.Body.String(), tc.wantBody) {
				t.Fatalf("got %d %s, want %d containing %s", rec.Code, rec.Body.String(), tc.wantCode, tc.wantBody)
			}
		})
	}
}
