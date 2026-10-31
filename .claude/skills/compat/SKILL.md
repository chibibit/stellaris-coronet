---
name: compat
description: Check how the Coronet mods get on with another mod, by Workshop item id or folder. Finds shared files, shared keys and shared event ids, says who wins under the game's load-order rules, and proposes the fix (rename, split, patch mod). Use when the owner asks whether a mod is compatible or a player reports a conflict.
allowed-tools: Read, Grep, Glob, Bash(scripts/compat.sh:*), Bash(scripts/vanilla.sh:*), Bash(scripts/logs.sh:*)
---

Check compatibility with `$ARGUMENTS` (a Workshop item id, a mod folder path, or part of a mod's name, which
`scripts/vanilla.sh workshop-list` resolves to an id among the subscribed mods).

1. `scripts/compat.sh <id or path>`. Read the whole report. The rules it applies are in `docs/development.md`,
   "How the game merges files"; the longer treatment is `local/knowledge/07-compatibility-and-versions.md`
   when it exists.
2. Interpret each finding:
   - `FILE`: both mods ship the same path. The one lower in the playset replaces the other wholesale. If it is
     our file, it must not carry a vanilla or a foreign name: rename it with the `crn_` prefix (hard rule 1)
     unless it is a deliberate whole-file override listed in the mod's page.
   - `KEY`: both define the same key in the same folder. In a last-wins folder the file that sorts later by
     name wins, in a first-wins folder the earlier one. A shared key that is ours by prefix means the other
     mod is patching us (fine); a shared vanilla key means both patch vanilla and only one survives.
   - `MERGE`: on_actions both add to; no conflict, but if firing order matters, say which file name fires
     first.
   - `EVENT`: same event id; the first by file name wins and the other never fires. Ours are prefixed, so this
     is almost always the other mod copying an id; report it.
3. Note the count of vanilla files the other mod overrides: a high count means an overhaul that other mods
   must load before, and that its patches (if any) are the place to look.
4. Propose, per finding, the smallest fix: a rename, moving a definition into its own file, a load-order
   instruction for the Workshop page, or a separate patch mod that loads after both (the convention in
   `local/knowledge/07-*.md`, section 2). Do not change files in this skill.

Report as a list grouped by our mod, then the proposals. End with one line: `compatible as is` or `N
findings, M need a change on our side`.
