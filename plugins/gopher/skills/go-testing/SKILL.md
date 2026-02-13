---
name: go-testing
description: Go testing patterns using stdlib as default, with table-driven tests, subtests, helpers, mocking, benchmarks, fuzzing, and Go 1.24 features. Use when writing Go tests, designing test strategies, or reviewing test quality.
---

# Go Testing Patterns

## Philosophy

- **Stdlib first** — use `testing` by default; testify is an option, not a requirement
- **Table-driven** — all tests use the table-driven pattern
- **Deterministic** — consistent results, no shared state

## Table-Driven Tests

```go
func TestValidateEmail(t *testing.T) {
    tests := []struct {
        name  string
        email string
        err   error
    }{
        {name: "valid", email: "user@example.com", err: nil},
        {name: "missing @", email: "invalid", err: ErrInvalidEmail},
        {name: "empty", email: "", err: ErrEmptyEmail},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := ValidateEmail(tt.email)
            if tt.err != nil {
                if !errors.Is(err, tt.err) {
                    t.Errorf("got %v, want %v", err, tt.err)
                }
                return
            }
            if err != nil {
                t.Errorf("unexpected error: %v", err)
            }
        })
    }
}
```

With testify (optional): `assert.ErrorIs(t, err, tt.err)` / `assert.NoError(t, err)`

## Test Helpers

```go
t.Helper()                      // points errors to caller's line
t.Cleanup(func() { db.Close() }) // runs after test, even on failure
dir := t.TempDir()              // auto-cleaned temp directory
t.Setenv("KEY", "val")          // auto-restored env var
ctx := t.Context()              // cancelled when test ends (Go 1.24)
t.Chdir(t.TempDir())            // restores cwd after test (Go 1.24)
```

## Mocking (hand-written default)

```go
type mockRepo struct {
    getFunc  func(ctx context.Context, id string) (*User, error)
    saveFunc func(ctx context.Context, u *User) error
}

func (m *mockRepo) GetByID(ctx context.Context, id string) (*User, error) {
    return m.getFunc(ctx, id)
}

func (m *mockRepo) Save(ctx context.Context, u *User) error {
    return m.saveFunc(ctx, u)
}
```

For complex mocking, testify/mock and gomock are options.

## Benchmarks (Go 1.24)

```go
func BenchmarkProcess(b *testing.B) {
    data := setup()
    b.ResetTimer()
    for b.Loop() {   // Go 1.24 preferred; classic: for range b.N
        Process(data)
    }
}

func BenchmarkSized(b *testing.B) {
    for _, size := range []int{10, 100, 1000} {
        b.Run(fmt.Sprintf("n=%d", size), func(b *testing.B) {
            data := generate(size)
            b.ResetTimer()
            for b.Loop() { Process(data) }
        })
    }
}

// Memory: b.ReportAllocs()
```

## Fuzzing

```go
func FuzzParse(f *testing.F) {
    f.Add([]byte(`{"name":"test"}`))
    f.Add([]byte(`null`))
    f.Fuzz(func(t *testing.T, data []byte) {
        var m map[string]any
        if err := json.Unmarshal(data, &m); err != nil {
            return
        }
        if _, err := json.Marshal(m); err != nil {
            t.Errorf("re-marshal failed: %v", err)
        }
    })
}
```

## testing/synctest (Go 1.24)

```go
synctest.Run(func() {
    ch := make(chan int)
    go func() {
        time.Sleep(time.Second) // fake clock
        ch <- 42
    }()
    synctest.Wait()
    val := <-ch // deterministic
})
```

## Race Detection

Always run with `-race` in CI: `go test -race ./...`

## Coverage

Default threshold: **80%** (configurable). Commands:

```bash
go test -coverprofile=coverage.out ./...
go tool cover -func=coverage.out
```

## Golden Files

```go
var update = flag.Bool("update", false, "update golden files")

func TestReport(t *testing.T) {
    got := Generate(data)
    golden := filepath.Join("testdata", t.Name()+".golden")
    if *update { os.WriteFile(golden, got, 0o644); return }
    want, _ := os.ReadFile(golden)
    if !bytes.Equal(got, want) { t.Error("mismatch; run -update") }
}
```

## Build Tags

```go
//go:build integration

func TestIntegration(t *testing.T) {
    if testing.Short() { t.Skip("skipping") }
}
```

`go test ./...` (unit only) | `go test -tags=integration ./...` | `go test -short ./...`
