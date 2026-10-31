# Runbook: install the mods from a clone

Registers every `crn_*/` folder with the Paradox launcher so the game loads it from the checkout. Run from the
repository root in a Bash shell (Git Bash on Windows).

## Steps

1. Close the Paradox launcher and the game. The launcher caches descriptors and can overwrite one written while it runs.
2. Check and register:

   ```bash
   scripts/check.sh
   scripts/install.sh
   ```

   `install.sh` writes `<user folder>/mod/<mod>.mod` for each mod: the mod's `descriptor.mod` plus a `path=` line
   pointing at this checkout. To see what it would write without touching anything: `scripts/install.sh --dry-run`.
   If the user folder is somewhere unusual, set `STELLARIS_USER_DIR` to it.
3. Start the launcher. Under Mods the Coronet mods appear as local mods. Add them to a playset, Core first.
4. Start a game. In the user folder, `logs/game.log` contains `Coronet: Core loaded`; `logs/error.log` contains
   no line mentioning `crn_`.

Re-run `scripts/install.sh` after any change to a `descriptor.mod` (the launcher copy carries the same fields)
and after adding a mod folder. Editing script, events or localisation needs no re-run: the game reads the folder.

## Remove

```bash
scripts/install.sh --remove
```

Deletes the descriptors the script wrote. The repository is untouched; the launcher forgets the mods on its next start.

## Troubleshooting

- **The mod is not in the launcher.** The launcher was open while `install.sh` ran, or the path in the descriptor
  is wrong. Close the launcher, `scripts/install.sh --dry-run` to see the path, run it again.
- **The mod shows but does not load.** A mod present both as a local folder and as a Workshop subscription is
  refused; unsubscribe one. A symlinked folder lists but does not load; this repository does not use links.
- **Nothing in `game.log`.** The mod is not in the active playset, or `error.log` has a parse error in the events
  or on_actions file that stopped it. Search `error.log` for `crn_`.
- **Localisation shows as raw keys.** The `.yml` lacks the UTF-8 BOM or the `l_english:` header. `scripts/check.sh` reports both.
