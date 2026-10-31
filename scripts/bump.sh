#!/usr/bin/env bash
# Sets supported_version in every mod's descriptor.mod to the same value (hard rule 7).
#
#   scripts/bump.sh [--dry-run] <supported_version>     e.g. scripts/bump.sh 'v4.6.*'
#
# Afterwards: scripts/brand.sh (the thumbnails carry the version), scripts/install.sh (the launcher copies
# carry it too), then play and read the logs.
set -euo pipefail

dry_run=false
if [[ "${1:-}" == "--dry-run" ]]; then dry_run=true; shift; fi
version="${1:-}"
[[ "$version" =~ ^v[0-9]+\.[0-9]+\.(\*|[0-9]+)$ ]] || { echo "usage: scripts/bump.sh [--dry-run] 'v<major>.<minor>.*'" >&2; exit 2; }

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
changed=0
for descriptor in "$repo_dir"/crn_*/descriptor.mod; do
  [[ -f "$descriptor" ]] || continue
  mod="$(basename "$(dirname "$descriptor")")"
  current="$(sed -n 's/^supported_version="\(.*\)"$/\1/p' "$descriptor")"
  if [[ "$current" == "$version" ]]; then
    echo "$mod: already $version"
    continue
  fi
  if $dry_run; then
    echo "$mod: $current -> $version (dry run)"
  else
    # write-and-move rather than sed -i, whose syntax differs between GNU and BSD
    sed "s/^supported_version=\".*\"$/supported_version=\"$version\"/" "$descriptor" > "$descriptor.tmp" && mv "$descriptor.tmp" "$descriptor"
    echo "$mod: $current -> $version"
  fi
  changed=$((changed + 1))
done
if [[ $changed -gt 0 ]] && ! $dry_run; then
  echo
  echo "next: scripts/brand.sh && scripts/install.sh, then play and scripts/logs.sh errors"
fi
