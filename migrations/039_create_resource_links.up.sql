-- UP: Resource Links table (relationships between resources)
CREATE TABLE IF NOT EXISTS resource_links (
    link_id              SERIAL PRIMARY KEY,
    parent_resource_id   INT NOT NULL,
    linked_resource_id   INT NOT NULL,
    relationship_type    VARCHAR(100) NOT NULL,
    created_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_resource_links_parent
        FOREIGN KEY (parent_resource_id) REFERENCES resources(resource_id) ON DELETE CASCADE,
    CONSTRAINT fk_resource_links_linked
        FOREIGN KEY (linked_resource_id) REFERENCES resources(resource_id) ON DELETE CASCADE,
    CONSTRAINT chk_different_resources
        CHECK (parent_resource_id != linked_resource_id),
    CONSTRAINT unique_resource_link
        UNIQUE (parent_resource_id, linked_resource_id)
);

CREATE INDEX idx_resource_links_parent ON resource_links (parent_resource_id);
CREATE INDEX idx_resource_links_linked ON resource_links (linked_resource_id);
CREATE INDEX idx_resource_links_type   ON resource_links (relationship_type);

CREATE TRIGGER resource_links_updated_at
BEFORE UPDATE ON resource_links
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
