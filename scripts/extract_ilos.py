#!/usr/bin/env python3
"""
ILO PDF Extraction Script

Extracts Intended Learning Outcomes from MOE PDFs and generates normalized CSVs.

Usage:
    python3 scripts/extract_ilos.py --pdf iloPDFs/Belizean\ Studies*.pdf --output private_storage/ilo_data/

Dependencies:
    pip install pdfplumber pandas
"""

import argparse
import json
import os
import re
import sys
from pathlib import Path
from typing import Dict, List, Tuple

try:
    import pdfplumber
    import pandas as pd
except ImportError:
    print("ERROR: Required packages not found.")
    print("Install with: pip install pdfplumber pandas")
    sys.exit(1)

# Subject mappings
SUBJECT_MAPS = {
    "Belizean Studies Learning Outcomes": {
        "subject": "Belizean History",
        "prefix": "BS",
        "target_subject": "Belizean History",
    },
    "Expressive Arts Learning Outcomes": {
        "subject": "Expressive Arts",
        "prefix": "EA",
        "target_subject": "Expressive Arts",
    },
    "Language Arts Learning Outcomes": {
        "subject": "Language Arts",
        "prefix": "LA",
        "target_subject": "Language Arts",
    },
    "Mathematics Learning Outcomes": {
        "subject": "Mathematics",
        "prefix": "MA",
        "target_subject": "Mathematics",
    },
    "Physical Education Learning Outcomes": {
        "subject": "Physical Education",
        "prefix": "PE",
        "target_subject": "Physical Education",
    },
    "Science and Technology Learning Outcomes": {
        "subject": "Science and Technology",
        "prefix": ["SC", "TC"],
        "target_subject": "Science and Technology",
    },
}

# Valid grade levels
VALID_GRADES = {
    "Preschool",
    "Infant 1",
    "Infant 2",
    "Standard 1",
    "Standard 2",
    "Standard 3",
    "Standard 4",
    "Standard 5",
    "Standard 6",
    "Mixed",
}


def extract_pdf_tables(pdf_path: str) -> List[Dict]:
    """Extract all tables from a PDF file."""
    print(f"📄 Extracting from: {pdf_path}")
    tables = []

    try:
        with pdfplumber.open(pdf_path) as pdf:
            for page_num, page in enumerate(pdf.pages, 1):
                page_tables = page.extract_tables()
                if page_tables:
                    for table in page_tables:
                        tables.append(
                            {"page": page_num, "rows": table, "raw_text": page.extract_text()}
                        )
                    print(f"   ✓ Page {page_num}: Found {len(page_tables)} table(s)")
        print(f"   Total tables found: {len(tables)}\n")
        return tables
    except Exception as e:
        print(f"   ✗ Error extracting PDF: {e}\n")
        return []


def parse_ilo_code(code_str: str) -> Tuple[str, int, int]:
    """
    Parse ILO code format like 'BS 1.1' into (prefix, strand_num, ilo_num).
    
    Returns:
        (prefix, strand_num, ilo_num) or (None, None, None) if invalid
    """
    match = re.match(r"([A-Z]{2})\s+(\d+)\.(\d+)", code_str.strip())
    if match:
        return match.group(1), int(match.group(2)), int(match.group(3))
    return None, None, None


def parse_ilo_cell(cell_text: str) -> List[Tuple[str, str]]:
    """
    Parse a cell containing multiple ILOs.
    Format: Code on one line, description on following lines until next code or strand.
    
    Returns:
        List of (code, description) tuples
    """
    if not cell_text or cell_text.strip() == "":
        return []

    ilos = []
    # Clean up cell text - remove extra whitespace and normalize
    cell_text = str(cell_text).strip()
    lines = cell_text.split("\n")
    
    current_code = None
    current_desc_lines = []
    
    for line in lines:
        line_stripped = line.strip()
        if not line_stripped:
            continue
        
        # Check if this line starts with an ILO code (e.g., "BS 1.1", "MA 2.3")
        code_match = re.match(r"^([A-Z]{2})\s+(\d+)\.(\d+)", line_stripped)
        
        if code_match:
            # Save previous ILO if we have one
            if current_code and current_desc_lines:
                description = " ".join(current_desc_lines).strip()
                if description:
                    ilos.append((current_code, description))
            
            # Start new ILO - use match groups to properly format code
            prefix = code_match.group(1)
            strand = code_match.group(2)
            ilo = code_match.group(3)
            current_code = f"{prefix} {strand}.{ilo}"  # "BS 1.1"
            current_desc_lines = []
            
            # Check if description is on same line after code
            match_end = code_match.end()
            remainder = line_stripped[match_end:].strip()
            if remainder:
                current_desc_lines.append(remainder)
        else:
            # This is part of description or a strand header
            if current_code and line_stripped:
                # Skip strand labels like "Number A", "Number B", "Identity in Belize"
                # These are typically short (1-4 words) or just "NUMBER X", "STRAND X"
                stripped_upper = line_stripped.upper()
                if stripped_upper in ("NUMBER A", "NUMBER B", "NUMBER C", "NUMBER D", 
                                      "NUMBER E", "NUMBER F", "NUMBER G", "NUMBER H",
                                      "GEOMETRY A", "GEOMETRY B", "GEOMETRY C", "GEOMETRY D",
                                      "MEASUREMENT", "SETS", "DATA", "PATTERNS",
                                      "SPATIAL RELATIONSHIPS & SHAPES",
                                      "NUMBERS & NUMBER OPERATIONS"):
                    # Skip strand headers
                    continue
                elif len(line_stripped.split()) <= 4 and all(word[0].isupper() for word in line_stripped.split() if word):
                    # Likely a strand header - skip it
                    continue
                else:
                    # Add to current description
                    current_desc_lines.append(line_stripped)
    
    # Don't forget the last ILO
    if current_code and current_desc_lines:
        description = " ".join(current_desc_lines).strip()
        if description:
            ilos.append((current_code, description))
    
    return ilos


def normalize_grade_level(grade_str: str) -> str:
    """Convert grade level string to standard format."""
    if not grade_str:
        return None
    grade = grade_str.strip()
    # Try to match one of our valid grades (case-insensitive)
    for valid in VALID_GRADES:
        if grade.lower() == valid.lower():
            return valid
    print(f"     ⚠️  Unknown grade level: {grade}")
    return grade  # Return as-is for manual review


def extract_pdf_ilos(pdf_path: str, subject_map: Dict) -> List[Dict]:
    """Extract ILOs from a PDF file."""
    tables = extract_pdf_tables(pdf_path)
    all_ilos = []

    for table_info in tables:
        rows = table_info["rows"]
        if not rows or len(rows) < 2:
            continue

        # Detect table orientation
        table_type = detect_inverted_table(rows)
        
        if table_type == "single_grade":
            # Handle single-grade table (Mathematics, Science & Tech layout)
            ilos = extract_ilos_single_grade(rows)
        elif table_type == "multi_grade":
            # Handle multi-grade inverted table (grades in columns, cycles in rows)
            ilos = extract_ilos_multi_grade(rows)
        else:
            # Handle standard table (grades in rows, cycles in columns)
            ilos = extract_ilos_standard(rows)
        
        all_ilos.extend(ilos)

    print(f"   ✓ Extracted {len(all_ilos)} ILOs\n")
    return all_ilos


def detect_inverted_table(rows: List[List]) -> bool:
    """
    Detect table structure type.
    
    Returns type indicator:
    - "standard": grades in rows, cycles in columns
    - "inverted": single grade per table, cycles in rows, data in column 3
    - False: unknown
    """
    if not rows or len(rows) < 2:
        return False
    
    header = rows[0]
    first_col = rows[1][0] if len(rows) > 1 else ""
    
    # Check for single-grade layout (column 1 has grade, cycles in rows)
    VALID_GRADES = {
        "Preschool", "Infant 1", "Infant 2", "Standard 1", "Standard 2",
        "Standard 3", "Standard 4", "Standard 5", "Standard 6", "Mixed",
    }
    
    if len(header) > 1 and header[1]:
        grade_text = str(header[1]).strip()
        for valid in VALID_GRADES:
            if grade_text.lower() == valid.lower():
                # Single grade layout
                return "single_grade"
    
    # Check if first column contains "Cycle" (standard inverted)
    if first_col and "cycle" in str(first_col).lower():
        return "multi_grade"
    
    # Check if header contains multiple grade names (multi-grade layout)
    grade_keywords = ["infant", "standard", "preschool", "mixed"]
    grade_count = sum(1 for cell in header if cell and any(kw in str(cell).lower() for kw in grade_keywords))
    if grade_count > 1:
        return "multi_grade"
    
    return False


def extract_ilos_standard(rows: List[List]) -> List[Dict]:
    """Extract ILOs from standard table (grades in rows, cycles in columns)."""
    ilos = []
    header_row = rows[0]
    
    for row_idx, row in enumerate(rows[1:], 1):
        if not row or len(row) < 2:
            continue

        grade_level = normalize_grade_level(row[0])
        if not grade_level or grade_level not in VALID_GRADES:
            print(f"     ⚠️  Skipping row {row_idx}: Invalid grade: {row[0]}")
            continue

        # Parse each cycle column (columns 1-4)
        for cycle_num in range(1, 5):
            if cycle_num >= len(row):
                continue

            cell_text = row[cycle_num]
            parsed_ilos = parse_ilo_cell(cell_text)

            for code, description in parsed_ilos:
                prefix, strand_num, ilo_num = parse_ilo_code(code)

                if prefix and strand_num and ilo_num:
                    ilos.append(
                        {
                            "code": code,
                            "prefix": prefix,
                            "strand_num": strand_num,
                            "ilo_num": ilo_num,
                            "grade_level": grade_level,
                            "cycle": cycle_num,
                            "description": description,
                        }
                    )
    
    return ilos


def extract_ilos_single_grade(rows: List[List]) -> List[Dict]:
    """
    Extract ILOs from single-grade table.
    
    Structure (Mathematics, Science & Technology):
    - Row 0: Grade level in column 1
    - Column 0: Cycle information ("Cycle 1", "Cycle 2", etc.)
    - Column 2: Strand names
    - Column 3: ILO data (strand label + codes + descriptions)
    """
    ilos = []
    
    if len(rows) < 2:
        return ilos
    
    VALID_GRADES = {
        "Preschool", "Infant 1", "Infant 2", "Standard 1", "Standard 2",
        "Standard 3", "Standard 4", "Standard 5", "Standard 6", "Mixed",
    }
    
    # Extract grade from header row
    header = rows[0]
    grade_level = None
    if len(header) > 1 and header[1]:
        for valid in VALID_GRADES:
            if str(header[1]).strip().lower() == valid.lower():
                grade_level = valid
                break
    
    if not grade_level:
        return ilos
    
    # Process data rows
    current_cycle = None
    for row_idx, row in enumerate(rows[1:], 1):
        if not row or len(row) < 4:
            continue
        
        # Check for cycle indicator in column 0
        if row[0]:
            cycle_match = re.search(r"[Cc]ycle\s+(\d+)", str(row[0]))
            if cycle_match:
                current_cycle = int(cycle_match.group(1))
        
        if not current_cycle:
            continue
        
        # ILO data is in column 3
        cell_text = row[3] if len(row) > 3 else None
        if not cell_text:
            continue
        
        parsed_ilos = parse_ilo_cell(cell_text)
        
        for code, description in parsed_ilos:
            prefix, strand_num, ilo_num = parse_ilo_code(code)
            
            if prefix and strand_num and ilo_num:
                ilos.append(
                    {
                        "code": code,
                        "prefix": prefix,
                        "strand_num": strand_num,
                        "ilo_num": ilo_num,
                        "grade_level": grade_level,
                        "cycle": current_cycle,
                        "description": description,
                    }
                )
    
    return ilos


def extract_ilos_multi_grade(rows: List[List]) -> List[Dict]:
    """
    Extract ILOs from multi-grade inverted table (grades in columns, cycles in rows).
    
    Structure:
    - Row 0: Grade level headers (columns 1+)
    - Column 0: Cycle information
    - Data cells: Contain strand and ILO information
    """
    ilos = []
    
    if len(rows) < 2:
        return ilos
    
    # Extract grade levels from header row (columns 1+)
    header_row = rows[0]
    VALID_GRADES = {
        "Preschool", "Infant 1", "Infant 2", "Standard 1", "Standard 2",
        "Standard 3", "Standard 4", "Standard 5", "Standard 6", "Mixed",
    }
    
    grades = {}  # col_idx -> normalized grade
    
    for col_idx, cell in enumerate(header_row[1:], 1):
        if cell:
            grade = normalize_grade_level(cell)
            if grade and grade in VALID_GRADES:
                grades[col_idx] = grade
    
    # Extract cycles and ILOs from data rows
    for row_idx, row in enumerate(rows[1:], 1):
        if not row or len(row) < 2:
            continue
        
        # First column usually contains cycle info ("Cycle 1", "Cycle 2", etc.)
        cycle_info = row[0]
        if not cycle_info:
            continue
        
        # Try to extract cycle number
        cycle_match = re.search(r"[Cc]ycle\s+(\d+)", str(cycle_info))
        if not cycle_match:
            # If not a cycle row, skip
            continue
        
        cycle_num = int(cycle_match.group(1))
        
        # Parse each grade column
        for col_idx, grade_level in grades.items():
            if col_idx >= len(row):
                continue
            
            cell_text = row[col_idx]
            parsed_ilos = parse_ilo_cell(cell_text)
            
            for code, description in parsed_ilos:
                prefix, strand_num, ilo_num = parse_ilo_code(code)
                
                if prefix and strand_num and ilo_num:
                    ilos.append(
                        {
                            "code": code,
                            "prefix": prefix,
                            "strand_num": strand_num,
                            "ilo_num": ilo_num,
                            "grade_level": grade_level,
                            "cycle": cycle_num,
                            "description": description,
                        }
                    )
    
    return ilos


def generate_csv_from_ilos(ilos: List[Dict], subject_map: Dict, output_path: str):
    """Generate CSV from extracted ILOs (without strand names - requires manual mapping)."""
    if not ilos:
        print("   ⚠️  No ILOs to export")
        return

    # For now, create CSV with strand_num (manual lookup needed for names)
    rows = [
        {
            "subject": subject_map["target_subject"],
            "grade_level": ilo["grade_level"],
            "cycle": ilo["cycle"],
            "strand_num": ilo["strand_num"],
            "ilo_code": ilo["code"],
            "description": ilo["description"],
        }
        for ilo in ilos
    ]

    df = pd.DataFrame(rows)

    # Check for duplicates
    duplicates = df[df.duplicated(subset=["subject", "grade_level", "cycle", "ilo_code"])]
    if len(duplicates) > 0:
        print(f"   ⚠️  Found {len(duplicates)} duplicate ILO codes")

    df.to_csv(output_path, index=False)
    print(f"   ✓ Saved: {output_path}")
    print(f"   Total rows: {len(df)}")
    print(f"   Unique subjects: {df['subject'].nunique()}")
    print(f"   Unique strands: {df['strand_num'].nunique()}")
    print()


def main():
    parser = argparse.ArgumentParser(description="Extract ILOs from MOE PDFs")
    parser.add_argument(
        "--pdf", type=str, required=True, help="Path to PDF file (or glob pattern)"
    )
    parser.add_argument(
        "--output",
        type=str,
        default="private_storage/ilo_data",
        help="Output directory for CSV files",
    )
    parser.add_argument(
        "--list-subjects",
        action="store_true",
        help="List available subjects and exit",
    )

    args = parser.parse_args()

    if args.list_subjects:
        print("Available subjects:")
        for pdf_name, config in SUBJECT_MAPS.items():
            print(f"  {pdf_name}")
        sys.exit(0)

    # Resolve PDF path
    pdf_path = args.pdf
    if not os.path.exists(pdf_path):
        print(f"ERROR: PDF not found: {pdf_path}")
        sys.exit(1)

    # Create output directory
    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)

    # Determine subject from PDF name
    pdf_name = os.path.basename(pdf_path)
    subject_map = None
    for key, config in SUBJECT_MAPS.items():
        if key.lower() in pdf_name.lower():
            subject_map = config
            break

    if not subject_map:
        print(f"ERROR: Could not identify subject from PDF name: {pdf_name}")
        print("Available subjects:")
        for key in SUBJECT_MAPS.keys():
            print(f"  {key}")
        sys.exit(1)

    print(f"\n{'='*60}")
    print(f"Extracting: {pdf_name}")
    print(f"Subject: {subject_map['subject']}")
    print(f"{'='*60}\n")

    # Extract ILOs
    ilos = extract_pdf_ilos(pdf_path, subject_map)

    if not ilos:
        print("ERROR: No ILOs extracted from PDF")
        sys.exit(1)

    # Generate CSV
    output_file = (
        output_dir / f"{subject_map['subject'].lower().replace(' ', '_')}.csv"
    )
    generate_csv_from_ilos(ilos, subject_map, str(output_file))

    print(f"✓ Extraction complete!")
    print(f"\nNEXT STEPS:")
    print(f"1. Review CSV for errors: {output_file}")
    print(f"2. Manually create strand name mapping in: private_storage/ilo_strand_keys.json")
    print(f"3. Run validation script")
    print()


if __name__ == "__main__":
    main()
