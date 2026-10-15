-- +goose Up
-- Media: photos are processed by the server (resize, EXIF stripped), videos
-- are uploaded straight to object storage with a presigned URL.
CREATE TYPE media_kind AS ENUM ('photo', 'video');

ALTER TABLE media
    ADD COLUMN kind       media_kind  NOT NULL DEFAULT 'photo',
    ADD COLUMN thumb_key  TEXT,
    ADD COLUMN width      INT CHECK (width > 0),
    ADD COLUMN height     INT CHECK (height > 0),
    ADD COLUMN taken_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    ADD COLUMN updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    ADD COLUMN deleted_at TIMESTAMPTZ;
ALTER TABLE media ALTER COLUMN kind DROP DEFAULT;

CREATE INDEX media_child_taken_idx ON media (child_id, taken_at DESC);
CREATE TRIGGER media_set_updated_at BEFORE UPDATE ON media
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- +goose Down
DROP TRIGGER IF EXISTS media_set_updated_at ON media;
DROP INDEX IF EXISTS media_child_taken_idx;
ALTER TABLE media
    DROP COLUMN IF EXISTS deleted_at,
    DROP COLUMN IF EXISTS updated_at,
    DROP COLUMN IF EXISTS taken_at,
    DROP COLUMN IF EXISTS height,
    DROP COLUMN IF EXISTS width,
    DROP COLUMN IF EXISTS thumb_key,
    DROP COLUMN IF EXISTS kind;
DROP TYPE IF EXISTS media_kind;
