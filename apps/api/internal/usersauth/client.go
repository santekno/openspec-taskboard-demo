// Package usersauth is Taskboard's client for the existing users-auth service.
// It relies only on contracts/users-auth.openapi.yaml (spec: openspec/specs/ext/users-auth).
package usersauth

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"net/url"
	"strings"
	"time"
)

var (
	// ErrNotFound means users-auth answered 404 for the id.
	ErrNotFound = errors.New("user not found")
	// ErrUnavailable means users-auth failed, timed out, or answered unexpectedly.
	ErrUnavailable = errors.New("users-auth unavailable")
)

// User is the subset of the users-auth User schema that Taskboard uses.
type User struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Email string `json:"email"`
}

// Client calls users-auth over HTTP.
type Client struct {
	BaseURL string
	HTTP    *http.Client
}

// New returns a client with the 2 second timeout from design.md.
func New(baseURL string) *Client {
	return &Client{BaseURL: strings.TrimRight(baseURL, "/"), HTTP: &http.Client{Timeout: 2 * time.Second}}
}

// GetUser fetches GET /users/{id}.
func (c *Client) GetUser(ctx context.Context, id string) (User, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, c.BaseURL+"/users/"+url.PathEscape(id), nil)
	if err != nil {
		return User{}, fmt.Errorf("%w: %v", ErrUnavailable, err)
	}
	res, err := c.HTTP.Do(req)
	if err != nil {
		return User{}, fmt.Errorf("%w: %v", ErrUnavailable, err)
	}
	defer res.Body.Close()
	switch res.StatusCode {
	case http.StatusOK:
		var u User
		if err := json.NewDecoder(res.Body).Decode(&u); err != nil || u.ID == "" || u.Name == "" {
			return User{}, fmt.Errorf("%w: bad user body", ErrUnavailable)
		}
		return u, nil
	case http.StatusNotFound:
		return User{}, ErrNotFound
	default:
		return User{}, fmt.Errorf("%w: status %d", ErrUnavailable, res.StatusCode)
	}
}
