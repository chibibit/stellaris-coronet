# ADR 0004: Brand assets are SVG sources rendered by script

- Status: accepted, 2026-10-31. Supersedes the last consequence of [ADR 0003](0003-bash-scripts.md) (thumbnails
  rendered by hand with .NET drawing APIs).

## Context

Every mod needs a `thumbnail.png` for the launcher and the Workshop, and a Workshop page wants a hero image. The
thumbnail carries the game version, so it changes with every patch, and the family should look the same across
all its mods while each mod stays recognisable. Hand-drawn PNGs drift, cannot be diffed, and have to be redone
per mod per patch. No vector tool is guaranteed on a clone, but a Chromium browser is on every Windows and most
developer machines, and `rsvg-convert` or Inkscape are a package away on Linux and macOS.

## Decision

The brand lives as SVG under `brand/`: the mark, the lockup, an emblem library, and templates with placeholders.
Each mod has a small config (`brand/mods/crn_<purpose>.conf`) naming its emblem, accent colour and tagline.
`scripts/brand.sh` fills the templates per mod from `descriptor.mod` and that config and renders the PNGs with
the first renderer it finds, falling back to a headless Chrome or Edge with a throwaway profile. Rendered PNGs
are committed, so a clone without a renderer still has them and the game always finds `thumbnail.png`.

## Consequences

- A new mod's images are a config file and one command. A game patch is one `supported_version` bump and one
  command for every thumbnail's version badge.
- The mark (ring, crown, corona) is fixed in one file. The wordmark is text in each template with the same
  face, colour and tracking, so a change to it touches every template. A mod's identity is its emblem and
  accent, chosen when the mod is named.
- Committed PNGs are derived files; a change to `brand/` without re-rendering is caught by review, not by a tool.
  `scripts/check.sh` fails on a thumbnail of 1 MB or more and warns when a thumbnail or a per-mod config is missing.
- Fonts are a soft dependency: the intended title face is Cinzel (Open Font License); without it the renderer
  falls back to Palatino Linotype or Georgia, which is acceptable for local use and should be fixed before a
  Workshop upload.
