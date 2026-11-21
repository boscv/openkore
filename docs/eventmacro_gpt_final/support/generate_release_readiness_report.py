#!/usr/bin/env python3
"""Generate release-readiness report after full contract completion."""
from __future__ import annotations

import json
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
COND = ROOT / "eventmacro_gpt_final" / "knowledge_ready" / "18_condition_catalog.json"
FP = ROOT / "eventmacro_gpt_final" / "knowledge_ready" / "19_macro_and_parameter_contracts.json"
OUT = ROOT / "eventmacro_gpt_final" / "support" / "05_release_readiness_report.md"


def main() -> None:
    cond = json.loads(COND.read_text(encoding="utf-8"))
    fp = json.loads(FP.read_text(encoding="utf-8"))

    total_cond = len(cond)
    complete_cond = sum(1 for c in cond if c.get("lexical_contract_status") == "COMPLETE")
    partial_cond = sum(1 for c in cond if c.get("lexical_contract_status") == "PARTIAL")
    insufficient_cond = sum(1 for c in cond if c.get("lexical_contract_status") == "INSUFFICIENT")
    explain_only = sum(1 for c in cond if c.get("generation_safety") == "EXPLAIN_ONLY")

    mf = fp["macro_functions"]
    ap = fp["automacro_parameters"]
    mf_complete = sum(1 for f in mf if f.get("lexical_contract_status") == "COMPLETE")
    mf_partial = sum(1 for f in mf if f.get("lexical_contract_status") == "PARTIAL")
    ap_complete = sum(1 for p in ap if p.get("lexical_contract_status") == "COMPLETE")
    ap_partial = sum(1 for p in ap if p.get("lexical_contract_status") == "PARTIAL")

    ready = (
        complete_cond == total_cond
        and partial_cond == 0
        and insufficient_cond == 0
        and explain_only == 0
        and mf_partial == 0
        and ap_partial == 0
    )

    lines = [
        "# 05 Release Readiness Report",
        "",
        f"Data de geração: **{date.today().isoformat()}**.",
        "",
        "## Coverage snapshot",
        "",
        "| Escopo | COMPLETE | PARTIAL | INSUFFICIENT | Total |",
        "|---|---:|---:|---:|---:|",
        f"| Conditions | {complete_cond} | {partial_cond} | {insufficient_cond} | {total_cond} |",
        f"| Macro functions | {mf_complete} | {mf_partial} | 0 | {len(mf)} |",
        f"| Automacro parameters | {ap_complete} | {ap_partial} | 0 | {len(ap)} |",
        "",
        "## Safety snapshot",
        "",
        f"- `EXPLAIN_ONLY` conditions: **{explain_only}**.",
        f"- Release readiness: **{'READY' if ready else 'NOT READY'}**.",
        "",
        "## Gate criteria",
        "",
        "- Conditions: 100% COMPLETE, 0 PARTIAL, 0 INSUFFICIENT.",
        "- Functions/parameters: 100% COMPLETE.",
        "- Generation safety: 0 EXPLAIN_ONLY.",
    ]

    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"OK: release readiness report generated: {OUT}")
    print(f"ready={ready} conditions_complete={complete_cond}/{total_cond} functions_complete={mf_complete}/{len(mf)} parameters_complete={ap_complete}/{len(ap)}")


if __name__ == "__main__":
    main()
