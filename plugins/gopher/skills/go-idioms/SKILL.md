---
name: go-idioms
description: Core Go idioms covering error handling, naming conventions, interface design, dependency injection, and documentation. Use when implementing Go features, reviewing Go code, or designing Go APIs.
---

# Go Idioms

## Core Philosophy

1. **Simplicity over cleverness**: clear, obvious code over clever abstractions
2. **Explicit over implicit**: make intentions visible through code structure
3. **Composition over inheritance**: build through interface composition
4. **Error values over exceptions**: handle errors as values

## Error Handling

### Sentinel Errors and Wrapping

```go
var ErrNotFound = errors.New("not found")

// Wrap with context — %w at the end
if err != nil {
    return fmt.Errorf("fetching user %d: %w", userID, err)
}

if errors.Is(err, ErrNotFound) { /* handle */ }

var valErr *ValidationError
if errors.As(err, &valErr) { /* access valErr.Field */ }
```

### Structured Errors

```go
type AppError struct {
    Code    string         `json:"code"`
    Message string         `json:"message"`
    Err     error          `json:"-"`
}

func (e *AppError) Error() string { return e.Message }
func (e *AppError) Unwrap() error { return e.Err }
```

### Rules

- Never ignore errors — handle or propagate explicitly
- Add context when wrapping — include relevant identifiers
- Handle once — either log or wrap+return, not both
- Panic only for programming errors, never for user input

## Naming Conventions

```go
// Packages: short, lowercase, no underscores
package user   // good
package util   // bad — too generic

// Avoid repetition: user.Service not user.UserService
package user
type Service struct{}   // user.Service
func New() *Service     // user.New()

// Interfaces: single-method = "er" suffix
type Reader interface { Read(p []byte) (int, error) }
type Repository interface {
    Save(ctx context.Context, entity *Entity) error
    Delete(ctx context.Context, id string) error
}

// Variables
userID    // good        ctx       // good
uID       // bad         context   // bad (shadows pkg)
isValid   // clear bool  valid     // less clear
```

## Interface Design

```go
// Accept interfaces, return structs
func NewService(repo Repository) *Service { return &Service{repo: repo} }
func NewRepository(db *sql.DB) *PostgresRepo { return &PostgresRepo{db: db} }

// Small, composable interfaces
type Reader interface { Read(ctx context.Context, id string) (*Data, error) }
type Writer interface { Write(ctx context.Context, data *Data) error }
type ReadWriter interface { Reader; Writer }

// Compile-time compliance check
var _ Repository = (*PostgresRepo)(nil)
```

## Dependency Injection

```go
// Constructor injection
func NewServer(users UserService, logger *slog.Logger, cfg *Config) *Server {
    return &Server{users: users, logger: logger, config: cfg}
}

// Functional options
type Option func(*Server)

func WithLogger(l *slog.Logger) Option { return func(s *Server) { s.logger = l } }
func WithTimeout(d time.Duration) Option { return func(s *Server) { s.timeout = d } }

func NewServer(opts ...Option) *Server {
    s := &Server{logger: slog.Default(), timeout: 30 * time.Second}
    for _, opt := range opts { opt(s) }
    return s
}
```

## Documentation

```go
// Package user provides user management including creation and authentication.
package user

// User represents a registered user in the system.
type User struct {
    ID    string
    Email string
}

// New creates a User with the given email. Returns an error if invalid.
func New(email string) (*User, error) { /* ... */ }
```

## Anti-Patterns

```go
result, _ := doSomething()           // ignoring errors
if err != nil { log.Error(err); return err } // double handling
if user == nil { panic("not found") }       // panic for recoverable
func process(r *io.Reader) {}               // pointer to interface
func NewRepo() Repository {}                // return interface
go func() { for { process() } }()          // unmanaged goroutine
```
