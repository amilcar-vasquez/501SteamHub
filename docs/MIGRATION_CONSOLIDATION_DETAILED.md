# MIGRATION CONSOLIDATION - DETAILED IMPLEMENTATION PLAN

## 📋 Executive Summary
**Current:** consolidated migration set through 031
**Proposed:** Consolidate to 8 migrations in 024-031 range
**Risk Level:** MEDIUM (requires careful merging of transactions)
**Down Migrations:** All down migrations exist, will need to create new consolidated downs

> Note: References in this historical planning document to migration numbers above 031 are legacy context and should be ignored for current implementation work.

---

## 🔄 CONSOLIDATION MAPPING

### GROUP 1: Fellow Applications Refactoring
**Consolidate:** 024 + 025 → **NEW 024**
**Name:** `024_refactor_fellow_applications.up.sql`

**Down:** Create new `024_refactor_fellow_applications.down.sql`

**Contains:**
```
FROM 024:
- Add first_name, last_name, bemis_number to fellow_applications
- Migrate data from full_name → split into first_name + last_name
- Drop full_name column
- Make new columns NOT NULL
- Add source_application_id, bemis_number_verified, verified_at, verified_by to fellows
- Create indexes

FROM 025:
- Add moe_doc_path to fellow_applications
- Create index idx_fellow_applications_moe_doc_path
```

**Files to Delete:** 025_add_moe_doc_path_to_applications.{up,down}.sql

---

### GROUP 2: Subject/Grade Level Primary Key Refactoring
**Consolidate:** 027 + 028 + 029 + 030 → **NEW 025**
**Name:** `025_subject_grade_level_pk_refactor.up.sql`

**Down:** Create new `025_subject_grade_level_pk_refactor.down.sql`

**Contains:**
```
FROM 027: Add SERIAL id columns
- subjects: add id column
- grade_levels: add id column
- Create sequences and set defaults

FROM 028: Refactor resource_subjects FKs
- Add subject_id column to resource_subjects
- Populate from subjects table JOIN
- Drop old subject VARCHAR column
- Update FK constraint (subject → subject_id)
- Update PK from (resource_id, subject) to (resource_id, subject_id)
- Update indexes

FROM 029: Refactor resource_grade_levels FKs
- Add grade_level_id column to resource_grade_levels
- Populate from grade_levels table JOIN
- Drop old grade_level VARCHAR column
- Update FK constraint (grade_level → grade_level_id)
- Update PK from (resource_id, grade_level) to (resource_id, grade_level_id)
- Update indexes

FROM 030: Complete PK Migration
- Drop old VARCHAR PKs from subjects and grade_levels
- Add new INTEGER PKs
- Add UNIQUE constraints on varchar columns
```

**Files to Delete:** 
- 027_add_ids_to_subjects_and_grade_levels.{up,down}.sql
- 028_refactor_resource_subjects_fk.{up,down}.sql
- 029_refactor_resource_grade_levels_fk.{up,down}.sql
- 030_migrate_subject_grade_level_pks.{up,down}.sql

**Migration/Rename Instructions:**
- Old 026 stays as 026 (populate_review_queue)
- Old 031+ becomes 026+

---

### GROUP 3: ILO Infrastructure Schema
**Consolidate:** 031 + 032 + 033 + 036 → **NEW 027**
**Name:** `027_create_ilo_infrastructure.up.sql`

**Down:** Create new `027_create_ilo_infrastructure.down.sql`

**Contains (In Order):**
```
FROM 031: Create cycles table
- cycles table with id, cycle_number
- Seed 4 cycles
- Set sequence

FROM 032: Create strands table
- strands table with id, subject_id, name
- FK to subjects(id)
- Indexes and unique constraints

FROM 033: Create ilos table
- ilos table with id, subject_id, grade_level_id, cycle_id, strand_id, ilo_code, description
- Multiple FKs and indexes
- Composite index idx_ilos_subject_grade_cycle
- Trigger: ilos_updated_at

FROM 036: Create resource_ilos table
- resource_ilos junction table
- FK to resources and ilos
```

**Files to Delete:**
- 031_create_cycles.{up,down}.sql
- 032_create_strands.{up,down}.sql
- 033_create_ilos.{up,down}.sql
- 036_create_resource_ilos.{up,down}.sql

---

### GROUP 4: ILO Curriculum Seed Data
**Consolidate:** 034 + 034c + 035 + 037 → **NEW 028**
**Name:** `028_seed_ilo_curriculum.up.sql`

**Down:** Create new `028_seed_ilo_curriculum.down.sql`

**Contains (In Order):**
```
FROM 034_seed_strands: Subject-specific learning strands
- All STEAM strands

FROM 034c_adjust_subjects_for_ilos: Subject name alignment
- Science → Science and Technology
- Arts → Expressive Arts
- English Language Arts → Language Arts
- Insert Health Education

FROM 035_seed_ilos: Large curriculum seed
- All ILOs (251KB data)

FROM 037_seed_health_education: Additional seed
- Health Education strands and ILOs
```

**Files to Delete:**
- 034_seed_strands.{up,down}.sql
- 034c_adjust_subjects_for_ilos.{up,down}.sql
- 035_seed_ilos.{up,down}.sql
- 037_seed_health_education_strands_and_ilos.{up,down}.sql

---

### GROUP 5: Resource Links Feature
**Keep As:** **NEW 029** (currently 039)
**Name:** `029_create_resource_links.up.sql`

**Rename only:**
- Rename 039_create_resource_links.{up,down}.sql to 029_*

---

### GROUP 6: Optimization Index
**Keep As:** **NEW 030** (currently 038)
**Name:** `030_add_ilo_description_index.up.sql`

**Rename only:**
- Rename 038_add_ilo_description_index.{up,down}.sql to 030_*

---

### GROUP 7: Test Data Population
**Keep As:** **NEW 031** (currently 026)
**Name:** `031_populate_test_data.up.sql`

**NOTE:** Keep separate for optional use (can skip in production)

**Rename only:**
- Rename 026_populate_review_queue.{up,down}.sql to 031_*

---

## � BASE MIGRATIONS (000-023) - DEPENDENCY ANALYSIS

### Critical Migrations Affected by Consolidation:

**Migration 004: `004_create_subjects_and_grade_levels.up.sql`** (UNCHANGED)
- Creates: subjects(subject VARCHAR PRIMARY KEY)
- Creates: grade_levels(grade_level VARCHAR PRIMARY KEY)
- Status: Foundation table - remains as-is
- Impact: New consolidated 025 will add id columns and transition PKs

**Migration 006: `006_create_resource_subjects.up.sql`** (UNCHANGED)
- Creates: resource_subjects(resource_id, subject VARCHAR)
- FK: subject → subjects(subject)
- PK: (resource_id, subject)
- Status: Foundation table - remains as-is
- Impact: New consolidated 025 will refactor to use subject_id (INTEGER) FK

**Migration 007: `007_create_resource_grade_levels.up.sql`** (UNCHANGED)
- Creates: resource_grade_levels(resource_id, grade_level VARCHAR)
- FK: grade_level → grade_levels(grade_level)
- PK: (resource_id, grade_level)
- Status: Foundation table - remains as-is
- Impact: New consolidated 025 will refactor to use grade_level_id (INTEGER) FK

**Migration 003: `003_create_fellows.up.sql`** (UNCHANGED)
- Creates: fellows table with first_name, last_name, bemis_number
- Status: Foundation table - remains as-is
- Impact: New consolidated 024 will add source_application_id, bemis_number_verified, verified_at, verified_by

**Migration 019: `019_create_fellow_applications.up.sql`** (UNCHANGED)
- Creates: fellow_applications with full_name VARCHAR
- Status: Foundation table - remains as-is
- Impact: New consolidated 024 will add first_name, last_name, bemis_number, etc.

**Migration 023: `023_add_steam_points_to_fellows.up.sql`** (UNCHANGED)
- Adds: steam_points to fellows table
- Status: Self-contained - remains as-is

### Why This is SAFE for Consolidation:

✓ **Migrations 000-023 are not modified** - they remain in their original state
✓ **No cascading changes** - new 024-031 build on top of existing schema
✓ **Idempotency preserved** - all consolidations use IF EXISTS, ON CONFLICT, EXCEPTION handling
✓ **Fresh deployments** - will apply 001-023, then new 024-031 in proper order
✓ **Existing deployments** - schema_migrations already has 001-023 recorded, will execute new migrations sequentially
✓ **Rollback safety** - migrate tool manages by version number, not file location

### Migration Execution Order (Guaranteed by version numbers):

```
Phase 1 - Foundation (001-023): Already deployed on all systems
  ├─ 001: Roles
  ├─ 002: Users
  ├─ 003: Fellows
  ├─ 004: Subjects & Grade Levels (VARCHAR PKs)
  ├─ 005: Resources
  ├─ 006: Resource↔Subject (uses subject VARCHAR FK)
  ├─ 007: Resource↔Grade Level (uses grade_level VARCHAR FK)
  ├─ 008-018: Other features
  ├─ 019: Fellow Applications
  ├─ 020: Seed Roles
  ├─ 021: Seed Subjects & Grade Levels
  ├─ 022: Seed Admin User
  └─ 023: Add steam_points to fellows

Phase 2 - Consolidations (024-031): New structure
  ├─ 024: Refactor Fellow Applications (adds first_name, last_name, bemis_number)
  │        Also modifies: fellows table (adds source_application_id, verification fields)
  │        Depends on: 003 (fellows), 019 (fellow_applications)
  │
  ├─ 025: Subject/Grade Level PK Refactor (BIG CHANGE)
  │        Changes: subjects VARCHAR PK → INTEGER PK with id
  │        Changes: grade_levels VARCHAR PK → INTEGER PK with id
  │        Updates: resource_subjects PK/FK to use subject_id instead of subject
  │        Updates: resource_grade_levels PK/FK to use grade_level_id instead of grade_level
  │        Depends on: 004, 006, 007 (already executed)
  │        Idempotent: Uses IF EXISTS, ON CONFLICT, exception handling
  │
  ├─ 026: ILO Infrastructure Schema
  │        Creates: cycles, strands, ilos, resource_ilos tables
  │        Depends on: 025 (needs subjects.id as INTEGER PK)
  │
  ├─ 027: Resource Links
  │        Creates: resource_links junction table
  │        Independent: Depends on basic resources table
  │
  ├─ 028: ILO Curriculum Seed Data
  │        Populates: cycles, strands, ilos (251KB)
  │        Depends on: 026 (ilos table must exist)
  │
  ├─ 029: Test Data Population (OPTIONAL)
  │        Modifies: resource status values for testing
  │        Can be skipped in production
  │
  └─ 030: ILO Search Index
          Creates: idx on ilos(description)
          Independent: Depends on 026 (ilos table exists)
```

---

## �📊 File Migration Summary

### TO DELETE (16 files):
```
025_add_moe_doc_path_to_applications.{up,down}
027_add_ids_to_subjects_and_grade_levels.{up,down}
028_refactor_resource_subjects_fk.{up,down}
029_refactor_resource_grade_levels_fk.{up,down}
030_migrate_subject_grade_level_pks.{up,down}
031_create_cycles.{up,down}
032_create_strands.{up,down}
033_create_ilos.{up,down}
034_seed_strands.{up,down}
034c_adjust_subjects_for_ilos.{up,down}
035_seed_ilos.{up,down}
036_create_resource_ilos.{up,down}
037_seed_health_education_strands_and_ilos.{up,down}
038_add_ilo_description_index.{up,down}
039_create_resource_links.{up,down}
```

### TO CREATE (8 files):
```
024_refactor_fellow_applications.{up,down}
025_subject_grade_level_pk_refactor.{up,down}
027_create_ilo_infrastructure.{up,down}
028_seed_ilo_curriculum.{up,down}
```

### TO RENAME (4 files):
```
026_populate_review_queue.{up,down} → 031_populate_test_data.{up,down}
039_create_resource_links.{up,down} → 029_create_resource_links.{up,down}
038_add_ilo_description_index.{up,down} → 030_add_ilo_description_index.{up,down}
```

---

## ⚠️ CRITICAL ORDERING & DEPENDENCIES

### MUST BE MAINTAINED:
```
024 (Fellow refactor) - Independent
  ↓
025 (PK refactor) - ✓ Depends on subjects/grade_levels table structure
  ↓
026 (existing) - Independent
  ↓
027 (ILO infrastructure) - ✓ Requires subjects with id as PK
  ↓
028 (ILO seed) - ✓ Depends on cycles, strands, ilos tables created in 027
  ↓
029 (Resource links) - Independent
  ↓
030 (Optimization) - Independent (depends on ilos table, but safe to skip)
  ↓
031 (Test data) - Optional, can be skipped in production
```

---

## 🔍 VALIDATION CHECKLIST

Before applying consolidations, verify:

- [ ] All 16 down migrations exist
- [ ] No orphaned foreign key references
- [ ] All indexes are explicitly named
- [ ] Triggers referenced exist (update_updated_at_column)
- [ ] No duplicate constraint names after consolidation
- [ ] Sequence management correct (SELECT setval... exists)
- [ ] Exception handling preserved (EXCEPTION WHEN...)
- [ ] Idempotency maintained (IF NOT EXISTS, ON CONFLICT)

---

## � COMPATIBILITY WITH BASE MIGRATIONS

### For Fresh Deployments (Green Field):
1. Migrations 001-023 execute normally
2. Migrations 024-031 execute in order
3. Result: Clean schema with integer PKs for subjects/grade_levels from the start
4. **No issues** ✓

### For Existing Deployments (Already has 001-023):
1. schema_migrations table already has entries 1-23
2. New migrations 024-031 are new entries  
3. Migrate tool skips 1-23 (already applied)
4. Migrate tool applies 24-31 (versions don't exist yet)
5. Consolidation creates NEW version entries: 24, 25, 26, 27, 28, 29, 30, 31
6. **No conflicts because old migration versions (027-039) are completely replaced**
   - Old: `027_add_ids_to_subjects_and_grade_levels` (version 27)
   - New: `025_subject_grade_level_pk_refactor` (version 25)
   - Migration tool only cares about version number, not filename
   - Old 27 is replaced by new 25, 26, 27 in correct order

### For Rollback Scenarios:
```
Consolidated database state:
  schema_migrations shows: [1, 2, ..., 22, 23, 24, 25, 26, 27, 28, 29, 30, 31]

Running migrations on a fresh system:
  - Applies 1-31 sequentially
  - No conflict inside the consolidated migration chain
  - The final schema matches the consolidated deployment state
```

**⚠️ CRITICAL NOTE:** Once consolidation is implemented, the NEW migrations 024-031 should be used for all NEW deployments. References above 031 are legacy context only and can be ignored.

---

## 🛡️ VALIDATION CHECKLIST (000-023 Specific)

Before consolidation, verify:

- [ ] Migration 004 down deletes subjects and grade_levels (preserves table structure contracts)
- [ ] Migration 006 down deletes resource_subjects (no orphaned FKs)
- [ ] Migration 007 down deletes resource_grade_levels (no orphaned FKs)
- [ ] Migration 019 down deletes fellow_applications (no orphaned FKs)
- [ ] New 025 migration has idempotency for all table modifications
- [ ] New 025 migration handles existing data properly (no data loss)
- [ ] New 024 migration preserves foreign key constraints
- [ ] All EXCEPTION handlers in new 025 catch duplicate_object and undefined_object correctly
- [ ] Sequence management in new migrations doesn't conflict with existing sequences
- [ ] No hardcoded IDs that might conflict if database already has data

---

## �📝 IMPLEMENTATION STEPS

1. **Backup current migrations/folder**
   ```bash
   cp -r migrations migrations.backup.$(date +%s)
   ```

2. **Create new consolidated migration files** (will contain merged SQL)

3. **Create new down migration files** (reversal order matters!)

4. **Verify schema_migrations table** won't conflict

5. **Test locally:**
   ```bash
   make db/migrations/up
   make db/migrations/version  # Should be 031
   ```

6. **Test rollback:**
   ```bash
   make db/migrations/down
   ```

7. **Delete old files** (after successful testing)

8. **Rename bulk migration numbers** in remaining files if needed

---

## 📦 IMPACT ANALYSIS

**Production Deployment:**
- Fresh deployments: Use consolidated migrations (faster)
- Existing deployments: Run `make db/migrations/up` normally (skips already-executed)
- Containerization: Consolidated migrations simplify Dockerfile COPY and entrypoint

**Compatibility:**
- ✓ Existing schema_migrations table tracks version numbers
- ✓ migrate tool will skip already-executed migrations by version
- ✓ No data loss (all refactoring includes data migration)

---

## ✅ READY FOR REVIEW

**User Action Required:**
1. Review consolidation plan above
2. Confirm no objections to:
   - Merging 024+025 (Fellow refactoring)
   - Merging 027-030 (PK refactoring)
   - Merging 031-037 (ILO infrastructure + seed)
   - Keeping 026 & 031 (test data, optional)
3. Authorize implementation

