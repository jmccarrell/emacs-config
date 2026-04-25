# Reference Emacs configs — synthesis

This file is the canonical record of which other developers' Emacs configs we
treat as ground-truth references during investigations, and what we've
already extracted from each. It is committed to the workspace repo and
travels with the project. The actual cloned repos in
`reference-emacs-configs/` are a per-machine cache, rebuildable from the
inventory in `reference-repos.list` via `just ref-show-plan`.

**Last refreshed:** 2026-04-25 (all 5 actively-analyzed repos resynced to
upstream HEAD).

## Inventory vs. synthesis

The inventory in `reference-repos.list` tracks **all 14 repos** currently on
disk, with last-known-SHAs for change detection. This synthesis file covers
the **5 we actively analyze** (HIGH/MEDIUM tier) — they're the ones whose
patterns we extract into our own config.

The other 9 repos (abo-abo-dotemacs, andreyorst-dotfiles, danielmai-dotemacs,
ebzzry-dotfiles, editorconfig-emacs, greendog-gtd, howardabrams-dot-files,
sirpscl-emacs.d, smartparens) are tracked in inventory for state preservation
but are not subjects of ongoing investigation. Any of them can be promoted
to active analysis by adding a section here; the inventory tooling already
snapshots their state.

## Tracked repos at a glance

The `name` column is also the local directory under
`reference-emacs-configs/` and the registry key in
`reference-repos.list`. The five rows below are the actively-analyzed
subset of the 14-entry inventory.

| name                   | URL                                          | tier   | use for                                  |
|------------------------|----------------------------------------------|--------|------------------------------------------|
| steve-purcell-dotemacs | https://github.com/purcell/emacs.d           | HIGH   | per-language patterns; clean migration templates |
| jwiegley-dotemacs      | https://github.com/jwiegley/dot-emacs        | HIGH   | AI / LLM integration; gptel; local models |
| bbatsov-dotemacs       | https://github.com/bbatsov/emacs.d           | MEDIUM | pragmatic 2026 modernizations; theme + UI nits |
| sacha-chua-dotemacs    | https://github.com/sachac/.emacs.d           | MEDIUM | organic evolution; org / blogging workflows |
| munen-emacs.d          | https://github.com/munen/emacs.d             | MEDIUM | gptel custom tools; MCP integration |

Tier definitions:

- **HIGH** — Active source for current or imminent sub-goals.
- **MEDIUM** — Useful for specific topic areas; consult when those areas come up.
- **LOW / DORMANT** — Either inactive upstream or supplanted by HIGH/MEDIUM
  refs. Currently un-tracked; can be re-added via `just ref-add` if needed.

## Per-repo notes

### steve-purcell-dotemacs

Steve Purcell's `emacs.d`. Most actively maintained reference in the set;
small commits, cleanly incremental migrations.

Latest commit at last sync: `5be20de8 2026-04-22 Add basic golang support`.

**What we've extracted so far:**

- `lisp/init-minibuffer.el` → completion-stack sub-goal (vertico + consult +
  embark + orderless + savehist + remap-style bindings).
- `lisp/init-python.el`, `lisp/init-flymake.el` → python-LSP-treesit
  sub-goal (eglot + ty + ruff + reformatter pattern; `flymake-ruff` hook).
- `lisp/init-go.el`, `lisp/init-javascript.el`, `lisp/init-docker.el` →
  lsp-coverage sub-goal (go-ts-mode + goimports reformatter; js-mode
  base + js2-mode minor; minimal dockerfile-mode).
- `lisp/init-treesitter.el` → reviewed but not adopted; his
  `auto-configure-treesitter` is more sophisticated than our explicit
  `treesit-ready-p` checks. Worth a second look if our remap list grows
  past ~10 languages.
- `lisp/init-git.el` → drop-hydra investigation; observed
  `magit-diff-visit-prefer-worktree` setting (not adopted yet).
- Drop-dash-s-f and drop-hydra investigations: confirmed zero usage.

**Likely future relevance:**

- Terraform LSP (he uses `tofu-ls`).
- Eat terminal investigation (he adopted eat).
- Modern undo investigation (his choice if he has one).

**Notable recent activity (as of 2026-04-25 sync):**

- 2026-04-22 — `Add basic golang support`: independent confirmation
  that `go-ts-mode` + `eglot` + `gopls` is the 2026 default (matches
  our lsp-coverage sub-goal).
- `Define a reformatter for terraform` + `Add tofu-ls as an eglot LSP
  for terraform` — directly applicable to the pending Terraform LSP
  sub-goal. Re-read his terraform setup before drafting that proposal.
- `Remove now-upstreamed addition of ty to eglot-server-programs` —
  `ty` is now bundled into upstream eglot's default
  `eglot-server-programs`. Our explicit `("ty" "server")` entry can
  be dropped when our Emacs ships that change (track as a small
  follow-up).
- `Define a handy ruff-fix-on-save-mode` — runs `ruff check --fix-only`
  on save (separate from `ruff format`). Candidate follow-on to our
  ruff-format integration.
- `Enable pulsar, but conservatively` — visual cursor-jump feedback;
  candidate QoL enhancement, not in our backlog yet.
- Eglot tweaks: keep same LSP across out-of-project xref jumps; don't
  display emoji in margin; non-emoji modeline character.

### jwiegley-dotemacs

John Wiegley's `dot-emacs`. The most sophisticated reference — uses
literate-style org for everything, deep customization, *very* AI-heavy
in 2025-2026.

Latest commit at last sync: `1d50d3e3f 2026-04-22 changes`.

**What we've extracted so far:**

- Phase 0 landscape: identified as the AI/LLM ceiling reference.
- drop-hydra investigation: noted he is one of the few who *still* uses
  hydra (lone holdout among references).

**Likely future relevance:**

- AI / LLM integration sub-goal (canonical reference): `gptel-presets.el`,
  `hf.el` (local llama-swap orchestration), `lisp/gptel-*` modules,
  `mcp-server-lib`, `agent-shell`.
- Lots of unused-so-far material; expect to mine heavily when we get
  to AI work.

**Notable recent activity (as of 2026-04-25 sync):**

- Most active files in the last 30 commits: `lisp/gptel-presets.el`
  (13 commits) and `lisp/hf.el` (10) — ongoing model-preset and
  local-LLM tuning. Confirms his AI focus is steady.
- `gptel: Update presets, fix LiteLLM header, enable org-roam sync` —
  he routes all LLM traffic through LiteLLM and is now enabling
  org-roam sync from gptel. Both mechanisms worth understanding before
  AI sub-goal.
- `init.org: Add relint, enable magit ANSI coloring, unblock org-roam
  sync` — beyond AI, he's still tuning core dev workflow.
- Move of `hf.el` into its own submodule — code organization step;
  suggests `hf.el` is mature enough to be reused independently.

### bbatsov-dotemacs

Bozhidar Batsov's `emacs.d`. Pragmatic, modern-leaning, opinionated
choices.

Latest commit at last sync: `d6cbae1 2026-04-06 Update tokyo-night setup
to reflect upstream changes`.

**What we've extracted so far:**

- Completion-stack sub-goal: cross-referenced his vertico / orderless /
  marginalia / consult setup.
- emacs-30 cleanups: cross-referenced his patterns (built-in which-key,
  use-package bootstrap drop).
- drop-dash-s-f and drop-hydra investigations: confirmed.

**Likely future relevance:**

- Small cleanup pass: `expand-region` → `expreg` (his choice),
  `repeat-mode` patterns, possible copilot patterns.
- Theme exploration: he uses tokyo-night / catppuccin.

**Notable recent activity (as of 2026-04-25 sync):**

A burst of small QoL upgrades worth scanning when designing any "minor
enhancements" sub-goal:

- `minibuffer-regexp-mode` — live regexp feedback in the minibuffer.
- `visual-wrap-prefix-mode` — indentation-aware soft-wrap.
- `read-extended-command-predicate` — filter irrelevant `M-x` candidates.
- `eglot-autoshutdown` — already in our config; corroboration.
- Dired drag-and-drop to other apps.
- `file-notification`-based auto-revert (replaces polling).
- Show matching paren context when offscreen.
- Silenced native-comp async warnings.
- `repeat-mode` with a custom repeat-map for expreg — directly relevant
  to the expand-region → expreg item in our Small cleanup pass.
- `Highlight current error in compilation/grep buffers`.
- Theme: tokyo-night (latest update 2026-04-06).

### sacha-chua-dotemacs

Sacha Chua's `.emacs.d`. Organic, blog/journaling-heavy, less of a clean
migration source.

Latest commit at last sync: `44d6958 2026-04-18 PDF` (on `gh-pages`
branch — her config is published as her blog).

**What we've extracted so far:**

- Phase 0 landscape: organic-evolution profile.
- drop-dash-s-f: confirmed.
- drop-hydra: confirmed.

**Likely future relevance:**

- Lower than the others — her config is shaped around blogging /
  transcript / publishing workflows that don't map onto Jeff's daily use.
- Useful for org-modern adoption notes (she has commits about it).
- Useful for `goto-chg` / `substitute` / `minibuffer-regexp-mode`
  evaluations.

**Notable recent activity (as of 2026-04-25 sync):**

- `more stuff from prot and bbatsov` (explicit cross-pollination
  signal — confirms Sacha tracks Prot and bbatsov's configs, same as we
  do). She's a good "what's filtering down to working users?" indicator.
- Whisperx (small model) for live transcription — relevant if we ever
  explore audio-input sub-goals.
- Streaming-related commits (her live coding sessions).
- yas-minor-mode-map TAB conflict resolution — small note for if/when
  we hit similar yasnippet/mode interactions.

### munen-emacs.d

Munen's `emacs.d`. Different AI flavor than jwiegley — heavy on custom
gptel tools (filesystem read/write/edit, lint integration), uses MCP and
agent-shell.

Latest commit at last sync: `010121d 2026-04-15 feat: Add
edge-tts-speak-region`.

**What we've extracted so far:**

- Phase 0 landscape: alt-pattern reference for AI integration.

**Likely future relevance:**

- AI / LLM integration sub-goal: complementary to jwiegley. munen's
  pattern (gptel + custom tools + MCP) is more compact; jwiegley's is
  more elaborate. Worth seeing both before designing.

**Notable recent activity (as of 2026-04-25 sync):**

- `agent-shell uses opencode by default` — opencode is an AI agent
  backend (CLI/protocol). Relevant alternative architecture for AI
  sub-goal.
- `Remove old-school js dev stuff and add agent-shell` — clear signal
  of AI-first refactor.
- `Add vterm package` — he previously didn't use a terminal; now does.
  Useful data point for the eat-vs-vterm investigation.
- `Add edge-tts-speak-region` — text-to-speech via Microsoft Edge TTS.
  Niche but interesting if we ever explore voice output.
- Many ongoing prompt iteration commits for agent-shell and gptel
  tools — suggests his prompt engineering is still active.
- `Prefer packages via Guix, again` — uses Guix (Linux) for package
  management. Less directly relevant for Jeff's macOS setup but
  illuminates his deployment style.

## Workflow

### Starting a new investigation that might need ground-truth refs

1. Read this file to identify candidate repos.
2. Confirm those repos are present locally (`reference-emacs-configs/<name>/`).
   `just ref-show-plan` prints clone commands for missing entries.
3. If a repo is potentially stale (last analyzed > N months and we're
   starting a substantial sub-goal in its area), refresh: `just
   ref-show-changes` reports new commits per repo since the
   inventory's last-known SHA. Pull manually if you want to advance
   local state, then `just ref-update-inventory` to record the new SHA.
4. Grep / read with `git -C reference-emacs-configs/<name> ...`.

### Discovering a new repo worth tracking

```sh
cd /Users/jeff/jwm/proj/emacs-config
just ref-add <name> <url>
just ref-show-plan          # prints `git clone …`
# execute the clone
just ref-update-inventory   # records the SHA
# update this file with notes about the new repo
git add justfile reference-configs.md reference-repos.list
git commit -m "ref: track <name>"
```

### Re-analysis heuristic

A tracked repo becomes worth re-analyzing if:

- We're starting an investigation in its specific area of focus
  (e.g. jwiegley before AI/LLM work).
- `just ref-show-changes` reports a non-trivial number of new commits
  since the last analyzed SHA.
- A specific question requires "what does this developer do *now*?"
  (current state) rather than "what did we extract previously?"
  (point-in-time snapshot).

### About the 9 inventory-only repos

The 9 repos we have on disk but don't actively analyze
(abo-abo-dotemacs, andreyorst-dotfiles, danielmai-dotemacs,
ebzzry-dotfiles, editorconfig-emacs, greendog-gtd,
howardabrams-dot-files, sirpscl-emacs.d, smartparens) are tracked in
`reference-repos.list` for state preservation. `just ref-show-changes`
reports their upstream activity along with the others; if anything
notable happens, we can promote one to active analysis by writing a
section here. Until then, no synthesis update needed.

`greendog-gtd` is a special case: no upstream URL (`-` in the
inventory). It's a local-only directory tracked for SHA snapshots
only. Recipes treat it gracefully (skip clone/fetch, note the
local-only state).

## Updating this file

Whenever a sub-goal pulls a new pattern from a tracked repo, append a
line to that repo's "What we've extracted" list. Whenever a new repo
gets `ref-add`'d, add a section here.
