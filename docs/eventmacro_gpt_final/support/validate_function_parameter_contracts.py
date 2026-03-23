#!/usr/bin/env python3
"""Validate macro function and automacro parameter contract file."""
from __future__ import annotations

import json
from pathlib import Path

FILE = Path(__file__).resolve().parents[1] / "knowledge_ready" / "19_macro_and_parameter_contracts.json"


def fail(msg: str) -> None:
    raise SystemExit(f"ERROR: {msg}")


def check_item(kind: str, item: dict) -> None:
    name = item.get("name", "<unknown>")
    required = ["lexical_contract_status", "accepted_separators", "forbidden_separators", "accepted_forms", "rejected_forms"]
    for k in required:
        if k not in item:
            fail(f"{kind}:{name} missing field {k}")
    if not item["accepted_separators"] or not item["forbidden_separators"]:
        fail(f"{kind}:{name} separators cannot be empty")
    if item["lexical_contract_status"] == "COMPLETE":
        if not item["accepted_forms"] or not item["rejected_forms"]:
            fail(f"{kind}:{name} COMPLETE requires accepted/rejected forms")


def main() -> None:
    data = json.loads(FILE.read_text(encoding="utf-8"))
    if "macro_functions" not in data or "automacro_parameters" not in data:
        fail("missing macro_functions or automacro_parameters blocks")

    for it in data["macro_functions"]:
        check_item("macro_function", it)
    for it in data["automacro_parameters"]:
        check_item("automacro_parameter", it)

    print("OK: function/parameter contracts validated")
    print(f"macro_functions={len(data['macro_functions'])} automacro_parameters={len(data['automacro_parameters'])}")


if __name__ == "__main__":
    main()
