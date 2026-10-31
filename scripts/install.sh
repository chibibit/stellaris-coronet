#!/usr/bin/env bash
# Registers every mod in this repository with the Paradox launcher.
#
# For each crn_*/descriptor.mod it writes <game user folder>/mod/<folder>.mod: the descriptor plus a
# path= line pointing at this checkout, which is exactly what the launcher writes for its own mods.
# Nothing is copied or linked; the game reads the files straight from the repository.
#
# Usage: scripts/install.sh [--dry-run] [--remove]
#   --dry-run   print what would be written, write nothing
#   --remove    delete the descriptors this script wrote
# STELLARIS_USER_DIR overrides the detected user folder (the one holding mod/, logs/ and settings.txt).
#
# Close the Paradox launcher first: it caches descriptors and can overwrite a file written while it runs.
set -euo pipefail
# shellcheck source=scripts/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

dry_run=false
remove=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=true ;;
    --remove) remove=true ;;
    *) echo "unknown argument: $arg" >&2; usage_of "${BASH_SOURCE[0]}" >&2; exit 2 ;;
  esac
done

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
user_dir="$(stellaris_user_dir)"
mod_dir="$user_dir/mod"

if [[ ! -d "$mod_dir" ]]; then
  echo "game mod folder not found: $mod_dir" >&2
  echo "start Stellaris once, or set STELLARIS_USER_DIR" >&2
  exit 1
fi

count=0
for descriptor in "$repo_dir"/crn_*/descriptor.mod; do
  [[ -f "$descriptor" ]] || continue
  folder="$(basename "$(dirname "$descriptor")")"
  target="$mod_dir/$folder.mod"
  count=$((count + 1))

  if $remove; then
    if [[ -f "$target" ]]; then
      if $dry_run; then echo "would remove $target"; else rm -f "$target"; echo "removed  $target"; fi
    fi
    continue
  fi

  if grep -q '^path=' "$descriptor"; then
    echo "$descriptor has a path= line; the launcher copy gets its own, remove it from the repo" >&2
    exit 1
  fi

  # $(cat) drops trailing newlines, so the path= line always lands on its own line
  content="$(printf '%s\npath="%s"\n' "$(tr -d '\r' < "$descriptor")" "$(native_path "$repo_dir/$folder")")"
  if $dry_run; then
    echo "would write $target:"
    printf '%s\n' "$content" | sed 's/^/    /'
  else
    printf '%s\n' "$content" > "$target"
    echo "wrote    $target"
  fi
done

if [[ $count -eq 0 ]]; then
  echo "no crn_*/descriptor.mod found under $repo_dir" >&2
  exit 1
fi

if ! $remove && ! $dry_run; then
  echo
  echo "Now start the launcher, open Mods, and add the Coronet mods to a playset."
fi
