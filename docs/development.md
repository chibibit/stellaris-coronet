# Development

## Requirements

- Stellaris, started at least once so the game's user folder exists. The mods target the game version in
  `supported_version` of every `descriptor.mod`.
- A Bash shell: Git Bash on Windows, or any shell on Linux and macOS ([ADR 0003](decisions/0003-bash-scripts.md)).
- An editor with Paradox script support. VS Code with the CWTools extension (`tboby.cwtools-vscode`) gives
  validation, scope checking and completion. Put this in the workspace's `.vscode/settings.json` (gitignored):

  ```json
  {
    "cwtools.rules_version": "latest",
    "[yaml]": { "files.encoding": "utf8bom" },
    "files.eol": "\n"
  }
  ```

  `latest` follows the rules repository's commits, which track current game patches; `stable` follows its tags,
  which lag. The encoding setting keeps localisation files valid when VS Code creates or re-saves them.
- Optional: Irony Mod Manager, a launcher replacement with a conflict solver that shows which mods touch the same
  keys. It can also generate the launcher descriptors itself, but `scripts/install.sh` is the way this repository does it.

## Where things are

| What | Windows | Linux | macOS |
|---|---|---|---|
| Game user folder | `Documents\Paradox Interactive\Stellaris` | `~/.local/share/Paradox Interactive/Stellaris` | `~/Documents/Paradox Interactive/Stellaris` |
| Launcher descriptors | `<user folder>/mod/*.mod` | same | same |
| Logs | `<user folder>/logs/error.log`, `game.log` | same | same |
| Vanilla reference files | `<game install>/common`, `events`, `localisation`, `interface` | same | same |

## How a mod is wired into the game

A mod is a folder with the game's own structure and a `descriptor.mod` at its root. The launcher learns about it
from a second copy of that descriptor in the user folder's `mod/` directory, which has one extra line: `path=`,
the absolute location of the folder. `scripts/install.sh` writes that copy for every `crn_*/` folder, so the game
reads the files straight out of this checkout and a change is live on the next game start
([ADR 0002](decisions/0002-descriptors-generated-not-linked.md)).

`descriptor.mod` keys:

| Key | Meaning |
|---|---|
| `name` | The title the launcher and the Workshop show: `Coronet: <Purpose>`. |
| `version` | This mod's own version, semver. Moves with its Workshop upload. |
| `supported_version` | The game patch, `v<major>.<minor>.*`. The launcher only flags a mismatch; the game still loads it. Same in every Coronet mod (hard rule 7). |
| `tags` | Up to ten, from the launcher's own list (`Gameplay`, `Utilities`, `Balance`, `Graphics`, ...). A tag not on the list can block an upload. |
| `picture` | Always `thumbnail.png`, in the mod folder. |
| `dependencies` | Mods that must load before this one, by their `name`. Every Coronet mod except Core lists `"Coronet: Core"`. |
| `remote_file_id` | Added by the launcher after the first Workshop upload. Public, keep it. |

Never `path=` in the repository copy; `scripts/check.sh` rejects it.

## Testing a change

1. `scripts/check.sh` from the repository root. Its header lists exactly what it checks: descriptors, the
   `crn_` prefix, localisation encoding and headers, line endings, the thumbnail and its size limit, the
   per-mod brand config.
2. Start the game with the mod in the active playset. Add `-debug_mode` to the launch options (Steam: game
   properties, launch options) for extra logging and the debug tooltips.
3. Read the logs in the user folder, by hand or with `scripts/logs.sh`:
   - `error.log`: every file or key the game rejected. `scripts/logs.sh errors` prints the lines that concern
     us; an empty list is the goal.
   - `game.log`: every Coronet mod writes `Coronet: <Purpose> loaded` on game start. That line is the proof the
     mod loaded and its on_action fired; `scripts/logs.sh loaded` prints them.
   - The game also rewrites `logs/script_documentation/` on every start: `effects.log`, `triggers.log`,
     `scopes.log`, `modifiers.log` and `localizations.log` list exactly what this build accepts.
     `scripts/logs.sh grep '^set_global_flag' effects` is the quickest way to check an effect, its scopes and
     its syntax. It beats the wiki, whose modding pages lag the game by years.
   In Claude Code, `/verify` runs the lint, waits for a play session and reports the logs decoded.
4. In game, the console (`` ` `` or Shift+Alt+C, not in Ironman) helps iterate:
   - `reload text`: reload localisation without restarting.
   - `event crn_core.1`: fire an event by id.
   - `debugtooltip`: show ids and keys on hover.
   - `effect <script>` and `trigger <file>`: run script directly.

Any console command and any gameplay mod disable achievements for that save. That is expected.

## How the game merges files from several mods

Files load in alphabetical order of file name across vanilla and every active mod. Two files with the same name:
the later one replaces the earlier wholesale. Two files with different names defining the same top-level key:
depends on the folder. Most of `common/` keeps the last definition loaded, `on_actions` lists are merged, events
keep the first definition, and a handful of folders need a whole-file override. The per-folder table is on the
Stellaris wiki's Modding page; it is community-maintained and occasionally stale, so when it matters, test.

The Coronet rule is: never a vanilla file name, always a new `crn_` file, and a whole-file override only when the
folder leaves no choice, documented in the mod's page under `mods/` with the reason.

Localisation: a key defined in `localisation/replace/` wins over every other definition, which is the way to
change vanilla text. Keys defined elsewhere follow load order.

## Localisation in other languages

The game has no fallback language: a player on German sees raw keys for every string that has no German
file. `scripts/loc-sync.sh` writes the nine other languages from each English file (same text, the right
header, the BOM, a marker line saying it is generated) and `--check` reports stale ones. Commit the generated
files with the change to the English file. A real translation replaces the generated file and drops the
marker; the script then leaves it alone. In Claude Code, `/loc-sync`.

## Checking against another mod

`scripts/compat.sh <workshop id or folder>` lists the files both mods ship at the same path, the keys both
define in the same folder with who wins under the sort rule, the event ids both use, and the on_actions both
add to; `scripts/vanilla.sh workshop-list` gives the ids of the subscribed mods. In Claude Code, `/compat`
interprets the report and proposes the fix.

## GitHub Actions

One workflow lives in `.github/workflows/`. `ci` runs on every push to `master`, every pull request, and by
hand (`gh workflow run ci --ref <branch>`): the lint, the localisation check, a pass over the scripts
(executable bit, LF endings, `bash -n`, shellcheck), and a gate that fails on any commit carrying an
attribution trailer. It has no game and no renderer, so it cannot play a mod or check the renders; that stays
local (`/verify`, `/brand`). There is no coding-agent workflow: a runner cannot verify a mod, so issues are
worked on in a local Claude Code session or by hand. The one-time GitHub set-up is in
[runbooks/github-setup.md](runbooks/github-setup.md).

## When the game patches

1. Read the patch notes' modding section.
2. `scripts/bump.sh 'v<major>.<minor>.*'` sets `supported_version` in every `descriptor.mod`; one commit.
3. Start the game once so `logs/script_documentation/` describes the new build, then search it for the
   effects and triggers the mods use: deprecations are marked there.
4. Run every mod, read `error.log`, fix what broke. Renamed vanilla keys and restructured definitions are the
   usual breakage between minor versions.
5. `scripts/brand.sh` (the thumbnail badge carries the version) and `scripts/install.sh` (so do the launcher
   copies).

In Claude Code, `/patch-bump` does steps 2 and 5, and the search of step 3 once you have started the game on
the new build; it lists the deprecated constructs it finds. Step 4 is `/verify` and your fixes.

## Images

Every mod's `thumbnail.png` and its Workshop images are rendered, not drawn: `brand/` holds the SVG masters,
the emblem library and a config per mod; `scripts/brand.sh` renders them with the first SVG renderer it finds
(`rsvg-convert`, Inkscape, ImageMagick, or headless Chrome or Edge, which every Windows machine has). Re-run it
after a game patch, because the thumbnail carries a game-version badge, and after any change under `brand/`.
The brand profile, palette, emblems and accents are in [`brand/README.md`](../brand/README.md).

## Adding a mod

In Claude Code, `/new-mod <what it should do>` does steps 1 to 4 and the lint and install of step 5 after the
name is chosen; starting the game and confirming the log line is `/verify`. By hand:

1. Pick the name with the repository owner (`CLAUDE.md`, Naming), and with it an emblem and accent from
   `brand/README.md`.
2. Create `crn_<purpose>/` with `descriptor.mod` (copy `crn_core/descriptor.mod`, change `name`, add
   `dependencies={ "Coronet: Core" }`) and the load event under `events/` plus its `on_actions` entry (copy the
   Core ones and rename).
3. Create `brand/mods/crn_<purpose>.conf` with `tagline`, `emblem` and `accent`, then `scripts/brand.sh` to
   render its thumbnail and Workshop images.
4. Add the page `docs/mods/crn_<purpose>.md` and the row in `README.md`.
5. `scripts/check.sh`, `scripts/install.sh`, start the game, confirm the log line.
