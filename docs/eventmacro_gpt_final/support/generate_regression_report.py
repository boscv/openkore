#!/usr/bin/env python3
"""Generate lexical coverage regression report for condition catalog.

Compares current coverage against the baseline recorded in
`docs/eventmacro_lexical_contract_patch/00_patch_scope_and_method.md`.
"""

from __future__ import annotations

import json
import re
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CATALOG = ROOT / "eventmacro_gpt_final" / "knowledge_ready" / "18_condition_catalog.json"
BASELINE_MD = ROOT / "eventmacro_lexical_contract_patch" / "00_patch_scope_and_method.md"
OUT = ROOT / "eventmacro_gpt_final" / "support" / "04_regression_report.md"


def parse_baseline(text: str) -> dict[str, int]:
    patterns = {
        "total": r"Conditions totais:\s*(\d+)",
        "complete": r"Lexical COMPLETE:\s*(\d+)",
        "partial": r"Lexical PARTIAL:\s*(\d+)",
        "insufficient": r"Lexical INSUFFICIENT:\s*(\d+)",
    }
    out: dict[str, int] = {}
    for key, pat in patterns.items():
        m = re.search(pat, text)
        if not m:
            raise SystemExit(f"ERROR: baseline markdown missing field: {key}")
        out[key] = int(m.group(1))
    return out


def current_counts(data: list[dict]) -> dict[str, int]:
    return {
        "total": len(data),
        "complete": sum(1 for c in data if c.get("lexical_contract_status") == "COMPLETE"),
        "partial": sum(1 for c in data if c.get("lexical_contract_status") == "PARTIAL"),
        "insufficient": sum(1 for c in data if c.get("lexical_contract_status") == "INSUFFICIENT"),
    }


def pct(value: int, total: int) -> str:
    return f"{(100.0 * value / total):.2f}%" if total else "n/a"


def main() -> None:
    baseline = parse_baseline(BASELINE_MD.read_text(encoding="utf-8"))
    data = json.loads(CATALOG.read_text(encoding="utf-8"))
    current = current_counts(data)

    delta_complete = current["complete"] - baseline["complete"]
    delta_partial = current["partial"] - baseline["partial"]
    delta_insufficient = current["insufficient"] - baseline["insufficient"]

    lines = [
        "# 04 Regression Report (Lexical Coverage)",
        "",
        f"Data de geração: **{date.today().isoformat()}**.",
        "",
        "## Baseline vs Current",
        "",
        "| Métrica | Baseline | Current | Delta |",
        "|---|---:|---:|---:|",
        f"| Conditions totais | {baseline['total']} | {current['total']} | {current['total'] - baseline['total']:+d} |",
        f"| Lexical COMPLETE | {baseline['complete']} ({pct(baseline['complete'], baseline['total'])}) | {current['complete']} ({pct(current['complete'], current['total'])}) | {delta_complete:+d} |",
        f"| Lexical PARTIAL | {baseline['partial']} ({pct(baseline['partial'], baseline['total'])}) | {current['partial']} ({pct(current['partial'], current['total'])}) | {delta_partial:+d} |",
        f"| Lexical INSUFFICIENT | {baseline['insufficient']} ({pct(baseline['insufficient'], baseline['total'])}) | {current['insufficient']} ({pct(current['insufficient'], current['total'])}) | {delta_insufficient:+d} |",
        "",
        "## Leitura rápida",
        "",
        f"- COMPLETE aumentou em **{delta_complete:+d}** conditions.",
        f"- PARTIAL reduziu em **{(-delta_partial) if delta_partial < 0 else 0}** conditions (delta bruto: {delta_partial:+d}).",
        f"- INSUFFICIENT permaneceu em **{current['insufficient']}**.",
        "",
        "## Critério mínimo sugerido para curadoria operacional",
        "",
        "- `COMPLETE >= 60%` das conditions.",
        "- `INSUFFICIENT == 0`.",
        "",
        f"Status atual: **{'ATENDE' if (current['total'] and current['complete'] / current['total'] >= 0.60 and current['insufficient'] == 0) else 'NÃO ATENDE'}**.",
    ]

    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"OK: regression report generated: {OUT}")
    print(f"baseline_complete={baseline['complete']} current_complete={current['complete']} delta={delta_complete:+d}")


if __name__ == "__main__":
    main()
