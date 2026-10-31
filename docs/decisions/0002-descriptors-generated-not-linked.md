# ADR 0002: Launcher descriptors are generated, not linked or copied

- Status: accepted, 2026-10-30

## Context

The game finds a mod through a `.mod` file in the user folder's `mod/` directory whose `path=` line names the
mod folder. Three ways to connect a git checkout to it are in use:

- Clone or copy the mod into `mod/` itself. Simple, but the checkout then lives inside the game's user folder,
  one mod per clone, and a copy step has to be repeated after every change.
- A directory junction or symlink from `mod/<name>` to the checkout. The wiki's recommendation; junctions work,
  symlinks list but do not load, and the `.mod` file still has to be written by hand.
- A `.mod` file with an absolute `path=` to the checkout. The wiki documents the path as absolute or relative;
  the launcher itself writes absolute paths, including to other drives, for Workshop subscriptions.

A committed `.mod` file would carry one machine's path, which hard rule 5 forbids.

## Decision

`descriptor.mod` in each mod folder is the single source and never contains `path=`. `scripts/install.sh` writes
the launcher's `.mod` copy from it, adding the absolute `path=` to this checkout, for every mod in one run. Nothing
is linked or copied; the game reads the checkout.

## Consequences

- A fresh clone needs one command to be playable; the repository stays free of local paths.
- Script, event and localisation changes are live on the next game start. Only a changed `descriptor.mod` needs
  the script re-run.
- The first Workshop upload from a folder outside the user folder is untested. If the launcher refuses, the
  fallback is a junction (never a symlink) under `mod/` for the upload only; this ADR is then revisited.
- `remote_file_id`, which the launcher adds after an upload, belongs in the committed `descriptor.mod`: it is
  public and identifies the Workshop item.
