package server

import (
	"context"
	"net/http"
	"strings"
	"testing"

	"example.com/taskboard/api/internal/usersauth"
)

type fakeUsers struct {
	err   error
	calls int
}

func (f *fakeUsers) GetUser(_ context.Context, id string) (usersauth.User, error) {
	f.calls++
	if f.err != nil {
		return usersauth.User{}, f.err
	}
	if id != "u-1" {
		return usersauth.User{}, usersauth.ErrNotFound
	}
	return usersauth.User{ID: "u-1", Name: "Ayu Lestari"}, nil
}

func TestCreateTask_Assignee(t *testing.T) {
	cases := []struct {
		name, body string
		err        error
		code       int
		want       string
		listed     bool
	}{
		{"known assignee", `{"title":"Buy milk","assigneeId":"u-1"}`, nil, 201, `"assignee":{"id":"u-1","name":"Ayu Lestari"}`, true},
		{"unknown assignee", `{"title":"Buy milk","assigneeId":"u-404"}`, nil, 400, `{"error":"assignee not found"}`, false},
		{"users-auth down", `{"title":"Buy milk","assigneeId":"u-1"}`, usersauth.ErrUnavailable, 502, `{"error":"users-auth unavailable"}`, false},
		{"no assignee, users-auth down", `{"title":"Buy milk"}`, usersauth.ErrUnavailable, 201, `"title":"Buy milk"`, true},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			users := &fakeUsers{err: tc.err}
			h := NewWith(users)
			rec := do(t, h, http.MethodPost, "/api/tasks", tc.body)
			if rec.Code != tc.code || !strings.Contains(rec.Body.String(), tc.want) {
				t.Fatalf("got %d %s, want %d containing %s", rec.Code, rec.Body, tc.code, tc.want)
			}
			list := do(t, h, http.MethodGet, "/api/tasks", "").Body.String()
			if got := strings.Contains(list, "Buy milk"); got != tc.listed {
				t.Fatalf("listed = %v, want %v (%s)", got, tc.listed, list)
			}
		})
	}
}

func TestCreateTask_NoAssigneeOmitsField(t *testing.T) {
	users := &fakeUsers{}
	rec := do(t, NewWith(users), http.MethodPost, "/api/tasks", `{"title":"Solo","assigneeId":"  "}`)
	if rec.Code != 201 || strings.Contains(rec.Body.String(), "assignee") || users.calls != 0 {
		t.Fatalf("got %d %s, calls=%d", rec.Code, rec.Body, users.calls)
	}
}
