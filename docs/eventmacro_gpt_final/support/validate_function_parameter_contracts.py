#!/usr/bin/env python3
"""Validate macro function and automacro parameter contract file."""
from __future__ import annotations

import json
import re
from pathlib import Path

FILE = Path(__file__).resolve().parents[1] / "knowledge_ready" / "19_macro_and_parameter_contracts.json"
DATA_PM = Path(__file__).resolve().parents[3] / "plugins" / "eventMacro" / "eventMacro" / "Data.pm"
RUNNER_PM = Path(__file__).resolve().parents[3] / "plugins" / "eventMacro" / "eventMacro" / "Runner.pm"


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

    data_pm = DATA_PM.read_text(encoding="utf-8")
    m = re.search(r"our \$macroKeywords = join '\|', qw\((.*?)\);", data_pm, flags=re.S)
    if not m:
        fail("could not parse $macroKeywords from Data.pm")
    data_keywords = set(m.group(1).split())

    runner_pm = RUNNER_PM.read_text(encoding="utf-8")
    sec = re.search(r"sub parse_command \{(.*?\n\})\n\n", runner_pm, flags=re.S)
    if not sec:
        fail("could not parse parse_command from Runner.pm")
    runner_keywords = set(re.findall(r"\$keyword eq '([^']+)'", sec.group(1)))

    contract_keywords = {it["name"] for it in data["macro_functions"]}

    if data_keywords != runner_keywords:
        missing_in_runner = sorted(data_keywords - runner_keywords)
        missing_in_data = sorted(runner_keywords - data_keywords)
        fail(f"Data.pm and Runner.pm keyword mismatch: data_only={missing_in_runner} runner_only={missing_in_data}")

    if data_keywords != contract_keywords:
        missing_in_contract = sorted(data_keywords - contract_keywords)
        extra_in_contract = sorted(contract_keywords - data_keywords)
        fail(f"Contract and Data.pm keyword mismatch: data_only={missing_in_contract} contract_only={extra_in_contract}")

    print("OK: function/parameter contracts validated")
    print(f"macro_functions={len(data['macro_functions'])} automacro_parameters={len(data['automacro_parameters'])}")


if __name__ == "__main__":
    main()
