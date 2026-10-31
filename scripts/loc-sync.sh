#!/usr/bin/env bash
# Generates every other language's localisation files from the English ones, so players on other languages
# see English text instead of raw keys. The game has no fallback language.
#
#   scripts/loc-sync.sh            # (re)write <mod>/localisation/<lang>/<base>_l_<lang>.yml for every language
#   scripts/loc-sync.sh --check    # exit 1 and list the generated files that are missing or out of date
#
# English is the source; the generated files are marked as such and overwritten on every run. To translate a
# language by hand later, remove the marker line from that file and the script leaves it alone.
set -euo pipefail

check=false
for arg in "$@"; do
  case "$arg" in
    --check) check=true ;;
    *) echo "unknown argument: $arg (only --check is accepted)" >&2; exit 2 ;;
  esac
done

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
languages=(braz_por french german japanese korean polish russian simp_chinese spanish)
marker="# Generated from the english file by scripts/loc-sync.sh. Edit the english file, then run it again."
bom="$(printf '\357\273\277')"

stale=0
written=0
for src in "$repo_dir"/crn_*/localisation/english/*_l_english.yml; do
  [[ -f "$src" ]] || continue
  mod_dir="$(dirname "$(dirname "$(dirname "$src")")")"
  base="$(basename "$src" _l_english.yml)"
  body="$(tail -n +2 "$src")"   # everything after the l_english: header
  for lang in "${languages[@]}"; do
    dst="$mod_dir/localisation/$lang/${base}_l_$lang.yml"
    rel="${dst#"$repo_dir"/}"
    if [[ -f "$dst" ]] && ! grep -q "scripts/loc-sync.sh" "$dst"; then
      continue   # translated by hand; not ours to overwrite
    fi
    expected="$(printf '%sl_%s:\n%s\n%s\n' "$bom" "$lang" "$marker" "$body")"
    if [[ -f "$dst" ]] && [[ "$(cat "$dst")" == "$expected" ]]; then
      continue
    fi
    if $check; then
      echo "stale or missing: $rel"
      stale=$((stale + 1))
    else
      mkdir -p "$(dirname "$dst")"
      printf '%s\n' "$expected" > "$dst"
      echo "wrote $rel"
      written=$((written + 1))
    fi
  done
done

if $check; then
  [[ $stale -eq 0 ]] && echo "all generated localisation files are current" || exit 1
else
  echo "$written file(s) written"
fi
