---
name: brand
description: Work on the Coronet visual identity. Re-renders the images and shows them, or designs a new emblem for a mod on the mark's grid with the emblem-designer agent and shows it in the sheet before it is kept. Use for "render the images", "new emblem for X", "change the accent", or any change under brand/.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(scripts/brand.sh:*), Bash(scripts/check.sh:*), Bash(git status:*), Bash(git diff:*), Agent
---

Brand work: `$ARGUMENTS` is one of `render`, `emblem <mod or name> <what it should evoke>`, `accent <mod>
<colour from the table>`, or free text describing a change. The brand profile and its rules are
`brand/README.md`; read it first. PNGs are never edited, only rendered (ADR 0004).

- **render**: `scripts/brand.sh`, then look at what changed: open with the Read tool every mod's
  `thumbnail.png`, `brand/renders/emblem-sheet.png` and one hero image, and describe what you see in two
  lines, so the owner hears about a broken render before they open it. `scripts/check.sh` for the size limit.
- **emblem**: run the `emblem-designer` agent with the mod's purpose and the owner's wording; it returns an
  SVG fragment and the reasoning. Write it to `brand/emblems/<name>.svg` with the one-line comment the other
  emblems carry, set `emblem=<name>` in the mod's `brand/mods/<mod>.conf` if a mod was named, render, and show
  the emblem sheet and the mod's thumbnail. Ask the owner whether to keep it. On no, put the conf back to its
  previous `emblem=` value and render again; the unused file in `brand/emblems/` is harmless and is the owner's
  to delete or keep for later. On yes, add the emblem to the list in `brand/README.md`.
- **accent**: the colour must be a row of the accent table in `brand/README.md` (gold is never an accent).
  Set it in the mod's conf, render, show the thumbnail.
- **free text**: a change to a template or the mark is edited in the SVG source, rendered, and shown as above.
  Changes to the mark itself affect every image; say so and show the sheet.

Report what changed, which files were rendered, and that nothing is committed. Do not commit.
