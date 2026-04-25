# emacs-config workspace

This folder is a workspace containing Jeff's Emacs configuration project and a collection of reference configurations. The workspace folder is itself a git repository (default branch `main`); `literate-emacs.d/` and `reference-emacs-configs/` are gitignored at this level — each contains its own independent git repo. The workspace repo tracks workspace-level files like this `CLAUDE.md`.

## Structure

```
emacs-config/
├── literate-emacs.d/        ← Jeff's Emacs config (worktree-enabled repo)
│   ├── .bare/               ← bare git repo (origin: git@github.com:jmccarrell/literate-emacs.d.git)
│   ├── .git                 ← pointer file to .bare (do not edit)
│   └── main/                ← main worktree (and any future feature worktrees)
│       ├── CLAUDE.md        ← repo-level context: conventions, key files, architecture
│       └── ...
└── reference-emacs-configs/ ← cloned reference repos (read-only, for inspiration)
    ├── abo-abo-dotemacs/
    ├── bbatsov-dotemacs/
    ├── howardabrams-dot-files/
    ├── jwiegley-dotemacs/
    ├── sacha-chua-dotemacs/
    └── ... (14 repos total)
```

## literate-emacs.d — the active project

This is a **bare git repo with worktrees**. All active work happens inside a worktree directory (e.g., `main/`), never at the `literate-emacs.d/` level itself.

For project conventions, key files, and architecture, read:
`literate-emacs.d/main/CLAUDE.md`

Future feature branches will appear as sibling directories to `main/` (e.g., `literate-emacs.d/some-feature/`). Each worktree is an independent checkout of a branch.

## reference-emacs-configs — read-only references

These are cloned copies of well-known Emacs configurations used for research and inspiration. They are **not actively developed** — treat them as read-only reference material. Do not commit to or modify these repos.

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

### Sub-goal pre-implementation checklist

Before editing files in a new worktree, Claude states in the chat message that kicks off implementation that the following are in place (or explicitly asks Jeff to set them up):

1. Worktree exists at `literate-emacs.d/<feature>/`.
2. `~/.emacs.d/init.el` is repointed at the worktree's `init.el`.
3. If the sub-goal adds new packages, `M-x package-refresh-contents` is expected before tangle.

### Verification step style

When writing verification steps inside a `TASK.md`, Claude follows two rules:

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
