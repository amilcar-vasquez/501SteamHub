-- 022_create_video_metadata.up.sql
-- Stores YouTube-specific metadata collected at submission time for Video resources.
-- One row per resource; enforced via UNIQUE constraint on resource_id.

CREATE TABLE IF NOT EXISTS video_metadata (
    id                  BIGSERIAL PRIMARY KEY,
    resource_id         BIGINT NOT NULL UNIQUE
                            REFERENCES resources(resource_id) ON DELETE CASCADE,
    youtube_title       VARCHAR(100)    NOT NULL,
    youtube_description TEXT            NOT NULL DEFAULT '',
    tags                TEXT[]          NOT NULL DEFAULT '{}',
    privacy_status      VARCHAR(20)     NOT NULL DEFAULT 'unlisted'
                            CHECK (privacy_status IN ('public', 'private', 'unlisted')),
    made_for_kids       BOOLEAN         NOT NULL DEFAULT false,
    category_id         INT             NOT NULL DEFAULT 27,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);
