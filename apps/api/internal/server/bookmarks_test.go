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

func TestHealth(t *testing.T) {
	rec := do(t, New(), http.MethodGet, "/api/health", "")
	if rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"status":"ok"`) {
		t.Fatalf("got %d %s", rec.Code, rec.Body)
	}
}

func TestListEmpty(t *testing.T) {
	rec := do(t, New(), http.MethodGet, "/api/bookmarks", "")
	if rec.Code != http.StatusOK || strings.TrimSpace(rec.Body.String()) != "[]" {
		t.Fatalf("got %d %q, want 200 []", rec.Code, rec.Body)
	}
}

func TestListNewestFirst(t *testing.T) {
	h := New()
	do(t, h, http.MethodPost, "/api/bookmarks", `{"url":"https://a.dev","title":"A"}`)
	do(t, h, http.MethodPost, "/api/bookmarks", `{"url":"https://b.dev","title":"B"}`)
	rec := do(t, h, http.MethodGet, "/api/bookmarks", "")
	var got []Bookmark
	if err := json.Unmarshal(rec.Body.Bytes(), &got); err != nil {
		t.Fatal(err)
	}
	if len(got) != 2 || got[0].Title != "B" || got[1].Title != "A" || got[0].URL != "https://b.dev" || got[0].ID != 2 {
		t.Fatalf("got %+v, want B then A", got)
	}
}

func TestSave(t *testing.T) {
	cases := []struct {
		name, body string
		code       int
		want       string
	}{
		{"valid, title trimmed", `{"url":"https://go.dev","title":"  Go  "}`, 201, `"title":"Go"`},
		{"not a URL", `{"url":"go.dev","title":"Go"}`, 400, `{"error":"url must be an absolute http(s) URL"}`},
		{"ftp scheme", `{"url":"ftp://go.dev","title":"Go"}`, 400, `{"error":"url must be an absolute http(s) URL"}`},
		{"empty title", `{"url":"https://go.dev","title":"   "}`, 400, `{"error":"title is required"}`},
		{"title too long", `{"url":"https://go.dev","title":"` + strings.Repeat("a", 121) + `"}`, 400, `{"error":"title must be at most 120 characters"}`},
		{"title at limit", `{"url":"https://go.dev","title":"` + strings.Repeat("a", 120) + `"}`, 201, `"id":1`},
		{"invalid JSON", `{`, 400, `{"error":"invalid JSON body"}`},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			rec := do(t, New(), http.MethodPost, "/api/bookmarks", tc.body)
			if rec.Code != tc.code || !strings.Contains(rec.Body.String(), tc.want) {
				t.Fatalf("got %d %s, want %d containing %s", rec.Code, rec.Body, tc.code, tc.want)
			}
		})
	}
}
