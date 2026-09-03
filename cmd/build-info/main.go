package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"runtime"
	"time"
)

var (
	version = "dev"
	commit  = "none"
	builtAt = "unknown"
)

type buildInfo struct {
	Version      string `json:"version"`
	Commit       string `json:"commit"`
	BuiltAt      string `json:"built_at"`
	Architecture string `json:"architecture"`
	OS           string `json:"os"`
}

func info() buildInfo {
	return buildInfo{version, commit, builtAt, runtime.GOARCH, runtime.GOOS}
}

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("{\"status\":\"ok\"}\n"))
	})
	mux.HandleFunc("/info", func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode(info())
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	server := &http.Server{Addr: ":" + port, Handler: mux, ReadHeaderTimeout: 5 * time.Second}
	fmt.Printf("build-info %s (%s/%s) listening on :%s\n", version, runtime.GOOS, runtime.GOARCH, port)
	log.Fatal(server.ListenAndServe())
}

