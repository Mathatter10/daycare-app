-- +goose Up
-- Offline-first sync: soft-deleted activities must reach other devices, and
-- clients pull changes with a keyset cursor on (updated_at, id).
ALTER TABLE activities ADD COLUMN deleted_at TIMESTAMPTZ;
CREATE INDEX activities_sync_idx ON activities (updated_at, id);
CREATE INDEX attendance_sync_idx ON attendance (updated_at, id);

-- +goose Down
DROP INDEX IF EXISTS attendance_sync_idx;
DROP INDEX IF EXISTS activities_sync_idx;
ALTER TABLE activities DROP COLUMN IF EXISTS deleted_at;
