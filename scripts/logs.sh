#!/usr/bin/env bash
# Reads the game's logs and generated script documentation for this family of mods.
# Read-only; nothing in the user folder is modified.
#
#   scripts/logs.sh user-dir              # the game's user folder (mod/, logs/, settings.txt)
#   scripts/logs.sh loaded                # the "Coronet: <Name> loaded" lines of the last game start
#   scripts/logs.sh errors [--all]        # error.log lines that name us (crn_, Coronet, this checkout) and
#                                         #   parse errors next to such a line; --all prints every line
#   scripts/logs.sh docs                  # the folder with effects.log, triggers.log, scopes.log,
#                                         #   modifiers.log, localizations.log (rewritten on every game start)
#   scripts/logs.sh grep <pattern> [file] # search those docs (file: effects|triggers|scopes|modifiers|localizations)
#   scripts/logs.sh fresh                 # when error.log and game.log were last written
#
# STELLARIS_USER_DIR overrides the detected user folder.
set -euo pipefail
# shellcheck source=scripts/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
user_dir="$(stellaris_user_dir)"
logs="$user_dir/logs"
docs="$logs/script_documentation"
repo_in_logs="$(native_path "$repo_dir")"   # the checkout as the game writes it in messages

need() { [[ -f "$1" ]] || { echo "not found: $1 (start the game once, or set STELLARIS_USER_DIR)" >&2; exit 1; }; }
# lines of stdin that name us: the prefix or brand (regex) or the checkout path (fixed string)
ours() { local all; all="$(cat)"; { printf '%s\n' "$all" | grep -a -iE 'crn_|coronet' || true; printf '%s\n' "$all" | grep -a -F -- "$repo_in_logs" || true; }; }

cmd="${1:-}"
case "$cmd" in
  user-dir)
    printf '%s\n' "$user_dir"
    ;;
  loaded)
    need "$logs/game.log"
    if ! grep -a 'Coronet: .* loaded' "$logs/game.log"; then
      echo "no 'Coronet: <Name> loaded' line in game.log: the mod is not in the active playset, or did not fire" >&2
      exit 1
    fi
    ;;
  errors)
    need "$logs/error.log"
    total=$(grep -ac . "$logs/error.log" || true)
    if [[ "${2:-}" == "--all" ]]; then
      cat "$logs/error.log"
    else
      {
        ours < "$logs/error.log"
        # parse errors: the file name is often on a neighbouring line, so look two lines either side
        grep -a -B2 -A2 -iE 'unexpected token|malformed token|error reading file' "$logs/error.log" | ours || true
      } | awk '!seen[$0]++'
    fi
    echo "-- error.log: $total line(s) in total" 2>/dev/null || true
    ;;
  docs)
    [[ -d "$docs" ]] || { echo "not found: $docs (start the game once; the folder is written at the end of loading)" >&2; exit 1; }
    printf '%s\n' "$docs"
    ;;
  grep)
    [[ -n "${2:-}" ]] || { echo "usage: scripts/logs.sh grep <pattern> [effects|triggers|scopes|modifiers|localizations]" >&2; exit 2; }
    [[ -d "$docs" ]] || { echo "not found: $docs" >&2; exit 1; }
    if [[ -n "${3:-}" ]]; then
      need "$docs/$3.log"
      grep -a -n -iE -- "$2" "$docs/$3.log" || { echo "no match for '$2' in $3.log" >&2; exit 1; }
    else
      grep -a -n -iE -- "$2" "$docs"/*.log || { echo "no match for '$2' in $docs" >&2; exit 1; }
    fi
    ;;
  fresh)
    for f in error.log game.log; do
      need "$logs/$f"
      printf '%-10s %s\n' "$f" "$(epoch_to_text "$(mtime "$logs/$f")")"
    done
    ;;
  *)
    usage_of "${BASH_SOURCE[0]}"
    exit 2
    ;;
esac
