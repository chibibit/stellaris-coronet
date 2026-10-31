# ADR 0001: One repository for the whole family

- Status: accepted, 2026-10-30. The first consequence is extended by
  [ADR 0004](0004-brand-assets-are-rendered-from-svg.md): a new mod also gets a brand config under `brand/mods/`.

## Context

Stellaris modders on GitHub use two layouts. Large published mods (Gigastructural Engineering, StarNet, the
Idrinth and OldEnt collections) use one repository per mod with the mod folder at the repository root, because
every template, validator and Workshop-upload action assumes it and users can clone straight into the game's mod
folder. Personal collections of five to twenty-five mods almost all use one repository with a folder per mod,
because the mods share tooling, reference each other and are maintained by one person.

Coronet starts from zero, with one owner, a shared Core mod that the others depend on, shared scripts and docs,
and a common prefix. The costs people report for the single-repository layout are duplicated per-mod scripts and
launcher-written absolute paths leaking into commits.

## Decision

One repository, `stellaris-coronet`, holding every Coronet mod as a top-level `crn_<purpose>/` folder. Shared
scripts live once in `scripts/`, shared conventions once in `CLAUDE.md`, and the launcher descriptors are never
committed (ADR 0002), which removes both reported costs.

## Consequences

- A new mod is a new folder, a page under `docs/mods/` and a row in `README.md`; nothing else to set up.
- `supported_version` moves for every mod in one commit (hard rule 7); the family tracks one game version.
- Workshop uploads are per mod and manual (the launcher), since upload automation assumes one mod per repository.
  If a mod grows collaborators or needs automated releases, its folder is split out into its own repository; the
  folder is already a complete mod, so that is a move, not a rewrite.
- Users cannot `git clone` straight into the game's mod folder; they run `scripts/install.sh` instead.
