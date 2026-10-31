#!/usr/bin/env bash
# Shared helpers, sourced by the other scripts: `. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"`.
# Platform detection, path conversion for the game (forward slashes, a drive letter on Windows), the game's
# user folder, portable file times, and the usage printer. No side effects beyond defining these.

on_windows=false
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) on_windows=true ;; esac
on_macos=false
[[ "$(uname -s)" == Darwin ]] && on_macos=true

to_posix() { if $on_windows; then cygpath -u "$1"; else printf '%s\n' "$1"; fi; }
native_path() { if $on_windows; then cygpath -m "$1"; else printf '%s\n' "$1"; fi; }
file_url() { if $on_windows; then printf 'file:///%s\n' "$(cygpath -m "$1")"; else printf 'file://%s\n' "$1"; fi; }

# The Documents folder on Windows may be redirected (OneDrive, policy); ask the shell for it.
windows_documents() {
  local d
  d="$(powershell.exe -NoProfile -NonInteractive -Command '[Environment]::GetFolderPath("MyDocuments")' 2>/dev/null | tr -d '\r')"
  [[ -n "$d" ]] && d="$(cygpath -u "$d")" || d="$(cygpath -u "$USERPROFILE")/Documents"
  printf '%s\n' "$d"
}

# The game's user folder: mod/, logs/, settings.txt. STELLARIS_USER_DIR overrides detection.
stellaris_user_dir() {
  if [[ -n "${STELLARIS_USER_DIR:-}" ]]; then printf '%s\n' "$STELLARIS_USER_DIR"; return; fi
  if $on_windows; then printf '%s\n' "$(windows_documents)/Paradox Interactive/Stellaris"
  elif $on_macos; then printf '%s\n' "$HOME/Documents/Paradox Interactive/Stellaris"
  else printf '%s\n' "$HOME/.local/share/Paradox Interactive/Stellaris"
  fi
}

# Modification time of a file as epoch seconds (GNU and BSD stat).
mtime() { stat -c %Y "$1" 2>/dev/null || stat -f %m "$1"; }
# Epoch seconds as a readable local time (GNU and BSD date).
epoch_to_text() { date -d "@$1" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -r "$1" '+%Y-%m-%d %H:%M:%S'; }

# Prints the leading comment block of a script (its usage) without the shebang.
usage_of() { awk 'NR > 1 && /^#/ { print substr($0, 3); next } NR > 1 { exit }' "$1"; }

# Escapes a value for use inside XML text or attribute content.
xml_escape() { printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g'; }
