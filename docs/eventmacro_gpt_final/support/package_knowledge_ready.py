#!/usr/bin/env python3
"""Create a reproducible tar.gz package from docs/eventmacro_gpt_final/knowledge_ready."""
from __future__ import annotations

import argparse
import hashlib
import tarfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
KNOWLEDGE = ROOT / "eventmacro_gpt_final" / "knowledge_ready"


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", required=True, help="output tar.gz path")
    args = parser.parse_args()

    out = Path(args.output).resolve()
    out.parent.mkdir(parents=True, exist_ok=True)

    files = sorted(p for p in KNOWLEDGE.iterdir() if p.is_file())
    with tarfile.open(out, "w:gz") as tf:
        for f in files:
            tf.add(f, arcname=f"knowledge_ready/{f.name}")

    digest = sha256_file(out)
    print(f"OK: package created: {out}")
    print(f"files={len(files)}")
    print(f"sha256={digest}")


if __name__ == "__main__":
    main()
