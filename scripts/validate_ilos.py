#!/usr/bin/env python3
"""
ILO CSV Validation Script

Validates extracted ILO CSV files for quality, consistency, and database compatibility.

Usage:
    python3 scripts/validate_ilos.py --csv private_storage/ilo_data/*.csv
"""

import argparse
import sys
from pathlib import Path
from typing import Dict, List, Set

try:
    import pandas as pd
except ImportError:
    print("ERROR: pandas not found. Install with: pip install pandas")
    sys.exit(1)

# Valid values for database
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

VALID_CYCLES = {1, 2, 3, 4}

VALID_SUBJECTS = {
    "Belizean History",
    "Expressive Arts",
    "Language Arts",
    "Mathematics",
    "Physical Education",
    "Science and Technology",
    "Health Education",
}

# Grade level mappings for consistency
GRADE_MAPPINGS = {
    "preschool": "Preschool",
    "infant 1": "Infant 1",
    "infant 2": "Infant 2",
    "standard 1": "Standard 1",
    "standard 2": "Standard 2",
    "standard 3": "Standard 3",
    "standard 4": "Standard 4",
    "standard 5": "Standard 5",
    "standard 6": "Standard 6",
    "mixed": "Mixed",
}


class ILOValidator:
    """Validator for ILO CSV files."""

    def __init__(self, csv_path: str):
        self.csv_path = csv_path
        self.df = None
        self.errors = []
        self.warnings = []
        self.info = []

    def load(self) -> bool:
        """Load CSV file."""
        try:
            self.df = pd.read_csv(self.csv_path)
            self.info.append(f"Loaded {len(self.df)} rows")
            return True
        except Exception as e:
            self.errors.append(f"Failed to load CSV: {e}")
            return False

    def validate_columns(self):
        """Check required columns exist."""
        required = {"subject", "grade_level", "cycle", "ilo_code", "description"}
        if not required.issubset(set(self.df.columns)):
            missing = required - set(self.df.columns)
            self.errors.append(f"Missing columns: {missing}")
            return False
        return True

    def validate_grades(self):
        """Validate grade level values."""
        invalid_grades = set()
        for grade in self.df["grade_level"].unique():
            if grade not in VALID_GRADES:
                invalid_grades.add(grade)

        if invalid_grades:
            self.errors.append(
                f"Invalid grade levels: {invalid_grades}. Valid: {VALID_GRADES}"
            )
            return False
        return True

    def validate_cycles(self):
        """Validate cycle values."""
        invalid_cycles = set(self.df["cycle"].unique()) - VALID_CYCLES
        if invalid_cycles:
            self.errors.append(f"Invalid cycles: {invalid_cycles}. Valid: {VALID_CYCLES}")
            return False
        return True

    def validate_subjects(self):
        """Validate subject values."""
        invalid_subjects = set(self.df["subject"].unique()) - VALID_SUBJECTS
        if invalid_subjects:
            self.errors.append(
                f"Invalid subjects: {invalid_subjects}. Valid: {VALID_SUBJECTS}"
            )
            return False
        return True

    def validate_codes(self):
        """Validate ILO code format."""
        import re

        pattern = r"^[A-Z]{2}\s+\d+\.\d+$"
        invalid_codes = []
        for idx, code in enumerate(self.df["ilo_code"].unique(), 1):
            if not re.match(pattern, str(code)):
                invalid_codes.append(code)

        if invalid_codes:
            count = len(invalid_codes)
            self.errors.append(
                f"{count} invalid code format(s): {invalid_codes[:5]}... "
                f"(expected format: 'BS 1.1')"
            )
            return False
        return True

    def validate_descriptions(self):
        """Validate description content."""
        issues = []

        # Check for empty descriptions
        empty = self.df[self.df["description"].isna() | (self.df["description"] == "")]
        if len(empty) > 0:
            issues.append(f"{len(empty)} rows have empty descriptions")

        # Check description length
        too_short = self.df[self.df["description"].str.len() < 10]
        if len(too_short) > 0:
            issues.append(f"{len(too_short)} rows have very short descriptions (<10 chars)")

        too_long = self.df[self.df["description"].str.len() > 500]
        if len(too_long) > 0:
            self.warnings.append(f"{len(too_long)} rows have long descriptions (>500 chars)")

        if issues:
            self.errors.extend(issues)
            return False
        return True

    def check_duplicates(self):
        """Check for duplicate ILO codes within subject/grade/cycle."""
        duplicates = self.df[
            self.df.duplicated(subset=["subject", "grade_level", "cycle", "ilo_code"])
        ]
        if len(duplicates) > 0:
            self.errors.append(f"{len(duplicates)} duplicate ILO codes found")
            print("Duplicates:")
            print(duplicates[["subject", "grade_level", "cycle", "ilo_code"]])
            return False
        return True

    def check_strand_consistency(self):
        """Check strand numbers are consistent per subject."""
        if "strand_num" not in self.df.columns:
            return True  # Optional column

        for subject in self.df["subject"].unique():
            subject_df = self.df[self.df["subject"] == subject]
            strands = subject_df["strand_num"].unique()
            # Check if strand numbers are sequential (1, 2, 3, ...)
            strands_sorted = sorted(strands)
            if strands_sorted != list(range(1, max(strands_sorted) + 1)):
                self.warnings.append(
                    f"{subject}: Strand numbers not sequential: {strands_sorted}"
                )

        return True

    def summarize(self):
        """Print validation summary."""
        print(f"\n{'='*60}")
        print(f"Validation Report: {Path(self.csv_path).name}")
        print(f"{'='*60}")

        # Stats
        print(f"\n📊 Statistics:")
        print(f"  Rows: {len(self.df)}")
        print(f"  Unique subjects: {self.df['subject'].nunique()}")
        print(f"  Unique grades: {self.df['grade_level'].nunique()}")
        print(f"  Unique codes: {self.df['ilo_code'].nunique()}")

        # Info
        if self.info:
            print(f"\nℹ️  Info:")
            for msg in self.info:
                print(f"  • {msg}")

        # Warnings
        if self.warnings:
            print(f"\n⚠️  Warnings:")
            for msg in self.warnings:
                print(f"  • {msg}")

        # Errors
        if self.errors:
            print(f"\n❌ Errors:")
            for msg in self.errors:
                print(f"  • {msg}")

        # Result
        if self.errors:
            print(f"\n❌ FAILED validation")
            return False
        else:
            print(f"\n✅ PASSED validation")
            return True

    def validate(self) -> bool:
        """Run all validations."""
        if not self.load():
            return False

        checks = [
            ("Columns", self.validate_columns),
            ("Grade levels", self.validate_grades),
            ("Cycles", self.validate_cycles),
            ("Subjects", self.validate_subjects),
            ("ILO codes", self.validate_codes),
            ("Descriptions", self.validate_descriptions),
            ("Duplicates", self.check_duplicates),
            ("Strand consistency", self.check_strand_consistency),
        ]

        results = {}
        for name, check_func in checks:
            try:
                results[name] = check_func()
            except Exception as e:
                self.errors.append(f"Error during {name} check: {e}")
                results[name] = False

        return self.summarize()


def main():
    parser = argparse.ArgumentParser(description="Validate ILO CSV files")
    parser.add_argument("--csv", type=str, required=True, help="Path to CSV file or glob pattern")
    args = parser.parse_args()

    # Handle glob patterns
    csv_files = list(Path(".").glob(args.csv))
    if not csv_files:
        # Try as direct path
        if Path(args.csv).exists():
            csv_files = [Path(args.csv)]
        else:
            print(f"ERROR: No CSV files found matching: {args.csv}")
            sys.exit(1)

    all_passed = True
    for csv_file in csv_files:
        validator = ILOValidator(str(csv_file))
        if not validator.validate():
            all_passed = False

    sys.exit(0 if all_passed else 1)


if __name__ == "__main__":
    main()
