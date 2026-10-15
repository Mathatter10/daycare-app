package push

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
)

const fcmScope = "https://www.googleapis.com/auth/firebase.messaging"

// FCM sends through the Firebase Cloud Messaging HTTP v1 API using a
// service-account key.
type FCM struct {
	client    *http.Client
	projectID string
	endpoint  string
}

// NewFCM builds a sender from a service-account JSON key. endpoint is
// normally https://fcm.googleapis.com (overridable for tests).
func NewFCM(ctx context.Context, serviceAccountJSON []byte, endpoint string) (*FCM, error) {
	creds, err := google.CredentialsFromJSONWithType(ctx, serviceAccountJSON, google.ServiceAccount, fcmScope)
	if err != nil {
		return nil, fmt.Errorf("fcm credentials: %w", err)
	}
	if creds.ProjectID == "" {
		return nil, fmt.Errorf("fcm credentials: project_id missing")
	}
	client := oauth2.NewClient(ctx, creds.TokenSource)
	client.Timeout = 10 * time.Second
	return &FCM{client: client, projectID: creds.ProjectID, endpoint: strings.TrimRight(endpoint, "/")}, nil
}

func (f *FCM) Send(ctx context.Context, token string, msg Message) error {
	payload := map[string]any{
		"message": map[string]any{
			"token":        token,
			"notification": map[string]string{"title": msg.Title, "body": msg.Body},
			"data":         msg.Data,
			"android":      map[string]any{"priority": "high"},
			"apns":         map[string]any{"payload": map[string]any{"aps": map[string]any{"sound": "default"}}},
		},
	}
	body, err := json.Marshal(payload)
	if err != nil {
		return err
	}
	url := fmt.Sprintf("%s/v1/projects/%s/messages:send", f.endpoint, f.projectID)
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(body))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := f.client.Do(req)
	if err != nil {
		return fmt.Errorf("fcm request: %w", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode == http.StatusOK {
		return nil
	}

	respBody, _ := io.ReadAll(io.LimitReader(resp.Body, 4096))
	if isUnregistered(resp.StatusCode, respBody) {
		return ErrInvalidToken
	}
	return fmt.Errorf("fcm: status %d: %s", resp.StatusCode, respBody)
}

// isUnregistered detects responses meaning the token will never work again.
func isUnregistered(status int, body []byte) bool {
	var e struct {
		Error struct {
			Status  string `json:"status"`
			Details []struct {
				ErrorCode string `json:"errorCode"`
			} `json:"details"`
		} `json:"error"`
	}
	if json.Unmarshal(body, &e) != nil {
		return false
	}
	for _, d := range e.Error.Details {
		if d.ErrorCode == "UNREGISTERED" || d.ErrorCode == "INVALID_ARGUMENT" {
			return true
		}
	}
	return status == http.StatusNotFound && e.Error.Status == "NOT_FOUND"
}
