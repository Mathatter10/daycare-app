// Package push sends notifications to parents' phones in the background.
package push

import (
	"context"
	"errors"
	"log/slog"
	"strings"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
	"github.com/Mathatter10/daycare-app/backend-go/internal/worker"
)

// ErrInvalidToken means the device token is no longer valid (app removed,
// token rotated) and should be deleted.
var ErrInvalidToken = errors.New("invalid device token")

type Message struct {
	Title string
	Body  string
	Data  map[string]string // for deep links: type, child_id, id
}

type Sender interface {
	Send(ctx context.Context, token string, msg Message) error
}

// LogSender is used when FCM is not configured: it only logs.
type LogSender struct{}

func (LogSender) Send(_ context.Context, _ string, msg Message) error {
	slog.Info("push not configured, notification skipped", "title", msg.Title)
	return nil
}

// Dispatcher fans a notification out to every device of a child's parent.
type Dispatcher struct {
	q      *repository.Queries
	sender Sender
	pool   *worker.Pool
}

func NewDispatcher(db *pgxpool.Pool, sender Sender, pool *worker.Pool) *Dispatcher {
	return &Dispatcher{q: repository.New(db), sender: sender, pool: pool}
}

// NotifyParents queues a notification about a child. build receives the
// child's display name (nickname, else first name). It never blocks the
// caller; if the queue is full the notification is dropped and logged.
func (d *Dispatcher) NotifyParents(childID uuid.UUID, build func(childName string) Message) {
	d.pool.TrySubmit(func(ctx context.Context) {
		names, err := d.q.GetChildNames(ctx, childID)
		if err != nil {
			slog.Error("push: load child", "child_id", childID, "err", err)
			return
		}
		tokens, err := d.q.ListParentDeviceTokens(ctx, childID)
		if err != nil {
			slog.Error("push: load device tokens", "child_id", childID, "err", err)
			return
		}
		if len(tokens) == 0 {
			return
		}

		msg := build(displayName(names))
		for _, token := range tokens {
			err := d.sender.Send(ctx, token, msg)
			switch {
			case errors.Is(err, ErrInvalidToken):
				if delErr := d.q.DeleteDeviceTokenByValue(ctx, token); delErr != nil {
					slog.Error("push: delete invalid token", "err", delErr)
				}
			case err != nil:
				slog.Error("push: send failed", "child_id", childID, "err", err)
			}
		}
	})
}

func displayName(n repository.GetChildNamesRow) string {
	if n.Nickname.Valid && n.Nickname.String != "" {
		return n.Nickname.String
	}
	first, _, _ := strings.Cut(strings.TrimSpace(n.FullName), " ")
	return first
}
