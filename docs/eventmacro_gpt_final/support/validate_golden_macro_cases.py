#!/usr/bin/env python3
"""Validate golden macro cases against curated contracts."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COND = ROOT / "knowledge_ready" / "18_condition_catalog.json"
FUNC_PARAM = ROOT / "knowledge_ready" / "19_macro_and_parameter_contracts.json"
CASES = Path(__file__).resolve().parent / "golden_macro_cases.json"


def fail(msg: str) -> None:
    raise SystemExit(f"ERROR: {msg}")


def main() -> None:
    conditions = json.loads(COND.read_text(encoding="utf-8"))
    fp = json.loads(FUNC_PARAM.read_text(encoding="utf-8"))
    cases = json.loads(CASES.read_text(encoding="utf-8"))

    cond_map = {c["name"]: c for c in conditions}
    func_map = {f["name"]: f for f in fp["macro_functions"]}
    param_map = {p["name"]: p for p in fp["automacro_parameters"]}

    seen = set()
    for case in cases:
        cid = case["id"]
        if cid in seen:
            fail(f"duplicate case id: {cid}")
        seen.add(cid)
        ctype = case["type"]

        cond_ok = True
        func_ok = True
        param_ok = True

        for name in case.get("used_conditions", []):
            c = cond_map.get(name)
            if not c:
                fail(f"{cid}: unknown condition {name}")
            safe = c.get("generation_safety") == "GENERATION_SAFE" and c.get("lexical_contract_status") == "COMPLETE"
            cond_ok &= safe

        for name in case.get("used_functions", []):
            f = func_map.get(name)
            if not f:
                fail(f"{cid}: unknown function {name}")
            func_ok &= (f.get("lexical_contract_status") == "COMPLETE")

        for name in case.get("used_parameters", []):
            p = param_map.get(name)
            if not p:
                fail(f"{cid}: unknown parameter {name}")
            param_ok &= (p.get("lexical_contract_status") == "COMPLETE")

        all_ok = cond_ok and func_ok and param_ok

        if ctype == "valid" and not all_ok:
            fail(f"{cid}: valid case uses non-COMPLETE or non-GENERATION_SAFE item")
        if ctype == "invalid" and all_ok:
            fail(f"{cid}: invalid case unexpectedly passes all contracts")

    print("OK: golden macro cases validated")
    print(f"cases={len(cases)}")


if __name__ == "__main__":
    main()
