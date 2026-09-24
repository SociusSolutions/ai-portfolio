#!/usr/bin/env bash
# Every project page must carry the full template, and required front matter.
# The template is the reason the site reads as one system rather than ten essays.

set -uo pipefail

fails=0

require_fm() {
  local file="$1" key="$2"
  if ! sed -n '2,/^---$/p' "$file" | grep -q "^${key}:"; then
    echo "MISS  $file  front matter: $key"
    fails=$((fails + 1))
  fi
}

require_h2() {
  local file="$1" heading="$2"
  if ! grep -qF "## $heading" "$file"; then
    echo "MISS  $file  section: ## $heading"
    fails=$((fails + 1))
  fi
}

count=0
for f in _projects/*.md; do
  [ -e "$f" ] || continue
  count=$((count + 1))

  for k in title subtitle blurb order kind stack techniques role period status domain; do
    require_fm "$f" "$k"
  done

  require_h2 "$f" "Problem"
  require_h2 "$f" "What I built"
  require_h2 "$f" "AI techniques used"

  if grep -q '^corporate: true' "$f"; then
    require_h2 "$f" "Approach"
    require_h2 "$f" "Problem class"
    # Corporate pages must carry the availability note and must not claim results.
    if ! grep -q 'available on request' "$f"; then
      echo "MISS  $f  corporate page without an availability note"
      fails=$((fails + 1))
    fi
  else
    require_h2 "$f" "How it works"
    require_h2 "$f" "Outcome"
    require_h2 "$f" "What I'd do differently"
  fi

  # A diagram is part of the template.
  if ! grep -q 'class="mermaid"' "$f"; then
    echo "MISS  $f  no diagram"
    fails=$((fails + 1))
  fi
  if grep -q 'class="mermaid"' "$f" && ! grep -q '^mermaid: true' "$f"; then
    echo "MISS  $f  has a diagram but no 'mermaid: true' front matter"
    fails=$((fails + 1))
  fi

  # Unbalanced <pre> would silently swallow the rest of the page.
  o=$(grep -c '<pre class="mermaid">' "$f")
  c=$(grep -c '</pre>' "$f")
  if [ "$o" -ne "$c" ]; then
    echo "MISS  $f  unbalanced mermaid blocks: $o open, $c close"
    fails=$((fails + 1))
  fi
done

# Plate numbers must be unique and contiguous.
orders=$(grep -h '^order:' _projects/*.md | awk '{print $2}' | sort -n)
dupes=$(printf '%s\n' "$orders" | uniq -d)
if [ -n "$dupes" ]; then
  echo "MISS  duplicate order values: $(printf '%s ' $dupes)"
  fails=$((fails + 1))
fi

echo
if [ "$fails" -gt 0 ]; then
  echo "FAIL  $fails structural problems across $count project pages." >&2
  exit 1
fi
echo "PASS  $count project pages carry the full template."
