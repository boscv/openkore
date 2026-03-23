#!/usr/bin/env python3
"""Validate final eventMacro GPT package consistency.

Checks:
- knowledge_ready has <=20 files
- required core files exist
- manifest count matches filesystem count
- condition catalog JSON parses and is non-empty list
"""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
KNOWLEDGE = ROOT / "knowledge_ready"
MANIFEST = KNOWLEDGE / "17_upload_manifest.md"
CATALOG = KNOWLEDGE / "18_condition_catalog.json"

REQUIRED_FILES = {
    "02_grammar_and_parsing.md",
    "03_variables_and_special_variables.md",
    "04_operators_regex_ranges_and_comparisons.md",
    "07_automacro_parameters.md",
    "08_conditions_state_part_1.md",
    "09_conditions_state_part_2.md",
    "10_conditions_event.md",
    "12_invalid_syntax_and_negative_catalog.md",
    "16_gpt_system_instructions_final.md",
    "18_condition_catalog.json",
}


def fail(msg: str) -> None:
    raise SystemExit(f"ERROR: {msg}")


def main() -> None:
    if not KNOWLEDGE.exists():
        fail(f"missing folder: {KNOWLEDGE}")

    files = sorted(p.name for p in KNOWLEDGE.iterdir() if p.is_file())
    count = len(files)
    if count > 20:
        fail(f"knowledge_ready has {count} files (must be <=20)")

    missing = sorted(REQUIRED_FILES - set(files))
    if missing:
        fail(f"missing required files: {', '.join(missing)}")

    if not MANIFEST.exists():
        fail("missing manifest file 17_upload_manifest.md")

    text = MANIFEST.read_text(encoding="utf-8")
    m = re.search(r"Total:\s*\*\*(\d+)\s+arquivos\*\*", text)
    if not m:
        fail("could not parse total from manifest")
    manifest_total = int(m.group(1))
    if manifest_total != count:
        fail(f"manifest total={manifest_total} differs from filesystem total={count}")

    if not CATALOG.exists():
        fail("missing 18_condition_catalog.json")

    data = json.loads(CATALOG.read_text(encoding="utf-8"))
    if not isinstance(data, list) or not data:
        fail("18_condition_catalog.json must be a non-empty JSON list")

    print("OK: final package validated")
    print(f"knowledge_ready_files={count}")
    print(f"catalog_entries={len(data)}")


if __name__ == "__main__":
    main()
