package main

import (
	"runtime"
	"testing"
)

func TestInfoReportsRuntimeArchitecture(t *testing.T) {
	got := info()
	if got.Architecture != runtime.GOARCH {
		t.Fatalf("architecture = %q, want %q", got.Architecture, runtime.GOARCH)
	}
	if got.OS != runtime.GOOS {
		t.Fatalf("os = %q, want %q", got.OS, runtime.GOOS)
	}
}

