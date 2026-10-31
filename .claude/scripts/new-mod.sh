#!/usr/bin/env bash
# Scaffolds a new Coronet mod. Called by /new-mod after the repository owner has chosen the name.
#
#   .claude/scripts/new-mod.sh [--dry-run] <purpose> "<Workshop title>" <emblem> <accent> "<tagline>"
#
#   purpose   lower case, letters, digits and underscores; the folder becomes crn_<purpose>
#   title     the descriptor name, "Coronet: <Purpose>"
#   emblem    a name from brand/emblems/ (without .svg)
#   accent    a hex colour from the accent table in brand/README.md
#   tagline   one line for the Workshop hero image, at most 60 characters, no quotes, &, <, >, | or backslashes
#
# Creates: crn_<purpose>/ (descriptor.mod depending on Core, the load event, its on_action entry, English
# localisation with BOM), brand/mods/crn_<purpose>.conf, and docs/mods/crn_<purpose>.md. It does not touch
# README.md (the skill adds the row), and does not generate the other languages, render or install (the
# skill runs scripts/loc-sync.sh, brand.sh, check.sh and install.sh afterwards).
set -euo pipefail

dry_run=false
if [[ "${1:-}" == "--dry-run" ]]; then dry_run=true; shift; fi
[[ $# -eq 5 ]] || { awk 'NR > 1 && /^#/ { print substr($0, 3); next } NR > 1 { exit }' "${BASH_SOURCE[0]}" >&2; exit 2; }

purpose="$1" title="$2" emblem="$3" accent="$4" tagline="$5"
tagline="${tagline%.}"   # the yml and the hero add their own punctuation
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
mod="crn_$purpose"
mod_dir="$repo_dir/$mod"

[[ "$purpose" =~ ^[a-z][a-z0-9_]*$ ]] || { echo "purpose must be lower case letters, digits, underscores: $purpose" >&2; exit 2; }
[[ "$purpose" != "core" ]] || { echo "crn_core already exists" >&2; exit 2; }
[[ ! -e "$mod_dir" ]] || { echo "already exists: $mod_dir" >&2; exit 2; }
[[ "$title" == "Coronet: "* ]] || { echo "title must start with 'Coronet: ' (got: $title)" >&2; exit 2; }
[[ -f "$repo_dir/brand/emblems/$emblem.svg" ]] || { echo "no such emblem: brand/emblems/$emblem.svg" >&2; exit 2; }
[[ "$accent" =~ ^#[0-9A-Fa-f]{6}$ ]] || { echo "accent must be a hex colour like #9D8CFF: $accent" >&2; exit 2; }
[[ ${#tagline} -le 60 ]] || { echo "tagline is ${#tagline} characters; at most 60" >&2; exit 2; }
[[ "$tagline" =~ ^[^\"\&\<\>\|\\]+$ ]] || { echo "tagline must not contain quotes, &, <, >, | or backslashes (it goes into yml and SVG)" >&2; exit 2; }

core_descriptor="$repo_dir/crn_core/descriptor.mod"
supported="$(sed -n 's/^supported_version="\(.*\)"$/\1/p' "$core_descriptor")"
[[ -n "$supported" ]] || { echo "cannot read supported_version from $core_descriptor" >&2; exit 1; }
today="$(date +%Y-%m-%d)"

write() { # write <relative path> ; content on stdin
  local path="$repo_dir/$1"
  if $dry_run; then
    echo "would write $1"; cat > /dev/null
  else
    mkdir -p "$(dirname "$path")"
    cat > "$path"
    echo "wrote $1"
  fi
}

write "$mod/descriptor.mod" <<EOF
name="$title"
version="0.1.0"
supported_version="$supported"
tags={
	"Gameplay"
}
picture="thumbnail.png"
dependencies={
	"Coronet: Core"
}
EOF

write "$mod/common/on_actions/${mod}_on_actions.txt" <<EOF
# On_action lists merge across mods, so this adds to vanilla's on_game_start without replacing it.
on_game_start = {
	events = {
		$mod.1	# Announce the mod: set ${mod}_active, write the load line to game.log
	}
}
EOF

write "$mod/events/${mod}_events.txt" <<EOF
namespace = $mod

# Fired once from on_game_start (common/on_actions/${mod}_on_actions.txt).
# Other Coronet mods and compatibility patches test has_global_flag = ${mod}_active;
# the log line in game.log is the proof the mod loaded.
event = {
	id = $mod.1
	hide_window = yes
	is_triggered_only = yes

	immediate = {
		set_global_flag = ${mod}_active
		log = "$title loaded"
	}
}
EOF

{ printf '\xEF\xBB\xBF'; cat <<EOF
l_english:
 ${mod}_name:0 "$title"
 ${mod}_desc:0 "$tagline. Requires Coronet: Core."
EOF
} | write "$mod/localisation/english/${mod}_l_english.yml"

write "brand/mods/$mod.conf" <<EOF
# Per-mod brand configuration, read by scripts/brand.sh. Keys: tagline, emblem, accent.
tagline=$tagline
emblem=$emblem
accent=$accent
EOF

write "docs/mods/$mod.md" <<EOF
# $mod — $title

$tagline. Depends on [Coronet: Core](crn_core.md), which loads first.

## What it changes in the game

Nothing yet. On game start it sets the global flag \`${mod}_active\` and writes \`$title loaded\` to \`game.log\`.

## Files

| File | What |
|---|---|
| \`descriptor.mod\` | Name, version, supported game version, tags, thumbnail, dependency on Core. |
| \`common/on_actions/${mod}_on_actions.txt\` | Adds \`$mod.1\` to \`on_game_start\`. |
| \`events/${mod}_events.txt\` | Namespace \`$mod\`. Event \`$mod.1\`: hidden, triggered only, sets the flag and logs. |
| \`localisation/english/${mod}_l_english.yml\` | The mod's name and description keys. |
| \`thumbnail.png\` | 512x512, rendered by \`scripts/brand.sh\` from \`brand/mods/$mod.conf\` (emblem \`$emblem\`). Never edited by hand. |

## Vanilla files overridden

None.

## What other mods may rely on

- \`${mod}_active\` global flag.

## Workshop

Not uploaded yet. Created $today.
EOF

echo
echo "next: add the row to README.md, then scripts/loc-sync.sh && scripts/brand.sh && scripts/check.sh && scripts/install.sh"
