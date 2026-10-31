#!/usr/bin/env bash
# Lint for the mod folders. Exit code 1 on any error.
#   - every crn_*/ has a descriptor.mod with name=, supported_version= identical to crn_core's (hard rule 7),
#     picture="thumbnail.png", dependencies naming "Coronet: Core" for every mod but Core, and no path= line
#   - thumbnail.png exists (warning) and is under 1 MB (error: Steam rejects it)
#   - brand/mods/<mod>.conf exists (warning: the renders use the family defaults otherwise)
#   - every localisation file is named *_l_<language>.yml, starts with a UTF-8 BOM and the l_<language>: header
#   - file names under a mod start with crn_ (a warning, since a whole-file override must keep the vanilla name)
#   - no CRLF line endings in script and localisation files
set -uo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
errors=0
warnings=0
err()  { echo "error:   $*"; errors=$((errors + 1)); }
warn() { echo "warning: $*"; warnings=$((warnings + 1)); }

bom="$(printf '\357\273\277')"
cr="$(printf '\r')"

shopt -s nullglob
mods=("$repo_dir"/crn_*/)
if [[ ${#mods[@]} -eq 0 ]]; then
  err "no crn_*/ mod folders found"
fi
core_version=""
[[ -f "$repo_dir/crn_core/descriptor.mod" ]] && core_version="$(sed -n 's/^supported_version="\(.*\)"$/\1/p' "$repo_dir/crn_core/descriptor.mod" | head -1)"

for mod in "${mods[@]}"; do
  mod="${mod%/}"
  name="$(basename "$mod")"
  descriptor="$mod/descriptor.mod"

  if [[ ! -f "$descriptor" ]]; then
    err "$name: descriptor.mod missing"
    continue
  fi
  grep -q '^name=' "$descriptor" || err "$name: descriptor.mod has no name="
  grep -q '^supported_version=' "$descriptor" || err "$name: descriptor.mod has no supported_version="
  grep -q '^path=' "$descriptor" && err "$name: descriptor.mod must not contain path= (scripts/install.sh adds it)"
  grep -q '^picture="thumbnail.png"$' "$descriptor" || err "$name: descriptor.mod must have picture=\"thumbnail.png\""
  this_version="$(sed -n 's/^supported_version="\(.*\)"$/\1/p' "$descriptor" | head -1)"
  if [[ -n "$core_version" && "$this_version" != "$core_version" ]]; then
    err "$name: supported_version is $this_version but crn_core has $core_version (hard rule 7: bump them together, scripts/bump.sh)"
  fi
  if [[ "$name" != crn_core ]] && ! grep -q '"Coronet: Core"' "$descriptor"; then
    err "$name: descriptor.mod must list \"Coronet: Core\" under dependencies"
  fi
  if [[ -f "$mod/thumbnail.png" ]]; then
    [[ $(wc -c < "$mod/thumbnail.png") -lt 1000000 ]] || err "$name: thumbnail.png is 1 MB or more; Steam rejects it (re-render with scripts/brand.sh)"
  else
    warn "$name: thumbnail.png missing (run scripts/brand.sh)"
  fi
  [[ -f "$repo_dir/brand/mods/$name.conf" ]] || warn "$name: no brand/mods/$name.conf (emblem, accent, tagline)"

  while IFS= read -r -d '' file; do
    rel="${file#"$repo_dir"/}"
    base="$(basename "$file")"
    case "$base" in
      descriptor.mod|thumbnail.png) continue ;;
    esac
    [[ "$base" == crn_* ]] || warn "$rel: file name does not start with crn_ (fine only for a whole-file override)"
    case "$file" in
      *.yml)
        if [[ "$base" =~ _l_([a-z_]+)\.yml$ ]]; then
          lang="${BASH_REMATCH[1]}"
          first="$(head -n 1 "$file" | tr -d "$cr" | sed 's/[[:space:]]*$//')"
          [[ "$first" == "$bom"* ]] || err "$rel: missing UTF-8 BOM"
          [[ "${first#"$bom"}" == "l_$lang:" ]] || err "$rel: first line must be l_$lang:"
        else
          err "$rel: localisation file must end in _l_<language>.yml"
        fi
        ;;
    esac
    case "$file" in
      *.txt|*.yml|*.mod|*.gui|*.gfx)
        grep -q "$cr" "$file" && err "$rel: CRLF line endings"
        ;;
    esac
  done < <(find "$mod" -type f -print0)
done

echo
echo "$errors error(s), $warnings warning(s)"
[[ $errors -eq 0 ]]
