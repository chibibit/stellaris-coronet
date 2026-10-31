# stellaris-coronet — conventions for Claude Code and contributors

The Coronet family of Stellaris mods: one repository, one folder per mod, each folder a complete mod the game loads
straight from this checkout. `README.md` is the overview; installing, testing and publishing are in `docs/`.

## Check and install

```bash
scripts/check.sh      # lint: descriptors, crn_ prefixes, localisation encoding, line endings, thumbnails
scripts/install.sh    # register every mod with the launcher (writes <mod>.mod into the game's mod folder)
scripts/brand.sh      # render every mod's thumbnail and Workshop images from the SVG masters in brand/
scripts/logs.sh       # read the game's logs for our lines, and search its generated script documentation
scripts/vanilla.sh    # locate and search the game install and subscribed Workshop mods
scripts/loc-sync.sh   # generate the other languages' localisation files from the English ones
scripts/bump.sh       # set supported_version in every descriptor after a game patch
scripts/compat.sh     # report collisions with another mod (files, keys, event ids)
```

- `scripts/check.sh` must pass before a commit. All scripts run in any Bash: Git Bash on Windows, Linux, macOS.
- Thumbnails and Workshop images are never drawn by hand: `brand/` holds the SVG sources and per-mod emblem,
  accent and tagline, `scripts/brand.sh` renders them. See `brand/README.md`.
- There is no build step. The game reads the mod folders in place, so a change is live on the next game start
  (localisation also on `reload text` from the console).
- Verifying a change means starting the game and reading `error.log` and `game.log` in the game's user folder;
  every Coronet mod writes a `Coronet: <Name> loaded` line there on game start. See `docs/development.md`.

## Documentation: what goes where

| File | Contains | Checked in |
|---|---|---|
| `CLAUDE.md` (this file) | Conventions that hold for every clone: check/install, where docs go, hard rules, naming, layout, script style, branches, labels and ideas, pull requests. | yes |
| `README.md` | Overview and entry point: what this is, the mods, where to look, quick start. | yes |
| `docs/` | The documentation proper: `development.md` (tooling, testing, how the game merges files), `mods/` (one page per mod: what it changes, which vanilla files it overrides and why), `runbooks/` (step-by-step: install, publish, GitHub set-up), `decisions/` (ADRs, numbered, superseded rather than edited). Index in `docs/README.md`. | yes |
| `brand/README.md`, `brand/mods/README.md`, `brand/workshop/README.md` | The brand profile (idea, palette, type, emblems, accents, rules, rendering) and the formats of the per-mod config and the Workshop page text. | yes |
| `CLAUDE.local.md` | The owner's machine: game install and user folder paths, editor set-up, current status, open questions, scratch notes. | no (gitignored) |
| `.claude/settings.json`, `.claude/rules/*.md`, `.claude/skills/*/SKILL.md`, `.claude/agents/*.md`, `.claude/scripts/*.sh`, `.mcp.json` | Shared Claude Code configuration: permissions, path-scoped rules, skills, subagents, the helper the skills call, project MCP servers. | yes |
| `.github/` | The `ci` workflow and the pull request template. | yes |
| anything under `.claude/` with a `.local` or `-local` name part | Personal Claude Code configuration. | no (gitignored) |
| `local/` | Local-only working files, and under `local/knowledge/` optional reference notes on Stellaris modding that the skills and agents read when the folder exists. A clone works without it. | no (gitignored) |

Layout and conventions for `.claude/` are in `.claude/README.md`.

Keep them in sync when something changes: a new rule goes here, a new procedure goes in a runbook, a new or changed
mod goes in its page under `docs/mods/`, a changed decision gets a new ADR, and anything about one person's machine,
drive letters or current status goes in `CLAUDE.local.md`. Never copy local-only facts into the checked-in files,
and never name a person in them: write "the repository owner". The repo is written to be safe to publish: no user
names, host names or local paths. Workshop item ids are public and fine.

Every `CLAUDE.md` has a sibling `CLAUDE.local.md` in the same directory (gitignored at any depth). If a subfolder
ever gets its own `CLAUDE.md`, create its `CLAUDE.local.md` at the same time, even if it starts nearly empty.

## Hard rules

1. **Everything is prefixed `crn_`.** File names, event namespaces, every key defined under `common/`, localisation
   keys, flags, variables, scripted triggers and effects. Stellaris has one global namespace shared with every
   other loaded mod and a collision fails silently. The only exception is a deliberate whole-file override, which
   keeps the vanilla file name and is listed in the mod's page under `docs/mods/` with the reason.
2. **Never copy a vanilla file and edit it.** Add a new `crn_` file; most folders merge by top-level key and
   `on_actions` lists merge. Overriding a whole file is the last resort of rule 1.
3. **Localisation is UTF-8 with BOM**, named `crn_<mod>_l_<language>.yml` under `localisation/<language>/`, first
   line `l_<language>:`. The game silently drops a file without the BOM; `scripts/check.sh` catches it.
   English is the source; the other languages are generated from it by `scripts/loc-sync.sh` and committed with
   every change to the English file, so no player ever sees a raw key.
4. **Scripts are Bash and cross-platform.** `scripts/*.sh`, LF line endings, executable bit set, no PowerShell or
   batch files, no drive letters or `\` separators in the scripts. They run from Git Bash on Windows as well as
   Linux and macOS. See `docs/decisions/0003-bash-scripts.md`.
5. **Nothing machine-specific is checked in.** `descriptor.mod` never has a `path=` line; `scripts/install.sh`
   adds it in the launcher's copy. Local paths live in `CLAUDE.local.md`. See `docs/decisions/0002-descriptors-generated-not-linked.md`.
6. **Docs are always up to date.** A change that makes a doc wrong updates that doc in the same commit: the mod's
   page for what it changes, a runbook for a procedure, a new ADR for a changed decision, `README.md` for the
   overview. "Update docs later" is not an option.
7. **One game version for the whole family.** `supported_version` is the same in every `descriptor.mod` and is
   bumped for all mods in one commit when the game patches. Each mod's own `version=` is semver and moves with its
   Workshop upload.

## Naming

The brand is **Coronet** and the prefix is `crn_`:

| Thing | Pattern | Example |
|---|---|---|
| Mod folder | `crn_<purpose>` | `crn_core` |
| Workshop title (`name=` in `descriptor.mod`) | `Coronet: <Purpose>` | `Coronet: Core` |
| Script and localisation files | `crn_<purpose>_<topic>.<ext>` | `crn_core_events.txt`, `crn_core_l_english.yml` |
| Event namespace | the mod folder name | `namespace = crn_core`, events `crn_core.1` |
| Global flag announcing the mod | `crn_<purpose>_active` | `crn_core_active` |
| Any other key | `crn_<purpose>_<name>` | `crn_core_some_trigger` |

A new mod gets its name before it is built: propose two or three options to the repository owner and let them
choose. Do not invent one. Vanilla terms, DLC names and other mods' names are not reused. With the name come its
emblem and accent colour (`brand/README.md`), recorded in `brand/mods/crn_<purpose>.conf`.

## Layout

| Path | What |
|---|---|
| `crn_core/` | Coronet: Core. The shared framework: the `crn_core_active` flag and the load log line; later the scripted triggers, effects and icons other Coronet mods share. Every other Coronet mod lists it in `dependencies`. |
| `crn_<purpose>/` | One folder per further mod, each a complete mod: `descriptor.mod`, `thumbnail.png`, and the game's own folder structure (`common/`, `events/`, `localisation/`, `gfx/`, `interface/`). |
| `docs/` | Development guide, one page per mod, runbooks, ADRs. Index in `docs/README.md`. |
| `brand/` | The visual identity: palette, type, the mark and lockup as SVG, the emblem library, templates, per-mod `mods/crn_<purpose>.conf`, the rendered PNGs under `renders/`, and the Workshop page text under `workshop/`. `brand/README.md` is the brand profile. |
| `scripts/` | Bash only. `check.sh` (lint), `install.sh` (register the mods with the launcher), `brand.sh` (render thumbnails and Workshop images), `logs.sh` (read the game's logs and generated script docs), `vanilla.sh` (find and search the game install and Workshop mods), `loc-sync.sh` (generate the other languages), `bump.sh` (new game version), `compat.sh` (collisions with another mod), `lib.sh` (shared helpers the others source: platform, paths, the game's user folder). |
| `.claude/` | Claude Code project config: the skills (`/new-mod`, `/add`, `/verify`, `/patch-bump`, `/publish`, `/compat`, `/loc-sync`, `/brand`), the agents (`log-triage`, `script-reviewer`, `docs-staleness`, `vanilla-researcher`, `emblem-designer`), rules, the helper script the skills call. Committed vs `.local` convention in `.claude/README.md`. |
| `.github/` | `workflows/ci.yml` (lint, localisation check, shell scripts, the no-trailer gate) and `pull_request_template.md`. |

## Script style

- Tabs, like vanilla. One definition per block, a comment above it saying what it is for in the game, not what the
  syntax does.
- The reference for every effect, trigger and key is the vanilla file next to it in the game's `common/` and
  `events/` folders, not memory. Check it before writing.
- Every mod has one `on_game_start` event that sets its `crn_<purpose>_active` flag and writes
  `log = "Coronet: <Purpose> loaded"`. That line in `game.log` is the proof the mod loaded.
- Localisation keys are defined once, in the mod that owns the thing they describe.

## Branches, issues and labels

### Branches

`master` is the only long-lived branch. Work happens on short-lived branches created from an up-to-date `master`
and deleted after merge, named `<prefix>/<short-description>`: lowercase, words separated by hyphens, the issue
number first when there is one. Examples: `mod/12-core-scripted-triggers`, `tooling/compat-report`.

| Prefix | What goes on it |
|---|---|
| `mod/` | A change inside a `crn_*/` folder: new content, new behaviour. |
| `fix/` | A bug fix inside a `crn_*/` folder. |
| `tooling/` | `scripts/`, `.claude/`, `.github/`, `CLAUDE.md`: anything that changes how the repository is worked on. |
| `docs/` | Documentation only: `docs/`, `README.md`, `brand/README.md` wording. |
| `chore/` | Renders, generated localisation, version bumps, editor and git configuration with no behaviour change. |

The prefix follows the main change. Docs the change makes wrong are updated on the same branch (hard rule 6);
that does not make it a `docs/` branch. Two unrelated changes are two branches. Something noticed along the way
that does not fit the branch name becomes an `idea` issue (below), not a commit on this branch.

A commit is one concern and its message says what changed in the game, not which files were edited. Commit
messages carry no attribution trailers: no `Co-Authored-By`, no "generated with" line; `ci` rejects them. A
local agent commits only when the repository owner asks, and never pushes on its own.

### Labels

The repository has exactly nine labels; GitHub's defaults (`bug`, `enhancement`, `documentation`, `good first
issue`, `help wanted`, `invalid`, `accessibility`) were removed so that nothing overlaps. The colours are the
ones below; the one-line descriptions shown on GitHub are the ones `docs/runbooks/github-setup.md` sets, which
also recreates the set.

Every issue carries exactly one **type label**, named after a branch prefix. The branch for the issue uses that
prefix, and the pull request gets the same label.

| Type label | Colour | Use it when the work is |
|---|---|---|
| `mod` | `#1d76db` | New content or behaviour inside a `crn_*/` folder: a technology, a building, an event, a new mod. |
| `fix` | `#d73a4a` | Something inside a `crn_*/` folder that does not work as its page says: a wrong scope, a missing key, a broken trigger. |
| `tooling` | `#5319e7` | `scripts/`, `.claude/`, `.github/` or `CLAUDE.md`: how the repository is worked on, including the skills, agents and workflows. |
| `docs` | `#0075ca` | Documentation only: `docs/`, `README.md`, `brand/README.md` wording. A doc change that rides along with a `mod` change is not `docs`. |
| `chore` | `#bfdadc` | No behaviour change: re-rendered images, regenerated localisation, a game-version bump, editor or git configuration. |

Next to the type label an issue can carry one **state label**:

| State label | Colour | Meaning |
|---|---|---|
| `idea` | `#fbca04` | A proposal that is not yet agreed work. Always combined with a type label, never alone; nobody starts work while it is on. |
| `question` | `#d876e3` | Needs an answer from the repository owner before work can start. |
| `duplicate` | `#cfd3d7` | Already covered by another issue or pull request; link it and close. |
| `wontfix` | `#ffffff` | Will not be worked on; say why when closing. |

### Ideas

An idea is an issue labelled `idea` plus the type label of the work it would become. Nobody starts work on an
issue that still carries `idea`. When the repository owner accepts it, the `idea` label comes off; the type
label gives the branch its prefix. Something that comes up while working on a branch and falls outside its
name is opened as a new `idea` issue, linking back to where it came up.

Work on an issue happens in a local Claude Code session or by hand, never by an agent running on GitHub: there
is no coding-agent workflow in this repository, because a runner has no game to verify a mod with.

### What enforces this

The prefixes and labels are a convention; nothing enforces them. Protection of `master` itself (pull request
required, `ci` required) is a GitHub ruleset the repository owner sets (`docs/runbooks/github-setup.md`).

## Pull requests

- Branch from `master`, one concern per PR, `ci` must be green (it runs on every pull request), the repository
  owner merges.
- A PR is always **squash merged**: one commit on `master` per PR, with the PR title as its message, and no
  trailer.
- Every PR description follows `.github/pull_request_template.md`. It is written for the human who reviews: a
  summary readable without the diff, what was actually run, what was **not** verified, and where to look
  hardest. Never claim a check that was not performed; a mod that was not started in the game says so.
- Every PR carries exactly one type label, the same one as its issue and branch prefix; the template's
  checklist asks for it.
- Before a PR is opened from a local session, the `script-reviewer` and `docs-staleness` agents have run on
  the branch and their blocking findings are fixed.
- What goes into the template depends on the branch prefix:

  | Prefix | How it was verified | After merge |
  |---|---|---|
  | `mod/`, `fix/` | lint, localisation check, and the game: the load lines and `error.log`, or "not played" | `scripts/install.sh` if a descriptor changed; `/publish` when it is ready for the Workshop |
  | `tooling/` | one real invocation of the changed script, skill, agent or workflow and what happened | usually "Nothing" |
  | `docs/`, `chore/` | links and commands checked; lint | usually "Nothing", stated explicitly |
