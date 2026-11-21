#!/usr/bin/env python3
"""Validate lexical contract quality for eventMacro condition catalog."""
from __future__ import annotations

import json
from pathlib import Path

CATALOG = Path(__file__).resolve().parents[1] / "knowledge_ready" / "18_condition_catalog.json"


def fail(msg: str) -> None:
    raise SystemExit(f"ERROR: {msg}")


def main() -> None:
    data = json.loads(CATALOG.read_text(encoding="utf-8"))
    if not isinstance(data, list) or not data:
        fail("catalog must be non-empty list")

    bad_safe = []
    missing_sep = []
    missing_forms = []
    missing_examples = []

    for c in data:
        name = c.get("name", "<unknown>")
        gs = c.get("generation_safety")
        lcs = c.get("lexical_contract_status")
        acc_sep = c.get("accepted_separators") or []
        forb_sep = c.get("forbidden_separators") or []
        acc_forms = c.get("accepted_forms") or []
        rej_forms = c.get("rejected_forms") or []
        ex_ok = c.get("examples_validated") or []
        ex_bad = c.get("examples_rejected") or []

        if gs == "GENERATION_SAFE" and lcs != "COMPLETE":
            bad_safe.append(name)
        if not acc_sep or not forb_sep:
            missing_sep.append(name)
        if lcs == "COMPLETE" and (not acc_forms or not rej_forms):
            missing_forms.append(name)
        if lcs == "COMPLETE" and (not ex_ok or not ex_bad):
            missing_examples.append(name)

    if bad_safe:
        fail(f"GENERATION_SAFE without COMPLETE: {', '.join(bad_safe[:10])}")
    if missing_sep:
        fail(f"missing separators info: {', '.join(missing_sep[:10])}")
    if missing_forms:
        fail(f"missing forms for COMPLETE: {', '.join(missing_forms[:10])}")
    if missing_examples:
        fail(f"missing validated/rejected examples for COMPLETE: {', '.join(missing_examples[:10])}")

    print("OK: lexical contracts validated")
    print(f"conditions={len(data)}")


if __name__ == "__main__":
    main()
