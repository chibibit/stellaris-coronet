# ADR 0003: Scripts are Bash and run on every platform the game runs on

- Status: accepted, 2026-10-30. The last consequence below is superseded by
  [ADR 0004](0004-brand-assets-are-rendered-from-svg.md): images are rendered by `scripts/brand.sh`.

## Context

Stellaris runs on Windows, Linux and macOS and the user folder is in a different place on each. Anyone who
clones this repository has git, and on Windows that means Git for Windows, which ships Bash; Linux and macOS
have it already. A PowerShell or batch script would work on one platform only and would need a twin for the
others, and two scripts for one task drift apart.

## Decision

Every script in `scripts/` is Bash: LF line endings, executable bit set, no drive letters or backslashes in the
code. Platform differences (the user folder, the path form the game expects) are handled inside the script by
checking `uname` and using `cygpath` on Windows. No PowerShell, no batch files, no platform-specific twins.

## Consequences

- One script per task under `scripts/` serves Windows (Git Bash), Linux and macOS. The platform differences
  every script needs (path forms, the game's user folder, file times) live in `scripts/lib.sh`; a lookup only
  one script needs (browser locations, Steam roots) stays next to its use.
- Windows users need Git for Windows, which they have if they cloned the repository.
- One-off Windows chores that have no Bash equivalent, such as rendering a thumbnail with .NET drawing APIs, are
  done by hand and not kept as scripts in the repository.
