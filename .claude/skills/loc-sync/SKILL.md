---
name: loc-sync
description: Regenerate the other languages' localisation files from the English ones so non-English players see English instead of raw keys, and report what is still untranslated. Use after any change to a *_l_english.yml file, or when the owner asks about translations.
allowed-tools: Read, Grep, Glob, Bash(scripts/loc-sync.sh:*), Bash(scripts/check.sh:*), Bash(git status:*)
---

Sync localisation. `$ARGUMENTS` may be `--check` to only report.

1. `scripts/loc-sync.sh --check` to see what is stale; then `scripts/loc-sync.sh` unless only a check was
   asked. The script writes `<mod>/localisation/<language>/<base>_l_<language>.yml` for nine languages from
   each English file, with the BOM and the right header, and marks each file as generated. A file without the
   marker is a hand translation and is left alone.
2. `scripts/check.sh` must stay clean (it checks every `.yml` for BOM, header and name).
3. Report: files written, hand-translated files that exist and may now lag the English (compare their key
   lists to the English file's and name missing keys), and that these generated files are committed with the
   change to the English file, in the same commit (the game needs them; hard rule 6 in spirit). Do not commit.
