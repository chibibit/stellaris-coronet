#!/usr/bin/env bash
# Reports where another mod and the Coronet mods would collide: same file paths (whole-file replacement),
# same top-level keys in the same common/ folder (last or first definition wins by file-name order), same
# event ids, and on_actions both add to. Read-only.
#
#   scripts/compat.sh <workshop item id | path to a mod folder>
#
# Load-order rules it applies (see docs/development.md, "How the game merges files"): files from every mod and
# vanilla sort together by name; in common/ the last definition of a key wins, in events/ the first does.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="${1:-}"
[[ -n "$target" ]] || { echo "usage: scripts/compat.sh <workshop item id | mod folder>" >&2; exit 2; }
if [[ "$target" =~ ^[0-9]+$ ]]; then
  target="$("$repo_dir/scripts/vanilla.sh" workshop "$target")"
fi
[[ -d "$target" ]] || { echo "not a folder: $target" >&2; exit 1; }
their_name=""
[[ -f "$target/descriptor.mod" ]] && their_name="$(tr -d '\r' < "$target/descriptor.mod" | sed -n 's/^name="\(.*\)"$/\1/p' | head -1)"
echo "Comparing with: ${their_name:-$(basename "$target")} ($target)"

# first-definition-wins folders under common/ (the rest of common/ is last-wins; events/ is checked by id below)
fios='^(common/scripted_variables|common/scripted_loc|common/component_templates|common/component_sets|common/global_ship_designs|common/ship_behaviors|common/solar_system_initializers|common/special_projects|common/event_chains|common/start_screen_messages|common/governments/authorities)(/|$)'

keys_of() { # keys_of <file>: top-level keys (column 0, followed by =)
  grep -a -oE '^[A-Za-z0-9_@.:-]+[[:space:]]*=' "$1" 2>/dev/null | sed 's/[[:space:]]*=$//' | sort -u
}
event_ids_of() { grep -a -oE '^[[:space:]]*id[[:space:]]*=[[:space:]]*[A-Za-z0-9_]+\.[0-9]+' "$1" 2>/dev/null | sed 's/.*=[[:space:]]*//' | sort -u; }

findings=0
for mod_dir in "$repo_dir"/crn_*; do
  [[ -d "$mod_dir" ]] || continue
  mod="$(basename "$mod_dir")"
  echo
  echo "== $mod"

  # 1. same relative path: whole-file replacement, the mod lower in the playset wins
  while IFS= read -r -d '' ours; do
    rel="${ours#"$mod_dir"/}"
    if [[ -f "$target/$rel" ]]; then
      echo "FILE   $rel: both ship this file; the one lower in the playset replaces the other wholesale"
      findings=$((findings + 1))
    fi
  done < <(find "$mod_dir" -type f \( -name '*.txt' -o -name '*.gui' -o -name '*.gfx' -o -name '*.yml' \) -print0)

  # 2. same top-level key in the same common/ subfolder, different files
  while IFS= read -r -d '' ours; do
    rel="${ours#"$mod_dir"/}"
    folder="$(dirname "$rel")"
    [[ -d "$target/$folder" ]] || continue
    our_keys="$(keys_of "$ours")"
    [[ -n "$our_keys" ]] || continue
    for theirs in "$target/$folder"/*.txt; do
      [[ -f "$theirs" ]] || continue
      [[ "$(basename "$theirs")" != "$(basename "$ours")" ]] || continue
      shared="$(comm -12 <(printf '%s\n' "$our_keys") <(keys_of "$theirs"))"
      [[ -n "$shared" ]] || continue
      label=KEY
      if [[ "$folder" =~ $fios ]]; then rule="first file by name wins"; else rule="last file by name wins"; fi
      if [[ "$folder" == common/on_actions ]]; then label=MERGE; rule="lists merge, no conflict; firing order follows file name"; fi
      ordered="$(printf '%s\n%s\n' "$(basename "$ours")" "$(basename "$theirs")" | LC_ALL=C sort | tr '\n' ' ')"
      printf '%-6s %s: shared with %s/%s (%s; name order: %s)\n' "$label" "$rel" "$folder" "$(basename "$theirs")" "$rule" "$ordered"
      printf '%s\n' "$shared" | sed 's/^/         /'
      findings=$((findings + 1))
    done
  done < <(find "$mod_dir/common" -type f -name '*.txt' -print0 2>/dev/null)

  # 3. same event ids
  if [[ -d "$mod_dir/events" && -d "$target/events" ]]; then
    ours_ids="$(cat "$mod_dir"/events/*.txt 2>/dev/null | event_ids_of /dev/stdin || true)"
    theirs_ids="$(cat "$target"/events/*.txt 2>/dev/null | event_ids_of /dev/stdin || true)"
    shared="$(comm -12 <(printf '%s\n' "$ours_ids") <(printf '%s\n' "$theirs_ids") | grep -v '^$' || true)"
    if [[ -n "$shared" ]]; then
      echo "EVENT  same event ids on both sides (first definition by file name wins):"
      printf '%s\n' "$shared" | sed 's/^/         /'
      findings=$((findings + 1))
    fi
  fi
done

echo
# 4. does the other mod replace vanilla files? (a sign it is an overhaul that others must load around)
if game="$("$repo_dir/scripts/vanilla.sh" dir 2>/dev/null)"; then
  n=0
  while IFS= read -r -d '' f; do
    rel="${f#"$target"/}"
    [[ -f "$game/$rel" ]] && n=$((n + 1))
  done < <(find "$target" -type f \( -name '*.txt' -o -name '*.gui' -o -name '*.gfx' \) -print0)
  echo "The other mod ships $n file(s) with a vanilla file's path (whole-file overrides of vanilla)."
fi
echo "$findings finding(s)."
