# Coronet brand

The visual identity of the Coronet mod family. Everything here is source: SVG masters and templates that
`scripts/brand.sh` renders into the PNGs the launcher, the Steam Workshop and the web need. Edit the SVG, re-run
the script, never hand-edit a PNG.

## The idea

A coronet is a small crown. A star's corona is its crown. The mark is a star seen in eclipse: a gold ring for the
star's limb, five corona points on its upper arc forming a crown, faint rays below for the rest of the corona, and
a small bright star at the heart. It reads as a crown at a glance and as a star on a second look, which is the
whole brand in one shape, and it sits comfortably next to Stellaris' own dark, thin-lined interface.

Tone: stately, not cute; quiet, not loud. Gold on near-black, a single cool accent, generous letter-spacing,
nothing animated or glossy.

## Palette

| Token | Hex | Use |
|---|---|---|
| Void | `#0E1224` | The base of backgrounds, the emblem sheet, text on gold. The eclipse disc inside the mark is its own gradient, `#151B36` to `#090C18`. |
| Coronet gold | `#D6AC40` | The mark, the wordmark, rules and frames. The one colour that must appear. The ring carries a gradient from `#EFCB70` through gold to `#B58C2C` for depth. |
| Corona light | `#F3E3B0` | Jewels, emblems, highlights, the version badge text. Sparingly. |
| Signal teal | `#5CC8DC` | The default accent: subtitles, labels, links. Picks up the game's own UI blue. A mod may use another accent from the table below. |
| Ash | `#A9AFC3` | Body and secondary text on dark. |
| Ivory | `#F4F1EA` | Stars, primary text on dark when gold is too much. |

Backgrounds are never flat. The square images (thumbnail, collection) use a radial gradient from `#1F2B60` at
the glow centre through `#141A36` to `#090C18` at the edges, with two translucent haze ellipses in `#2E3F8A`
and `#1A2456` at 30 to 50 % opacity. The hero uses a diagonal gradient from `#182148` through Void to `#080A14`
with haze in `#2A3A84` and `#1E2A5E`. All get a faint gold halo behind the mark and a vignette of translucent
black at the corners. Those are the only navy tones.
Gold and teal never touch as text on each other; both sit on the background. No pure white; black appears only
as the translucent vignette.

## Typography

| Role | Font | Fallbacks | Notes |
|---|---|---|---|
| Wordmark and titles | Cinzel | Palatino Linotype, Georgia, serif | Upper case, letter-spacing 6 to 14 % of size. Cinzel (Open Font License) is the intended face; install it on the machine that renders, or the first fallback is used. Renders meant for the Workshop are made with Cinzel installed. |
| Labels and subtitles | Bahnschrift | Segoe UI, sans-serif | Upper case with wide tracking for subtitles; sentence case for taglines and body. |

The wordmark is always `CORONET` in the title face, gold, tracked. A mod's name under it is its purpose in the
label face, teal, tracked: `CORE`, `HABITATS`, never the full `Coronet: Core`.

## One family, one emblem per mod

The ring, the crown and the corona are the family and never change. What changes per mod is the emblem inside
the eclipse disc and the accent colour of its subtitle. That is enough for a mod to be recognised on its own and
still read as Coronet in a row of thumbnails.

- **Emblem**: a small glyph in Corona light inside the disc. Core carries the family's own heart star; every
  other mod picks one from `emblems/` or gets a custom one drawn on the same grid. Six are ready:
  `star` (the heart; Core), `orbit` (habitats, stations, megastructures), `hex` (technology, frameworks),
  `planet` (planets, colonies, districts), `ship` (ships, fleets, components), `beacon` (events, diplomacy, UI).
  `renders/emblem-sheet.png` shows them all inside the mark.
- **Accent**: one colour for the subtitle and labels, from this table. Two mods share an accent only when they are
  a pair.

| Accent | Hex | Suggested for |
|---|---|---|
| Signal teal | `#5CC8DC` | The framework (Core) and the family itself |
| Violet | `#9D8CFF` | Technology, research, psionics |
| Verdant | `#7FD69A` | Planets, biology, habitability |
| Rose | `#E58CA6` | Species, leaders, society |
| Ember | `#F0945A` | Ships, war, crises |
| Ice | `#BFD9F2` | Interface, utilities, quality of life |

Each mod's choice lives in `mods/crn_<purpose>.conf` (`emblem=`, `accent=`, `tagline=`; format in `mods/README.md`).
Gold is never used as an accent and the emblem is never recoloured: Corona light on Void is what makes it part of the mark.

## Files

| File | What |
|---|---|
| `coronet-mark.svg` | The mark alone, 200x200 grid, 20 units clear space. The group between the `mark:start` and `mark:end` comments is inlined into every template, so it carries its own defs; the block between `emblem:start` and `emblem:end` is what the per-mod emblem replaces. Edit the mark here only. |
| `coronet-logo-horizontal.svg` | Template for the horizontal lockup: mark plus wordmark on a transparent background, filled and rendered by the script to `renders/coronet-logo-horizontal-1600x400.png`, which is the file to use for README headers, Discord banners and forum signatures. |
| `emblems/*.svg` | The emblem library: SVG fragments on the mark's grid, inside radius 38 around (100,100). |
| `mods/crn_<purpose>.conf` | Per-mod emblem, accent and tagline. `mods/README.md` has the format. |
| `templates/thumbnail.svg` | 512x512 mod thumbnail: mark with the mod's emblem, wordmark, the mod's purpose in its accent, a game-version badge. Rendered to every `crn_*/thumbnail.png`. |
| `templates/workshop-hero.svg` | 1920x1080 hero image for a mod's Workshop page: first screenshot and description header. |
| `templates/collection.svg` | 1024x1024 family image: Workshop collection, repository avatar, Discord icon. |
| `renders/` | The rendered PNGs, committed so a clone without a renderer still has them: the family mark, lockup and collection image, the emblem sheet, and per mod its mark (512), its thumbnail (in the mod folder) and its hero. |
| `workshop/` | The Workshop page text per mod, `crn_<purpose>.txt` in Steam BBCode, drafted by `/publish` and committed. |

Template placeholders: `{{MARK}}` (the inlined mark, with the mod's emblem), `{{SUBTITLE}}` (purpose from the
mod's `name=`, upper case), `{{VERSION}}` (from `supported_version`, `v<major>.<minor>.*` becomes
`<major>.<minor>`), `{{TAGLINE}}`
(from the mod's conf). The accent replaces Signal teal wherever a template uses it.

## Rendering

```bash
scripts/brand.sh            # render everything: brand/renders/* and every crn_*/thumbnail.png
scripts/brand.sh --check    # say which renderer would be used and what would be rendered
```

In Claude Code, `/brand render` renders and shows the results, `/brand emblem <mod> <idea>` designs a new
emblem within the rules below and shows it in the sheet before it is kept, and `/brand accent <mod> <colour>`
changes an accent. `brand/workshop/` holds the Workshop page text per mod, drafted by `/publish`.

The script uses the first renderer it finds: `rsvg-convert`, Inkscape, ImageMagick, or a headless Chrome or
Edge (present on every Windows machine). Browser rendering uses a throwaway profile and never touches the user's
browser. Re-render after every game patch so the version badge is right, and after any change in `brand/`.

## Rules

- The mark is never recoloured, outlined, rotated, or put on a light background without the navy disc behind it.
- Minimum size: the mark 32 px, the horizontal lockup 160 px wide. Below that, use the mark alone.
- One thumbnail layout for every mod, differing only in emblem, accent, subtitle and badge, so the family is
  recognisable in Workshop search results at 200 px and each mod is recognisable on its own.
- A new mod gets its emblem and accent when it gets its name: a conf file in `mods/` before its first render.
- The version badge shows the game version the mod is built for, not the mod's own version.
- Screenshots on a Workshop page are real in-game captures; the hero image is the only composed image.
