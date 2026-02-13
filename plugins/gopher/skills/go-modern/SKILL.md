---
name: go-modern
description: Modern Go 1.21-1.24 features including new stdlib packages, generics, slog, HTTP server patterns, iterators, and Go 1.24 additions. Use when leveraging recent Go features or reviewing code for modern patterns.
---

# Modern Go (1.21–1.24)

## Go 1.21 — stdlib Packages

```go
import ("slices"; "maps"; "cmp")

slices.Sort(items)
slices.SortFunc(items, func(a, b Item) int { return cmp.Compare(a.Name, b.Name) })
slices.Contains(items, item)
slices.Reverse(items)
slices.Compact(items)    // remove consecutive dupes
cloned := slices.Clone(items)

cloned := maps.Clone(m)
maps.Copy(dst, src)
maps.Equal(a, b)

cmp.Compare(a, b)       // -1, 0, 1
cmp.Or(a, b, fallback)  // first non-zero (Go 1.22)

clear(myMap)             // keeps capacity
x := min(a, b)
y := max(a, b, c)
```

## Go 1.22

```go
// Range over integers
for i := range 10 { process(i) }

// Loop variable fix — each iteration has its own variable
for _, item := range items {
    go func() { use(item) }() // safe, no capture needed
}

// New http.ServeMux with method routing + path params
mux := http.NewServeMux()
mux.HandleFunc("GET /api/users/{id}", func(w http.ResponseWriter, r *http.Request) {
    id := r.PathValue("id")
})
```

## Go 1.23

```go
// Range over functions (iterators)
func Backwards[E any](s []E) func(yield func(int, E) bool) {
    return func(yield func(int, E) bool) {
        for i := len(s) - 1; i >= 0; i-- {
            if !yield(i, s[i]) { return }
        }
    }
}
for i, v := range Backwards(items) { /* ... */ }

// Collecting iterators
keys := slices.Collect(maps.Keys(m))
sorted := slices.Sorted(maps.Keys(m))

// unique package — interned comparable handles
handle := unique.Make("hello")
```

## Go 1.24

```go
// Generic type aliases
type Set[T comparable] = map[T]struct{}

// testing/synctest — deterministic concurrency testing
synctest.Run(func() {
    ch := make(chan int)
    go func() { time.Sleep(time.Second); ch <- 42 }() // fake clock
    synctest.Wait()
    val := <-ch
})

// os.Root — sandboxed filesystem
root, _ := os.OpenRoot("/data")
defer root.Close()
f, _ := root.Open("file.txt") // confined to /data

// b.Loop() for benchmarks
for b.Loop() { foo() }

// T.Context() and T.Chdir()
ctx := t.Context()       // cancelled when test ends
t.Chdir(t.TempDir())    // restores cwd after test

// weak pointers
ptr := weak.Make(&obj)
if strong := ptr.Value(); strong != nil { /* alive */ }

// runtime.AddCleanup — GC finalizer
runtime.AddCleanup(&obj, func(tok int) { cleanup(tok) }, token)

// Tool directives in go.mod
// tool ( golang.org/x/tools/cmd/goimports )

// omitzero JSON tag
type Config struct {
    Created time.Time `json:"created,omitzero"`
}

// Post-quantum crypto: crypto/mlkem
```

## Generics

```go
// Use for: generic algorithms, type-safe collections, reducing duplication
// Avoid for: single concrete type, just to look modern

type Number interface { ~int | ~int32 | ~int64 | ~float32 | ~float64 }
func Sum[T Number](vals []T) T {
    var s T; for _, v := range vals { s += v }; return s
}

type Repository[T any, ID comparable] interface {
    GetByID(ctx context.Context, id ID) (*T, error)
    Save(ctx context.Context, entity *T) error
    Delete(ctx context.Context, id ID) error
}
```

## slog

```go
logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo}))
logger.Info("created", slog.String("user_id", id), slog.Int("age", age))
logger.InfoContext(ctx, "request", slog.Duration("latency", elapsed))
logger.Info("event", slog.Group("user", slog.String("id", id)))
```

## HTTP Patterns

```go
// Middleware chain
type Middleware func(http.Handler) http.Handler
func Chain(h http.Handler, mws ...Middleware) http.Handler {
    for i := len(mws) - 1; i >= 0; i-- { h = mws[i](h) }
    return h
}

// Server with timeouts
srv := &http.Server{
    Addr: ":8080", Handler: handler,
    ReadTimeout: 15 * time.Second, WriteTimeout: 15 * time.Second,
}
```

## Performance

```go
users := make([]User, 0, n)           // pre-allocate
var b strings.Builder; b.Grow(n)      // string building
strconv.Itoa(42)                       // faster than fmt.Sprintf
```
