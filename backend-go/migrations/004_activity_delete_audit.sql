-- +goose Up
-- Who deleted an activity, so the admin can see and undo a mistaken delete.
-- Older deletions keep NULL (unknown).
ALTER TABLE activities ADD COLUMN deleted_by UUID REFERENCES users (id);
CREATE INDEX activities_deleted_idx ON activities (deleted_at DESC) WHERE deleted_at IS NOT NULL;

-- +goose Down
DROP INDEX IF EXISTS activities_deleted_idx;
ALTER TABLE activities DROP COLUMN IF EXISTS deleted_by;
