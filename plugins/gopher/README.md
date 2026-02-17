# gopher

A Claude Code plugin for Go 1.24+ development. Provides specialized agents, skills, and commands for professional Go development with TDD, quality gates, and code review.

## Installation

```bash
# Add the marketplace and install from within a Claude session
/plugin marketplace add car12o/claude-workflows
/plugin install gopher

# Or from the command line
claude plugin marketplace add car12o/claude-workflows
claude plugin install gopher

# Or clone and install for development
git clone https://github.com/car12o/claude-workflows.git
claude --plugin-dir ./claude-workflows/plugins/gopher
```

## Commands

### `/gopher-feat <feature description>`

Full development lifecycle: analysis, design, TDD implementation, quality gates, and code review.

```
/gopher-feat Add user authentication with JWT tokens
```

**Workflow:**
1. **Analysis** — go-analyzer examines requirements and codebase
2. **Design** — go-designer creates architecture and task plan
3. **[STOP 1]** — You approve the design
4. **Implementation** — go-implementer + go-quality-gate per task (autonomous)
5. **Review** — go-reviewer batch reviews all changes
6. **[STOP 2]** — You approve the final result

Scale-adaptive: small features get a lightweight inline plan; large features get full ADR + design doc.

### `/gopher-fix <bug description or issue reference>`

Lightweight bug fix workflow: reproduce with a failing test, diagnose, apply minimal fix, and review.

```
/gopher-fix Login returns 500 when email contains plus sign
```

**Workflow:**
1. **Reproduce** — go-implementer writes a failing test proving the bug
2. **Diagnose** — go-analyzer traces root cause and identifies minimal change set
3. **Fix** — go-implementer applies minimal fix + go-quality-gate runs 8 gates
4. **Review** — go-reviewer verifies correctness

Fully autonomous (no stop points). Escalates to `/gopher-feat` if the fix requires 5+ files or interface changes.

### `/gopher-refactor <description of what to refactor>`

Safe refactoring with test coverage guarantee and behavior preservation.

```
/gopher-refactor Extract user validation into shared package
```

**Workflow:**
1. **Analysis** — go-analyzer identifies target files, coverage, and blast radius
2. **Safety Net** — if coverage < 80%, go-implementer adds tests for existing behavior
3. **Refactor** — go-implementer applies changes + go-quality-gate runs 8 gates
4. **Review** — go-reviewer verifies behavior is preserved
5. **[STOP]** — You approve the final result

### `/gopher-init <module-path> [--layout minimal|standard|service]`

Scaffold a new Go project with standard structure.

```
/gopher-init github.com/myorg/myservice --layout standard
```

**Layouts:**
- `minimal` — single-file project (default)
- `standard` — cmd/internal structure with Makefile, linter config Dockerfile and migrations dir
- `service` — multi-binary

### `/gopher-review [file|--staged|--diff <base>|--pr [number]]`

Quick code review without the full development workflow.

```
/gopher-review --staged
/gopher-review internal/service/user.go
/gopher-review --diff main
/gopher-review --pr
/gopher-review --pr 42
```

## Skills

Skills are reference knowledge that agents use automatically. They activate based on context.

| Skill | Focus |
|-------|-------|
| **go-idioms** | Error handling, naming, interfaces, dependency injection |
| **go-testing** | Table-driven tests, helpers, mocking, benchmarks, fuzzing |
| **go-concurrency** | Context, errgroup, channels, sync primitives, graceful shutdown |
| **go-modern** | Go 1.21-1.24 features: slices/maps/cmp, generics, slog, iterators |
| **go-project-layout** | Project structure, package design, Makefile, CI/CD |
| **go-quality-gates** | 8-gate quality pipeline definition |

## Agents

| Agent | Role |
|-------|------|
| **go-analyzer** | Requirements analysis and scale determination |
| **go-designer** | Architecture design and task planning |
| **go-implementer** | TDD implementation (RED-GREEN-REFACTOR) |
| **go-quality-gate** | Execute 8 quality gates with auto-fix |
| **go-reviewer** | Final batch code review |

## Quality Gates

8 gates run after each implementation task:

| # | Gate | Auto-fix | Required |
|---|------|----------|----------|
| 1 | gofmt | Yes | Yes |
| 2 | goimports | Yes | Yes |
| 3 | go mod tidy | Yes | Yes |
| 4 | go vet | No | Yes |
| 5 | golangci-lint | Partial | Optional* |
| 6 | govulncheck | No | Optional* |
| 7 | go test -race | No | Yes |
| 8 | go build | No | Yes |

*Optional gates skip gracefully if the tool is not installed.

## Customization

### Coverage Threshold

Default is 80%. Override per project:

```bash
export GOPHER_COVERAGE_THRESHOLD=90
```

### Linter Configuration

Place a `.golangci.yml` in your project root. The quality gate agent will use it automatically.

### Hooks

The plugin includes a post-edit hook that advises on Go formatting issues. It's non-blocking — the quality gates handle enforcement.

## Design Decisions

- **stdlib testing by default** — testify shown as option, not mandated
- **Go 1.24+ target** — leverages latest stable features
- **Scale-adaptive stop points** — `/gopher-feat` has 2 (design + final), `/gopher-refactor` has 1 (final), `/gopher-fix` has 0 (fully autonomous)
- **Graceful degradation** — works without golangci-lint/govulncheck installed
- **Skills < 200 lines each** — focused, independently useful
