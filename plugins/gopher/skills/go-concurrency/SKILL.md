---
name: go-concurrency
description: Go concurrency patterns including context propagation, errgroup, goroutine lifecycle, channels, synchronization, and graceful shutdown. Use when designing concurrent systems or reviewing concurrency safety.
---

# Go Concurrency Patterns

## Context Propagation

```go
// Every I/O function: context as first param
func (s *Service) Process(ctx context.Context, id string) error {
    data, err := s.repo.Get(ctx, id)
    if err != nil { return fmt.Errorf("getting data: %w", err) }

    if err := ctx.Err(); err != nil { return err } // check before expensive ops
    return s.handle(ctx, data)
}

// Timeout
ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
defer cancel()

// Values (sparingly, use unexported key types)
type contextKey string
const reqIDKey contextKey = "requestID"
func WithReqID(ctx context.Context, id string) context.Context {
    return context.WithValue(ctx, reqIDKey, id)
}
```

## errgroup

```go
import "golang.org/x/sync/errgroup"

// Basic — concurrent fetch
g, ctx := errgroup.WithContext(ctx)
results := make([]Data, len(ids))
for i, id := range ids {
    g.Go(func() error {
        data, err := fetch(ctx, id)
        if err != nil { return fmt.Errorf("fetching %s: %w", id, err) }
        results[i] = data
        return nil
    })
}
if err := g.Wait(); err != nil { return nil, err }

// With concurrency limit
g.SetLimit(10)
for _, item := range items {
    g.Go(func() error { return process(ctx, item) })
}
```

## Goroutine Lifecycle

```go
func (w *Worker) Start(ctx context.Context) error {
    g, ctx := errgroup.WithContext(ctx)
    for range w.numWorkers {
        g.Go(func() error {
            for {
                select {
                case <-ctx.Done():
                    return ctx.Err()
                case job, ok := <-w.jobs:
                    if !ok { return nil }
                    if err := w.process(ctx, job); err != nil { return err }
                }
            }
        })
    }
    return g.Wait()
}
```

## Channel Patterns

```go
// Pipeline
func Pipeline(ctx context.Context, in <-chan int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)
        for { select {
            case <-ctx.Done(): return
            case v, ok := <-in:
                if !ok { return }
                select { case out <- transform(v): case <-ctx.Done(): return }
        }}
    }()
    return out
}
```

## Synchronization

```go
// Mutex
type SafeCache struct {
    mu    sync.RWMutex
    items map[string]Item
}
func (c *SafeCache) Get(k string) (Item, bool) {
    c.mu.RLock(); defer c.mu.RUnlock()
    v, ok := c.items[k]; return v, ok
}
func (c *SafeCache) Set(k string, v Item) {
    c.mu.Lock(); defer c.mu.Unlock()
    c.items[k] = v
}

// Atomic
var counter atomic.Int64
counter.Add(1)
counter.Load()

// Once
var once sync.Once
once.Do(func() { conn = openDB() })

// Pool
var bufPool = sync.Pool{New: func() any { return new(bytes.Buffer) }}
buf := bufPool.Get().(*bytes.Buffer)
defer func() { buf.Reset(); bufPool.Put(buf) }()
```

## Graceful Shutdown

```go
func main() {
    ctx, stop := signal.NotifyContext(context.Background(),
        syscall.SIGINT, syscall.SIGTERM)
    defer stop()

    srv := &http.Server{Addr: ":8080", Handler: mux}
    g, ctx := errgroup.WithContext(ctx)

    g.Go(func() error {
        if err := srv.ListenAndServe(); !errors.Is(err, http.ErrServerClosed) {
            return err
        }
        return nil
    })
    g.Go(func() error {
        <-ctx.Done()
        shutCtx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
        defer cancel()
        return srv.Shutdown(shutCtx)
    })

    if err := g.Wait(); err != nil && !errors.Is(err, context.Canceled) {
        slog.Error("exit", "error", err)
        os.Exit(1)
    }
}
```

## Anti-Patterns

- Goroutine without lifecycle: `go func() { for { process() } }()`
- Shared state without sync: `go func() { counter++ }()`
- Goroutine leak: no way to cancel/stop
- `context.Background()` deep in call stack
- Mutex held across I/O calls
