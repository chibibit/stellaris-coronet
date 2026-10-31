---
name: publish
description: Prepare a mod for a Steam Workshop upload or update and walk the owner through the launcher steps. Checks the preconditions, bumps the mod's own version, renders, drafts the Workshop page text in Steam BBCode and the change note, and records the item id afterwards. Use when the owner wants to upload or update a mod on the Workshop.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(scripts/check.sh:*), Bash(scripts/brand.sh:*), Bash(scripts/loc-sync.sh --check:*), Bash(scripts/install.sh:*), Bash(git log:*), Bash(git status:*), Bash(git diff:*)
---

Publish `$ARGUMENTS` (a mod folder such as `crn_core`; optionally `--first` for a mod with no Workshop item
yet, or the new version number). The upload itself happens in the Paradox launcher, by the owner; this skill
does everything around it. The runbook is `docs/runbooks/publish.md`; follow it and do not invent steps.

1. **Preconditions.** `scripts/check.sh` clean; `scripts/loc-sync.sh --check` current; the mod's page under
   `docs/mods/` describes what is being uploaded; `git status` shows nothing half-done in the mod folder. Any
   failure stops the skill with the reason.
2. **Version.** Bump `version=` in the mod's `descriptor.mod` (semver; a new version for every upload), then
   `scripts/brand.sh` so the thumbnail is current, and `scripts/install.sh` so the launcher copy matches.
3. **Page text.** Write `brand/workshop/<mod>.txt` in Steam BBCode (`[h1]`, `[b]`, `[list][*]`, `[url=]`):
   a one-paragraph summary from the mod's page, what it changes, compatibility (Core required; what it
   overrides, if anything; checksum and achievements: a gameplay mod breaks them, say so), load order (after
   Core), known issues, a link to the repository when it is public, and a changelog section whose newest entry
   is this version. The change note for the upload dialog is that newest entry; from `git log -- <mod>` since
   the last upload when the page has an item id, otherwise "First release".
4. **Hand over.** Tell the owner the launcher steps for a first upload or an update, as the runbook has them,
   and which files to use: the thumbnail is in the mod folder, the hero image is
   `brand/renders/<mod>-workshop-hero-1920x1080.png`, the page text is the file from step 3. Wait for their word
   that the upload is done.
5. **Record.** Find the item id: the launcher writes `remote_file_id` into `descriptor.mod` (in the repository
   or in the launcher copy under the game's user folder; copy it into the repository's file if it only landed
   there). Put the id and the Workshop URL in the mod's page under "Workshop". Re-run `scripts/install.sh` if
   the descriptor changed.
6. **Report** version, item id and URL, and what was not verified (the upload from a folder outside the user
   folder is the open question in ADR 0002: if the launcher refused, say so and point at the junction fallback
   in the runbook). Do not commit.
