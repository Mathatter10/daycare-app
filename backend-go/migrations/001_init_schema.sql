-- +goose Up
-- Daycare MVP initial schema. Requires PostgreSQL 13+ (gen_random_uuid built in).

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------
CREATE TYPE user_role       AS ENUM ('admin', 'caregiver', 'parent');
CREATE TYPE activity_type   AS ENUM ('eat', 'sleep', 'toilet', 'play', 'medical');
CREATE TYPE media_status    AS ENUM ('pending', 'ready', 'failed');
CREATE TYPE device_platform AS ENUM ('android', 'ios', 'web');

-- +goose StatementBegin
CREATE FUNCTION set_updated_at() RETURNS trigger AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd

-- ---------------------------------------------------------------------------
-- Users (admins, caregivers, parents)
-- ---------------------------------------------------------------------------
CREATE TABLE users (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    email         TEXT        NOT NULL,
    password_hash TEXT        NOT NULL,                -- bcrypt, cost >= 10
    full_name     TEXT        NOT NULL,
    phone         TEXT,
    role          user_role   NOT NULL,
    is_active     BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Case-insensitive uniqueness; admin links children to parents by email.
CREATE UNIQUE INDEX users_email_lower_key ON users (lower(email));
CREATE INDEX users_role_idx ON users (role);

-- ---------------------------------------------------------------------------
-- Classes and caregiver assignments
-- ---------------------------------------------------------------------------
CREATE TABLE classes (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name        TEXT        NOT NULL UNIQUE,
    description TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RBAC: a caregiver may only write data for children in their assigned classes.
CREATE TABLE class_caregivers (
    class_id     UUID        NOT NULL REFERENCES classes (id) ON DELETE CASCADE,
    caregiver_id UUID        NOT NULL REFERENCES users (id)   ON DELETE CASCADE,
    assigned_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (class_id, caregiver_id)
);
CREATE INDEX class_caregivers_caregiver_idx ON class_caregivers (caregiver_id);

-- ---------------------------------------------------------------------------
-- Children
-- ---------------------------------------------------------------------------
CREATE TABLE children (
    id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name         TEXT        NOT NULL,
    nickname          TEXT,
    date_of_birth     DATE        NOT NULL,
    gender            TEXT        CHECK (gender IN ('male', 'female')),
    class_id          UUID        REFERENCES classes (id) ON DELETE SET NULL,
    -- RBAC: parents can only read children where parent_id = their user id.
    parent_id         UUID        NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    photo_key         TEXT,       -- object storage key; served via signed URL
    allergies         TEXT,
    medical_notes     TEXT,
    emergency_contact TEXT,
    is_active         BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX children_class_idx  ON children (class_id);
CREATE INDEX children_parent_idx ON children (parent_id);

-- ---------------------------------------------------------------------------
-- Attendance (one row per child per day)
-- ---------------------------------------------------------------------------
CREATE TABLE attendance (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id        UUID        NOT NULL REFERENCES children (id) ON DELETE CASCADE,
    attendance_date DATE        NOT NULL,
    check_in_at     TIMESTAMPTZ NOT NULL,
    check_in_by     UUID        NOT NULL REFERENCES users (id) ON DELETE RESTRICT,
    check_out_at    TIMESTAMPTZ,
    check_out_by    UUID        REFERENCES users (id) ON DELETE RESTRICT,
    picked_up_by    TEXT,       -- name of person collecting the child
    notes           TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (child_id, attendance_date),
    CHECK (check_out_at IS NULL OR check_out_at >= check_in_at),
    CHECK ((check_out_at IS NULL) = (check_out_by IS NULL))
);
CREATE INDEX attendance_date_idx ON attendance (attendance_date);

-- ---------------------------------------------------------------------------
-- Activities (timeline entries)
-- ---------------------------------------------------------------------------
CREATE TABLE activities (
    id           UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id     UUID          NOT NULL REFERENCES children (id) ON DELETE CASCADE,
    caregiver_id UUID          NOT NULL REFERENCES users (id)    ON DELETE RESTRICT,
    type         activity_type NOT NULL,
    started_at   TIMESTAMPTZ   NOT NULL DEFAULT now(),
    ended_at     TIMESTAMPTZ,  -- e.g. nap end; NULL while still sleeping
    -- Type-specific payload, e.g. {"portion":"half","menu":"porridge"},
    -- {"kind":"wet"}, {"temperature_c":38.2}. Keeps logging to a few taps.
    details      JSONB         NOT NULL DEFAULT '{}'::jsonb,
    notes        TEXT,
    created_at   TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ   NOT NULL DEFAULT now(),
    CHECK (ended_at IS NULL OR ended_at >= started_at)
);
-- Parent timeline query: WHERE child_id = $1 ORDER BY started_at DESC
CREATE INDEX activities_child_started_idx ON activities (child_id, started_at DESC);

-- ---------------------------------------------------------------------------
-- Media (photos / videos, uploaded in background)
-- ---------------------------------------------------------------------------
CREATE TABLE media (
    id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id    UUID         NOT NULL REFERENCES children (id)   ON DELETE CASCADE,
    activity_id UUID         REFERENCES activities (id)          ON DELETE SET NULL,
    uploaded_by UUID         NOT NULL REFERENCES users (id)      ON DELETE RESTRICT,
    storage_key TEXT         NOT NULL UNIQUE, -- never a public URL; sign on read
    mime_type   TEXT         NOT NULL,
    size_bytes  BIGINT       CHECK (size_bytes >= 0),
    status      media_status NOT NULL DEFAULT 'pending',
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE INDEX media_child_created_idx ON media (child_id, created_at DESC);
CREATE INDEX media_activity_idx      ON media (activity_id);

-- ---------------------------------------------------------------------------
-- Auth: mobile refresh tokens and admin web sessions (hashes only)
-- ---------------------------------------------------------------------------
CREATE TABLE refresh_tokens (
    id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    token_hash TEXT        NOT NULL UNIQUE, -- SHA-256 of the opaque token
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX refresh_tokens_user_idx ON refresh_tokens (user_id);

CREATE TABLE web_sessions (
    id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID        NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    token_hash TEXT        NOT NULL UNIQUE, -- SHA-256 of the HttpOnly cookie value
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX web_sessions_user_idx ON web_sessions (user_id);

-- ---------------------------------------------------------------------------
-- Push notification device tokens
-- ---------------------------------------------------------------------------
CREATE TABLE device_tokens (
    id           UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID            NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    token        TEXT            NOT NULL UNIQUE,
    platform     device_platform NOT NULL,
    last_seen_at TIMESTAMPTZ     NOT NULL DEFAULT now(),
    created_at   TIMESTAMPTZ     NOT NULL DEFAULT now()
);
CREATE INDEX device_tokens_user_idx ON device_tokens (user_id);

-- ---------------------------------------------------------------------------
-- updated_at triggers
-- ---------------------------------------------------------------------------
CREATE TRIGGER users_set_updated_at      BEFORE UPDATE ON users      FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER classes_set_updated_at    BEFORE UPDATE ON classes    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER children_set_updated_at   BEFORE UPDATE ON children   FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER attendance_set_updated_at BEFORE UPDATE ON attendance FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER activities_set_updated_at BEFORE UPDATE ON activities FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- +goose Down
DROP TABLE IF EXISTS device_tokens;
DROP TABLE IF EXISTS web_sessions;
DROP TABLE IF EXISTS refresh_tokens;
DROP TABLE IF EXISTS media;
DROP TABLE IF EXISTS activities;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS children;
DROP TABLE IF EXISTS class_caregivers;
DROP TABLE IF EXISTS classes;
DROP TABLE IF EXISTS users;
DROP FUNCTION IF EXISTS set_updated_at();
DROP TYPE IF EXISTS device_platform;
DROP TYPE IF EXISTS media_status;
DROP TYPE IF EXISTS activity_type;
DROP TYPE IF EXISTS user_role;
