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

### 1. Create Directory Structure

Create directories based on the chosen layout.

### 2. Initialize Module

```bash
go mod init <module-path>
```

Then edit `go.mod` to set Go 1.24:

```
module <module-path>

go 1.24
```

### 3. Create main.go

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

### 4. Create main_test.go (minimal only)

```go
package main

import "testing"

func TestMain(t *testing.T) {
	// TODO: add tests
}
```

### 5. Create Makefile

Generate a Makefile with targets: `build`, `test`, `lint`, `fmt`, `vet`, `tidy`, `coverage`, `run`, `clean`, `check`.

### 6. Create .golangci.yml (standard and service)

Generate a `.golangci.yml` with recommended linters enabled.

### 7. Create Dockerfile (standard and service)

```dockerfile
FROM golang:1.24 AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -o /bin/api ./cmd/api

FROM gcr.io/distroless/static-debian12
COPY --from=builder /bin/api /bin/api
ENTRYPOINT ["/bin/api"]
```

### 8. Create README.md

Generate a README with:
- Project name (from module path)
- Getting started
- Development commands (from Makefile)
- Project structure explanation

### 9. Finalize

```bash
go mod tidy
```

### 10. Report

```
## Project Created

**Module:** <module-path>
**Layout:** <layout>
**Go version:** 1.24

**Files created:**
- [list of files]

**Next steps:**
1. cd <project-dir>
2. make test
3. Start coding!
```
