---
description: "Scaffold a new Go 1.24+ project with standard structure, Makefile, and linter config."
argument-hint: "<module-path> [--layout minimal|standard|service]"
---

Scaffold a new Go 1.24+ project.

## Arguments

Parse from `$ARGUMENTS`:
- **module-path** (required): Go module path (e.g., `github.com/org/project`)
- **--layout** (optional): `minimal`, `standard` (default), or `service`

If no arguments provided, ask the user for the module path.

## Layouts

### minimal

```
project/
├── go.mod
├── main.go
├── main_test.go
├── Makefile
└── README.md
```

### standard

```
project/
├── cmd/
│   └── server/
│       └── main.go
├── internal/
│   ├── domain/
│   ├── service/
│   ├── repository/
│   ├── handler/
│   └── config/
├── pkg/
├── migrations/
├── go.mod
├── Makefile
├── .golangci.yml
├── Dockerfile
└── README.md
```

### service

```
project/
├── cmd/
│   ├── api/
│   │   └── main.go
│   └── worker/
│       └── main.go
├── internal/
│   ├── domain/
│   ├── service/
│   ├── repository/
│   ├── handler/
│   └── config/
├── pkg/
├── migrations/
├── go.mod
├── Makefile
├── .golangci.yml
├── Dockerfile
└── README.md
```

## Steps

### 1. Pre-flight Check

Check which files and directories from the chosen layout already exist. Track them — subsequent steps will **skip existing files** rather than overwriting them.

### 2. Create Directory Structure

Report: "Creating directory structure..."

Create directories based on the chosen layout. Skip directories that already exist.

### 3. Initialize Module

Report: "Initializing Go module..."

**Skip if `go.mod` already exists.**

```bash
go mod init <module-path>
```

Then edit `go.mod` to set Go 1.24.

For **standard** and **service** layouts, add tool directives:

```
module <module-path>

go 1.24

tool (
    golang.org/x/tools/cmd/goimports
    github.com/golangci/golangci-lint/cmd/golangci-lint
    golang.org/x/vuln/cmd/govulncheck
)
```

For **minimal**:

```
module <module-path>

go 1.24
```

### 4. Create main.go

**Skip if the target main.go already exists.**

For **minimal**:

```go
package main

import "fmt"

func main() {
	fmt.Println("Hello, World!")
}
```

For **standard** and **service** (`cmd/server/main.go` or `cmd/api/main.go`):

```go
package main

import (
	"context"
	"log/slog"
	"os"
	"os/signal"
	"syscall"
)

func main() {
	ctx, stop := signal.NotifyContext(context.Background(),
		syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	logger.InfoContext(ctx, "starting")

	<-ctx.Done()
	logger.InfoContext(ctx, "shutting down")
}
```

### 5. Create Test Files

**Skip test files that already exist.**

For **minimal** — create `main_test.go`:

```go
package main

import "testing"

func TestMain(t *testing.T) {
	// TODO: add tests
}
```

For **standard** — create `cmd/server/main_test.go`:

```go
package main

import "testing"

func TestMain(t *testing.T) {
	// TODO: add tests
}
```

For **service** — create `cmd/api/main_test.go`:

```go
package main

import "testing"

func TestMain(t *testing.T) {
	// TODO: add tests
}
```

### 6. Create Makefile

Report: "Generating Makefile and config files..."

**Skip if `Makefile` already exists.**

Generate a Makefile with targets: `build`, `test`, `lint`, `fmt`, `vet`, `tidy`, `coverage`, `run`, `clean`, `check`.

### 7. Create .golangci.yml (standard and service)

**Skip if `.golangci.yml` already exists.**

Generate a `.golangci.yml` with recommended linters enabled.

### 8. Create Dockerfile (standard and service)

**Skip if `Dockerfile` already exists.**

Adjust the binary name and `cmd/` path based on the layout:
- **standard**: binary `server`, path `./cmd/server`
- **service**: binary `api`, path `./cmd/api`

```dockerfile
FROM golang:1.24 AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -o /bin/<binary> ./cmd/<binary>

FROM gcr.io/distroless/static-debian12
COPY --from=builder /bin/<binary> /bin/<binary>
ENTRYPOINT ["/bin/<binary>"]
```

### 9. Create README.md

**Skip if `README.md` already exists.**

Generate a README with:
- Project name (from module path)
- Getting started
- Development commands (from Makefile)
- Project structure explanation

### 10. Finalize

```bash
go mod tidy
```

### 11. Report

```
## Project Scaffolded

**Module:** <module-path>
**Layout:** <layout>
**Go version:** 1.24

**Created:**
- [list of newly created files]

**Skipped (already existed):**
- [list of skipped files, or "None" if all were created]

**Next steps:**
1. cd <project-dir>
2. make test
3. Start coding!
```
