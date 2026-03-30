# ILO PDF Extraction Strategy & Parser Guide

## Data Structure Understanding

### Cell Content Format
Each PDF table cell contains **multiple ILOs**, each on a separate line:
```
BS 1.1: Students can identify cultural symbols in Belize
BS 1.2: Students can explain the significance of national identities
BS 1.3: Students can describe historical events
```

### Extraction Mapping

| PDF Element | Maps To | Example |
|-------------|---------|---------|
| Bolded header | Strand name | "Identity in Belize" |
| Strand number in code | Strand ID | `BS 1.x` → strand 1 |
| Grade level (first column) | Grade level name | "Standard 1" |
| Column position (1-4) | Cycle | 1st data col = Cycle 1 |
| Code (before colon) | ILO code | "BS 1.1" |
| Text after colon | ILO description | "Students can identify..." |

---

## Subject Mapping

| Subject File | Subject DB Name | Subject Prefix | Actions |
|--------------|-----------------|-----------------|---------|
| Belizean Studies | Belizean History | BS | Use as-is |
| Expressive Arts | Expressive Arts | EA | Use as-is |
| Language Arts | Language Arts | LA | Use as-is |
| Mathematics | Mathematics | MA | Use as-is |
| Physical Education | Physical Education | PE | Use as-is |
| Health Education | ❌ SKIP | HE | Not in scope (future work - strand 5 = ICT focus) |
| Science and Technology | Science and Technology | SC / TC | Use as single subject (no split) |
| Spanish | ❌ SKIP | SP | Not implemented |

**Note:** Science and Technology keeps both SC and TC prefixes as a single subject. Future work may split Computer Science/Information Technology into separate subjects once strand 5 expansion is planned.

---

## Extraction Pipeline

### Step 1: PDF → Raw Text

**Tool:** pdfplumber (Python)
- Extract all tables from PDF
- Preserve table structure (rows, columns)
- Keep formatting hints (bold text for strands)

**Challenge:** Bold text detection
- pdfplumber may not preserve bold formatting
- **Workaround:** Look for text appearing OUTSIDE table bounds but ABOVE rows (visual positioning)
- Or: Manually identify strand headers while reviewing output

### Step 2: Parse Table Structure

For each table:
1. **Extract header row:** Skip or identify as column 0
2. **Identify grade levels** (first column): Preschool, Infant 1, Infant 2, Standard 1-6, Mixed
3. **Identify data columns:** 4 columns for Cycles 1-4
4. **Extract strand headers:** Bolded text between rows (requires manual review initially)

### Step 3: Split Multiple ILOs per Cell

For each cell, split by newline:
```python
ilos_in_cell = cell_text.split('\n')
# Result: ["BS 1.1: Description 1", "BS 1.2: Description 2", ...]
```

For each ILO string:
```python
code, description = ilo_text.split(':', 1)
code = code.strip()  # "BS 1.1"
description = description.strip()  # "Students can..."
```

### Step 4: Extract Strand Number from Code

```python
prefix, strand_and_ilo = code.split(' ')  # "BS" and "1.1"
strand_num = int(strand_and_ilo.split('.')[0])  # 1
# Now link strand_num to strand_name from bolded headers
```

### Step 5: Generate Normalized CSV

**Schema:**
```
subject,grade_level,cycle,strand_number,strand_name,ilo_code,description
Belizean History,Standard 1,1,1,Identity in Belize,BS 1.1,Students can identify cultural symbols in Belize
```

---

## Quality Assurance Checks

### During Extraction
- [ ] All grade levels match our 10 valid values
- [ ] All cycle numbers are 1-4
- [ ] All codes match pattern: `[A-Z]{2} \d+\.\d+`
- [ ] All descriptions are non-empty
- [ ] Subject prefix matches expected values

### Post-Extraction
- [ ] No duplicate (subject, grade_level, cycle, ilo_code) combinations
- [ ] Strand numbers are consistent per subject (e.g., BS 1.x, BS 2.x, BS 3.x)
- [ ] Strand names are consistent (same strand_num = same strand_name across all grades/cycles)
- [ ] Description lengths: 10-500 characters (flag outliers)
- [ ] Total ILOs per subject: Expect 30-100+ per subject (4 cycles × ~10 grades × ~1-3 per strand)

---

## Manual Steps (Required)

Since bold formatting is hard to extract automatically:

1. **For each PDF:**
   - Open in viewer
   - Note all strand headers in order
   - Create a mapping: `{1: "Identity in Belize", 2: "National Identity", ...}`
   - Save as JSON: `private_storage/ilo_strand_keys.json`

**Example:**
```json
{
  "Belizean History": {
    "1": "Identity in Belize",
    "2": "National Identity",
    "3": "Historical Development"
  },
  "Arts": {
    "1": "Dance and Drama",
    "2": "Music",
    "3": "Creative Art Forms",
    "4": "Three-Dimensional Art"
  }
}
```

---

## Output Files

After extraction:
```
private_storage/
  ilo_data/
    belizean_history.csv
    arts.csv
    language_arts.csv
    mathematics.csv
    physical_education.csv
    science_split.csv          # Contains both Science + Engineering rows
  ilo_strand_keys.json         # Manual mappings
  extraction_log.txt           # Summary of extraction
```

---

## Next Steps

1. **Create strand key mappings** (manual review of each PDF)
2. **Build PDF parser** (Python script using pdfplumber)
3. **Validate CSVs** (check for errors, duplicates, consistency)
4. **Create migrations** (034a: strands, 034b: ilos)
