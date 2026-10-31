# Runbook: put the repository on GitHub

One-time steps by the repository owner. Nothing here is needed to play or develop the mods locally; it is what
makes `ci`, labels and pull requests work.

## Repository

1. Create the repository on GitHub **empty** (no README, licence or gitignore; private or public, the files are
   written to be safe either way). Add it as `origin` and push `master` as the first branch:

   ```bash
   git remote add origin <url>
   git push -u origin master
   ```

   The default branch must be `master`, which everything here assumes (the `ci` push trigger, the ruleset).
   An empty repository takes the first pushed branch as its default. If GitHub created a `main`
   anyway, switch and delete it:

   ```bash
   gh repo edit --default-branch master
   git push origin --delete main
   ```
2. Labels. The repository has exactly the nine from `CLAUDE.md`, "Labels", with these descriptions and colours;
   GitHub's default labels are deleted so nothing overlaps. With `gh` (or by hand on the Labels page):

   ```bash
   gh label create mod       --color 1d76db --force --description "Type: new content or behaviour inside a crn_* mod folder"
   gh label create fix       --color d73a4a --force --description "Type: a bug fix inside a crn_* mod folder"
   gh label create tooling   --color 5319e7 --force --description "Type: scripts/, .claude/, .github/ or CLAUDE.md; how the repository is worked on"
   gh label create docs      --color 0075ca --force --description "Type: documentation only (docs/, README.md, brand/README.md wording)"
   gh label create chore     --color bfdadc --force --description "Type: renders, generated localisation, version bumps, configuration; no behaviour change"
   gh label create idea      --color fbca04 --force --description "State: a proposal not yet agreed; always with a type label; nobody starts work while it is on"
   gh label create question  --color d876e3 --force --description "Further information is requested"
   gh label create duplicate --color cfd3d7 --force --description "This issue or pull request already exists"
   gh label create wontfix   --color ffffff --force --description "This will not be worked on"
   for l in bug enhancement documentation "good first issue" "help wanted" invalid accessibility; do gh label delete "$l" --yes; done
   ```

3. Protect `master` with a ruleset (Settings, Rules, Rulesets, New branch ruleset, target the default branch):
   require a pull request before merging, require the `ci` status checks to pass, and allow squash merging
   only (Settings, General, Pull Requests: untick merge commits and rebase merging).
## After every change to a workflow file

A pull request runs its own branch's copy of `ci.yml`, and so does a manual run started with `--ref <branch>`;
the push trigger and a manual run without `--ref` use the file on `master`, so a workflow change reaches those
only once it is merged.
