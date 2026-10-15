// Package worker runs background jobs on a fixed number of goroutines with
// a bounded queue, so a burst of uploads or notifications cannot exhaust
// memory, and in-flight jobs can finish during graceful shutdown.
package worker

import (
	"context"
	"log/slog"
	"sync"
	"time"
)

// Job runs with a context that is independent of any HTTP request (Fiber
// request contexts are recycled once the handler returns).
type Job func(ctx context.Context)

type Pool struct {
	name    string
	timeout time.Duration
	jobs    chan Job
	wg      sync.WaitGroup
	mu      sync.RWMutex
	closed  bool
	baseCtx context.Context
	cancel  context.CancelFunc
}

// NewPool starts workers goroutines. Each job gets jobTimeout to finish.
func NewPool(name string, workers, queueSize int, jobTimeout time.Duration) *Pool {
	ctx, cancel := context.WithCancel(context.Background())
	p := &Pool{
		name:    name,
		timeout: jobTimeout,
		jobs:    make(chan Job, queueSize),
		baseCtx: ctx,
		cancel:  cancel,
	}
	for range workers {
		p.wg.Add(1)
		go p.run()
	}
	return p
}

func (p *Pool) run() {
	defer p.wg.Done()
	for job := range p.jobs {
		p.exec(job)
	}
}

func (p *Pool) exec(job Job) {
	ctx, cancel := context.WithTimeout(p.baseCtx, p.timeout)
	defer cancel()
	defer func() {
		if r := recover(); r != nil {
			slog.Error("background job panicked", "pool", p.name, "panic", r)
		}
	}()
	job(ctx)
}

// TrySubmit queues a job without blocking. It returns false when the queue
// is full or the pool is shutting down.
func (p *Pool) TrySubmit(job Job) bool {
	p.mu.RLock()
	defer p.mu.RUnlock()
	if p.closed {
		return false
	}
	select {
	case p.jobs <- job:
		return true
	default:
		slog.Warn("background queue full, job dropped", "pool", p.name)
		return false
	}
}

// Close stops accepting jobs and waits for queued ones until ctx expires;
// then running jobs are cancelled.
func (p *Pool) Close(ctx context.Context) error {
	p.mu.Lock()
	if !p.closed {
		p.closed = true
		close(p.jobs)
	}
	p.mu.Unlock()

	done := make(chan struct{})
	go func() { p.wg.Wait(); close(done) }()
	select {
	case <-done:
		return nil
	case <-ctx.Done():
		p.cancel()
		return ctx.Err()
	}
}
