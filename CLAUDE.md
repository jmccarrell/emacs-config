# emacs-config workspace

This folder is a workspace containing Jeff's Emacs configuration project and a collection of reference configurations. The workspace folder is itself a git repository (default branch `main`); `literate-emacs.d/` and `reference-emacs-configs/` are gitignored at this level — each contains its own independent git repo. The workspace repo tracks workspace-level files like this `CLAUDE.md`.

## Structure

```
emacs-config/
├── specs/                        ← numbered briefs from Jeff (durable, git-tracked)
├── literate-emacs.d/             ← Jeff's Emacs config (normal git repo)
│   ├── jeff-emacs-config.org     ← literate source of truth
│   ├── init.el                   ← generated (tangled from the org file)
│   ├── CLAUDE.md                 ← repo-level context: conventions, key files, architecture
│   └── ...
├── literate-emacs.d_<feature>/   ← optional feature worktree (sibling directory)
└── reference-emacs-configs/      ← cloned reference repos (read-only, for inspiration)
    ├── abo-abo-dotemacs/
    ├── bbatsov-dotemacs/
    ├── jwiegley-dotemacs/
    ├── munen-emacs.d/
    ├── sacha-chua-dotemacs/
    ├── steve-purcell-dotemacs/
    └── ... (see reference-repos.list)
```

## literate-emacs.d — the active project

`literate-emacs.d/` is a normal git repo (origin `git@github.com:jmccarrell/literate-emacs.d.git`), checked out on a branch (default `main`). Day-to-day work happens on `main` or a feature branch. For larger or parallel changes, Jeff uses a **git worktree** — a sibling directory such as `literate-emacs.d_<feature>/`, created with `git worktree add`. Worktrees are still part of the flow; the bare-root layout is not.

For literate-config conventions (org/init.el coupling, key files, architecture), read `literate-emacs.d/CLAUDE.md`. The rest of *this* document covers workspace-level concerns and how Claude should work in the repo.

## Multi-machine workflow

Two repos are in play across machines, each with its own GitHub origin:

- The workspace repo at `/Users/jeff/jwm/proj/emacs-config/` — tracks `specs/`, this `CLAUDE.md`, `spec-shapes.md`, `skills/`, `justfile`, `reference-repos.list`, `reference-configs.md`.
- `literate-emacs.d/` — the Emacs config repo (a normal git repo), optionally with feature worktrees as sibling directories.

Sync each by fetching and pulling normally (`git pull --ff-only`, or a rebase when branches have diverged).

Workspace-specific per-machine state (does not cross machines):

- `~/.emacs.d/init.el` symlink target — points at `literate-emacs.d/init.el` by default; repoint per machine, and when creating or removing a feature worktree you want to test live.
- `reference-emacs-configs/` cache — regenerate via `just ref-show-plan` from the workspace root.

`TASK.md` is **branch-tracked** (committed alongside the work it describes; removed before the branch is merged so it never reaches `main`). It travels cross-machine via the branch.

### Session-start sync

At the start of any planning or implementation session, check both repos against origin. The check is read-only; the pull is Jeff-side.

```sh
cd /Users/jeff/jwm/proj/emacs-config && git fetch && git status -sb
cd /Users/jeff/jwm/proj/emacs-config/literate-emacs.d && git fetch && git status -sb
# plus any active feature worktree: git -C ../literate-emacs.d_<feature> status -sb
# if behind: git pull --ff-only
```

Claude runs the read-only checks and reports drift; Jeff runs any `git pull` himself. The `emacs-spec-intake` skill includes this as Step 0 of any spec-driven work. Drift is surfaced, not gated — Jeff decides whether to sync first or proceed against current state.

## reference-emacs-configs — read-only references

`reference-emacs-configs/` is a local cache of other developers' Emacs configs used as ground truth during investigations. The directory is gitignored at workspace level — repos in it are *not* committed; each has its own upstream origin.

**Tracked repos** are listed in `reference-repos.list` at the workspace root. Each line is three whitespace-delimited fields: `name url last-known-sha`. The `last-known-sha` is the upstream commit at which we last analyzed the repo; comparing it to current upstream tells us what's new since then. A SHA of `-` means the inventory has not captured a local HEAD for that repo yet.

The synthesis file `reference-configs.md` is the canonical home for reference-repo analysis: what each tracked repo is for, which repos are active references, and what we've already extracted from each. The inventory tracks registered repos; the synthesis covers the subset we actively analyze. Roadmap files such as `literate-emacs.d/emacs-2026-landscape.org` should link to this synthesis rather than duplicating per-repo surveys.

### Workflow

To work on a fresh machine after cloning the workspace:

```sh
cd /Users/jeff/jwm/proj/emacs-config
just ref-show-plan         # prints `git clone …` commands needed
# execute the printed commands (or pipe to bash)
just ref-update-inventory  # capture the just-cloned commit SHAs into the inventory
```

To check for upstream changes since the last analysis:

```sh
just ref-show-changes      # prints what's new per repo since last-known-sha
# consume notable changes into reference-configs.md
# if a repo was pulled to advance local: 
just ref-update-inventory  # records new SHAs
```

To add a new repo discovered during an investigation:

```sh
just ref-add NAME https://github.com/owner/repo
just ref-show-plan         # prints clone command
# execute it
just ref-update-inventory  # records the SHA
# then add a section to reference-configs.md describing what it's for
```

To see the current registry:

```sh
just ref-list
```

### Recipe summary

- **`ref-list`**: cat the inventory.
- **`ref-add NAME URL`**: append a new entry with `-` placeholder for SHA.
- **`ref-show-plan`**: print git commands needed to align filesystem with inventory + upstream HEAD. Doesn't execute.
- **`ref-show-changes`**: per-repo, fetch upstream and list new commits since last-known-sha. Use this to feed analysis updates into `reference-configs.md`.
- **`ref-update-inventory`**: capture each repo's current local HEAD into its inventory `last-known-sha`. Run after consuming changes.

**Workflow rule:** before starting an investigation, read `reference-configs.md` to identify which tracked repos are relevant. If a needed repo isn't tracked yet, add it via `just ref-add`. Treat these repos as read-only — don't commit to them or modify them; they're regenerable cache.

## specs/ — durable briefs

Numbered Markdown files in `specs/` (e.g. `specs/003-local-ai-in-emacs-1.md`) capture Jeff's intent before implementation. Each spec is short and addressed to Claude: what to do, why, sometimes corrections to a previous proposal (e.g. `002-improve-reference-repo-tracking.md` pushed back on outcomes from `001-plan-reference-repos.md`). Specs are git-tracked and persist as project history.

Specs are **upstream** of TASK.md:

- A spec is the ask. It sets scope and lives forever.
- A TASK.md is the plan-of-record for one branch/worktree implementing one slice of a spec. It is branch-tracked during the work and removed before the branch is merged, so it never reaches `main`.

When a spec arrives, Claude reads it, may discuss approach in chat, then (once work begins on a branch) writes a TASK.md whose Goal narrowly restates one sub-goal of the spec and whose Why links back to `specs/NNN-….md`. A single broad spec (like `003`, "AI/LLM integration") can produce multiple TASK.md files across multiple branches.

Before starting work, Claude should look in `specs/` for a relevant numbered spec. If the work has no spec, Claude surfaces that — for anything multi-step, it may be worth writing a spec first so the intent is captured durably rather than only in chat.

Specs come in a handful of recognizable shapes (broad exploratory, narrow directive, pushback, extension). `spec-shapes.md` at the workspace root catalogs those shapes — what to look for, what to investigate, how to decompose. Read it when handed a spec. The catalog is meant to evolve as new specs reveal new shapes.

## TASK.md convention

When working on a feature, a `TASK.md` file in the repo root (or a feature worktree's root) describes what's currently being worked on — goal, approach, notes, verification checklist. It provides immediate context to any Claude session.

`TASK.md` is **tracked on the feature branch** (committed alongside the work it describes; travels cross-machine via the branch) and should be **removed before the branch is merged** so it never reaches `main`. If a branch or worktree has a `TASK.md`, read it before starting any work there.

## Feature worktrees (for Claude agents)

For larger or parallel changes, Jeff uses a git worktree — a sibling directory of `literate-emacs.d/`. The mechanics are plain git; the bare-root layout and the old `wt::*` recipes are gone.

```sh
# from inside the repo, create a worktree + branch (Jeff-side, mutating):
cd /Users/jeff/jwm/proj/emacs-config/literate-emacs.d
git worktree add ../literate-emacs.d_<feature> -b <feature>
# tear down when done (after killing its buffers — see below):
git worktree remove ../literate-emacs.d_<feature>
git worktree list   # inspect
```

**Claude reads; Jeff acts on mutating git commands.** Claude inspects state with read-only git (`status`, `log`, `worktree list`, `diff`) and edits files, then hands Jeff the exact `git` commands for anything that mutates history, branches, worktrees, or remotes.

### Sandbox path-translation

Claude agents working on this project run in a sandbox that mounts `/Users/jeff/jwm/proj/emacs-config/` at a different absolute path (`/sessions/<session-id>/mnt/emacs-config/`). File tools (Read/Write/Edit) translate paths automatically. Only `git` commands are affected, and git run *in the sandbox* against a worktree can mislead: a worktree registered at the real `/Users/jeff/...` path may show as `prunable` or error ("fatal: not a git repository") simply because that path doesn't exist inside the sandbox. Treat sandbox git output about worktree paths with suspicion, and defer to the "Claude reads; Jeff acts" rule.

### `~/.emacs.d/init.el` symlink

`~/.emacs.d/init.el` is a symlink. Its default target is `literate-emacs.d/init.el` (the repo's tangled output). To test a feature worktree's changes without merging, repoint the symlink at the feature worktree's `init.el`; a fresh Emacs then loads that `init.el` and picks up the worktree's config. `~/.emacs.d/` is outside the sandbox mount, so Claude cannot change the symlink directly — this is always a Jeff-side command.

```sh
# point at a feature worktree to test it live:
ln -sf /Users/jeff/jwm/proj/emacs-config/literate-emacs.d_<feature>/init.el ~/.emacs.d/init.el
# point back at the main checkout when done (before removing the worktree, or it dangles):
ln -sf /Users/jeff/jwm/proj/emacs-config/literate-emacs.d/init.el ~/.emacs.d/init.el
```

The worktree's `init.el` starts identical to the branch point — Jeff still needs to tangle inside the worktree before restarting Emacs to actually pick up the changes.

### Global Emacs state disclosure

**Rule: Claude discloses non-routine global Emacs state changes before they happen.** Anything under `~/.emacs.d/` or another non-worktree, non-git-managed Emacs location is Jeff-side state, even when a command is legitimate. Routine package installs from package archives already configured in Jeff's Emacs config are expected Emacs work and do not need extra reporting or approval.

For global Emacs files outside the worktree, Claude must distinguish provenance before acting: package-provided artifacts from packages Jeff intentionally uses are acceptable Emacs state, while Claude-authored files, ad hoc shell output, symlink changes, generated caches, package installs from arbitrary URLs, `package-vc`, Git checkouts, or unconfigured archives need explicit disclosure before execution. Disclosure means naming the path, provenance, purpose, teardown path, and replication implication.

Example: `M-x mcp-server-lib-install` may install `~/.emacs.d/emacs-mcp-stdio.sh`. That file is acceptable if it is the package-provided helper for `mcp-server-lib`; the important part is to make its provenance and lifecycle visible before invoking the command, so Jeff is not surprised by an unexplained global helper script. This matters for spikes: if the spike fails, the global state must be torn down; if it works, the global state must be replicated in Jeff's other environments. Claude may inspect these locations read-only when needed, but must not create, modify, remove, install, or regenerate non-routine global Emacs artifacts unless Jeff explicitly approves that specific write in chat. Prefer writing project-tracked source or documenting the Jeff-side command to run.

### Sub-goal pre-implementation checklist

Before editing files in a new worktree, Claude states in the chat message that kicks off implementation that the following are in place (or explicitly asks Jeff to set them up):

1. Worktree exists at `literate-emacs.d_<feature>/` (created via `git worktree add ../literate-emacs.d_<feature> -b <feature>`).
2. `~/.emacs.d/init.el` is repointed at the worktree's `init.el` (if testing the change live).
3. If the sub-goal adds new packages, `M-x package-refresh-contents` is expected before tangle.

### Tangling and verifying via justfile

The repo's `justfile` (in the main checkout and in every worktree) has shell-side recipes for tangling and basic load-checking. Use these instead of `M-x org-babel-tangle` when scripting or when a quick syntax check is more useful than starting Emacs.

```sh
cd literate-emacs.d        # or the feature worktree
just --list                # show recipes
just tangle                # regenerate init.el from jeff-emacs-config.org
just verify-tangle         # tangle, then load init.el in batch -Q to catch errors
```

`just tangle` runs:

```sh
emacs --batch -l org \
      --eval '(org-babel-tangle-file "jeff-emacs-config.org")'
```

Confirmed byte-identical to interactive `M-x org-babel-tangle`. Cold-run wall time is ~480ms on Apple Silicon.

In TASK.md "Tangle steps" sections, Claude should suggest `just tangle` (shell-side, no Emacs context-switch) as the primary path, and `M-x org-babel-tangle` as the alternate. Claude itself cannot run these in the sandbox today (no `emacs` binary), but the recipes are the same on both sides.

### Git workflow: org and init.el commit together

`jeff-emacs-config.org` is the source of truth; `init.el` is its tangled output. **They must always be committed together** in the same commit, so the tracked `init.el` always matches the org it was tangled from. After editing the org, tangle, verify, and stage both:

```sh
cd /Users/jeff/jwm/proj/emacs-config/literate-emacs.d   # or the worktree
just verify-tangle && git add jeff-emacs-config.org init.el && git commit -m "<summary>"
```

See `literate-emacs.d/CLAUDE.md`'s "Git workflow" section for the literate-config-specific details.

### Info-node grounding for investigations

`literate-emacs.d/info-dir.txt` is a snapshot of all Info manuals visible to Jeff's Emacs (generated via `(info "(dir)")` after `package-initialize`). It's the canonical reference for what package documentation is locally available.

**Standard workflow:** any investigation that might reference Emacs / package docs begins with Claude reading `info-dir.txt` (via the Read tool). This grounds analysis in Jeff's specific install state — which packages have manuals, what version, what aliases — rather than generic 2026 emacs knowledge.

Refresh after package install/remove:

```sh
cd literate-emacs.d        # or the worktree
just info-dir-update
git add info-dir.txt && git commit -m "info-dir: refresh after package changes"
```

For specific Info nodes (e.g. when reading a section of magit's manual):

```sh
just info-node "(magit) Worktree"
```

Writes `info-node.txt` in the cwd of whichever checkout's justfile was invoked. Overwritten each call. Per-investigation; not committed. Jeff attaches the file to the session; Claude reads it via Read. The recipe accepts any node reference of the form `"(MANUAL) NODE"` — including `"(MANUAL) Top"` for a manual's table of contents when `info-dir.txt`'s one-line description isn't enough to guess the right section name.

When proposing info-node fetches, Claude states up front *which nodes* and *why each one* — discovery should be explicit, not blind.

### Verification step style

When writing verification steps inside a `TASK.md` (or in chat), Claude follows three rules:

- **Match verification depth to behavior change.** For sub-goals that produce *no* expected user-visible change in live Emacs (pure deletions of unused declarations, refactors that should be byte-identical, doc-only edits), `just verify-tangle` is sufficient on its own. It tangles + loads `init.el` in batch `-Q`; a clean exit proves both tangle correctness and load success in one shot. Skip the longer flows (step-0 grep checks, live-Emacs keystroke walks) — they have nothing meaningful to confirm. For sub-goals that *do* change behavior (new packages, new bindings, new modes, anything Jeff would notice), keep the fuller verification flow with the bullets below.
- **Prefer keystrokes over typed commands.** Use `C-h v <var>` rather than `M-x describe-variable RET <var> RET`, `C-h f <fn>` rather than `M-x describe-function`, `C-h k <keys>` rather than `M-x describe-key`. Reading a keystroke in a checklist builds muscle memory; typing a command name at `M-x` does not.
- **Isolate preconditions.** Each pass-criterion should either be provable by a single command whose failure mode is unambiguous, or should explicitly list what else needs to be true for the test to pass. When a test's pass depends on the symlink or tangle state, add a step-0 check (`readlink ~/.emacs.d/init.el`, or `grep <change> <checkout>/init.el`) that isolates that precondition before the live-emacs test.

### Meta-doc edits (in the repo or in the workspace)

Documentation-only files that do not get tangled into `init.el` may be edited directly (no separate worktree needed), because they don't risk breaking the live Emacs config. Examples:

- `literate-emacs.d/emacs-2026-landscape.org` — backlog tracker (repo-level).
- `literate-emacs.d/emacs-cheat-sheet.org` — when adding rows to existing sections that don't depend on a new `use-package` block (cheat-sheet edits *coupled* to a new config block still commit alongside that config change).
- `/Users/jeff/jwm/proj/emacs-config/CLAUDE.md` — workspace-level meta-doc (this file).

**Rule: every direct edit Claude makes to a tracked file must be accompanied in the same response by an explicit commit command** that Jeff can paste. Without the commit, the edit accumulates as silent uncommitted state, and merge conflicts later when worktrees touch the same file.

For repo-level files (in `literate-emacs.d/`):

```sh
cd /Users/jeff/jwm/proj/emacs-config/literate-emacs.d && \
  git add <file> && git commit -m "<short summary>"
```

For workspace-level files (this `CLAUDE.md`, etc.):

```sh
cd /Users/jeff/jwm/proj/emacs-config && \
  git add <file> && git commit -m "<short summary>"
```
