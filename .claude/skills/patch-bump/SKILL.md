---
name: patch-bump
description: Move the whole family to a new game version after a Stellaris patch. Bumps supported_version everywhere, hunts for script the patch deprecated, re-renders the version badges, re-registers the mods and sets up the verification. Use when the game has updated or the owner names a new version.
allowed-tools: Read, Edit, Grep, Glob, Bash(scripts/bump.sh:*), Bash(scripts/vanilla.sh:*), Bash(scripts/logs.sh:*), Bash(scripts/brand.sh:*), Bash(scripts/check.sh:*), Bash(scripts/install.sh:*), Bash(git status:*), Bash(git diff:*), Agent
---

Bump the family to `$ARGUMENTS` (a version like `v4.6.*`; without one, use `scripts/vanilla.sh version` and
derive `v<major>.<minor>.*`).

1. **Confirm the game.** `scripts/vanilla.sh version` must match the requested major.minor; if the install is
   still older, stop: the generated script docs would describe the old build.
2. **Read what changed.** `local/knowledge/07-compatibility-and-versions.md` (section 4, the version table, and
   the solo-modder checklist) when it exists, and the patch's own modding notes if the owner pastes them. If
   the game has been started on the new build, `scripts/logs.sh docs` is current: grep it for every effect,
   trigger and scope link our script uses and list anything marked deprecated or missing
   (`scripts/logs.sh grep 'deprecated' effects`, same for `triggers`, then the Grep tool over `crn_*/` for the
   identifiers to check). When a construct's replacement is unclear, ask the `vanilla-researcher` agent how
   vanilla does it on the new build.
3. **Bump.** `scripts/bump.sh --dry-run <version>`, then without `--dry-run`. Every `descriptor.mod` moves
   together (hard rule 7).
4. **Re-render and re-register.** `scripts/brand.sh` (the thumbnails carry the version badge),
   `scripts/check.sh`, `scripts/install.sh`.
5. **Docs.** Nothing in the checked-in docs names the game version except the ADRs' dates, so usually nothing
   to change; the owner's `CLAUDE.local.md` status section is theirs to update, mention it.
6. **Report** the bump, the deprecated constructs found with file and line, and that `/verify` on the new build
   is the proof. Do not fix script in this skill unless the owner says so; do not commit.
