# Resource Linking Feature Implementation Summary

## Overview
Implemented a complete resource linking system that allows resources to be linked together with relationships, validating that linked resources share the same contributor and have overlapping subjects or grade levels.

## Database Changes

### New Table: `resource_links` (Migration 039)
```sql
CREATE TABLE resource_links (
    link_id              SERIAL PRIMARY KEY,
    parent_resource_id   INT NOT NULL,
    linked_resource_id   INT NOT NULL,
    relationship_type    VARCHAR(100) NOT NULL,
    created_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (parent_resource_id, linked_resource_id),
    CHECK (parent_resource_id != linked_resource_id)
)
```

**Key Features:**
- Unique constraint on (parent_resource_id, linked_resource_id) prevents duplicate links
- Check constraint prevents self-linking
- Automatic timestamp management with trigger
- Indexed on parent_id, linked_id, and relationship_type for fast queries

## Code Changes

### 1. Model: `internal/data/resource_links.go`
**New ResourceLinksModel with methods:**
- `Insert(parentID, linkedID, relationshipType)` - Create a new link
- `GetByParent(parentID)` - Get all resources linked FROM a resource
- `GetByLinked(linkedID)` - Get all resources that link TO a resource
- `Delete(parentID, linkedID)` - Remove a link
- `Exists(parentID, linkedID)` - Check if a link exists

**Types:**
- `LinkedResource` - Represents a resource in the linked_resources array
- `ResourceLink` - Internal representation of the relationship

### 2. Updated: `internal/data/resources.go`
**Resource struct changes:**
- Added `LinkedResources []*LinkedResource` field (JSON field name: "linked_resources")

**New methods:**
- `GetLinkedResources(resourceID)` - Loads linked resources for a resource

**Modified methods:**
- `Get()` - Now loads linked resources automatically (non-critical, continues on error)
- `GetBySlug()` - Now loads linked resources automatically

### 3. Updated: `internal/data/models.go`
- Added `ResourceLinks *ResourceLinksModel` to Models struct
- Updated `NewModels()` to initialize ResourceLinksModel

### 4. Helper Function: `cmd/api/helpers.go`
**New function:**
```go
func hasOverlap(a, b []string) bool
```
Checks if two string slices have at least one common element using efficient O(n+m) algorithm with map-based lookup.

### 5. Updated Handler: `cmd/api/resourceHandlers.go`

#### createResourceHandler Changes:
**Input struct updated:** Added LinkedResources field:
```go
LinkedResources []struct {
    ResourceID       int64  `json:"resource_id"`
    RelationshipType string `json:"relationship_type"`
} `json:"linked_resources,omitempty"`
```

**Validation Logic:**
After resource creation, processes linked resources with:
1. **Existence check** - Linked resource must exist
2. **Contributor match** - Both resources must have same ContributorID
3. **Overlap validation** - Resources must share at least one:
   - Subject OR
   - Grade level
4. **Duplicate prevention** - Won't create duplicate links
5. **Selective insertion** - Invalid links are skipped with logging, not rejected

**Logging:** Comprehensive logging for debugging:
- Successfully processed links
- Skipped links with reasons (contributor mismatch, no overlap, already exists)
- Errors during processing

**Response Impact:**
- getResourceHandler automatically includes linked_resources array
- getResourceBySlugHandler automatically includes linked_resources array

## Usage Examples

### Creating a Resource with Links
```json
{
  "title": "Advanced Calculus Lesson",
  "category": "LessonPlan",
  "subjects": ["Mathematics"],
  "grade_levels": ["Grade 11", "Grade 12"],
  "status": "Draft",
  "contributor_id": 42,
  "linked_resources": [
    {
      "resource_id": 100,
      "relationship_type": "prerequisite"
    },
    {
      "resource_id": 101,
      "relationship_type": "related_topic"
    }
  ]
}
```

### Response with Linked Resources
```json
{
  "resource": {
    "resource_id": 105,
    "title": "Advanced Calculus Lesson",
    "category": "LessonPlan",
    "subjects": ["Mathematics"],
    "grade_levels": ["Grade 11", "Grade 12"],
    "contributor_id": 42,
    "contributor_name": "John Doe",
    "linked_resources": [
      {
        "resource_id": 100,
        "title": "Limits and Continuity",
        "category": "Video",
        "summary": "Introduction to limits",
        "contributor_id": 42,
        "contributor_name": "John Doe",
        "relationship_type": "prerequisite"
      },
      {
        "resource_id": 101,
        "title": "Derivatives Fundamentals",
        "category": "Slideshow",
        "summary": "Basic derivative concepts",
        "contributor_id": 42,
        "contributor_name": "John Doe",
        "relationship_type": "related_topic"
      }
    ]
  }
}
```

## Validation Rules

### Valid Link Requirements (ALL must be met):
1. ✅ Linked resource exists
2. ✅ Same ContributorID
3. ✅ At least one overlapping subject OR grade level
4. ✅ No duplicate link exists

### Invalid Link Scenarios (skipped with logging):
- ❌ Linked resource doesn't exist → Logged as warning, skipped
- ❌ Different contributor → Logged as warning, skipped
- ❌ No subject/grade level overlap → Logged as warning, skipped
- ❌ Link already exists → Logged as info, skipped

## Architecture & Best Practices

### Clean Separation of Concerns:
- **DB Logic**: `ResourceLinksModel` handles all database operations
- **Validation**: `createResourceHandler` validates business rules
- **Helpers**: `hasOverlap()` utility function for common operations
- **Models**: `Resource` and `LinkedResource` types clearly defined

### Performance Considerations:
- Linked resources loaded only on demand in `Get()` and `GetBySlug()`
- `GetAll()` does NOT load linked resources to avoid N+1 queries
- Efficient overlap checking using map-based lookups
- Indexes on foreign keys and relationship_type for fast queries

### Error Handling:
- Non-critical errors (e.g., failed to load linked resources in Get) don't fail the request
- Invalid links during creation are logged but don't stop the creation
- All database operations use context with 3-second timeout

### Idiomatic Go:
- Follows existing project patterns and conventions
- Proper error handling and logging throughout
- Clean struct organization and tagging
- Transaction use where appropriate

## Migration Steps

1. Run migration 039:
   ```bash
   migrate -path ./migrations -database "postgres://..." up
   ```

2. Rebuild the application:
   ```bash
   go build ./cmd/api
   ```

3. Test the feature with POST requests to `/v1/resources` with `linked_resources` field

## Future Enhancements

Potential additions:
- Bulk operations for managing links (add multiple, delete multiple)
- Query parameter filtering by relationship_type
- Endpoint to manage links separately from resource creation
- Link validation in update handler
- Reverse link support (automatic bidirectional linking)
- Link metadata (e.g., sequence order, strength/weight)
