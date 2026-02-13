---
name: go-project-layout
description: Go project structure, package design, module configuration, Makefile patterns, linting config, and CI/CD essentials. Use when scaffolding Go projects or reviewing project organization.
---

# Go Project Layout

## Directory Structures

**Minimal** (library / small tool):
```
go.mod, main.go, main_test.go, README.md
```

**Standard** (single service):
```
cmd/server/main.go
internal/{domain,service,repository,handler}/
go.mod, Makefile, .golangci.yml
```

**Service** (multi-binary):
```
cmd/{api,worker}/main.go
internal/{domain,service,repository,handler,config}/
pkg/               # public libraries (sparingly)
migrations/
go.mod, Makefile, .golangci.yml, Dockerfile
```

## Package Design

- Single responsibility: one package = one clear purpose
- Minimal exports: only export what consumers need
- No circular imports: dependencies flow one direction
- `internal/` by default; `pkg/` only for genuinely reusable libraries
- Flat over nested: avoid deep hierarchies

## go.mod (Go 1.24)

```
module github.com/org/project

go 1.24

tool (
    golang.org/x/tools/cmd/goimports
    github.com/golangci/golangci-lint/cmd/golangci-lint
    golang.org/x/vuln/cmd/govulncheck
)
```

## Makefile

```makefile
.PHONY: build test lint fmt vet tidy coverage run clean check

build:
	go build -trimpath -o bin/ ./cmd/...
test:
	go test -race ./...
coverage:
	go test -race -coverprofile=coverage.out ./...
	go tool cover -func=coverage.out
fmt:
	gofmt -s -w . && goimports -w .
vet:
	go vet ./...
lint:
	golangci-lint run
tidy:
	go mod tidy && go mod verify
clean:
	rm -rf bin/ coverage.out
check: fmt vet lint test build
```

## .golangci.yml

```yaml
run:
  timeout: 5m
  go: "1.24"
linters:
  enable:
    # Defaults (explicit for clarity)
    - errcheck
    - govet
    - staticcheck
    - unused
    - gosimple
    - ineffassign
    # Error handling
    - errorlint        # error wrapping correctness
    - errname          # error variable naming (ErrFoo)
    # Security
    - gosec            # security issues
    - bodyclose        # unclosed HTTP response bodies
    - noctx            # HTTP requests without context
    # Code quality
    - gocritic         # diagnostic + style + performance
    - revive           # extensible linter
    - unconvert        # unnecessary type conversions
    - wastedassign     # dead assignments
    - forcetypeassert  # unchecked type assertions
    - exhaustive       # enum switch exhaustiveness
    - nilnil           # confusing (nil, nil) returns
    - usestdlibvars    # use stdlib constants (http.StatusOK vs 200)
    - misspell         # spelling in comments/strings
    - prealloc         # slice pre-allocation opportunities
    # Conditional (common in Go 1.24+ projects)
    - sloglint         # log/slog best practices
    - testifylint      # testify best practices
issues:
  exclude-dirs: [vendor]
```

## Tooling

| Tool | Purpose | Install |
|------|---------|---------|
| gopls | Language server | `go install golang.org/x/tools/gopls@latest` |
| goimports | Import mgmt | `go install golang.org/x/tools/cmd/goimports@latest` |
| golangci-lint | Lint suite | `go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest` |
| govulncheck | Vuln scan | `go install golang.org/x/vuln/cmd/govulncheck@latest` |

## GitHub Actions

```yaml
name: Go CI
on:
  push: { branches: [main] }
  pull_request: { branches: [main] }
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with: { go-version: "1.24" }
      - run: go mod verify
      - run: go vet ./...
      - uses: golangci/golangci-lint-action@v6
      - run: go test -race -coverprofile=coverage.out ./...
      - run: go build ./...
```
