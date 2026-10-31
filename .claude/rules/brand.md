---
paths:
  - "brand/**"
  - "crn_*/thumbnail.png"
---

# Working under brand/

- PNGs are derived files: never edit one, never draw one by hand. Change the SVG source and run
  `scripts/brand.sh`; commit the renders with the source change (ADR 0004).
- The mark is edited only in `brand/coronet-mark.svg`, between its `mark:start` and `mark:end` comments; the
  templates inline it. The block between `emblem:start` and `emblem:end` is what a mod's emblem replaces.
- Emblems are fragments on the 200-grid inside radius 38 around (100,100), in Corona light only, one idea each.
  New ones go through `/brand emblem` so the owner sees the render before it is kept.
- Accents come from the table in `brand/README.md`; gold is never an accent, and two mods share one only as a
  pair. A mod's choices live in `brand/mods/crn_<purpose>.conf`.
- The thumbnail's version badge comes from `supported_version`; after a game patch, re-render.
- A thumbnail must stay under 1 MB; `scripts/check.sh` fails otherwise.
- Fonts: the title face is Cinzel with Palatino Linotype and Georgia as fallbacks; do not introduce another.
