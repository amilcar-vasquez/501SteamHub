# Migration Consolidation Analysis Report

## Current Migration Timeline (024-031)

> Note: Any references in this historical analysis to migration numbers above 031 are legacy context and should be ignored for current implementation work.

### PHASE 1: Fellow Onboarding Refactoring (024-025)
**Purpose:** Restructure fellow_applications data model

**024_refactor_fellow_onboarding.up.sql**
- ✓ Add first_name, last_name, bemis_number to fellow_applications
- ✓ Migrate data from full_name → first_name + last_name
- ✓ Drop full_name column
- ✓ Add traceability to fellows: source_application_id, bemis_number_verified, verified_at, verified_by
- ✓ Create unique index: unique_pending_application_per_user
- ✓ Create index: idx_fellows_verified

**025_add_moe_doc_path_to_applications.up.sql**
- ✓ Add moe_doc_path to fellow_applications
- ✓ Create index: idx_fellow_applications_moe_doc_path

**Consolidation Opportunity:** 024 and 025 could be consolidated into one migration
**Status:** These are ALREADY data migrations, minimal schema change impact

---

### PHASE 2: Data Migration (026)
**Purpose:** Populate review queue with sample data

**026_populate_review_queue.up.sql**
- ✓ Convert 3 Draft → Submitted
- ✓ Convert 2 Approved → UnderReview  
- ✓ Convert 1 Draft → NeedsRevision

**Status:** Test data migration, non-architectural
**Risk:** LOW - Safe to move to seed data or keep separate

---

### PHASE 3: Primary Key Refactoring (027-030) ⚠️ CRITICAL CONSOLIDATION AREA
**Purpose:** Migrate from VARCHAR PKs to INTEGER PKs for subjects/grade_levels

**Pattern:** 
1. Add INTEGER id columns
2. Update foreign keys in dependent tables
3. Drop old VARCHAR primary keys
4. Make new INTEGER ids primary keys

**027_add_ids_to_subjects_and_grade_levels.up.sql**
- ✓ Add SERIAL id columns to subjects, grade_levels
- ✓ Create sequences and set defaults
- Status: Initial setup step

**028_refactor_resource_subjects_fk.up.sql**
- ✓ Add subject_id column to resource_subjects
- ✓ Populate from subjects table JOIN
- ✓ Drop old subject VARCHAR column
- ✓ Create new FK: fk_resource_subjects_subject_id (subject_id → subjects.id)
- ✓ Update PK: (resource_id, subject) → (resource_id, subject_id)

**029_refactor_resource_grade_levels_fk.up.sql**
- ✓ Add grade_level_id column to resource_grade_levels
- ✓ Populate from grade_levels table JOIN
- ✓ Drop old grade_level VARCHAR column
- ✓ Create new FK: fk_resource_grade_levels_grade_level_id (grade_level_id → grade_levels.id)
- ✓ Update PK: (resource_id, grade_level) → (resource_id, grade_level_id)

**030_migrate_subject_grade_level_pks.up.sql**
- ✓ Drop old VARCHAR PKs from subjects and grade_levels
- ✓ Create new PKs on id columns
- ✓ Add UNIQUE constraints on varchar columns for backward compatibility (subject, grade_level)

**Consolidation Opportunity:** 027-030 should be ONE atomic transaction
**Status:** These are SAFE to consolidate - they form a single logical refactoring

**Dependency Chain:** 027 → 028 → 029 → 030 (MUST stay in order)

---

### PHASE 4: ILO Infrastructure (027-031 consolidated)
**Purpose:** Create learning outcome system

**031_create_cycles.up.sql**
- ✓ Create cycles table (id, cycle_number 1-4)
- ✓ Seed 4 cycles
- Status: Standalone foundation table

**032_create_strands.up.sql**
- ✓ Create strands table (id, subject_id, name)
- ✓ FK: strands.subject_id → subjects.id
- ✓ UNIQUE: (subject_id, name)
- Status: Depends on subjects table with id as PK

**033_create_ilos.up.sql**
- ✓ Create ilos table (id, subject_id, grade_level_id, cycle_id, strand_id, ilo_code, description)
- ✓ FKs: subject_id, grade_level_id, cycle_id, strand_id
- ✓ Multiple indexes including composite idx_ilos_subject_grade_cycle
- ✓ UNIQUE: (subject_id, grade_level_id, cycle_id, ilo_code)
- ✓ Trigger: ilos_updated_at
- Status: Depends on cycles, strands, subjects (with id PKs)

**034c_adjust_subjects_for_ilos.up.sql**
- ✓ Rename subjects: Science → Science and Technology, Arts → Expressive Arts, English Language Arts → Language Arts
- ✓ Insert: Health Education
- Status: Seed data/naming alignment

**034_seed_strands.up.sql**
- ✓ Populates strands table with STEAM curriculum data
- Status: Seed data (separate from schema)

**035_seed_ilos.up.sql** (251KB!)
- ✓ Large seed of ILOs (all curriculum outcomes)
- Status: Seed data (separate from schema)

**036_create_resource_ilos.up.sql**
- ✓ Create resource_ilos junction table (resource_id → ilo_id)
- ✓ FK: resource_ilos.resource_id → resources.resource_id
- ✓ FK: resource_ilos.ilo_id → ilos.id
- ✓ UNIQUE: (resource_id, ilo_id)
- Status: Depends on ilos table

**037_seed_health_education_strands_and_ilos.up.sql**
- ✓ Additional strand/ILO seed data for Health Education
- Status: Seed data

**038_add_ilo_description_index.up.sql**
- ✓ Create index on ilos(description) for search
- Status: Minor optimization

**Consolidation Opportunity:** 
- Keep 031, 032, 033, 036 as schema migrations (form logical unit)
- Consolidate 034_seed_strands + 035_seed_ilos + 037_health_ed into ONE seed migration
- Keep 034c as optional name alignment
- Keep 038 as independent optimization

---

### PHASE 5: Resource Linking (029 consolidated)
**Purpose:** Add relationship tracking between resources

**039_create_resource_links.up.sql**
- ✓ Create resource_links table (link_id, parent_resource_id, linked_resource_id, relationship_type)
- ✓ FKs: both resource_ids → resources.resource_id with CASCADE
- ✓ CHECK: parent != linked
- ✓ UNIQUE: (parent_resource_id, linked_resource_id)
- ✓ Multiple indexes on parent, linked, type
- Status: Standalone feature

---

## Identified Issues & Conflicts

### ✓ NO MAJOR CONFLICTS FOUND
All migrations are well-structured with proper idempotency (IF NOT EXISTS, ON CONFLICT DO NOTHING, EXCEPTION handling)

### Potential Concerns
1. **034c subject renames** - Apply AFTER 034c seed completes (order matters for seeding)
2. **Migration 026 test data** - Consider making optional for production
3. **Seed size (035)** - 251KB+ ILO data might slow initial deployments

---

## Database Schema Summary (Final State)

### Core Tables
- users, roles, fellows, fellow_applications
- resources, resource_subjects, resource_grade_levels, resource_access
- resource_reviews, resource_comments, review_comments, resource_status_history
- resource_links
- lessons, lesson_versions, video_metadata

### Subject/Grade System (Refactored)
- subjects (VARCHAR unique, INTEGER PK with id)
- grade_levels (VARCHAR unique, INTEGER PK with id)
- resource_subjects (FK: subject_id)
- resource_grade_levels (FK: grade_level_id)

### ILO System (New)
- cycles (4 pre-defined cycles)
- strands (subject-specific learning strands)
- ilos (intended learning outcomes)
- resource_ilos (resource → ILO mapping)

### Notifications & Logging
- notifications, auth_tokens, contributions
- schema_migrations, update_updated_at_column trigger

---

## ⚠️ BASE MIGRATIONS (000-023) - NO CHANGES

### Migrations that are NOT consolidated but form the foundation:
- **001-002**: Roles and users
- **003**: Fellows table (first_name, last_name, bemis_number, etc.)
- **004**: Subjects and grade_levels tables **(VARCHAR PKs - foundation for refactoring)**
- **005**: Resources table
- **006**: Resource ↔ Subject junction table **(uses VARCHAR FK to subjects)**
- **007**: Resource ↔ Grade Level junction table **(uses VARCHAR FK to grade_levels)**
- **008-023**: Other features and seed data

### Critical Dependency Chain:
```
004 (Creates subjects, grade_levels with VARCHAR PKs)
  ↓ FK dependency
006 (Creates resource_subjects with FK: subject → subjects(subject))
007 (Creates resource_grade_levels with FK: grade_level → grade_levels(grade_level))
  ↓ Building on
024 (Refactor fellow_applications)
025 (Refactor PKs - NEW consolidated 027-030)
   ↑ CONVERTS: subjects.subject VARCHAR PK → subjects.id INTEGER PK
   ↑ CONVERTS: grade_levels.grade_level VARCHAR PK → grade_levels.id INTEGER PK
   ↑ CONVERTS: resource_subjects FK from (resource_id, subject) → (resource_id, subject_id)
   ↑ CONVERTS: resource_grade_levels FK from (resource_id, grade_level) → (resource_id, grade_level_id)
```

### Why Consolidation is SAFE:
✓ Migrations 000-023 are **NOT changed**
✓ New consolidated 025 (from 027-030) uses idempotency (IF EXISTS, ON CONFLICT, EXCEPTION handling)
✓ Fresh databases: 004 creates VARCHAR PKs → 025 converts to INTEGER (proper sequence)
✓ Existing databases: 004 already applied, 025 is new conversion step (safe)
✓ Schema_migrations table tracks both old and new version numbers
✓ Migrate tool skips already-executed migrations

---

## Final Consolidation Plan

### CONSOLIDATE INTO:
1. **Pre-existing** (001-023 remain unchanged - foundation layer)
2. **024_refactor_fellow_applications.up** (merge 024 + 025)
3. **025_subject_grade_level_pk_refactor.up** (merge 027 + 028 + 029 + 030)
4. **026_create_ilo_infrastructure.up** (merge 031 + 032 + 033 + 036)
5. **027_create_resource_links.up** (keep as-is, was 039)
6. **028_seed_ilo_curriculum.up** (merge 034 + 034c + 035 + 037)
7. **029_populate_test_data.up** (keep as-is for optional use, was 026)
8. **030_add_ilo_search_index.up** (was 038)

### Total: 8 consolidated migrations in the 024-031 range

---

## Dependency Order (MUST BE MAINTAINED)

### Foundation Layer (Unchanged, already rolled out):
```
000-023 (base schema, including 004, 006, 007, 019)
```

### Refactoring Layer (Will be consolidated):
```
024 (Fellow refactor) - builds on 019 (fellow_applications table)
  ↓
025 (PK refactor) - converts 004, 006, 007 FKs to use INTEGER PKs
   Dependencies: Requires 004, 006, 007 already applied
   Action: Adds id columns, migrates data, changes PKs, updates FKs
  ↓
026 (ILO infrastructure) - creates new cycle/strand/ilo tables
   Dependencies: Requires 025 (needs subjects.id as INTEGER PK)
  ↓
027 (Resource links) - creates resource_links junction table
  ↓
028 (ILO curriculum seed) - populates cycles, strands, ilos with data
  ↓
029 (Test data) - optional population, safe to skip in production
  ↓
030 (Search index) - adds optimization index
```

### Impact on Database State:
- **After 023**: subjects.subject is PRIMARY KEY (VARCHAR)
- **After 025**: subjects.id is PRIMARY KEY (INTEGER), subject is UNIQUE (VARCHAR)
- **After 026**: Can reference subjects.id safely throughout ILO system

