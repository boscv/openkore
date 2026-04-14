#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "[1/3] Syntax check: tools/remote_gateway.pl"
perl -c tools/remote_gateway.pl

echo "[2/3] Smoke test: RemoteGatewaySmokeTest"
perl src/test/unittests.pl RemoteGatewaySmokeTest

echo "[3/3] Release checks passed"
