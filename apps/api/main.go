package main

import (
	"log"
	"net/http"
	"os"

	"example.com/taskboard/api/internal/server"
)

func main() {
	addr := ":8080"
	if p := os.Getenv("PORT"); p != "" {
		addr = ":" + p
	}
	log.Printf("api listening on %s", addr)
	log.Fatal(http.ListenAndServe(addr, server.New()))
}
