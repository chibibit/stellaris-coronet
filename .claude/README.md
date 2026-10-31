# .claude — Claude Code project configuration

Committed files are shared by every clone. **Anything under `.claude/` whose name has a `.local` or `-local`
part is personal and gitignored** (`.gitignore` rules `.claude/**/*.local.*`, `*.local/`, `*-local.*`,
`*-local/`). A name that merely contains the word, such as a `localisation-review` skill, is committed.

| Kind | Committed | Local (gitignored) | Notes |
|---|---|---|---|
| Settings | `settings.json` | `settings.local.json` | Local overrides shared; shared overrides `~/.claude/settings.json`. `permissions.allow` lists merge. |
| Rules | `rules/<name>.md` | `rules/<name>.local.md` | Extra instructions; with `paths:` frontmatter they load only when matching files are touched. |
| Subagents | `agents/<name>.md` | `agents/<name>.local.md` | Claude Code loads every `.md` in `agents/`; the agent's name comes from frontmatter, so the file suffix is only a git convention. |
| Skills | `skills/<name>/SKILL.md` | `skills/<name>.local/SKILL.md` | Invoked as `/<name>`. |
| Scripts | `scripts/<name>.sh` | `scripts/<name>.local.sh` | Bash helpers the skills call. Not to be confused with the repository's `scripts/`, which is the tooling people run too (lint, install, render, logs). |
| Memory | `../CLAUDE.md` | `../CLAUDE.local.md` | Project conventions vs personal notes. Every `CLAUDE.md` has a sibling local file. |
| MCP servers | `../.mcp.json` | none in the repo | Personal servers: `claude mcp add --scope local <name> ...`. |

## What is here today

- `settings.json`: allow-list for the lint script, a dry run of the install script and the read-only git commands;
  deny-list for force pushes and for reading the local settings file.
- `rules/mods.md`: loads when files under a `crn_*/` mod folder are touched. The Paradox script rules: prefixes,
  encodings, how vanilla files are overridden, how a load is verified.
- `skills/new-mod/SKILL.md`: `/new-mod <what it should do>` proposes names, emblem and accent, and on the
  owner's pick scaffolds the mod, its brand config and docs page, renders, lints and registers it. Calls
  `.claude/scripts/new-mod.sh` for the file creation.
- `skills/verify/SKILL.md`: `/verify [--logs-only] [mod]` lints, registers, waits for the owner to play, then
  has `log-triage` read the logs and reports what loaded and what the game rejected.
- `skills/add/SKILL.md`: `/add <kind> <what> in <mod>` adds a technology, building, trait, civic or any
  other content kind the vanilla way, with localisation, docs and a review. `skills/patch-bump/SKILL.md`:
  `/patch-bump [version]` moves every mod to a new game version and hunts for deprecated script.
  `skills/publish/SKILL.md`: `/publish <mod>` prepares a Workshop upload or update and records the item id.
  `skills/compat/SKILL.md`: `/compat <workshop id|folder|name>` reports collisions with another mod and the
  fix. `skills/loc-sync/SKILL.md`: `/loc-sync` regenerates the other languages from English.
  `skills/brand/SKILL.md`: `/brand render|emblem|accent|...` renders and shows the images, or designs a new
  emblem with `emblem-designer`.
- `agents/log-triage.md`: reads `error.log` and `game.log` through `scripts/logs.sh`, decodes every line that
  concerns us and traces it to a file. `agents/script-reviewer.md`: reviews script, localisation and descriptors
  in a diff or the working tree against the game's generated grammar and the rules in `CLAUDE.md`.
  `agents/docs-staleness.md`: lists the doc lines a change makes wrong (hard rule 6).
  `agents/vanilla-researcher.md`: read-only answers from the installed game and its generated docs.
  `agents/emblem-designer.md`: returns an emblem fragment within the brand's constraints; `/brand` writes it.
- `rules/brand.md`: loads when files under `brand/` or a thumbnail are touched: never edit a PNG, where the
  mark and emblems are edited, accents from the table.
- `scripts/new-mod.sh`: creates a mod folder, brand config and docs page from five arguments; `--dry-run`
  lists what it would write. The skills also call the repository's own `scripts/` (lint, install, render,
  logs, vanilla, bump, loc-sync, compat).

Adding a committed rule, agent or skill is a normal commit; adding a local one is just creating the `.local` file.
