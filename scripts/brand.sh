#!/usr/bin/env bash
# Renders the brand assets from the SVG masters in brand/:
#   brand/renders/coronet-mark-1024.png, coronet-logo-horizontal-1600x400.png, coronet-collection-1024.png,
#   emblem-sheet.png (every emblem inside the mark, 240 px per emblem by 300)
#   per mod: crn_<mod>/thumbnail.png (512x512), brand/renders/crn_<mod>-mark-512.png and
#   brand/renders/crn_<mod>-workshop-hero-1920x1080.png
#
# Usage: scripts/brand.sh [--check]
#   --check   report the renderer and the targets, render nothing
#
# Renderer, first found: rsvg-convert, inkscape, magick (ImageMagick with SVG support), or a headless
# Chrome/Chromium/Edge. The browser runs with a throwaway profile and does not touch the user's browser.
set -euo pipefail
# shellcheck source=scripts/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

check=false
for arg in "$@"; do
  case "$arg" in
    --check) check=true ;;
    *) echo "unknown argument: $arg" >&2; usage_of "${BASH_SOURCE[0]}" >&2; exit 2 ;;
  esac
done

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
brand_dir="$repo_dir/brand"
out_dir="$brand_dir/renders"
mark_file="$brand_dir/coronet-mark.svg"

# ---- renderer detection -------------------------------------------------------------------------------
renderer=""
browser=""
if command -v rsvg-convert >/dev/null 2>&1; then renderer=rsvg
elif command -v inkscape >/dev/null 2>&1; then renderer=inkscape
elif command -v magick >/dev/null 2>&1; then renderer=magick
else
  candidates=()
  for b in google-chrome google-chrome-stable chromium chromium-browser microsoft-edge; do
    command -v "$b" >/dev/null 2>&1 && candidates+=("$(command -v "$b")")
  done
  if $on_windows; then
    for root in "${PROGRAMFILES:-}" "$(printenv 'ProgramFiles(x86)' 2>/dev/null || true)" "${LOCALAPPDATA:-}"; do
      [[ -n "$root" ]] || continue
      root="$(to_posix "$root")"
      candidates+=("$root/Google/Chrome/Application/chrome.exe" "$root/Microsoft/Edge/Application/msedge.exe")
    done
  elif $on_macos; then
    candidates+=("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge")
  fi
  for c in "${candidates[@]}"; do
    if [[ -x "$c" ]]; then browser="$c"; renderer=browser; break; fi
  done
fi
if [[ -z "$renderer" ]]; then
  echo "no SVG renderer found: install rsvg-convert, inkscape, ImageMagick, or Chrome/Edge" >&2
  exit 1
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

render() { # render <svg> <png> <width> <height>
  local svg="$1" png="$2" w="$3" h="$4"
  mkdir -p "$(dirname "$png")"
  case "$renderer" in
    rsvg) rsvg-convert -w "$w" -h "$h" "$svg" -o "$png" ;;
    inkscape) inkscape "$svg" --export-type=png --export-filename="$png" -w "$w" -h "$h" >/dev/null 2>&1 ;;
    magick) magick -background none -density 192 "$svg" -resize "${w}x${h}!" "$png" ;;
    browser)
      "$browser" --headless=new --disable-gpu --hide-scrollbars --no-first-run --no-default-browser-check \
        --user-data-dir="$(native_path "$work/profile")" --default-background-color=00000000 \
        --window-size="${w},${h}" --screenshot="$(native_path "$png")" "$(file_url "$svg")" >/dev/null 2>&1
      ;;
  esac
  [[ -s "$png" ]] || { echo "render failed: $png" >&2; exit 1; }
}

# ---- mark and emblem ------------------------------------------------------------------------------------
family_mark="$work/mark-family.fragment"
sed -n '/<!-- mark:start -->/,/<!-- mark:end -->/p' "$mark_file" > "$family_mark"
[[ -s "$family_mark" ]] || { echo "no <!-- mark:start --> / <!-- mark:end --> block in $mark_file" >&2; exit 1; }
grep -q '<!-- emblem:start -->' "$family_mark" || { echo "no <!-- emblem:start --> / <!-- emblem:end --> block in $mark_file" >&2; exit 1; }

mark_with_emblem() { # mark_with_emblem <emblem file> <out fragment>: the family mark with the emblem swapped in
  awk -v emblem="$1" '
    /<!-- emblem:start -->/ { print; while ((getline line < emblem) > 0) print line; close(emblem); skip = 1; next }
    /<!-- emblem:end -->/   { skip = 0 }
    !skip                   { print }
  ' "$family_mark" > "$2"
}

emblem_path() { # emblem_path <name or path>: resolves a conf emblem value to a file
  local e="$1"
  if [[ -f "$brand_dir/emblems/$e.svg" ]]; then printf '%s\n' "$brand_dir/emblems/$e.svg"
  elif [[ -f "$repo_dir/$e" ]]; then printf '%s\n' "$repo_dir/$e"
  else echo "emblem not found: $e (no brand/emblems/$e.svg and no file $e)" >&2; exit 1
  fi
}

# ---- template filling ---------------------------------------------------------------------------------
# Values reach awk through the environment, so no character in them is special; text values are XML-escaped.
fill() { # fill <template> <out svg> <mark fragment> [SUBTITLE] [VERSION] [TAGLINE] [ACCENT]
  local template="$1" out="$2"
  MARK="$3" SUBTITLE="$(xml_escape "${4:-}")" VERSION="$(xml_escape "${5:-}")" TAGLINE="$(xml_escape "${6:-}")" ACCENT="${7:-#5CC8DC}" \
  awk '
    function subst(line, key, val,    i, head) {
      head = ""
      while ((i = index(line, key)) > 0) { head = head substr(line, 1, i - 1) val; line = substr(line, i + length(key)) }
      return head line
    }
    # only a line that is nothing but the placeholder; a comment that mentions it stays a comment
    /^[[:space:]]*\{\{MARK\}\}[[:space:]]*$/ { while ((getline l < ENVIRON["MARK"]) > 0) print l; close(ENVIRON["MARK"]); next }
    {
      line = subst($0, "{{SUBTITLE}}", ENVIRON["SUBTITLE"])
      line = subst(line, "{{VERSION}}", ENVIRON["VERSION"])
      line = subst(line, "{{TAGLINE}}", ENVIRON["TAGLINE"])
      line = subst(line, "#5CC8DC", ENVIRON["ACCENT"])
      print line
    }
  ' "$template" > "$out"
}

descriptor_value() { # descriptor_value <descriptor.mod> <key>
  tr -d '\r' < "$1" | sed -n "s/^$2=\"\(.*\)\"[[:space:]]*$/\1/p" | head -1
}

conf_value() { # conf_value <conf file> <key> [default]
  local v=""
  [[ -f "$1" ]] && v="$(tr -d '\r' < "$1" | sed -n "s/^$2=//p" | head -1)"
  printf '%s\n' "${v:-${3:-}}"
}

# ---- targets --------------------------------------------------------------------------------------------
echo "renderer: $renderer${browser:+ ($browser)}"

targets=()
targets+=("$mark_file|$out_dir/coronet-mark-1024.png|1024|1024")
fill "$brand_dir/coronet-logo-horizontal.svg" "$work/logo-horizontal.svg" "$family_mark"
targets+=("$work/logo-horizontal.svg|$out_dir/coronet-logo-horizontal-1600x400.png|1600|400")
fill "$brand_dir/templates/collection.svg" "$work/collection.svg" "$family_mark"
targets+=("$work/collection.svg|$out_dir/coronet-collection-1024.png|1024|1024")

for descriptor in "$repo_dir"/crn_*/descriptor.mod; do
  [[ -f "$descriptor" ]] || continue
  mod="$(basename "$(dirname "$descriptor")")"
  conf="$brand_dir/mods/$mod.conf"
  [[ -f "$conf" ]] || echo "warning: no brand/mods/$mod.conf; using the family emblem, accent and no tagline" >&2
  name="$(descriptor_value "$descriptor" name)"
  subtitle="$(printf '%s' "${name#Coronet: }" | tr '[:lower:]' '[:upper:]')"
  version="$(descriptor_value "$descriptor" supported_version | sed -e 's/^v//' -e 's/\.\*$//')"
  tagline="$(conf_value "$conf" tagline)"
  [[ -n "$tagline" ]] || echo "warning: no tagline for $mod" >&2
  accent="$(conf_value "$conf" accent '#5CC8DC')"
  emblem="$(emblem_path "$(conf_value "$conf" emblem star)")"

  mark="$work/$mod-mark.fragment"
  mark_with_emblem "$emblem" "$mark"
  # the mod's own mark as a standalone image, for avatars and badges
  { echo '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 200 200">'; cat "$mark"; echo '</svg>'; } > "$work/$mod-mark.svg"
  targets+=("$work/$mod-mark.svg|$out_dir/$mod-mark-512.png|512|512")

  fill "$brand_dir/templates/thumbnail.svg" "$work/$mod-thumbnail.svg" "$mark" "$subtitle" "$version" "" "$accent"
  targets+=("$work/$mod-thumbnail.svg|$repo_dir/$mod/thumbnail.png|512|512")
  fill "$brand_dir/templates/workshop-hero.svg" "$work/$mod-hero.svg" "$mark" "$subtitle" "$version" "$tagline" "$accent"
  targets+=("$work/$mod-hero.svg|$out_dir/$mod-workshop-hero-1920x1080.png|1920|1080")
done

# the emblem sheet: every emblem in the library inside the mark, for choosing one
emblems=("$brand_dir"/emblems/*.svg)
n=${#emblems[@]}
{
  echo "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" viewBox=\"0 0 $((n * 240)) 300\">"
  echo "<rect width=\"$((n * 240))\" height=\"300\" fill=\"#0E1224\"/>"
  i=0
  for e in "${emblems[@]}"; do
    ename="$(basename "$e" .svg)"
    mark_with_emblem "$e" "$work/sheet-$ename.fragment"
    # ids inside the mark repeat per copy; browsers resolve each use to the first definition, which is identical
    echo "<g transform=\"translate($((i * 240 + 20)) 20)\">"; cat "$work/sheet-$ename.fragment"; echo "</g>"
    echo "<text x=\"$((i * 240 + 120))\" y=\"270\" text-anchor=\"middle\" font-family=\"Bahnschrift, 'Segoe UI', sans-serif\" font-size=\"24\" letter-spacing=\"6\" fill=\"#5CC8DC\">$(printf '%s' "$ename" | tr '[:lower:]' '[:upper:]')</text>"
    i=$((i + 1))
  done
  echo "</svg>"
} > "$work/emblem-sheet.svg"
targets+=("$work/emblem-sheet.svg|$out_dir/emblem-sheet.png|$((n * 240))|300")

for t in "${targets[@]}"; do
  IFS='|' read -r svg png w h <<< "$t"
  rel="${png#"$repo_dir"/}"
  if $check; then
    echo "would render $rel (${w}x${h})"
    continue
  fi
  render "$svg" "$png" "$w" "$h"
  size=$(wc -c < "$png")
  echo "rendered $rel (${w}x${h}, $((size / 1024)) KB)"
  if [[ "$rel" == */thumbnail.png && $size -ge 1000000 ]]; then
    echo "error: $rel is $size bytes; Steam rejects thumbnails of 1 MB or more" >&2
    exit 1
  fi
done
