package usersauth

// Contract test: runs Taskboard's real client against a running users-auth.
// It is the check that our assumptions (openspec/specs/ext/users-auth) still
// match the other team's service. Skipped unless USERS_AUTH_URL is set:
//   (cd apps/users-auth && go run .) &
//   USERS_AUTH_URL=http://localhost:8081 go test -run Contract ./internal/usersauth/

import (
	"context"
	"errors"
	"os"
	"testing"
)

func TestContractUsersAuth(t *testing.T) {
	base := os.Getenv("USERS_AUTH_URL")
	if base == "" {
		t.Skip("USERS_AUTH_URL not set; start apps/users-auth to run the contract test")
	}
	c := New(base)

	t.Run("known user", func(t *testing.T) {
		u, err := c.GetUser(context.Background(), "u-1")
		if err != nil || u.ID != "u-1" || u.Name == "" {
			t.Fatalf("GET /users/u-1 = %+v, %v; want id u-1 and a name", u, err)
		}
	})
	t.Run("unknown user", func(t *testing.T) {
		if _, err := c.GetUser(context.Background(), "u-404"); !errors.Is(err, ErrNotFound) {
			t.Fatalf("GET /users/u-404 err = %v; want ErrNotFound (404)", err)
		}
	})
}
