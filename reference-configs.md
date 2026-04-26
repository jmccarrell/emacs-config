# Reference Emacs configs — synthesis

This file is the canonical home for analysis of other developers' Emacs
configs: which repos we treat as ground-truth references during
investigations, what we've already extracted from each, and how recent
upstream changes should influence Jeff's roadmap. It is committed to the
workspace repo and travels with the project. The actual cloned repos in
`reference-emacs-configs/` are a per-machine cache, rebuildable from the
inventory in `reference-repos.list` via `just ref-show-plan`.

**Last refreshed:** 2026-04-26 (AI/LLM reference expansion: five
additional lived-in configs registered; Sacha promoted as a practical
AI-workflow signal).

## Inventory vs. synthesis

The inventory in `reference-repos.list` tracks all registered repos, with
last-known-SHAs for change detection. This synthesis file covers the repos
we actively analyze (HIGH/MEDIUM tier) — they're the ones whose patterns we
extract into our own config.

The other inventory-only repos are tracked for state preservation but are not
subjects of ongoing investigation. Any of them can be promoted to active
analysis by adding a section here; the inventory tooling already snapshots
their state.

## Relationship to the Landscape Document

`literate-emacs.d/main/emacs-2026-landscape.org` owns Jeff's modernization
roadmap: the section-by-section map, shipped work, pending backlog, and open
questions. This file owns the reference-repo intelligence that feeds that
roadmap.

When `just ref-show-changes` turns up new upstream commits:

1. Summarize the repo-specific signal here.
2. Update the landscape only if the signal changes a recommendation,
   priority, shipped-note, or pending sub-goal.
3. Avoid duplicating repo-by-repo commit surveys in the landscape.

## Tracked repos at a glance

The `name` column is also the local directory under
`reference-emacs-configs/` and the registry key in
`reference-repos.list`. The rows below are the actively-analyzed subset of
the inventory.

| name                           | URL                                                   | tier   | use for                                  |
|--------------------------------|-------------------------------------------------------|--------|------------------------------------------|
| steve-purcell-dotemacs         | https://github.com/purcell/emacs.d                    | HIGH   | per-language patterns; clean migration templates |
| jwiegley-dotemacs              | https://github.com/jwiegley/dot-emacs                 | HIGH   | AI / LLM integration; gptel; local models |
| yqrashawn-yqdotfiles           | https://github.com/yqrashawn/yqdotfiles               | HIGH   | advanced gptel tools, MCP, agent/proxy backends |
| bbatsov-dotemacs               | https://github.com/bbatsov/emacs.d                    | MEDIUM | pragmatic 2026 modernizations; theme + UI nits |
| abo-abo-dotemacs               | https://github.com/abo-abo/oremacs.git                | MEDIUM | Ivy-author counter-signal; Dired/vterm/Magit/Python micro-patterns |
| sacha-chua-dotemacs            | https://github.com/sachac/.emacs.d                    | MEDIUM | practical gptel / agent-shell use in Org workflows |
| munen-emacs.d                  | https://github.com/munen/emacs.d                      | MEDIUM | gptel custom tools; MCP integration |
| redguardtoo-emacs.d            | https://github.com/redguardtoo/emacs.d                | MEDIUM | compact local Ollama gptel + Aider setup |
| abougouffa-minemacs            | https://github.com/abougouffa/minemacs                | MEDIUM | local/cloud LLM stack; Ellama, gptel, Aidermacs, MCP |
| matthewzmd-emacs.d             | https://github.com/MatthewZMD/.emacs.d                | MEDIUM | Aidermacs author config; OpenRouter model defaults |
| manateelazycat-lazycat-emacs   | https://github.com/manateelazycat/lazycat-emacs       | MEDIUM | OpenRouter gptel, Aidermacs, Emigo, Whisper |
| jkitchin-scimax                | https://github.com/jkitchin/scimax                    | MEDIUM | scientific Org, org-db, and RAG context |

Tier definitions:

- **HIGH** — Active source for current or imminent sub-goals.
- **MEDIUM** — Useful for specific topic areas; consult when those areas come up.
- **LOW / DORMANT** — Either inactive upstream, inventory-only, or
  supplanted by HIGH/MEDIUM refs. Promote by adding a section here when a
  specific question makes the repo relevant again.

## Current Landscape-Level Signals

These are the cross-repo conclusions that currently matter most to
Jeff's roadmap:

- Purcell remains the cleanest migration reference for language tooling and
  built-in-era Emacs defaults. Re-read him before Terraform, eat, undo, or
  any broad language-mode work.
- AI references now have a useful spread: jwiegley remains the ambitious
  ceiling; munen and yqrashawn cover custom tools / MCP; redguardtoo covers
  compact local Ollama; Sacha covers practical Org/language-learning use;
  MinEmacs, MatthewZMD, and Lazycat show package-stack and agent choices.
- John Kitchin's scimax is worth tracking for scientific Org workflows,
  org-db, and RAG-adjacent context, but not as current daily-driver AI config:
  its public `scimax-gptel` work is not yet present, and the README says
  scimax development was discontinued on 2026-04-23.
- bbatsov is best for small, pragmatic quality-of-life upgrades and modern
  defaults that can land as tight cleanup commits.
- abo-abo is now an active counter-signal rather than a dormant reference:
  still Ivy/Counsel/Hydra/Flycheck-flavored, but using Eglot/Ruff/vterm and
  pruning unused package surface.
- Sacha is useful when the question touches Org, publishing, blogging,
  transcription, or "what has filtered into long-running daily use?" She is
  now also a practical gptel / agent-shell reference rather than only an
  Org/blogging reference.

## Secondary AI Sources

These are not tracked as personal-config ground truth, but they should be
consulted during AI work:

- `karthink/gptel` and https://gptel.org/ — package-level truth for backend
  support, tool use, MCP integration, multimodal context, and transient UI.
- `xenodium/agent-shell` — package-level truth for ACP agent shells, supported
  agents, environment handling, MCP server config, and container path
  resolution.
- `MatthewZMD/aidermacs` and `tninja/aider.el` — package-level truth for
  Aider-style pair programming from Emacs.
- John Kitchin's RAG packages (`jkitchin/emacs-rag-libsql`,
  `jkitchin/org-db-v3`) — secondary package context to read alongside
  tracked `jkitchin-scimax` when an AI sub-goal reaches retrieval or
  Org/DB-backed context.
- Mastering Emacs / Mickey Petersen — useful as blog and package context
  (e.g. Combobulate, ligatures, shell/editor workflow), but no current public
  personal Emacs config was found during this pass.

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

### abo-abo-dotemacs

Oleh Krehel's `oremacs`. Highly active, highly personal, and useful as a
counter-signal: as the Ivy author, he naturally still carries a lot of
Ivy/Counsel/Hydra/Flycheck-era muscle memory. Do not use this as a clean
2026 migration template. Use it to understand what a power user keeps,
removes, and hand-tunes after years of daily use.

Latest commit at last sync: `b17e90e 2025-12-17 packages.el: Remove
docker-tramp`.

**What we've extracted so far:**

- Phase 0 landscape: active-evolution signal, but not one of the clean
  migration templates.
- 2026-04-25 refresh: 227 commits since `0c5f328` were reviewed for
  backlog relevance. The useful signal is mostly in topic modules rather
  than wholesale package choices.

**Likely future relevance:**

- Dired / Dirvish investigation: `modes/ora-dired.el` is a strong
  "power-user Dired, not Dirvish" counterexample. Mine it for small Dired
  affordances first (archive binding, omit rules, `dired-dwim-target`,
  remote/TRAMP adjustments, file-size helpers) before deciding that a
  full Dirvish front-end is worth the surface area.
- Eat / terminal investigation: he added `vterm` rather than `eat`.
  Together with Munen's vterm adoption and Purcell's eat adoption, this
  gives us the right comparison frame: pure-Elisp portability versus
  native-module terminal fidelity.
- Verb / HTTP investigation: he added `restclient` support, not `verb`.
  That is evidence that the restclient family is still viable for power
  users; `verb` needs to win on concrete org workflow benefits, not just
  novelty.
- Magit worktree / ecosystem investigation: his Magit module binds
  `magit-diff-visit-worktree-file`, adds `magit-ediff`, and prunes status
  sections/headers for a denser status buffer. Read this when evaluating
  Magit's worktree affordances and small Magit UX improvements.
- Python follow-ups: `modes/ora-flycheck-ruff.el` and
  `modes/ora-python.el` confirm Ruff's importance, but he keeps a very
  custom Flycheck/Jedi setup and explicitly disables some Eglot/Flymake
  behavior to fix completion delay. Treat this as troubleshooting signal
  for Eglot completion latency, not as a reason to unwind our
  Flymake-first Python migration.

**Notable recent activity (as of 2026-04-25 sync):**

- `modes/ora-python.el: Fix eglot completion delay` — disables Eglot's
  completion-provider resolution path and removes Eglot's Flymake backend
  from managed buffers. Useful if our Python buffers ever feel sluggish
  under Eglot; not something to preemptively copy.
- `modes/ora-flycheck-ruff.el: Add` — converges on Ruff diagnostics, but
  via Flycheck. Our `flymake-ruff` choice remains better aligned with
  built-in Eglot/Flymake.
- `modes/ora-vterm.el: Add` and later updates — vterm is the active
  terminal choice in this reference.
- `modes/ora-http.el: Add` — a small `restclient-mode` workflow, relevant
  to the `verb` comparison.
- `modes/ora-javascript.el: Don't start lsp` — corroborates our current
  "no JS LSP unless pain appears" stance. It does not argue against the
  small cleanup pass from `js2-mode` toward `js-ts-mode`.
- `modes/ora-nextmagit.el: Fix magit-diff-visit-worktree-file`, followed
  later by `modes/ora-nextmagit.el: Remove` and a self-contained
  `modes/ora-magit.el` — useful Magit patterns were consolidated, not
  abandoned.
- `packages.el: Remove docker-tramp` and `Clean up unused packages` —
  reinforces the ongoing cleanup theme: remove latent package surface
  when actual call sites disappear.

### sacha-chua-dotemacs

Sacha Chua's `.emacs.d`. Organic, blog/journaling-heavy, less of a clean
migration source, but now a concrete practical AI-workflow reference.

Latest commit at last sync: `44d6958 2026-04-18 PDF` (on `gh-pages`
branch — her config is published as her blog).

**What we've extracted so far:**

- Phase 0 landscape: organic-evolution profile.
- drop-dash-s-f: confirmed.
- drop-hydra: confirmed.
- 2026-04-26 AI reference expansion: `Sacha.org` now has `gptel`
  backends for Groq, Gemini, paid Gemini, and Mistral; a custom
  `sacha-gptel-set-model`; `agent-shell` defaults for Claude Code; and
  task-specific `gptel-request` workflows for language learning.

**Likely future relevance:**

- Practical AI workflows inside Org, especially small task-specific
  `gptel-request` helpers and "what actually stuck in daily use?"
  patterns.
- Still lower than jwiegley / yqrashawn for agentic coding architecture;
  her config is shaped around blogging, transcript, publishing, and
  learning workflows that only partially map onto Jeff's daily use.
- Useful for org-modern adoption notes (she has commits about it).
- Useful for `goto-chg` / `substitute` / `minibuffer-regexp-mode`
  evaluations.

**Notable recent activity (as of 2026-04-25 sync):**

- `more stuff from prot and bbatsov` (explicit cross-pollination
  signal — confirms Sacha tracks Prot and bbatsov's configs, same as we
  do). She's a good "what's filtering down to working users?" indicator.
- Whisperx (small model) for live transcription — relevant if we ever
  explore audio-input sub-goals.
- `gptel` backend matrix includes Groq, Gemini, paid Gemini, and Mistral
  with API keys read from environment variables.
- `agent-shell` is present with Claude Code as the preferred agent and a
  custom per-working-directory dot-subdir function.
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

### redguardtoo-emacs.d

Chen Bin's `emacs.d`. Very popular, active, and useful as the compact
local-first AI counterpoint to jwiegley's large stack.

Latest commit at last sync: `8c892ed7 2026-04-19 use apeleia to format code`.

**What we've extracted so far:**

- 2026-04-26 AI reference expansion: `lisp/init-ai.el` configures `gptel`
  with local Ollama backends for DeepSeek R1 and Gemma 3n, org-mode chat
  buffers, presets, prompt directives, and `gptel-include-reasoning nil`.
- Same module wires Aider to local Ollama models and adds small project /
  commit analysis helpers around `gptel-request`.

**Likely future relevance:**

- Best small reference for "local model first, minimum Emacs surface" and
  for deciding which parts of AI integration can stay lightweight.
- Re-read before local Ollama, local Aider, or one-off code-review helper
  sub-goals.

### abougouffa-minemacs

Abdelhak Bougouffa's MinEmacs framework. More of an Emacs distribution
than a single personal init, but active and broad enough to be useful for
package-stack comparisons.

Latest commit at last sync: `ae4967d6 2026-04-26 chore(version): v14.0.0`.

**What we've extracted so far:**

- 2026-04-26 AI reference expansion: `modules/me-ai.el` combines `llm`,
  `llm-ollama`, `llm-models`, Ellama, gptel, Aidermacs, `mcp-hub`, and
  Whisper in one module.
- Shows local-backend choices for Ollama and llama.cpp, dynamic Aidermacs
  model selection from available Ollama models, and an MCP-to-Ellama-tools
  bridge.

**Likely future relevance:**

- Useful when comparing gptel-first versus Ellama/`llm` abstractions.
- Re-read for MCP server registration and "many AI packages in one module"
  tradeoffs.

### matthewzmd-emacs.d

Matthew Zeng's M-EMACS configuration. Useful mainly because Matthew is the
Aidermacs author; the personal AI surface is smaller than the package repo.

Latest commit at last sync: `e8a999b 2026-03-14 Update stuff`.

**What we've extracted so far:**

- 2026-04-26 AI reference expansion: `elisp/init-llm.el` configures
  Aidermacs with `comint`, disables auto-commits, uses OpenRouter Gemini
  as the default model, and sets a DeepSeek weak model.
- Same file enables Emigo against OpenRouter, using `OPENROUTER_API_KEY`
  from the environment.

**Likely future relevance:**

- Re-read when evaluating Aidermacs defaults, model split between primary
  and weak model, and whether to use `comint` or terminal-backed agent UI.
- Treat `MatthewZMD/aidermacs` itself as the package-level source of truth.

### manateelazycat-lazycat-emacs

Andy Stewart's `lazycat-emacs`. Highly customized, large surface area, and
useful for seeing AI packages inside a long-running personal config.

Latest commit at last sync: `200684c3 2026-02-23 Fix key echo error.`

**What we've extracted so far:**

- 2026-04-26 AI reference expansion: `site-lisp/config/init-gptel.el`
  configures gptel through OpenRouter, binds RET in `gptel-mode`, and adds
  a small `gptel-request` helper for pinyin-to-Chinese conversion.
- `init-aidermacs.el` configures Aidermacs with OpenRouter Claude 3.7
  Sonnet; `init-emigo.el` enables Emigo with OpenRouter Gemini 2.5; the
  repo also has `init-whisper.el`.

**Likely future relevance:**

- Useful for OpenRouter-centric setups, Emigo comparison, and "AI as a
  cluster of small packages" rather than one gptel-only stack.
- Less useful as a clean migration template; expect many local conventions.

### yqrashawn-yqdotfiles

Yuan Fu's dotfiles. Advanced Doom-based AI reference with substantial
custom gptel tooling, MCP server work, proxy backends, and tests.

Latest commit at last sync: `900106d4 2026-04-25 fix: auq`.

**What we've extracted so far:**

- 2026-04-26 AI reference expansion: `.doom.d/llm.el` builds a large gptel
  preset matrix for Claude Code, OpenRouter, GitHub Copilot, and Codex-like
  local proxy backends.
- `.doom.d/gptel-tools/` contains tested tools for file creation/editing,
  reading, buffers, ripgrep, shell, linting, memory, imenu, treesit, todo,
  and workspace context.
- `.doom.d/packages.el` includes gptel, Elysium, chatgpt-shell, Whisper,
  Copilot, Aidermacs, MCP, `mcp-server-lib`, `elisp-dev-mcp`,
  `agent-shell`, `agent-shell-sidebar`, and `agent-shell-manager`.

**Likely future relevance:**

- New HIGH-tier AI reference for agentic gptel architecture, custom tool
  design, MCP/server integration, and local proxy adapters for external
  coding agents.
- Re-read alongside jwiegley before designing any serious tool-use or
  agent-shell sub-goal; use redguardtoo if the desired answer is smaller.

### jkitchin-scimax

John Kitchin's scimax starterkit for scientists and engineers. This is the
right Kitchin repo to track; `jkitchin/jmax` exists, but last moved in 2018
and is not a current config reference.

Latest commit at last sync: `f1f12ac1 2026-04-23 Update README with scimax
development status`.

**What we've extracted so far:**

- 2026-04-26 Kitchin follow-up: track `jkitchin/scimax` as scientific
  Org / org-db / RAG context, not as a top-tier current AI implementation.
- `README.org` says the 2025 scimax 4.0 direction included LLM/gptel energy,
  a non-public `scimax-gptel` package with tool and MCP integration for
  scientific writing, and an org-db rewrite for semantic search.
- `org-db-v2/` and `scimax.org` are concrete references for indexing Org
  material into SQLite, full-text search, image/audio support, and agenda
  workflows.

**Likely future relevance:**

- Re-read for scientific notebook patterns, Org database indexing, and
  retrieval-shaped context before designing any RAG or research-note AI
  workflow.
- Keep `jkitchin/emacs-rag-libsql` and `jkitchin/org-db-v3` as package-level
  secondary sources for newer retrieval experiments.

**Caveat:**

- The 2026-04-23 README says Kitchin no longer uses Emacs and is
  discontinuing scimax development, so do not treat this as a current
  daily-use AI config unless upstream activity resumes.

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

### About the inventory-only repos

Repos that appear in `reference-repos.list` but not in the table above are
tracked for state preservation. `just ref-show-changes` reports their
upstream activity along with the others; if anything notable happens, we can
promote one to active analysis by writing a section here. Until then, no
synthesis update needed.

Current inventory-only notes:

- `andreyorst-dotfiles`: tracked for continuity. GitLab / web search did not
  surface a strong AI/LLM config signal during the 2026-04-26 AI reference
  expansion, so it remains inventory-only.
- `danielmai-dotemacs`: historically useful to Jeff's original config, but
  currently lower signal than Purcell/bbatsov for modern migrations.

## Updating this file

Whenever a sub-goal pulls a new pattern from a tracked repo, append a
line to that repo's "What we've extracted" list. Whenever a new repo
gets `ref-add`'d, add a section here.
