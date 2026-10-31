# Runbook: publish a mod to the Steam Workshop

Uploads go through the Paradox launcher. The first upload of a mod creates its Workshop item and gives it a
`remote_file_id`; every later upload updates that item. In Claude Code, `/publish <mod>` runs the checks,
bumps the version, drafts the page text into `brand/workshop/<mod>.txt` and records the id afterwards; the
launcher steps below stay yours.

## Before an upload

1. `scripts/check.sh` passes and the mod has been played from this checkout with no `crn_` lines in `error.log`.
2. `descriptor.mod` has the right `version` (bumped for this upload), `supported_version`, up to ten `tags` from
   the launcher's list, and `picture="thumbnail.png"` with the file present.
3. `scripts/brand.sh` has been run since the last change to `supported_version` or `brand/`, so the thumbnail's
   version badge is current and `brand/renders/crn_<purpose>-workshop-hero-1920x1080.png` exists for the page.
4. The mod's page under `docs/mods/` matches what is being uploaded.
5. Steam is running and Steam Cloud is enabled for Stellaris; the launcher needs it to upload.

## First upload

1. Open the launcher, Mods, Mod tools, Upload mod.
2. Select the mod, choose Steam Workshop, upload.
3. Steam opens the new Workshop page: set visibility (start hidden or friends-only until it is tested), write the
   description, tick the agreement. Upload the mod's hero image from `brand/renders/` as the first screenshot
   and real in-game captures after it. For a Workshop collection of the family, use
   `brand/renders/coronet-collection-1024.png`.
4. The launcher writes `remote_file_id` into the descriptor. If it lands in the repository's `descriptor.mod`,
   commit it: the id is public and other tooling reads it from there. If it only landed in the launcher copy under
   the user folder, copy the line into `descriptor.mod` by hand and re-run `scripts/install.sh`.
5. Update the Workshop section of the mod's page under `docs/mods/` with the item id.

## Update an existing mod

1. Bump `version` in `descriptor.mod`; re-run `scripts/install.sh` so the launcher copy matches.
2. Launcher, Mods, Mod tools, Upload mod, select the mod. Press "Fetch Info" first so the launcher refreshes the
   item details from Steam, then upload.
3. Post a changelog on the Workshop page.

## Known limits

- Uploading from a folder outside the user folder (this repository's set-up) is documented as allowed and loading
  works, but the first real upload is the proof. If the launcher refuses, create a directory junction inside
  `<user folder>/mod/` that points at the mod folder (on Windows `mklink /J`, never a symlink) and upload from that.
- Automated uploads with `steamcmd` from CI need an existing `remote_file_id` and a dedicated Steam account with
  cached Steam Guard; not set up for this repository.
