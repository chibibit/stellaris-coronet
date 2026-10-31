#!/usr/bin/env bash
# Finds the game install and the Workshop downloads, and searches them. Read-only.
#
#   scripts/vanilla.sh dir                       # the game install folder
#   scripts/vanilla.sh version                   # the installed game version
#   scripts/vanilla.sh ls <subpath>              # list a folder of the install, e.g. common/buildings
#   scripts/vanilla.sh grep <pattern> [subpath]  # search the install (default: common events localisation/english)
#   scripts/vanilla.sh cat <file>                # print a vanilla file, e.g. common/on_actions/00_on_actions.txt
#   scripts/vanilla.sh workshop <item id>        # the download folder of a subscribed Workshop mod
#   scripts/vanilla.sh workshop-list             # every subscribed mod: id and name
#
# STELLARIS_GAME_DIR overrides detection, which reads Steam's libraryfolders.vdf.
set -euo pipefail
# shellcheck source=scripts/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

steam_roots() {
  if $on_windows; then
    printf '%s\n' "$(to_posix "$(printenv 'ProgramFiles(x86)' 2>/dev/null || printf '%s' "${PROGRAMFILES:-}")")/Steam"
  elif $on_macos; then
    printf '%s\n' "$HOME/Library/Application Support/Steam"
  else
    printf '%s\n' "$HOME/.steam/steam" "$HOME/.local/share/Steam" "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam"
  fi
}

libraries() { # every Steam library folder, the default root first; physical paths, so a symlinked root is listed once
  local root vdf
  for root in $(steam_roots | tr ' ' '\001'); do
    root="${root//$'\001'/ }"
    [[ -d "$root" ]] || continue
    (cd -P "$root" && pwd)
    vdf="$root/steamapps/libraryfolders.vdf"
    [[ -f "$vdf" ]] || continue
    tr -d '\r' < "$vdf" | sed -n 's/^[[:space:]]*"path"[[:space:]]*"\(.*\)"[[:space:]]*$/\1/p' | sed 's/\\\\/\\/g' | while IFS= read -r p; do
      p="$(to_posix "$p")"
      [[ -d "$p" ]] && (cd -P "$p" && pwd)
    done
  done | awk '!seen[$0]++'
}

game_dir() {
  if [[ -n "${STELLARIS_GAME_DIR:-}" ]]; then printf '%s\n' "$STELLARIS_GAME_DIR"; return; fi
  local lib
  while IFS= read -r lib; do
    if [[ -f "$lib/steamapps/common/Stellaris/launcher-settings.json" ]]; then
      printf '%s\n' "$lib/steamapps/common/Stellaris"; return
    fi
  done < <(libraries)
  echo "Stellaris install not found in any Steam library; set STELLARIS_GAME_DIR" >&2
  exit 1
}

workshop_dir() { # workshop_dir <item id>
  local lib
  while IFS= read -r lib; do
    if [[ -d "$lib/steamapps/workshop/content/281990/$1" ]]; then
      printf '%s\n' "$lib/steamapps/workshop/content/281990/$1"; return
    fi
  done < <(libraries)
  echo "Workshop item $1 is not downloaded in any Steam library" >&2
  exit 1
}

cmd="${1:-}"
case "$cmd" in
  dir) game_dir ;;
  version)
    sed -n 's/^[[:space:]]*"rawVersion":[[:space:]]*"\(.*\)",\{0,1\}$/\1/p' "$(game_dir)/launcher-settings.json"
    ;;
  ls)
    [[ -n "${2:-}" ]] || { echo "usage: scripts/vanilla.sh ls <subpath>" >&2; exit 2; }
    g="$(game_dir)"
    ls "$g/$2"
    ;;
  grep)
    [[ -n "${2:-}" ]] || { echo "usage: scripts/vanilla.sh grep <pattern> [subpath]" >&2; exit 2; }
    g="$(game_dir)"
    if [[ -n "${3:-}" ]]; then
      grep -rn -a -iE --include='*.txt' --include='*.yml' --include='*.gui' --include='*.gfx' --include='*.asset' -- "$2" "$g/$3" | sed "s|^$g/||"
    else
      grep -rn -a -iE --include='*.txt' --include='*.yml' -- "$2" "$g/common" "$g/events" "$g/localisation/english" | sed "s|^$g/||"
    fi
    ;;
  cat)
    [[ -n "${2:-}" ]] || { echo "usage: scripts/vanilla.sh cat <file>" >&2; exit 2; }
    g="$(game_dir)"
    cat "$g/$2"
    ;;
  workshop)
    [[ "${2:-}" =~ ^[0-9]+$ ]] || { echo "usage: scripts/vanilla.sh workshop <item id>" >&2; exit 2; }
    workshop_dir "$2"
    ;;
  workshop-list)
    while IFS= read -r lib; do
      for d in "$lib"/steamapps/workshop/content/281990/*/; do
        [[ -f "$d/descriptor.mod" ]] || continue
        printf '%s\t%s\n' "$(basename "$d")" "$(tr -d '\r' < "$d/descriptor.mod" | sed -n 's/^name="\(.*\)"$/\1/p' | head -1)"
      done
    done < <(libraries) | sort -t$'\t' -k2
    ;;
  *)
    awk 'NR > 1 && /^#/ { print substr($0, 3); next } NR > 1 { exit }' "${BASH_SOURCE[0]}"
    exit 2
    ;;
esac
