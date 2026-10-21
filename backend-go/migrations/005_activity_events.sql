-- +goose Up
-- History of changes to an activity after it was logged (edited, deleted,
-- restored), with who and when. Backs the admin timeline used for incident
-- reports; updated_at alone cannot tell an edit from a restore.
CREATE TYPE activity_event_action AS ENUM ('edited', 'deleted', 'restored');

CREATE TABLE activity_events (
    id          UUID                  PRIMARY KEY DEFAULT gen_random_uuid(),
    activity_id UUID                  NOT NULL REFERENCES activities (id) ON DELETE CASCADE,
    action      activity_event_action NOT NULL,
    actor_id    UUID                  REFERENCES users (id), -- NULL: unknown (before logging)
    at          TIMESTAMPTZ           NOT NULL DEFAULT now()
);
CREATE INDEX activity_events_activity_idx ON activity_events (activity_id, at);

-- Deletions recorded so far.
INSERT INTO activity_events (activity_id, action, actor_id, at)
SELECT id, 'deleted', deleted_by, deleted_at FROM activities WHERE deleted_at IS NOT NULL;

-- +goose Down
DROP TABLE IF EXISTS activity_events;
DROP TYPE IF EXISTS activity_event_action;
