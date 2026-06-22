#!/usr/bin/env bash
# Run all test suites.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0

run_suite() {
  local name="$1"
  local script="$2"
  echo "=== $name ==="
  if bash "$script"; then
    echo ""
  else
    echo ""
    echo "SUITE FAILED: $name"
    FAIL=1
  fi
}

run_suite "Skill frontmatter" "$ROOT/tests/unit/test-skill-frontmatter.sh"

if (( FAIL == 0 )); then
  echo "All suites passed."
else
  echo "One or more suites failed."
  exit 1
fi
