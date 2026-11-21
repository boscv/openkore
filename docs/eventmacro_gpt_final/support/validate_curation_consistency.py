#!/usr/bin/env python3
"""Cross-file consistency checks for eventMacro curated package.

This gate checks:
- EXPLAIN_ONLY conditions in JSON match delimiter-attention markdown list
- lexical completeness requirements for COMPLETE conditions
- GPT instruction file contains required safety sections
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "knowledge_ready" / "18_condition_catalog.json"
ATTN = Path("docs/eventmacro_lexical_contract_patch/06_conditions_requiring_delimiter_attention.md")
INSTR = ROOT / "knowledge_ready" / "16_gpt_system_instructions_final.md"
FUNC_PARAM = ROOT / "knowledge_ready" / "19_macro_and_parameter_contracts.json"


def fail(msg: str) -> None:
    raise SystemExit(f"ERROR: {msg}")


def parse_attention_names(text: str) -> set[str]:
    names = set()
    for line in text.splitlines():
        m = re.match(r"\s*-\s*`([^`]+)`\s*$", line)
        if m:
            names.add(m.group(1))
    return names


def main() -> None:
    data = json.loads(CATALOG.read_text(encoding="utf-8"))
    if not isinstance(data, list) or not data:
        fail("catalog missing or empty")

    explain_only = {c["name"] for c in data if c.get("generation_safety") == "EXPLAIN_ONLY"}

    if not ATTN.exists():
        fail(f"missing attention list: {ATTN}")
    attn_names = parse_attention_names(ATTN.read_text(encoding="utf-8"))

    if explain_only != attn_names:
        only_json = sorted(explain_only - attn_names)
        only_md = sorted(attn_names - explain_only)
        fail(
            "EXPLAIN_ONLY mismatch between JSON and attention markdown. "
            f"only_json={only_json[:8]} only_md={only_md[:8]}"
        )

    # extra lexical sanity for COMPLETE
    for c in data:
        if c.get("lexical_contract_status") == "COMPLETE":
            if not c.get("accepted_separators") or not c.get("forbidden_separators"):
                fail(f"missing separators in COMPLETE condition: {c['name']}")
            if not c.get("accepted_forms") or not c.get("rejected_forms"):
                fail(f"missing forms in COMPLETE condition: {c['name']}")
            if not c.get("examples_validated") or not c.get("examples_rejected"):
                fail(f"missing examples in COMPLETE condition: {c['name']}")

    if not FUNC_PARAM.exists():
        fail(f"missing function/parameter contracts file: {FUNC_PARAM}")

    instr_text = INSTR.read_text(encoding="utf-8")
    required_tokens = [
        "Gate lexical obrigatório por condition",
        "Expert behavior mode (criação de macro completa)",
        "Whole-macro validation (antes de entregar)",
        "Gate para funções e parâmetros (macro/automacro)",
    ]
    missing = [t for t in required_tokens if t not in instr_text]
    if missing:
        fail(f"instruction file missing required sections: {missing}")

    print("OK: cross-file curation consistency validated")
    print(f"conditions={len(data)} explain_only={len(explain_only)}")


if __name__ == "__main__":
    main()
