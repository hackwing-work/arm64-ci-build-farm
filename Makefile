.PHONY: test lint build build-all preflight verify

VERSION ?= dev
COMMIT ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo none)
BUILD_DATE ?= $(shell git show -s --format=%cI HEAD 2>/dev/null || echo unknown)
LDFLAGS := -s -w -X main.version=$(VERSION) -X main.commit=$(COMMIT) -X main.builtAt=$(BUILD_DATE)

test:
	go test -race -coverprofile=coverage.out ./...

lint:
	go vet ./...

build:
	go build -trimpath -ldflags="$(LDFLAGS)" -o bin/build-info ./cmd/build-info

build-all:
	powershell -NoProfile -File scripts/build-all.ps1 -Version $(VERSION)

preflight:
	powershell -NoProfile -File scripts/preflight.ps1

verify:
	powershell -NoProfile -File scripts/verify-repository.ps1

