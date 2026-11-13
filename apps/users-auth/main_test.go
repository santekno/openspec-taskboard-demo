package main

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestMock(t *testing.T) {
	cases := []struct {
		method, path, body string
		code               int
		want               string
	}{
		{"GET", "/users/u-1", "", 200, `"name":"Ayu Lestari"`},
		{"GET", "/users/u-404", "", 404, `"error":"user not found"`},
		{"POST", "/auth/verify", `{"token":"demo-token-ayu"}`, 200, `"userId":"u-1"`},
		{"POST", "/auth/verify", `{"token":"nope"}`, 401, `"error":"invalid token"`},
	}
	for _, tc := range cases {
		rec := httptest.NewRecorder()
		handler().ServeHTTP(rec, httptest.NewRequest(tc.method, tc.path, strings.NewReader(tc.body)))
		if rec.Code != tc.code || !strings.Contains(rec.Body.String(), tc.want) {
			t.Errorf("%s %s = %d %s, want %d %s", tc.method, tc.path, rec.Code, rec.Body, tc.code, tc.want)
		}
	}
	_ = http.StatusOK
}
