#!/usr/bin/env bash
# Verify every internal link in the built site resolves to a real file.
# Catches the classic Jekyll baseurl mistake, where local links work and the
# deployed project-page site 404s on every one of them.
#
# Usage: scripts/check-links.sh [site-dir] [baseurl]

set -uo pipefail

SITE="${1:-_site}"
BASEURL="${2:-/ai-portfolio}"

if [ ! -d "$SITE" ]; then
  echo "FAIL  build directory '$SITE' not found. Run the build first." >&2
  exit 2
fi

fails=0
checked=0

# Collect href/src values that are site-internal (start with / but not //).
while IFS= read -r pair; do
  src="${pair%%|*}"
  url="${pair#*|}"

  # Strip fragment and query.
  path="${url%%#*}"
  path="${path%%\?*}"
  [ -z "$path" ] && continue

  # Only check root-relative internal links.
  case "$path" in
    //*) continue ;;
    /*)  ;;
    *)   continue ;;
  esac

  # Strip the baseurl prefix to get a path inside the build output.
  rel="$path"
  case "$rel" in
    "$BASEURL"/*) rel="${rel#"$BASEURL"}" ;;
    "$BASEURL")   rel="/" ;;
    *)
      echo "BASE  $src  ->  $path   (internal link missing baseurl '$BASEURL')"
      fails=$((fails + 1))
      continue
      ;;
  esac

  checked=$((checked + 1))
  target="$SITE$rel"

  if [ -d "$target" ] && [ -f "$target/index.html" ]; then continue; fi
  if [ -f "$target" ]; then continue; fi
  case "$rel" in
    */) if [ -f "${target}index.html" ]; then continue; fi ;;
  esac

  echo "404   $src  ->  $path"
  fails=$((fails + 1))
done < <(
  grep -rIoE '(href|src)="[^"]+"' "$SITE" --include='*.html' 2>/dev/null |
  sed -E 's/^([^:]*):(href|src)="([^"]*)"$/\1|\3/'
)

echo
if [ "$fails" -gt 0 ]; then
  echo "FAIL  $fails broken or baseurl-less internal links ($checked checked)." >&2
  exit 1
fi
echo "PASS  $checked internal links resolve."
