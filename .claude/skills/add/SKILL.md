---
name: add
description: Add a piece of game content (a technology, building, district, job, trait, civic, origin, policy, edict, tradition, ascension perk, ship part, megastructure, deposit, anomaly, situation, resource...) to a Coronet mod, with its localisation and docs, following the vanilla definition of the same kind. Use when the owner asks for new content in a mod.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(scripts/vanilla.sh:*), Bash(scripts/logs.sh:*), Bash(scripts/check.sh:*), Bash(scripts/loc-sync.sh:*), Bash(git status:*), Agent
---

Add the content described by `$ARGUMENTS` (the kind of thing, what it should do, and the mod it belongs in;
ask for the mod when there is more than one and it is not named).

1. **Learn the shape.** Read the recipe for this kind in `local/knowledge/04-content-types.md` when it exists,
   then confirm it against the real thing: `scripts/vanilla.sh ls common/<folder>` and `scripts/vanilla.sh cat`
   a small vanilla definition of the same kind, and `scripts/logs.sh grep '^<key>' modifiers` for every
   modifier key you intend to use. The vanilla file is the truth where the recipe disagrees. Note the
   localisation keys the kind implies (`<key>`, `<key>_desc`, `_plural` for some kinds) and the icon the kind
   expects (folder, file name pattern or `GFX_` sprite, size).
2. **Plan, briefly.** Say which files you will create or change, every key and localisation key, the icon that
   is needed and that you will not draw it, and how the thing is unlocked (prerequisites, `potential`,
   `possible`, weights). Keep it short; wait for the owner's go only when the plan involves a choice they must
   make (a vanilla override, a cost, a name).
3. **Write.** New files only, named `crn_<mod>_<topic>.txt`, every key prefixed `crn_` (hard rule 1), tabs,
   a comment above each definition saying what it is for in the game. Localisation into the mod's
   `crn_<mod>_l_english.yml`, then `scripts/loc-sync.sh` for the other languages. An icon that does not exist
   yet gets a note in the mod's page under "Files" naming the path and size it needs, so it is not forgotten.
4. **Check.** `scripts/check.sh`, then the `script-reviewer` agent on the working tree; fix what it blocks.
5. **Docs.** The mod's page under `docs/mods/`: what the thing changes in the game, the files, any vanilla
   override (hard rule 6).
6. **Report** what was added, the keys, the icon still needed, and that `/verify` is the next step. Do not commit.
