-- UP: Video metadata table (YouTube upload details for Video resources)
CREATE TABLE IF NOT EXISTS video_metadata (
    id                  BIGSERIAL PRIMARY KEY,
    resource_id         BIGINT NOT NULL UNIQUE
                            REFERENCES resources(resource_id) ON DELETE CASCADE,
    youtube_title       VARCHAR(100) NOT NULL,
    youtube_description TEXT         NOT NULL DEFAULT '',
    tags                TEXT[]       NOT NULL DEFAULT '{}',
    privacy_status      VARCHAR(20)  NOT NULL DEFAULT 'unlisted'
                            CHECK (privacy_status IN ('public', 'private', 'unlisted')),
    made_for_kids       BOOLEAN      NOT NULL DEFAULT FALSE,
    category_id         INT          NOT NULL DEFAULT 27,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);
