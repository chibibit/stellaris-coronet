# stellaris-coronet docs

| Section | What you find there |
|---|---|
| [development.md](development.md) | Working on the mods: tooling, how a mod is wired into the game, testing with the logs and the console, how the game merges files from several mods, version bumps, adding a new mod. |
| [mods/](mods/) | One page per mod: what it changes in the game, the files it ships, the vanilla files it overrides and why, what other mods can rely on. |
| [runbooks/](runbooks/) | Step-by-step operations: [install](runbooks/install.md) the mods from a clone, [publish](runbooks/publish.md) to the Steam Workshop, [put the repository on GitHub](runbooks/github-setup.md) with `ci`, labels and pull requests. |
| [decisions/](decisions/) | Architecture decision records. One decision per file, numbered, never rewritten: a later ADR supersedes an earlier one. |

Related files outside `docs/`:

- [`../README.md`](../README.md): the overview and entry point.
- [`../CLAUDE.md`](../CLAUDE.md): conventions for contributors and Claude Code.
- [`../brand/README.md`](../brand/README.md): the brand profile, and how thumbnails and Workshop images are rendered.

## Writing rules

- **Docs are always up to date.** A change that makes a page wrong updates that page in the same commit. There is
  no "later": hard rule 6 in `CLAUDE.md`.
- A doc answers one question; link instead of repeating. Procedure in a runbook, reasoning in an ADR, what a mod
  does in its mod page.
- Commands are complete and copy-paste ready for a Bash shell, with the directory they run from.
- Anything specific to one person's machine, drive letters, paths or current status is **not** documented here; it
  belongs in the gitignored `CLAUDE.local.md`.
- When a decision changes, add a new ADR that supersedes the old one and update the pages that depended on it.
