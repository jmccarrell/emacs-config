# 014 — Detect package manifest drift, and deliberately not automate the fix

*Drafted by Claude at Jeff's request ("write spec 014"), like 013 and unlike specs 001–012
which are Jeff's own briefs. Edit freely — this is a proposal, not a record of intent.*

*Revised after Jeff pushed back on the first draft: twelve reference configs declining to
solve a problem is evidence about the problem, not about them. The first draft recommended
making `M-x package-autoremove` authoritative. This one argues against that and recommends
detection only. The reasoning is in § Why not automate the fix.*

## The ask

Notice when the package manifest and `~/.emacs.d/elpa` disagree. Do not act on it
automatically.

## What happened

Emacs printed this at every start:

```
Unable to activate package ‘counsel-projectile’.
Required package ‘projectile-2.5.0’ is unavailable
```

`projectile` was uninstalled when built-in `project.el` replaced it (the reason is recorded
at `jeff-emacs-config.org:960`: the 2026 MELPA snapshot dropped `projectile-global-mode`).
`counsel-projectile` was not — nothing removed it, because nothing ever removes anything. It
sat on disk with an unsatisfiable dependency, failing activation on every start.

An audit found it was not alone: **36 of 95 installed packages** were outside the transitive
closure of `jwm/required-packages`. Whole abandoned stacks — ivy/counsel, elpy, the ELPA
tree-sitter packages, Ruby — plus 2023 ELPA copies of `use-package` and `bind-key` that were
*shadowing Emacs 30.2's built-in versions*.

All 36 have been deleted. `package-activate-all` is now silent and `just verify-tangle`
passes. **This spec is about the mechanism, not the mess** — the mess is already cleaned up.

### How that cleanup was verified, and what it did not cover

Each candidate was checked for reachability from the config: no deleted package is
`require`d, named in `:commands` or `:bind`, or referenced in a keybinding. The only
`require` that matched was `use-package`, which now resolves to
`/Applications/Emacs.app/…/lisp/use-package/use-package.elc`.

What that does **not** cover is interactive-only use. `rg`, `ag`, `macrostep`,
`imenu-anywhere`, `direx`, `psession` and `smartparens` are all plausibly invoked by hand
without ever appearing in `init.el`, and `just verify-tangle` batch-loads `init.el` — it
never exercises a deferred `:config` block or an autoloaded command.

The mitigating fact is that none of the 36 was in `jwm/required-packages`, so no fresh
machine has had them since the manifest was written. They were survivors of an earlier era
on this machine only. Recorded here because it is a real limit on the verification, not a
hypothetical one.

## Root cause

`jwm/required-packages` (`jeff-emacs-config.org:216`) is a genuinely good design — an
explicit manifest, decoupled from `package-selected-packages` for a documented and correct
reason (`:211`). But `just install-packages` only ever runs it forwards:

```
manifest ──install what's missing──▶ disk
manifest ◀────────── nothing ────────  disk
```

Drop a name from the manifest and the package lives on disk forever. There is no reverse
edge, and nothing that would notice.

Two aggravating factors:

- **The failure is a `message`, not a warning.** It scrolls past in `*Messages*` during a
  noisy startup. This one went unnoticed long enough that nobody can date it.
- **`M-x package-autoremove` could not have helped.** It reads `package-selected-packages`,
  which in `settings.el` is a stale Custom value still listing `counsel-projectile`, `elpy`,
  `flycheck` and friends. It would have protected every orphan it was asked to remove.

The second point is what the first draft of this spec tried to fix. See below for why that
was the wrong conclusion.

## What the reference configs do

All 14 tracked repos were audited (the 6 that were inventory-only have been cloned; see
§ Inventory). Two are single packages rather than configs, leaving 12.

**None of them automates orphan removal.** State that precisely, because the obvious
stronger claim is not supported: `package-autoremove` is an *interactive* command, and
grepping tracked source cannot show whether purcell runs it monthly. What the audit
establishes is that nobody commits automation for it — not that nobody prunes.

### The pattern: safe, deliberately not effective

Purcell independently diagnosed **the same custom-file ordering bug** documented at
`jeff-emacs-config.org:211`, and reached the same `after-init-hook` workaround
(`steve-purcell-dotemacs/lisp/init-elpa.el:73`). Then he wired it like this (`:112`):

```elisp
(package--save-selected-packages
 (seq-uniq (append sanityinc/required-packages package-selected-packages)))
```

It **unions** with the saved value, so the list only ever grows. Munen's
`(add-to-list 'package-selected-packages p)` (`munen-emacs.d/configuration.org:213`) is the
same shape.

The first draft of this spec called that self-defeating. It is better read as a **ratchet
that can only protect more**: `package-autoremove` stays safe to run, and never becomes
sharp enough to delete something the config forgot to declare. That is a deliberate position
on a cost asymmetry, not an oversight — and the fact that both configs bother to maintain
`package-selected-packages` at all is circumstantial evidence they *do* prune by hand, with
the ratchet as the guard rail.

### Declarative managers do not close the loop either

- **minemacs** has the most machinery of anyone: version lockfiles via
  `straight-thaw-versions`, and `+straight-prune-build-cache`
  (`abougouffa-minemacs/core/me-bootstrap.el:169`). But `straight-prune-build` (`:172`)
  prunes *build artifacts*, not source repos — `straight/repos/` still accumulates.
- **abo-abo** uses `straight-use-package` but never calls a prune function.
- **yqrashawn** looks like the structural answer — a Nix flake with `emacs-overlay` and a
  `sysdo gc` for unused store paths. It is not: Nix builds the *binary*, while packages come
  from Doom + straight (`.doom.d/packages.el`). The Nix GC never reaches them.

`doom sync` (`.doom.d/packages.el:4`) is the one tool in the corpus that reconciles both
directions in a single routine command. Worth knowing it exists; it is also a whole
framework, not a technique that transplants.

## Why not automate the fix

Twelve configs declining to solve a problem is evidence about the problem. Three specific
dangers, in ascending order of how badly the first draft got them wrong.

### 1. The asymmetry favours leaving orphans alone

An orphan costs disk and a `message`. A wrongly-removed package costs a broken config —
possibly discovered days later, in the middle of something else. The corpus consistently
picks the cheap failure. The first draft picked the expensive one and described the
alternative as a defect.

### 2. It changes what a manifest omission costs

Today `jwm/required-packages` is a **provisioning list**. Leave something out and a fresh
machine underinstalls: loud, obvious, one `package-install` to recover.

Assign `package-selected-packages` from it and the same omission makes `package-autoremove`
offer to **delete a package you actively use**. Identical human error, inverted blast radius.

This is not theoretical. The manifest has a documented incomplete category, in its own
comment at `jeff-emacs-config.org:213–215`: packages reached via `require` or a nested
`use-package` "aren't auto-derived — add them here by hand," with `yasnippet-snippets` cited
as the case that already caught this once. Making the manifest a deletion authority arms
exactly that footgun.

### 3. Deliberate undeclared packages are a normal steady state

`M-x package-install some-thing` to try it out is healthy behaviour. Under a naive design
that package is instantly an "orphan": the audit exits non-zero and `package-autoremove`
proposes deleting it. An alarm that fires during ordinary experimentation is ignored within
a month — the same trap as folding the audit into `verify-tangle`, one level up.

A real config's steady state *includes* undeclared packages. Twelve configs tolerating
orphans may be twelve configs where that is simply true.

## Design decisions

### 1. Detect; do not delete

Report drift. Let the human act. Detection has no blast radius, which is the entire reason
it is separable from the dangers above.

### 2. Add `just audit-packages`

`package-autoremove` is interactive-only and silent by default: it repairs drift once you
already suspect it, and never tells you drift exists. A batch check does, is agent- and
CI-runnable, and would have caught `counsel-projectile` the day `projectile` was uninstalled.

No reference config has this. It should report three categories separately:

- **broken deps** — any installed package with an unsatisfiable requirement. *This is the
  one that matters.* It is the actual observed failure, it is unambiguous, and it cannot be
  triggered by benign experimentation.
- **missing** — in the manifest, not installed. Means this machine is behind on
  `just install-packages`.
- **orphans** — installed, outside the manifest closure. Informational.

Non-zero exit on **broken deps only**. Orphans and missing print but do not fail; per
§ Why not automate the fix #3, an orphan is frequently correct.

### 3. An escape hatch for deliberate undeclared installs

Even as pure reporting, an orphan list that includes every package being trialled is noise
that trains you to skim. Add a second list — `jwm/extra-packages` or similar — for packages
knowingly installed outside the manifest. Not installed by `install-packages`; only
suppressed from the orphan report.

This is a real addition rather than a caveat: without it, decision 2's orphan category
decays into the thing decision 5 exists to prevent.

### 4. **Rejected:** assign `package-selected-packages` from the manifest

The first draft's headline recommendation:

```elisp
(add-hook 'after-init-hook
          (lambda () (setq package-selected-packages jwm/required-packages)))
```

Rejected for the three reasons in § Why not automate the fix. Recorded rather than deleted
because it is the obvious idea, purcell's code looks like an endorsement of it at a glance,
and the next person to have it deserves the argument rather than the rediscovery.

It could be reconsidered if the manifest were ever *derived* rather than hand-maintained —
tangled from the `use-package` forms themselves, so the incomplete-by-hand category
disappears. That is a different and much larger piece of work, and it is the actual
precondition, not "be careful."

### 5. Do **not** fold the audit into `verify-tangle`

`verify-tangle` is a *repo* check — it must pass on any machine from a clean checkout.
Package state is *machine* state. Folding them means `verify-tangle` starts failing on a
machine merely behind on `just install-packages`, which trains you to ignore it.

### 6. Do not migrate to straight.el or elpaca

The audit is not an argument for them: every straight-based config in the corpus has the
same accumulating-orphans problem, relocated to `straight/repos/`. A whole-config migration
to fix a once-in-a-few-years annoyance is a bad trade.

## Sketch

```make
# literate-emacs.d/justfile
audit-packages:
    emacs --batch -l etc/audit-packages.el
```

Unresolved, to settle during implementation:

- **Where the audit's elisp lives.** Inline in the recipe (matches `install-packages`, which
  inlines `--eval` forms) versus a tracked `.el` file. Leaning toward a tracked file — the
  closure computation is ~30 lines and does not read well shell-quoted.
- **How the audit reads the manifest.** The investigation script parsed the `defvar` out of
  `init.el` textually to avoid loading the whole config. Loading `init.el` in batch is
  simpler and `install-packages` already does it inside a `condition-case`. Prefer the
  latter if it proves reliable.
- **Where `jwm/extra-packages` lives.** Beside the manifest in the org file makes it
  reviewable and cross-machine; but it is inherently per-machine state (a package trialled
  on the laptop is not trialled on the desktop). Possibly it belongs in `settings.el` or an
  untracked file instead. Undecided, and decision 3 depends on getting it right.
- **Whether to warn loudly on activation failure.** An `after-init-hook` check raising a
  visible warning instead of a `message` would have surfaced this years earlier — and unlike
  everything in § Why not automate the fix, it only *reports*. Cheap. Probably yes, but it
  overlaps with the audit's broken-deps category.

## Verification plan

1. `emacs --batch -f package-activate-all` → silent. (Baseline; true as of the cleanup.)
2. `just audit-packages` on this just-pruned machine → clean, exit 0.
3. Hand-install a package not in the manifest → listed under **orphans**, exit still 0.
   Add it to `jwm/extra-packages` → disappears from the report.
4. Delete an installed manifest package's directory → reported under **missing**, not
   orphans, exit still 0.
5. Reproduce the original failure: install a package whose dependency is absent → reported
   under **broken deps**, exit **non-zero**. This is the regression test for the actual bug.
6. `just verify-tangle` still passes on a machine whose packages are deliberately out of
   date (confirms decision 5).

## Doc updates this implies

- `literate-emacs.d/CLAUDE.md` — document `just audit-packages` alongside `just tangle` /
  `just verify-tangle`, including decision 5's separation so nobody later merges them, and
  decision 2's exit-code split so a non-zero exit keeps meaning something.
- `emacs-config/CLAUDE.md` § Multi-machine workflow — the prune was per-machine. Other
  machines still carry all 36 orphans; add the audit to the per-machine list, beside the
  symlink target and `approvals.toml`.
- `reference-configs.md` — add a package-management note per repo. This is the first
  investigation to look at the corpus through that lens, and the finding worth recording is
  the asymmetry in § Why not automate the fix, not a list of who lacks what.
- **No change to `jeff-emacs-config.org:211`.** The first draft would have needed one; with
  decision 4 rejected, that comment stays exactly as true as it was.

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

- Making `package-autoremove` authoritative (decision 4) — rejected, with reasoning, above.
- Deriving the manifest from the `use-package` forms. This is the one change that would make
  decision 4 safe, and it is the interesting follow-on, but it is a much larger piece of work
  than a detection recipe.
- Migrating package management to straight.el / elpaca / Nix (decision 6).
- Version pinning or a lockfile. minemacs shows it works, but reproducible *versions* are a
  different problem from orphaned *packages*.
- The stale `package-selected-packages` value in `settings.el`. With decision 4 rejected
  nothing overrides it at runtime, so it stays wrong — inert, since nothing reads it unless
  you run `package-autoremove`, which this spec now recommends against relying on. Worth a
  one-time hand-edit sometime.
