---
name: go-quality-gates
description: Go quality pipeline with 8 gates covering formatting, linting, security, testing, and building. Defines gate order, auto-fix capabilities, and common failure remedies. Use when running quality checks or configuring CI pipelines.
---

# Go Quality Gates

## Pipeline Overview

8 gates executed in order. A gate must pass before proceeding to the next.

| # | Gate | Command | Auto-fix | Essential |
|---|------|---------|----------|-----------|
| 1 | Format | `gofmt -s -w .` | Yes | Yes |
| 2 | Imports | `goimports -w .` | Yes | Yes |
| 3 | Dependencies | `go mod tidy && go mod verify` | Yes | Yes |
| 4 | Static Analysis | `go vet ./...` | No | Yes |
| 5 | Lint + Security | `golangci-lint run --fix` | Partial | Optional* |
| 6 | Vulnerabilities | `govulncheck ./...` | No | Optional* |
| 7 | Tests + Race | `go test -race -coverprofile=coverage.out ./...` | No | Yes |
| 8 | Build | `go build ./...` | No | Yes |

*Optional gates degrade gracefully if the tool is not installed.

## Gate Details

### 1. Format (gofmt)

```bash
gofmt -s -w .
```

Auto-fixes all formatting. The `-s` flag applies simplification rules.

### 2. Imports (goimports)

```bash
goimports -w .
```

Organizes imports into groups: stdlib, external, internal. Auto-fixes.

**If missing:** `go install golang.org/x/tools/cmd/goimports@latest`

### 3. Dependencies (go mod tidy)

```bash
go mod tidy
go mod verify
```

Removes unused deps, adds missing ones. Verifies checksums.

### 4. Static Analysis (go vet)

```bash
go vet ./...
```

Catches common bugs: printf format mismatches, unreachable code, struct tag errors, etc.

**Common fixes:**
- Printf verb mismatch: correct format string
- Struct tag: fix JSON/XML tag syntax
- Unreachable code: remove or restructure

### 5. Lint + Security (golangci-lint)

```bash
golangci-lint run --fix
```

Runs multiple linters including gosec for security. `--fix` auto-corrects where possible.

**Common fixes:**
- `errcheck`: handle ignored errors
- `gosec`: fix security issues (SQL injection, hardcoded creds)
- `gocritic`: apply suggested improvements
- `noctx`: add context to HTTP requests

**If missing:** `go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest`

### 6. Vulnerabilities (govulncheck)

```bash
govulncheck ./...
```

Scans dependencies for known vulnerabilities.

**Common fixes:**
- Update vulnerable dependency: `go get dep@latest && go mod tidy`
- Replace deprecated module
- If no fix available: document accepted risk

**If missing:** `go install golang.org/x/vuln/cmd/govulncheck@latest`

### 7. Tests + Race Detection

```bash
go test -race -coverprofile=coverage.out ./...
go tool cover -func=coverage.out
```

Default coverage threshold: **80%** (configurable).

**Common fixes:**
- Test failure: fix logic or update test expectations
- Race condition: add proper synchronization (mutex, atomic, channels)
- Low coverage: add tests for uncovered paths

### 8. Build

```bash
go build ./...
```

Final compilation check. Should never fail if previous gates pass.

## Failure Response

| Severity | Condition | Action |
|----------|-----------|--------|
| Auto-fix | Format/import issues | Fix and proceed |
| Warning | Lint suggestions | Fix if severity >= warning |
| Blocking | Test failures | Block until fixed |
| Critical | Race conditions | Block, require redesign |
| Blocking | Coverage < threshold | Block until tests added |

## Graceful Degradation

When optional tools are missing:

```
Gate 5 (golangci-lint): SKIPPED — not installed
Gate 6 (govulncheck):   SKIPPED — not installed
```

Report skipped gates in the summary. The pipeline still passes if all essential gates pass.

## Customization

Projects can override defaults by setting environment variables or config:

- `GOPHER_COVERAGE_THRESHOLD=90` — raise coverage bar
- `.golangci.yml` — customize linter rules
- `//go:build !race` — exclude files from race testing (use sparingly)
