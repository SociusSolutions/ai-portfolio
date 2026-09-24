#!/usr/bin/env bash
# Fail if any forbidden string appears in the built site.
# Patterns live in _data/redactions.yml so the list is reviewable in one place.
#
# Usage: scripts/check-redactions.sh [site-dir]     (default: _site)

set -uo pipefail

SITE="${1:-_site}"
SPEC="_data/redactions.yml"

if [ ! -d "$SITE" ]; then
  echo "FAIL  build directory '$SITE' not found. Run the build first." >&2
  exit 2
fi
if [ ! -f "$SPEC" ]; then
  echo "FAIL  '$SPEC' not found." >&2
  exit 2
fi

# The sensitive identifier list is not committed. Locally it is .redactions.local.yml;
# in CI the workflow materialises it from a repository secret into REDACTIONS_EXTRA.
EXTRA="${REDACTIONS_EXTRA:-.redactions.local.yml}"
SPECS="$SPEC"
if [ -f "$EXTRA" ]; then
  SPECS="$SPEC $EXTRA"
else
  echo "WARN  no identifier list found at '$EXTRA'. Shape patterns only." >&2
  echo "WARN  set REDACTIONS_EXTRA, or create .redactions.local.yml, for the full gate." >&2
  warned=1
fi

fails=0
checked=0
warned="${warned:-0}"

# Parse the "- { pattern: ..., mode: x, why: ... }" lines without needing a YAML library.
while IFS= read -r line; do
  case "$line" in
    *"- { pattern:"*) ;;
    *) continue ;;
  esac

  pat=$(printf '%s' "$line" | sed -n 's/.*pattern:[[:space:]]*"\(.*\)"[[:space:]]*,[[:space:]]*mode:.*/\1/p')
  mode=$(printf '%s' "$line" | sed -n 's/.*mode:[[:space:]]*\([a-z]*\)[[:space:]]*,.*/\1/p')
  why=$(printf '%s' "$line" | sed -n 's/.*why:[[:space:]]*"\(.*\)".*/\1/p')

  [ -z "$pat" ] && continue
  checked=$((checked + 1))

  case "$mode" in
    i)  hits=$(grep -rIil -e "$pat" "$SITE" 2>/dev/null) ;;
    w)  hits=$(grep -rIlw -e "$pat" "$SITE" 2>/dev/null) ;;
    re) hits=$(grep -rIlE -e "$pat" "$SITE" 2>/dev/null) ;;
    *)  echo "FAIL  unknown mode '$mode' for pattern '$pat'" >&2; fails=$((fails + 1)); continue ;;
  esac

  if [ -n "$hits" ]; then
    echo "LEAK  '$pat'  (${why:-no reason recorded})"
    printf '%s\n' "$hits" | sed 's/^/        /'
    fails=$((fails + 1))
  fi
done < <(cat $SPECS)

echo
if [ "$fails" -gt 0 ]; then
  echo "FAIL  $fails of $checked redaction patterns matched. Do not publish." >&2
  exit 1
fi

if [ "$warned" = "1" ]; then
  echo "PASS  $checked shape patterns checked, none present in $SITE."
  echo "WARN  the identifier list was NOT loaded. This is a partial gate." >&2
  exit 0
fi
echo "PASS  $checked redaction patterns checked, none present in $SITE."
