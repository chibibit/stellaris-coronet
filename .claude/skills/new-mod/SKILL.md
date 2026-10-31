---
name: new-mod
description: Create a new Coronet mod end to end. Proposes names, emblem and accent for the repository owner to choose, then scaffolds the folder, brand config and docs page, renders the images, lints and registers the mod with the launcher. Use when the owner asks for a new mod.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(.claude/scripts/new-mod.sh:*), Bash(scripts/loc-sync.sh:*), Bash(scripts/brand.sh:*), Bash(scripts/check.sh:*), Bash(scripts/install.sh:*), Bash(scripts/logs.sh:*), Bash(scripts/vanilla.sh:*), Bash(git status:*)
---

Create the mod described by `$ARGUMENTS` (what it should do, in the owner's words; optionally a name they have
already chosen). Nothing is created until the owner has chosen the name: `CLAUDE.md`, "Naming".

1. **Propose.** Read `CLAUDE.md` (Naming), `brand/README.md` (the emblem list and the accent table) and
   `README.md` (the mods that exist). Offer two or three options, each a row: folder `crn_<purpose>`,
   Workshop title `Coronet: <Purpose>`, emblem, accent, and a tagline of at most 60 characters. Purposes are one
   plain word where possible; vanilla terms, DLC names and other mods' names are not reused. Check the
   subscribed Workshop mods for a title clash: `scripts/vanilla.sh workshop-list`. Then stop and wait for the
   owner's pick; a remark is not a pick.
2. **Scaffold.** With the chosen values:
   `.claude/scripts/new-mod.sh <purpose> "Coronet: <Purpose>" <emblem> <accent> "<tagline>"`
   (`--dry-run` first if anything is uncertain). It creates the mod folder with descriptor, load event,
   on_action entry and English localisation, the brand config and the docs page.
3. **Register in the docs.** Add the mod's row to the table under "The mods" in `README.md`, in folder order,
   linking its page. If the mod will override a vanilla file or depend on anything beyond Core, say so in its
   page now, not later (hard rule 6).
4. **Languages, render, lint, install.** `scripts/loc-sync.sh` (the other nine languages from the English
   file; hard rule 3), `scripts/brand.sh` (thumbnail, mark and hero image), `scripts/check.sh` (must report 0
   errors), `scripts/install.sh` (writes the launcher descriptor; the launcher should be closed).
5. **Report.** The folder, the files created, the images rendered, and that the mod still has to be added to a
   playset in the launcher and started once; `/verify` does the checking after that. Do not commit.
