#!/usr/bin/env bash
# All gates. Must pass before publishing.
set -uo pipefail
cd "$(dirname "$0")/.."

fail=0
echo "== structure =="
bash scripts/check-structure.sh || fail=1
echo
echo "== redactions =="
bash scripts/check-redactions.sh || fail=1
echo
echo "== links =="
bash scripts/check-links.sh || fail=1
echo
if [ "$fail" -ne 0 ]; then
  echo "VERIFY FAILED — do not publish." >&2
  exit 1
fi
echo "VERIFY PASSED"
