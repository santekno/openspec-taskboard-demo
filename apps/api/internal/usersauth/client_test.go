package usersauth

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

// fake answers with the examples from contracts/users-auth.openapi.yaml.
func fake(t *testing.T, h http.HandlerFunc) *Client {
	t.Helper()
	srv := httptest.NewServer(h)
	t.Cleanup(srv.Close)
	return New(srv.URL)
}

func TestGetUser(t *testing.T) {
	c := fake(t, func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/users/u-1":
			w.Write([]byte(`{"id":"u-1","name":"Ayu Lestari","email":"ayu@example.com"}`))
		case "/users/u-500":
			w.WriteHeader(http.StatusInternalServerError)
		case "/users/u-bad":
			w.Write([]byte(`{"id":""}`))
		default:
			w.WriteHeader(http.StatusNotFound)
			w.Write([]byte(`{"error":"user not found"}`))
		}
	})
	u, err := c.GetUser(context.Background(), "u-1")
	if err != nil || u.Name != "Ayu Lestari" {
		t.Fatalf("u-1: %+v %v", u, err)
	}
	if _, err := c.GetUser(context.Background(), "u-404"); !errors.Is(err, ErrNotFound) {
		t.Fatalf("u-404: err = %v, want ErrNotFound", err)
	}
	for _, id := range []string{"u-500", "u-bad"} {
		if _, err := c.GetUser(context.Background(), id); !errors.Is(err, ErrUnavailable) {
			t.Fatalf("%s: err = %v, want ErrUnavailable", id, err)
		}
	}
}

func TestGetUserTimeoutAndDown(t *testing.T) {
	c := fake(t, func(w http.ResponseWriter, r *http.Request) {
		select {
		case <-time.After(time.Second):
		case <-r.Context().Done():
		}
	})
	c.HTTP.Timeout = 50 * time.Millisecond
	if _, err := c.GetUser(context.Background(), "u-1"); !errors.Is(err, ErrUnavailable) {
		t.Fatalf("slow: err = %v, want ErrUnavailable", err)
	}
	down := New("http://127.0.0.1:1")
	if _, err := down.GetUser(context.Background(), "u-1"); !errors.Is(err, ErrUnavailable) {
		t.Fatalf("down: err = %v, want ErrUnavailable", err)
	}
	if New("http://x").HTTP.Timeout != 2*time.Second {
		t.Fatal("default timeout must be 2s")
	}
}
