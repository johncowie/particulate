#!/usr/bin/env bash
# Validates that every SKILL.md has required frontmatter fields.
set -euo pipefail

SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../skills" && pwd)"
PASS=0
FAIL=0
ERRORS=()

REQUIRED_FIELDS=(name description)

check_field() {
  local file="$1"
  local field="$2"
  # Match "field: <non-empty value>" inside the frontmatter block (between --- markers)
  if ! awk '/^---$/{f++} f==1 && /^'"$field"': .+/' "$file" | grep -q .; then
    ERRORS+=("  MISSING '$field' in $file")
    return 1
  fi
  return 0
}

while IFS= read -r -d '' skill_file; do
  skill_ok=true

  for field in "${REQUIRED_FIELDS[@]}"; do
    check_field "$skill_file" "$field" || skill_ok=false
  done

  if $skill_ok; then
    echo "PASS: $skill_file"
    ((PASS++)) || true
  else
    echo "FAIL: $skill_file"
    ((FAIL++)) || true
  fi
done < <(find "$SKILLS_DIR" -name "SKILL.md" -print0)

echo ""
if (( ${#ERRORS[@]} > 0 )); then
  echo "Errors:"
  for err in "${ERRORS[@]}"; do
    echo "$err"
  done
  echo ""
fi

echo "Results: $PASS passed, $FAIL failed"
(( FAIL == 0 ))
