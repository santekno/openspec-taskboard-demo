package server

import (
	"encoding/json"
	"errors"
	"net/http"
	"net/url"
	"strings"
	"sync"
	"unicode/utf8"
)

const maxTitle = 120

// Bookmark is a saved link.
type Bookmark struct {
	ID    int    `json:"id"`
	URL   string `json:"url"`
	Title string `json:"title"`
}

type store struct {
	mu        sync.Mutex
	nextID    int
	bookmarks []Bookmark // oldest first; list() reverses
}

func newStore() *store { return &store{nextID: 1} }

func (s *store) list() []Bookmark {
	s.mu.Lock()
	defer s.mu.Unlock()
	out := make([]Bookmark, 0, len(s.bookmarks))
	for i := len(s.bookmarks) - 1; i >= 0; i-- {
		out = append(out, s.bookmarks[i])
	}
	return out
}

func (s *store) add(u, title string) Bookmark {
	s.mu.Lock()
	defer s.mu.Unlock()
	b := Bookmark{ID: s.nextID, URL: u, Title: title}
	s.nextID++
	s.bookmarks = append(s.bookmarks, b)
	return b
}

func validateURL(raw string) (string, error) {
	u, err := url.ParseRequestURI(strings.TrimSpace(raw))
	if err != nil || (u.Scheme != "http" && u.Scheme != "https") || u.Host == "" {
		return "", errors.New("url must be an absolute http(s) URL")
	}
	return u.String(), nil
}

func validateTitle(raw string) (string, error) {
	title := strings.TrimSpace(raw)
	if title == "" {
		return "", errors.New("title is required")
	}
	if utf8.RuneCountInString(title) > maxTitle {
		return "", errors.New("title must be at most 120 characters")
	}
	return title, nil
}

func listBookmarks(s *store) http.HandlerFunc {
	return func(w http.ResponseWriter, _ *http.Request) {
		writeJSON(w, http.StatusOK, s.list())
	}
}

func saveBookmark(s *store) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var body struct {
			URL   string `json:"url"`
			Title string `json:"title"`
		}
		if err := json.NewDecoder(http.MaxBytesReader(w, r.Body, 8192)).Decode(&body); err != nil {
			writeError(w, http.StatusBadRequest, "invalid JSON body")
			return
		}
		u, err := validateURL(body.URL)
		if err != nil {
			writeError(w, http.StatusBadRequest, err.Error())
			return
		}
		title, err := validateTitle(body.Title)
		if err != nil {
			writeError(w, http.StatusBadRequest, err.Error())
			return
		}
		writeJSON(w, http.StatusCreated, s.add(u, title))
	}
}
