---
name: verify
description: Check the mods the way the game does. Lints, registers the mods with the launcher, waits for the owner to start a game, then reads error.log and game.log and reports every problem that concerns this family with its meaning and the file to fix. Use after any change to a mod, or on "check the logs".
allowed-tools: Read, Grep, Glob, Bash(scripts/check.sh:*), Bash(scripts/install.sh:*), Bash(scripts/logs.sh:*), Bash(git status:*), Bash(git diff:*), Agent
---

Verify the mods. `$ARGUMENTS` may be `--logs-only` (skip steps 1 and 2: the owner has already played) or the
name of one mod to focus the report on.

1. **Lint.** `scripts/check.sh`. On any error, stop and report it; the game would reject the same thing.
2. **Register.** `scripts/install.sh` when a `descriptor.mod` changed or a mod folder is new (`git status
   --short`); otherwise skip it, the game reads the folders in place.
3. **Hand over to the owner.** Note the current log times with `scripts/logs.sh fresh`, then tell the owner to
   start the game with the Coronet mods in the active playset, start or load a game, and say when they are done.
   Do not poll and do not try to launch the game; wait for their word. If they say the game is already running
   or just ran, continue.
4. **Triage.** `scripts/logs.sh fresh` again: if neither log is newer than before, say so and stop; the game did
   not start, or wrote nothing. Otherwise run the `log-triage` agent with the focus from the arguments and read
   its report.
5. **Report** in this order: which mods logged their `Coronet: <Name> loaded` line and which did not; every
   error that concerns us, each with the file and line in this repository, what the game objected to, and the
   fix; then the number of error lines that are not ours (the total `scripts/logs.sh errors` prints, minus the
   reported ones), for scale. End with one line: `all mods loaded, no errors` or
   what blocks. Do not fix anything in this skill; the owner decides what to change.
