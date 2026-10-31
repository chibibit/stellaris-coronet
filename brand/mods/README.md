# Per-mod brand configuration

One `crn_<purpose>.conf` per mod, read by `scripts/brand.sh`:

| Key | Meaning | Default |
|---|---|---|
| `tagline` | One line under the subtitle on the mod's Workshop hero image. At most 60 characters; no quotes, `&`, `<`, `>`, `\|` or backslashes. | empty, with a warning |
| `emblem` | Name of a file in `../emblems/` (without `.svg`), or a path relative to the repository root to a custom emblem fragment. It replaces the heart star inside the mark. | `star` |
| `accent` | Hex colour for the subtitle and labels. Pick from the accent table in `../README.md`; two mods should not share one unless they are a pair. | `#5CC8DC` |

An emblem fragment is SVG markup (no `<svg>` wrapper) on the mark's 200x200 grid, fitting inside radius 38
around (100,100), drawn in Corona light `#F3E3B0`. See the files in `../emblems/`.
