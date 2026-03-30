# ILO Data Extraction & Normalization Guide

## Overview

This guide walks through extracting Intended Learning Outcomes (ILOs) from MOE PDFs and normalizing them for database seeding.

---

## Quick Start

### Prerequisites

```bash
# Install required Python packages
pip install pdfplumber pandas
```

### 3-Step Process

```bash
# Step 1: Extract ILOs from PDFs
python3 scripts/extract_ilos.py --pdf iloPDFs/Belizean\ Studies*.pdf

# Step 2: Validate extracted data
python3 scripts/validate_ilos.py --csv "private_storage/ilo_data/*.csv"

# Step 3: Create migrations (once validated)
# See Migration sections below
```

---

## Step 1: Extract ILOs from PDFs

### What This Does

Reads each PDF, extracts learning outcomes from tables, and generates a **preliminary CSV** with:
- Subject
- Grade level
- Cycle (1-4)
- ILO code (e.g., `BS 1.1`)
- ILO description
- Strand number (derived from code)

### Command

```bash
# Extract one PDF
python3 scripts/extract_ilos.py --pdf iloPDFs/"Belizean Studies Learning Outcomes by Cycles and Class.pdf"

# Extract all PDFs
for pdf in iloPDFs/*.pdf; do
  python3 scripts/extract_ilos.py --pdf "$pdf"
done
```

### Example Output

**Input PDF table:**
```
Infant 1  | BA 1.1: Description A | BA 1.1: Description A (Cycle 2) | ...
          | BA 1.2: Description B | BA 1.2: Description B (Cycle 2) | ...
```

**Output CSV** (`belizean_history.csv`):
```csv
subject,grade_level,cycle,strand_num,ilo_code,description
Belizean History,Infant 1,1,1,BS 1.1,Description A
Belizean History,Infant 1,1,1,BS 1.2,Description B
Belizean History,Infant 1,2,1,BS 1.1,Description A (Cycle 2)
```

### Expected Issues

1. **⚠️ Invalid code format warnings:** Some lines might not parse correctly
   - Review the raw PDF; code format should be: `XX #.#` (e.g., `BS 1.1`)
   - Manual correction may be needed

2. **Unknown grade level warnings:** Grade labels that don't match our 10 valid grades
   - The script uses these grade mappings:
     - Preschool, Infant 1, Infant 2, Standard 1-6, Mixed
   - If PDFs use different labels, let me know and we'll create a mapping

---

## Step 2: Create Strand Name Mappings

### Why This Step?

The PDFs have **bolded strand headers** (e.g., "Identity in Belize") that group ILOs. These names aren't machine-readable, so we need to create a **manual mapping**.

**Example from PDF:**
```
[BOLD] Identity in Belize          ← Strand header
  BS 1.1: Description
  BS 1.2: Description

[BOLD] National Identity           ← Next strand header
  BS 2.1: Description
  BS 2.2: Description
```

### How To Create The Mapping

1. **Open each PDF** in a PDF viewer
2. **For each subject**, note the strand headers and their associated strand numbers:

   ```
   Belizean Studies Strands:
   - BS 1.x → "Identity in Belize"
   - BS 2.x → "National Identity"
   - BS 3.x → "Historical Development"
   ...
   ```

3. **Create `private_storage/ilo_strand_keys.json`:**

   ✅ **Already created** with all strand mappings from PDFs:
   - Belizean History (6 strands)
   - Expressive Arts (4 strands)
   - Language Arts (4 strands)
   - Mathematics (9 strands)
   - Physical Education (4 strands)
   - Science and Technology (7 strands, includes both SC and TC codes)
   - Health Education (5 strands - currently not extracted, for future work)

   **File location:** `private_storage/ilo_strand_keys.json`

### Format Rules

- File is valid JSON
- Keys are subject names (exactly as in database)
- Values are strand number → strand name mappings
- Strand names are:
  - 10-60 characters
  - Title Case
  - Descriptive but concise

---

## Step 3: Validate Extracted Data

### What This Does

Checks CSVs for:
- ✅ Valid grade levels (matches our 10 options)
- ✅ Valid cycles (1-4)
- ✅ Valid ILO code format (e.g., `BS 1.1`)
- ✅ Non-empty descriptions
- ✅ No duplicate ILO codes per subject/grade/cycle
- ✅ Strand number consistency

### Command

```bash
# Validate one CSV
python3 scripts/validate_ilos.py --csv private_storage/ilo_data/belizean_history.csv

# Validate all CSVs
python3 scripts/validate_ilos.py --csv "private_storage/ilo_data/*.csv"
```

### Example Output

```
============================================================
Validation Report: belizean_history.csv
============================================================

📊 Statistics:
  Rows: 120
  Unique subjects: 1
  Unique grades: 10
  Unique codes: 120

ℹ️  Info:
  Loaded 120 rows

✅ PASSED validation
```

### Fixing Issues

If validation fails, check:

| Error | Fix |
|-------|-----|
| Invalid grade levels | Review PDF labels; may need custom mapping |
| Invalid ILO code format | Ensure code is format `XX #.#` (e.g., `BS 1.1`) |
| Duplicate codes | Same code appears twice for same subject/grade/cycle |
| Empty descriptions | Check PDF for blank cells |
| Unknown subjects | Add new subject to database (requires code change) |

---

## Step 4: Create Migrations

Once CSVs are validated, generate SQL migrations:

### Migration 034a: Seed Strands

```sql
-- migrations/034a_seed_strands.up.sql

INSERT INTO strands (subject_id, name) VALUES
  ((SELECT id FROM subjects WHERE subject = 'Belizean History'), 'Identity in Belize'),
  ((SELECT id FROM subjects WHERE subject = 'Belizean History'), 'National Identity'),
  ...
ON CONFLICT (subject_id, name) DO NOTHING;
```

### Migration 034b: Seed ILOs

```sql
-- migrations/034b_seed_ilos.up.sql

INSERT INTO ilos (subject_id, grade_level_id, cycle_id, strand_id, ilo_code, description) VALUES
  (
    (SELECT id FROM subjects WHERE subject = 'Belizean History'),
    (SELECT id FROM grade_levels WHERE grade_level = 'Infant 1'),
    1,
    (SELECT id FROM strands WHERE subject_id = ... AND name = 'Identity in Belize'),
    'BS 1.1',
    'Students can identify cultural symbols in Belize'
  ),
  ...
ON CONFLICT (subject_id, grade_level_id, cycle_id, ilo_code) DO NOTHING;
```

---

## File Structure

After extraction and validation:

```
private_storage/
  ilo_data/
    belizean_history.csv       # Extracted from PDF
    expressive_arts.csv
    language_arts.csv
    mathematics.csv
    physical_education.csv
    science_and_technology.csv # Both SC and TC codes (no split)
  ilo_strand_keys.json         # Strand name mappings (COMPLETE)

migrations/
  034a_seed_strands.up.sql     # Insert into strands table
  034a_seed_strands.down.sql
  034b_seed_ilos.up.sql        # Insert into ilos table
  034b_seed_ilos.down.sql
```

**Subjects NOT extracted (future work):**
- **Health Education:** Focuses on strand 5 (Relationships and Communications/ICT). Will implement along with Computer Science and Information Technology splits.
- **Spanish:** Not currently in scope per curriculum roadmap.

---

## Quality Assurance Checklist

### Before Validation

- [ ] All CSVs generated without errors
- [ ] PDFs reviewed for strand headers
- [ ] `ilo_strand_keys.json` created with all subjects/strands

### After Validation

- [ ] All CSVs pass validation
- [ ] No duplicate ILO codes found
- [ ] Grade levels match our 10 valid options
- [ ] ILO code format is consistent

### Before Migration

- [ ] All strands present in  `ilo_strand_keys.json`
- [ ] Migrations 034a & 034b created
- [ ] Migrations tested on staging database
- [ ] Data counts verified (expected ~1000-2000 ILOs total)

### After Migration

- [ ] Staging database has new strands/ILOs
- [ ] API can query ILOs by subject/grade/cycle
- [ ] No constraint violations
- [ ] Rollback tested (down migrations work)

---

## Troubleshooting

### "Invalid code format" warnings

**Cause:** PDF cell content doesn't match `XX #.#` format  
**Fix:** 
1. Inspect raw PDF text (might have extra spaces/formatting)
2. Adjust extraction regex pattern in `scripts/extract_ilos.py`
3. Manual CSV cleanup

### "Unknown grade level" warnings

**Cause:** PDF uses label not in our 10 grade levels  
**Fix:**
1. Create mapping in extraction script
2. Or manually edit CSV to use standard labels

### Duplicate ILO codes

**Cause:** Same code (e.g., `BS 1.1`) appears twice for same subject/grade/cycle  
**Fix:**
1. Check PDF for duplicates (might be copy-paste error)
2. Remove duplicate from CSV
3. Note the issue for MOE validation

### Memory/performance issues

**Cause:** Large PDFs with many tables  
**Fix:**
1. Extract one PDF at a time
2. Process offline in text editor if needed
3. Split Science+Technology manually if auto-split fails

---

## Timeline Estimate

| Task | Time | Dependencies |
|------|------|--------------|
| PDF analysis + strand mapping | 1-2 hours | None |
| Run extraction scripts | 30 min | PDFs available |
| Validate CSVs | 30 min | Extraction complete |
| Create migrations | 1 hour | CSVs validated |
| Test on staging | 1-2 hours | Migrations ready |

**Total: ~5-7 hours**

---

## Next Steps

1. **Install dependencies:** `pip install pdfplumber pandas`
2. **Extract PDFs:** Run extraction script for each PDF
3. **Create strand mappings:** Build `ilo_strand_keys.json`
4. **Validate data:** Run validation script
5. **Report issues:** Share any errors or edge cases
6. **Create migrations:** Generate 034a & 034b
7. **Test on staging:** Deploy and verify
8. **Deploy to production:** Apply migrations

---

## Support

For issues or questions:
- Check troubleshooting section above
- Review PDF structure with sample details
- Reach out with specific error messages
