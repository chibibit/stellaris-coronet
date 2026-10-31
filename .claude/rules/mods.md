---
paths:
  - "crn_*/**"
---

# Working inside a mod folder

- Every identifier this mod defines starts with `crn_`: file names, event namespaces, keys in `common/`,
  localisation keys, flags, variables, scripted triggers and effects. The game has one global namespace shared with
  every other loaded mod; a bare name collides silently.
- Never copy a vanilla file and edit it. Add a new file with a `crn_` name. Most `common/` folders merge by
  top-level key (last loaded wins), `on_actions` lists merge, and localisation keys are overridden from
  `localisation/replace/`. The few folders that need a whole-file override are named in the mod's page under
  `docs/mods/`, with the vanilla file name and the reason.
- Localisation files are `localisation/<language>/crn_<mod>_l_<language>.yml`, UTF-8 **with BOM**, first line
  `l_<language>:`, one space of indent. Plain UTF-8 is silently ignored by the game. `scripts/check.sh` verifies the BOM.
- Paradox script uses tabs, like vanilla. The reference for any key or effect is the vanilla file next to it, not
  memory: look in the game's `common/` and `events/` folders before writing.
- `descriptor.mod` carries `name`, `version` (this mod's own version, semver), `supported_version` (the game patch,
  `v<major>.<minor>.*`, identical in every mod), `tags`, `picture="thumbnail.png"`, `dependencies` naming
  `"Coronet: Core"` for every mod but Core, and after the first upload the `remote_file_id` the launcher adds.
  Never a `path=` line: `scripts/install.sh` adds it in the copy it writes for the launcher.
- Every mod sets a global flag `crn_<mod>_active` and writes a `log = "Coronet: <Name> loaded"` line on game start
  (see `crn_core/events/`), so a load is verified by grepping `game.log` and other mods can test for it.
- After a change: `scripts/check.sh`, then start the game and read `error.log` and `game.log` in the user folder.
  `supported_version` is bumped for every mod in one commit when the game patches.
