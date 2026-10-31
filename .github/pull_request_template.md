## Summary

<!-- What this changes in the game or in the repository, and why, in two to four sentences a reviewer can
     read without opening the diff. Link the issue if there is one: "Closes #123".
     Label this pull request with the issue's type label (mod, fix, tooling, docs or chore), the same one the
     branch prefix comes from; a pull request without an issue still gets exactly one type label. -->

## Changes

<!-- The notable changes as a short list, grouped where it helps (crn_core, crn_<purpose>, brand, scripts,
     docs, .claude). Leave out trivia. Name any vanilla file this overrides. -->

## How it was verified

<!-- Exactly what was run and the result: `scripts/check.sh`, `scripts/loc-sync.sh --check`, and the game:
     which `Coronet: <Name> loaded` lines appeared and whether `error.log` had anything of ours. Then say
     plainly what was NOT verified, for example "not played past game start" or "not tested next to
     Gigastructures". -->

## Review focus

<!-- Where to look hardest: a key that collides with vanilla, a file name that changes load order, a scope that
     might be wrong, a performance-sensitive trigger, an override. "Nothing unusual" is a valid answer. -->

## After merge

<!-- What has to be done by hand once this is merged: re-run `scripts/install.sh`, re-render with
     `scripts/brand.sh`, a Workshop upload with `/publish`. "Nothing" if merging is enough. -->

## Checklist

- [ ] `scripts/check.sh` and `scripts/loc-sync.sh --check` pass
- [ ] Docs updated in this PR, or none affected
- [ ] Exactly one type label (`mod`, `fix`, `tooling`, `docs`, `chore`), matching the branch prefix
