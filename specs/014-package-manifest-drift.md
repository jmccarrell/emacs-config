# 014 — Close the one-way gap between `jwm/required-packages` and `~/.emacs.d/elpa`

*Drafted by Claude at Jeff's request ("write spec 014"), like 013 and unlike specs 001–012
which are Jeff's own briefs. Edit freely — this is a proposal, not a record of intent.*

## The ask

Make the package manifest authoritative in **both** directions. Today it only installs.

## What happened

Emacs printed this at every start:

```
Unable to activate package ‘counsel-projectile’.
Required package ‘projectile-2.5.0’ is unavailable
```

`projectile` was uninstalled when built-in `project.el` replaced it (the reason is recorded
at `jeff-emacs-config.org:960`: the 2026 MELPA snapshot dropped `projectile-global-mode`).
`counsel-projectile` was not — nothing removed it, because nothing ever removes anything.
It sat on disk with an unsatisfiable dependency, failing activation on every start.

An audit found it was not alone: **36 of 95 installed packages** were outside the transitive
closure of `jwm/required-packages`. Whole abandoned stacks — ivy/counsel, elpy, the ELPA
tree-sitter packages, Ruby — plus 2023 ELPA copies of `use-package` and `bind-key` that were
*shadowing Emacs 30.2's built-in versions*. All 36 have been deleted; `package-activate-all`
is now silent and `just verify-tangle` passes. **This spec is about the mechanism, not the
mess** — the mess is already cleaned up.

## Root cause

`jwm/required-packages` (`jeff-emacs-config.org:216`) is a genuinely good design — an
explicit manifest, decoupled from `package-selected-packages` for a documented and correct
reason (`:211`). But `just install-packages` only ever runs it forwards:

```
manifest ──install what's missing──▶ disk
manifest ◀────────── nothing ────────  disk
```

Drop a name from the manifest and the package lives on disk forever. There is no reverse
edge, and no check that would notice its absence.

Two aggravating factors:

- **The failure is a `message`, not a warning.** It scrolls past in `*Messages*` during a
  noisy startup. This one went unnoticed long enough that nobody can date it.
- **`M-x package-autoremove` cannot help.** It reads `package-selected-packages`, which in
  `settings.el` is a stale Custom value still listing `counsel-projectile`, `elpy`,
  `flycheck` and friends. It would have protected every orphan it was asked to remove.

## What the reference configs do

Audited all 14 tracked repos (the 6 that were inventory-only have been cloned; see
"Inventory" below). Two are single packages rather than configs, leaving 12.

**Headline: not one of them detects orphans.** No `package-autoremove` call, no
`straight-remove-unused-repos`, no prune step, no audit. Every hit for "orphan" or "prune"
across the corpus was org-agenda tasks or text-punctuation helpers.

### Additive `package-selected-packages` — purcell, munen

Purcell independently diagnosed **the same custom-file ordering bug** documented at
`jeff-emacs-config.org:211`, and reached the same `after-init-hook` workaround
(`steve-purcell-dotemacs/lisp/init-elpa.el:73`). Independent convergence is a good sign for
that mechanism.

But the implementation defeats itself (`:112`):

```elisp
(package--save-selected-packages
 (seq-uniq (append sanityinc/required-packages package-selected-packages)))
```

It **unions** with the saved value. Munen's `(add-to-list 'package-selected-packages p)`
(`munen-emacs.d/configuration.org:213`) has the same shape. Both make `package-autoremove`
*safe* — it will not delete something they need — but never *effective*: the saved list only
grows, so a package dropped from the config stays "selected" forever. That is precisely this
bug, relocated one level up.

### Declarative managers — abo-abo, andreyorst, minemacs, matthewzmd, yqrashawn

straight.el-based configs come closest, but none actually closes the loop:

- **minemacs** has the most machinery of anyone: version lockfiles via
  `straight-thaw-versions`, and `+straight-prune-build-cache`
  (`abougouffa-minemacs/core/me-bootstrap.el:169`). But `straight-prune-build` (`:172`)
  prunes *build artifacts*, not source repos — `straight/repos/` still accumulates.
- **abo-abo** uses `straight-use-package` but never calls a prune function; the capability
  sits unused in the tool.
- **yqrashawn** looked like the structural answer — a Nix flake with `emacs-overlay` and a
  `sysdo gc` for unused store paths. It is not: Nix builds the *binary*, while packages come
  from Doom + straight (`.doom.d/packages.el`). The Nix GC never reaches them.

### The one real precedent: `doom sync`

yqrashawn's `.doom.d/packages.el:4` states the model in its header comment — declare
packages in this file, then run `doom sync`. Doom's sync **reconciles disk to declaration in
both directions**, installing and purging in one command, and it is the *routine* command you
run after every edit rather than a cleanup you must remember.

That is the design lesson worth taking, and it is more important than any specific API:
**put the reverse edge on the path already travelled.** Purcell and munen both built the
right mechanism and then wired it additively; minemacs built prune machinery and pointed it
at the wrong artifact. The failure mode across the corpus is not ignorance of the problem —
it is a reconcile step that is optional, partial, or off the routine path.

### Tangential but relevant

abo-abo's `straight-built-in-pseudo-packages` (`abo-abo-dotemacs/packages.el:124`)
explicitly enumerates names that must resolve to Emacs's built-in copy rather than a fetched
one. That is the same hazard class as the `use-package`/`bind-key` shadowing found here,
handled declaratively. Worth remembering if the manifest ever grows a name that core later
absorbs — which is exactly how those two became stale.

## Design decisions

### 1. Assign `package-selected-packages`, do not append

On `after-init-hook`:

```elisp
(setq package-selected-packages jwm/required-packages)
```

Purcell's mechanism without the union that neuters it. This makes `M-x package-autoremove`
correct in both directions: the manifest is the top-level wanted set, and `package-autoremove`
computes the dependency closure itself — so the value assigned is the *manifest*, not the
closure.

`after-init-hook` is the right moment for the reason purcell documents and
`jeff-emacs-config.org:211` already records: the custom-file loads at `init.el:19`, long
before, so the manifest wins and the stale `settings.el` value stops mattering at runtime.

### 2. Plain `setq`, not `package--save-selected-packages`

Purcell guards with `(when (fboundp 'package--save-selected-packages))` and persists. Do
neither. That function is private *and* writes to custom-file; `package-autoremove` only
reads the variable, so persisting buys nothing and would keep churning `settings.el`.

Consequence worth stating: `settings.el:19` keeps its stale list on disk, now permanently
overridden at runtime. Cleaning it is optional and cosmetic — decide during implementation
whether to hand-edit it once or leave it as Custom's business.

### 3. Add `just audit-packages` — detection, separate from repair

`package-autoremove` is interactive-only and silent by default. It fixes drift once you
already suspect it; it never tells you drift exists. A batch check does, is agent- and
CI-runnable, and is what would have caught `counsel-projectile` the day `projectile` was
uninstalled.

No reference config has this, so it is additive rather than cargo-culted. It should report:

- **orphans** — installed but outside the manifest closure
- **missing** — in the manifest but not installed
- **broken deps** — any installed package with an unsatisfiable requirement

Non-zero exit if any category is non-empty. The audit script written during this
investigation already does all three and is the obvious starting point.

### 4. Do **not** fold the audit into `verify-tangle`

`verify-tangle` is a *repo* check — it must pass on any machine from a clean checkout.
Package state is *machine* state. Folding them together means `verify-tangle` starts failing
on a machine that is merely behind on `just install-packages`, which trains you to ignore it.
Keep them separate recipes.

### 5. Do not migrate to straight.el or elpaca

They solve this structurally, and the audit above is not an argument for them — every
straight-based config in the corpus has the same accumulating-orphans problem, just in
`straight/repos/` instead of `elpa/`. A whole-config migration to fix a once-in-a-few-years
annoyance is a bad trade when the manifest already captures most of the benefit.

## Sketch

```elisp
;; near the manifest in jeff-emacs-config.org
(add-hook 'after-init-hook
          (lambda ()
            ;; Assign, don't append: this is the *authoritative* wanted set, so
            ;; `package-autoremove' can see what is no longer wanted. Runs after
            ;; init so it beats the stale custom-file value loaded at startup.
            (setq package-selected-packages jwm/required-packages)))
```

```make
# literate-emacs.d/justfile
audit-packages:
    emacs --batch -l etc/audit-packages.el
```

Unresolved in the sketch, to settle during implementation:

- **Where the audit's elisp lives.** Inline in the justfile recipe (matches
  `install-packages`, which inlines `--eval` forms) versus a tracked `.el` file (readable,
  testable, but a new file and a new convention). Leaning toward a tracked file — the
  closure computation is ~30 lines and does not read well as a shell-quoted `--eval`.
- **How the audit reads the manifest.** The investigation script parsed the `defvar` form
  out of `init.el` textually to avoid loading the whole config. Loading `init.el` in batch
  is simpler and `install-packages` already does it inside a `condition-case`. Prefer the
  latter if it proves reliable.
- **Whether `package-autoremove` should be reachable from the justfile.** It is interactive
  and prompts; a batch equivalent means calling `package-delete` directly, which is a
  destructive recipe. Possibly not worth it once the audit exists to tell you to run
  `M-x package-autoremove`.
- **Whether to warn loudly on activation failure.** An `after-init-hook` check that raises a
  visible warning instead of a `message` would have surfaced this years earlier. Cheap, but
  it overlaps with the audit and may just be noise. Undecided.

## Verification plan

1. Fresh `emacs --batch -f package-activate-all` → silent. (Baseline; true as of the
   cleanup.)
2. `just audit-packages` on the current, just-pruned machine → clean, exit 0.
3. Remove a leaf package from the manifest, tangle, re-run `just audit-packages` → reports
   exactly that package as an orphan, exit non-zero. Restore.
4. Hand-install a package not in the manifest → audit reports it; `M-x package-autoremove`
   offers exactly it; accepting removes it and the audit goes clean.
5. Delete an installed manifest package's directory → audit reports it under *missing*, not
   orphans.
6. `C-h v package-selected-packages` in live Emacs → equals `jwm/required-packages`, not the
   stale `settings.el` list.
7. `just verify-tangle` still passes, and still passes on a machine whose packages are
   deliberately out of date (confirms decision 4).

## Doc updates this implies

- `literate-emacs.d/CLAUDE.md` — document `just audit-packages` alongside `just tangle` /
  `just verify-tangle`, and state the separation in decision 4 so nobody later "helpfully"
  merges them.
- `emacs-config/CLAUDE.md` § Multi-machine workflow — the prune is per-machine state. Other
  machines still carry all 36 orphans; add running the audit (and `package-autoremove`) to
  the per-machine list, next to the symlink target and `approvals.toml`.
- `jeff-emacs-config.org` near `:211` — that comment explains why the manifest is *not*
  `package-selected-packages`. Once decision 1 lands, both statements are true at once and
  the comment needs a sentence explaining the split: the manifest is the source of truth,
  and it is *pushed into* `package-selected-packages` after init so `package-autoremove`
  works.
- `reference-configs.md` — add a "package management" note per repo for the practices found
  above. This is the first investigation to look at the corpus through that lens, and none
  of the existing per-repo sections mention it.

## Inventory

Six tracked repos were registered but never cloned locally, so earlier analyses silently
covered 8 of 14. All six are now cloned and `reference-repos.list` is refreshed.

Two entries changed that were **not** part of this clone batch — `abo-abo-dotemacs`
(`b17e90e0` → `0c5f3284`) and `andreyorst-dotfiles` (`-` → `eb1e3615`). Their local checkouts
had drifted ahead of the recorded analysis SHA before this work started. `ref-update-inventory`
captures local HEAD by contract, so the refresh advanced them. For `andreyorst` that is a pure
gain (it had no SHA at all). For `abo-abo` it advances a "last analyzed" marker on the strength
of a narrow package-management read, not a full re-analysis — worth a deliberate look at
`b17e90e0..0c5f3284` before trusting the marker.

Separately, six *cloned* directories are absent from the inventory: `ebzzry-dotfiles`,
`editorconfig-emacs`, `greendog-gtd`, `howardabrams-dot-files`, `sirpscl-emacs.d`,
`smartparens`. Two are single packages rather than configs. Registering or removing them is
out of scope here but should not be left indefinitely.

## Out of scope

- Migrating package management to straight.el / elpaca / Nix (decision 5).
- Version pinning or a lockfile. minemacs demonstrates it works, but reproducible *versions*
  are a different problem from orphaned *packages*, and the manifest currently pins nothing
  by design.
- The stale `package-selected-packages` value physically in `settings.el` — overridden at
  runtime by decision 1, cosmetic thereafter.
