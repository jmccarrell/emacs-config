# emacs-config workspace

This folder is a workspace containing Jeff's Emacs configuration project and a collection of reference configurations. The workspace folder is itself a git repository (default branch `main`); `literate-emacs.d/` and `reference-emacs-configs/` are gitignored at this level — each contains its own independent git repo. The workspace repo tracks workspace-level files like this `CLAUDE.md`.

## Structure

```
emacs-config/
├── specs/                   ← numbered briefs from Jeff (durable, git-tracked)
├── literate-emacs.d/        ← Jeff's Emacs config (worktree-enabled repo)
│   ├── .bare/               ← bare git repo (origin: git@github.com:jmccarrell/literate-emacs.d.git)
│   ├── .git                 ← pointer file to .bare (do not edit)
│   └── main/                ← main worktree (and any future feature worktrees)
│       ├── CLAUDE.md        ← repo-level context: conventions, key files, architecture
│       └── ...
└── reference-emacs-configs/ ← cloned reference repos (read-only, for inspiration)
    ├── abo-abo-dotemacs/
    ├── bbatsov-dotemacs/
    ├── jwiegley-dotemacs/
    ├── munen-emacs.d/
    ├── sacha-chua-dotemacs/
    ├── steve-purcell-dotemacs/
    └── ... (see reference-repos.list)
```

## Multi-machine workflow

Jeff works on this project across multiple machines, sync'd via git. Two repos are in play:

- The workspace repo at `/Users/jeff/jwm/proj/emacs-config/` (tracks `specs/`, this `CLAUDE.md`, `spec-shapes.md`, `skills/`, `justfile`, `reference-repos.list`, `reference-configs.md`).
- The `literate-emacs.d` bare repo and its worktrees (tracks the literate config and the tangled `init.el`).

**Branches sync; worktrees do not.** A worktree's `.git` pointer file contains absolute filesystem paths, so worktree directories are not portable across machines. The branch is the shared abstraction — sync via `git push` / `git pull`. On a new machine, create a fresh worktree from the (already-sync'd) branch.

What does *not* cross machines:

- Worktree directories under `literate-emacs.d/<feature>/` — recreate per machine via `git worktree add`.
- The per-worktree `info/exclude` for `TASK.md` — re-add per machine.
- `TASK.md` itself — gitignored; reconstruct from chat + the originating spec if needed.
- `~/.emacs.d/init.el` symlink target — repoint per machine.
- `reference-emacs-configs/` cache — regenerate via `just ref-show-plan`.
- Git hooks in `literate-emacs.d/.bare/hooks/` — install via `just install-fixup-hook` from the workspace root. Canonical source: `hooks/pre-push` (tracked).

### Session-start sync

At the start of any planning or implementation session, sync both repos with origin. The check is read-only; the pull is Jeff-side.

```sh
# Workspace repo
cd /Users/jeff/jwm/proj/emacs-config && git fetch && git status -sb
# if behind: git pull --ff-only

# literate-emacs.d bare repo
cd /Users/jeff/jwm/proj/emacs-config/literate-emacs.d/.bare && git fetch origin

# Each active worktree (main and any feature)
cd /Users/jeff/jwm/proj/emacs-config/literate-emacs.d/main && git status -sb
# if behind: git pull --ff-only
```

Claude can run the read-only checks (`git fetch`, `git status -sb`) and report drift; Jeff runs any `git pull` himself. The `emacs-spec-intake` skill includes this as step 0 of any spec-driven work. Drift is surfaced, not gated — Jeff decides whether to sync first or proceed against current state.

## literate-emacs.d — the active project

This is a **bare git repo with worktrees**. All active work happens inside a worktree directory (e.g., `main/`), never at the `literate-emacs.d/` level itself.

For project conventions, key files, and architecture, read:
`literate-emacs.d/main/CLAUDE.md`

Future feature branches will appear as sibling directories to `main/` (e.g., `literate-emacs.d/some-feature/`). Each worktree is an independent checkout of a branch.

## reference-emacs-configs — read-only references

`reference-emacs-configs/` is a local cache of other developers' Emacs configs used as ground truth during investigations. The directory is gitignored at workspace level — repos in it are *not* committed; each has its own upstream origin.

**Tracked repos** are listed in `reference-repos.list` at the workspace root. Each line is three whitespace-delimited fields: `name url last-known-sha`. The `last-known-sha` is the upstream commit at which we last analyzed the repo; comparing it to current upstream tells us what's new since then. A SHA of `-` means the inventory has not captured a local HEAD for that repo yet.

The synthesis file `reference-configs.md` is the canonical home for reference-repo analysis: what each tracked repo is for, which repos are active references, and what we've already extracted from each. The inventory tracks registered repos; the synthesis covers the subset we actively analyze. Roadmap files such as `literate-emacs.d/main/emacs-2026-landscape.org` should link to this synthesis rather than duplicating per-repo surveys.

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
- A TASK.md is the plan-of-record for one worktree implementing one slice of a spec. It is gitignored and disposable.

When a spec arrives, Claude reads it, may discuss approach in chat, then (after a worktree is created) writes a TASK.md whose Goal narrowly restates one sub-goal of the spec and whose Why links back to `specs/NNN-….md`. A single broad spec (like `003`, "AI/LLM integration") can produce multiple TASK.md files across multiple worktrees.

Before starting work in a worktree, Claude should look in `specs/` for a relevant numbered spec. If the work has no spec, Claude surfaces that — for anything multi-step, it may be worth writing a spec first so the intent is captured durably rather than only in chat.

Specs come in a handful of recognizable shapes (broad exploratory, narrow directive, pushback, extension). `spec-shapes.md` at the workspace root catalogs those shapes — what to look for, what to investigate, how to decompose. Read it when handed a spec. The catalog is meant to evolve as new specs reveal new shapes.

## TASK.md convention

When working in a worktree (including `main/`), a `TASK.md` file in the worktree root describes what that worktree is currently working on. This file is **not tracked in git** (it is gitignored or excluded per-worktree). It provides immediate context to any Claude session about the current goal, approach, and relevant notes.

If a worktree has a `TASK.md`, read it before starting any work in that worktree.

## Feature worktrees (for Claude agents)

Claude agents working on this project run in a sandbox that mounts `/Users/jeff/jwm/proj/emacs-config/` at a different absolute path (`/sessions/<session-id>/mnt/emacs-config/`). Git worktrees record absolute paths in their metadata, so a worktree created from one side has a `.git` pointer that cannot be resolved from the other. File tools (Read/Write/Edit) translate paths automatically and work either way — only `git` commands are affected.

`~/.emacs.d/init.el` is a symlink. Its default target is `literate-emacs.d/main/init.el` (main's tangled output). To test a sub-goal's changes without merging, the symlink must be repointed at the feature worktree's `init.el`; a fresh Emacs then loads that `init.el` and picks up the sub-goal's config. `~/.emacs.d/` is outside the sandbox mount, so Claude cannot change the symlink directly — this is always a Jeff-side command.

**Rule: Claude does not edit files in `main/` for a new task or sub-goal.** At the start of any implementation phase, Claude asks Jeff to create a feature worktree before it begins editing. The commands Jeff runs:

```sh
cd /Users/jeff/jwm/proj/emacs-config/literate-emacs.d/main
git worktree add ../<feature> -b <feature>
cd ../<feature>
GITDIR="$(git rev-parse --git-dir)"
mkdir -p "$GITDIR/info"
echo 'TASK.md' >> "$GITDIR/info/exclude"
ln -sf "$PWD/init.el" ~/.emacs.d/init.el
```

The `git rev-parse --git-dir` form is necessary because `.git` inside a worktree is a pointer file, not a directory, so plain `.git/info/exclude` won't resolve via the shell. The `mkdir -p` step is required because `git worktree add` does not always create `info/` inside the worktree's gitdir. The `ln -sf` step repoints `~/.emacs.d/init.el` at this worktree's tangled output. Note: the worktree's `init.el` starts identical to main's — Jeff still needs to tangle inside the worktree before restarting Emacs to actually pick up the sub-goal's changes.

After Jeff confirms the worktree exists, Claude writes `TASK.md` and edits source files inside `literate-emacs.d/<feature>/`, using `/Users/jeff/...` paths throughout. Tangling and committing happen on Jeff's side.

Once the branch is merged and `init.el` regenerated, the worktree can be cleaned up. The `init.el` symlink must be pointed back at `main` *before* the worktree is removed, or the symlink dangles on next Emacs start:

```sh
cd /Users/jeff/jwm/proj/emacs-config/literate-emacs.d/main
ln -sf "$PWD/init.el" ~/.emacs.d/init.el
git worktree remove ../<feature>
git branch -d <feature>
```

### Cross-machine continuation

To pick up a feature branch on a different machine after it was started elsewhere and pushed to origin:

```sh
# Sync the bare repo so origin/<feature> is known locally
cd /Users/jeff/jwm/proj/emacs-config/literate-emacs.d/.bare
git fetch origin

# Create a fresh worktree tracking the existing remote branch
cd /Users/jeff/jwm/proj/emacs-config/literate-emacs.d/main
git worktree add -B <feature> ../<feature> origin/<feature>
cd ../<feature>
GITDIR="$(git rev-parse --git-dir)"
mkdir -p "$GITDIR/info"
echo 'TASK.md' >> "$GITDIR/info/exclude"
ln -sf "$PWD/init.el" ~/.emacs.d/init.el
```

The `-B <feature>` form creates or resets a local branch to match `origin/<feature>`, so the worktree is a normal tracking branch on this machine. The per-worktree `info/exclude`, the symlink, and `TASK.md` (reconstructed from chat + the originating spec) are all per-machine state and have to be re-established here.

### Sub-goal pre-implementation checklist

Before editing files in a new worktree, Claude states in the chat message that kicks off implementation that the following are in place (or explicitly asks Jeff to set them up):

1. Worktree exists at `literate-emacs.d/<feature>/`.
2. `~/.emacs.d/init.el` is repointed at the worktree's `init.el`.
3. If the sub-goal adds new packages, `M-x package-refresh-contents` is expected before tangle.

### Tangling and verifying via justfile

Each worktree (and `main/`) contains a `justfile` with shell-side recipes for tangling and basic load-checking. Use these instead of `M-x org-babel-tangle` when scripting or when a quick syntax check is more useful than starting Emacs.

```sh
cd literate-emacs.d/<worktree>
just --list      # show recipes
just tangle      # regenerate init.el from jeff-emacs-config.org
just verify-tangle      # tangle, then load init.el in batch -Q to catch errors
```

`just tangle` runs:

```sh
emacs --batch -l org \
      --eval '(org-babel-tangle-file "jeff-emacs-config.org")'
```

Confirmed byte-identical to interactive `M-x org-babel-tangle`. Cold-run wall time is ~480ms on Apple Silicon.

In TASK.md "Tangle steps" sections, Claude should suggest `just tangle` (shell-side, no Emacs context-switch) as the primary path, and `M-x org-babel-tangle` as the alternate. Claude itself cannot run these in the sandbox today (no `emacs` binary), but the recipes are the same on both sides.

### Git workflow

Sub-goal commits use **fixup commits** during the worktree's life (in-flight checkpoints) and autosquash rebase at sub-goal close. The full workflow — fixup loop, the literate-config rule that org and `init.el` must commit together, close pattern, pre-push hook — lives in `literate-emacs.d/main/CLAUDE.md`'s "Git workflow within a feature worktree" section. The per-worktree justfile carries `just fixup`, `just squash`, and `just fixups-pending`. The pre-push warning hook is per-machine setup; install via `just install-fixup-hook` from the workspace root.

### Info-node grounding for investigations

`literate-emacs.d/main/info-dir.txt` is a snapshot of all Info manuals visible to Jeff's Emacs (generated via `(info "(dir)")` after `package-initialize`). It's the canonical reference for what package documentation is locally available.

**Standard workflow:** any investigation that might reference Emacs / package docs begins with Claude reading `info-dir.txt` (via the Read tool). This grounds analysis in Jeff's specific install state — which packages have manuals, what version, what aliases — rather than generic 2026 emacs knowledge.

Refresh after package install/remove:

```sh
cd literate-emacs.d/<worktree>
just info-dir-update
git add info-dir.txt && git commit -m "info-dir: refresh after package changes"
```

For specific Info nodes (e.g. when reading a section of magit's manual):

```sh
just info-node "(magit) Worktree"
```

Writes `info-node.txt` in the cwd of whichever worktree's justfile was invoked (typically `literate-emacs.d/main/info-node.txt`). Overwritten each call. Per-investigation; not committed. Jeff attaches the file to the session; Claude reads it via Read. The recipe accepts any node reference of the form `"(MANUAL) NODE"` — including `"(MANUAL) Top"` for a manual's table of contents when `info-dir.txt`'s one-line description isn't enough to guess the right section name.

When proposing info-node fetches, Claude states up front *which nodes* and *why each one* — discovery should be explicit, not blind.

### Verification step style

When writing verification steps inside a `TASK.md`, Claude follows three rules:

- **Match verification depth to behavior change.** For sub-goals that produce *no* expected user-visible change in live Emacs (pure deletions of unused declarations, refactors that should be byte-identical, doc-only edits), `just verify-tangle` is sufficient on its own. It tangles + loads `init.el` in batch `-Q`; a clean exit proves both tangle correctness and load success in one shot. Skip the longer flows (step-0 grep checks, live-Emacs keystroke walks) — they have nothing meaningful to confirm. For sub-goals that *do* change behavior (new packages, new bindings, new modes, anything Jeff would notice), keep the fuller verification flow with the bullets below.
- **Prefer keystrokes over typed commands.** Use `C-h v <var>` rather than `M-x describe-variable RET <var> RET`, `C-h f <fn>` rather than `M-x describe-function`, `C-h k <keys>` rather than `M-x describe-key`. Reading a keystroke in a checklist builds muscle memory; typing a command name at `M-x` does not.
- **Isolate preconditions.** Each pass-criterion should either be provable by a single command whose failure mode is unambiguous, or should explicitly list what else needs to be true for the test to pass. When a test's pass depends on the symlink or tangle state, add a step-0 check (`readlink ~/.emacs.d/init.el`, or `grep <change> <worktree>/init.el`) that isolates that precondition before the live-emacs test.

### Meta-doc edits (in `main/` or in the workspace)

The worktree rule has a narrow exception: documentation-only files that do not get tangled into `init.el` may be edited directly. The rationale is that meta-doc edits don't risk breaking the live Emacs config, so a feature worktree adds friction without benefit. Examples:

- `literate-emacs.d/main/emacs-2026-landscape.org` — backlog tracker (repo-level)
- `literate-emacs.d/main/emacs-cheat-sheet.org` — when adding rows to existing sections that don't depend on a new `use-package` block (cheat-sheet edits *coupled* to a new sub-goal still go through a worktree alongside the config change)
- `/Users/jeff/jwm/proj/emacs-config/CLAUDE.md` — workspace-level meta-doc (this file)

**Rule: every direct edit Claude makes to a tracked file must be accompanied in the same response by an explicit commit command** that Jeff can paste. Without the commit, the edit accumulates as silent uncommitted state, and merge conflicts later when sub-goal worktrees touch the same file.

For repo-level files (in `literate-emacs.d/main/`):

```sh
cd /Users/jeff/jwm/proj/emacs-config/literate-emacs.d/main && \
  git add <file> && git commit -m "<short summary>"
```

For workspace-level files (this `CLAUDE.md`, etc.):

```sh
cd /Users/jeff/jwm/proj/emacs-config && \
  git add <file> && git commit -m "<short summary>"
```
