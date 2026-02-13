# Example: Customizing Quality Gates

The gopher plugin's quality gates are configurable to match your project's needs.

## Coverage Threshold

Default is 80%. To change it:

```bash
# Set for current session
export GOPHER_COVERAGE_THRESHOLD=90

# Or add to your shell profile
echo 'export GOPHER_COVERAGE_THRESHOLD=90' >> ~/.bashrc
```

The go-quality-gate agent reads this variable when running Gate 7 (tests + coverage).

## Linter Configuration

Create a `.golangci.yml` in your project root. The go-quality-gate agent uses it automatically during Gate 5.

### Strict Configuration

```yaml
run:
  timeout: 5m
  go: "1.24"

linters:
  enable:
    # Everything from recommended, plus extras
    # Defaults
    - errcheck
    - govet
    - staticcheck
    - unused
    - gosimple
    - ineffassign
    # Error handling
    - errorlint
    - errname
    # Security
    - gosec
    - bodyclose
    - noctx
    # Code quality
    - gocritic
    - revive
    - unconvert
    - wastedassign
    - forcetypeassert
    - exhaustive
    - nilnil
    - usestdlibvars
    - misspell
    - prealloc
    # Conditional
    - sloglint
    - testifylint
    # Strict extras
    - godot            # godoc sentence endings
    - unparam          # unused function parameters
    - gocheckcompilerdirectives  # validate //go: directives
```

### Relaxed Configuration

For prototypes or early-stage projects:

```yaml
run:
  timeout: 3m
  go: "1.24"

linters:
  enable:
    - errcheck
    - govet
    - staticcheck
    - gosimple
    - gosec
    - errorlint
```

## Skipping Optional Gates

Gates 5 (golangci-lint) and 6 (govulncheck) are optional. If you don't have these tools installed, the quality pipeline skips them gracefully and reports:

```
Gate 5 (golangci-lint): SKIPPED — not installed
Gate 6 (govulncheck):   SKIPPED — not installed
Result: PASS (6/6 essential gates passed, 2 optional skipped)
```

## Installing Optional Tools

To enable all 8 gates:

```bash
# golangci-lint
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# govulncheck
go install golang.org/x/vuln/cmd/govulncheck@latest
```

Or use Go 1.24 tool directives in your `go.mod`:

```
tool (
    github.com/golangci/golangci-lint/cmd/golangci-lint
    golang.org/x/vuln/cmd/govulncheck
)
```

Then run `go mod tidy` and tools will be available via `go tool`.
