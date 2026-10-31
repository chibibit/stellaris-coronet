# stellaris-coronet

The Coronet family of mods for Stellaris. One repository, one folder per mod, and the game reads the mod folders
straight from the checkout: no build, no copying. Every mod carries the `crn_` prefix on everything it defines, so
the family never collides with vanilla or with other mods.

Scripts are Bash and run from Git Bash on Windows as well as Linux and macOS
([ADR 0003](docs/decisions/0003-bash-scripts.md)).

## The mods

| Mod | Workshop title | What it does |
|---|---|---|
| `crn_core` | Coronet: Core | The shared framework. Sets the `crn_core_active` global flag and logs `Coronet: Core loaded` on game start; later holds the scripted triggers, effects and icons the other Coronet mods share. Every other Coronet mod depends on it. [Page](docs/mods/crn_core.md). |

## Documentation map

| You want to | Read |
|---|---|
| Set up the tooling, test a change, understand how the game merges mod files | [docs/development.md](docs/development.md) |
| Get the mods into the launcher from a fresh clone | [docs/runbooks/install.md](docs/runbooks/install.md) |
| Upload or update a mod on the Steam Workshop | [docs/runbooks/publish.md](docs/runbooks/publish.md) |
| See what a mod changes and which vanilla files it overrides | [docs/mods/](docs/mods/) |
| Know why a decision was made | [docs/decisions/](docs/decisions/) |
| Use the logo, pick an emblem and accent for a new mod, render the images | [brand/README.md](brand/README.md) |
| Name a mod, a file or a key; branch; label an issue; open a pull request | [CLAUDE.md](CLAUDE.md) |
| Put the repository on GitHub, set up `ci`, labels and pull requests | [docs/runbooks/github-setup.md](docs/runbooks/github-setup.md) |
| Add a Claude Code rule, agent or skill | [.claude/README.md](.claude/README.md) |

Index of everything in `docs/`: [docs/README.md](docs/README.md).

## Quick start

From a Bash shell (Git Bash on Windows), with Stellaris installed and started at least once:

```bash
git clone <this repository> stellaris-coronet && cd stellaris-coronet
scripts/check.sh          # lint the mod folders
scripts/install.sh        # register every mod with the Paradox launcher (close the launcher first)
```

Then start the launcher, open Mods, add the Coronet mods to a playset, and start a game. The line
`Coronet: Core loaded` in `game.log` in the game's user folder confirms the load; `error.log` lists anything the
game rejected. Full steps and the log locations per platform: [install runbook](docs/runbooks/install.md).

## Layout

| Path | What |
|---|---|
| `crn_<purpose>/` | One complete mod per folder: `descriptor.mod`, `thumbnail.png`, and the game's own structure (`common/`, `events/`, `localisation/`, ...). |
| `docs/` | Development guide, one page per mod, runbooks, ADRs. |
| `brand/` | The Coronet visual identity: SVG masters, emblem library, templates, per-mod config, rendered images, Workshop page text. [Brand profile](brand/README.md). |
| `scripts/` | `check.sh` (lint), `install.sh` (register with the launcher), `brand.sh` (render thumbnails and Workshop images), `logs.sh` (read the game's logs), `vanilla.sh` (find and search the game install), `loc-sync.sh` (other languages from English), `bump.sh` (new game version), `compat.sh` (collisions with another mod), `lib.sh` (shared helpers). Bash only. |
| `.claude/` | Claude Code project configuration. |
| `.github/` | The `ci` workflow and the pull request template. |
