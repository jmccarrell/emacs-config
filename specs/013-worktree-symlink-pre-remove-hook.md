# 013 — Guard the `~/.emacs.d/init.el` symlink with a worktrunk pre-remove hook

*Drafted by Claude at Jeff's request ("spec the pre-remove hook"), unlike specs 001–012
which are Jeff's own briefs. Edit freely — this is a proposal, not a record of intent.*

## The ask

Make the `~/.emacs.d/init.el` symlink check mechanical instead of prose.

Workspace `CLAUDE.md` tells Claude to run `readlink ~/.emacs.d/init.el` before removing a
worktree, and to repoint with `just link` if it aims into the doomed checkout. That is the
last honor-system rule in the worktree flow: worktrunk PR #25 (dotfiles) converted branch
deletion from prose to something `wt remove` enforces, and emacs-config PR #13 confirmed —
by test — that worktrunk does *not* extend that protection to this symlink:

```
✓ Removed feat worktree & branch (same commit as main, _)
resolves? NO — DANGLING
```

No warning. The next Emacs start reads a dangling `init.el`. A `pre-remove` hook closes
the gap: a non-zero exit aborts the removal.

## Verified behavior

Tested against worktrunk v0.70.0 in throwaway repos, with a project `.config/wt.toml`
carrying a `pre-remove` hook. All four results are empirical, not from the docs.

| Scenario | Result |
|---|---|
| Symlink points **into** the worktree | `✗ pre-remove command failed: exit status: 1` — worktree **and** branch both survive |
| Symlink points elsewhere | Removal proceeds normally; symlink intact |
| `wt remove --no-hooks` | Gate bypassed, symlink left dangling |
| Unapproved hook, **non-interactive** shell | `✗ Cannot prompt for approval in non-interactive environment` — removal fails |

The last row is the one that shapes the design, and it is not obvious from the docs.

## Design decisions

### 1. The hook lives in `literate-emacs.d/.config/wt.toml`

Only that repo's worktrees can host an `init.el`; workspace (`emacs-config`) worktrees
never do, so they need no hook. Project config is git-tracked, so the guard travels to
Jeff's other machines with a normal `git pull` — matching how `worktree-path` was seeded
through the dotfiles repo rather than configured per machine.

Implementation therefore spans two repos: a PR to `literate-emacs.d` adding the file, and
a follow-up doc edit in `emacs-config`.

### 2. Abort — do not auto-repoint

The hook could just run `just link` from the main checkout and let removal proceed. It
should not. `CLAUDE.md` § Global Emacs state disclosure makes `just link` a *disclosed*
action: Claude may run it, but must state target and rollback in the same message. A hook
firing it silently during teardown is exactly the unannounced global-state change that
section exists to prevent. Aborting keeps the human decision where it already is, and
matches the "hard gate … do not fall back" treatment worktree creation gets.

### 3. Jeff pre-approves once per machine; Claude does **not** pass `-y`

Worktrunk requires approval before running project-config commands. Two ways to satisfy it:

- `wt config approvals add` — Jeff approves once, interactively, stored in `approvals.toml`.
- `wt remove -y` — skips the approval prompt entirely.

**Choose the first, and forbid the second for this purpose.** `-y` means any command in a
tracked `.config/wt.toml` executes unreviewed — including one that arrived via `git pull`
from a branch nobody read closely. Since Claude's Bash runs non-interactive, an
unapproved or *changed* hook then fails loudly rather than executing silently: the
approval requirement becomes a review checkpoint instead of an obstacle.

Cost: `approvals.toml` is per-machine state that does not travel with the repo. It joins
the existing per-machine list in `CLAUDE.md` § Multi-machine workflow, alongside the
symlink target itself.

### 4. `--no-hooks` goes on Claude's never-list

It bypasses the gate — verified above. This is the same rule as "if the next required step
is on the never-list and Jeff is unavailable: stop and ask; never work around it." Worth
naming explicitly, because the failure message helpfully advertises the flag:
`↳ To skip pre-remove hooks, re-run with --no-hooks`.

## Sketch

```toml
# literate-emacs.d/.config/wt.toml
pre-remove = """
test "$(readlink ~/.emacs.d/init.el)" != "{{ worktree_path }}/init.el" || {
  echo "ABORT: ~/.emacs.d/init.el points into this worktree."
  echo "Repoint first:  cd {{ repo_path }} && just link"
  exit 1
}
"""
```

Unresolved in the sketch, to settle during implementation:

- **Path-form robustness.** The comparison assumes `{{ worktree_path }}` and `readlink`
  agree on absolute-path form. It held in testing, but should be checked against a real
  `literate-emacs.d.worktrees/<feature>` path, and hardened (compare resolved dirnames)
  if it does not.
- **Symlink absent entirely** (cold machine, no `~/.emacs.d/init.el`): `readlink` yields
  empty, the comparison passes, removal proceeds. Believed correct; confirm.
- **Whether the message should name `just link`'s disclosure requirement**, or trust
  `CLAUDE.md` to carry it.

## Verification plan

1. Real worktree in `literate-emacs.d.worktrees/`, symlink repointed at it via `just link`
   → `wt remove` aborts; worktree, branch, and symlink all intact.
2. `just link` back to the main checkout → `wt remove` succeeds; symlink still resolves.
3. Fresh clone, hook unapproved, non-interactive → removal fails with the approval error
   rather than running the hook.
4. `wt config approvals add`, then repeat 1 and 2 → same outcomes without `-y`.
5. Existing `rust-cargo-compile-command` worktree untouched throughout.

## Doc updates this implies

- `emacs-config/CLAUDE.md` § Feature worktrees — the symlink check becomes "the hook
  enforces this; here is what its abort looks like," not "remember to check."
- Same file § Multi-machine workflow — add `approvals.toml` to per-machine state.
- `~/.claude/CLAUDE.md` § Git authority — add `--no-hooks` to the never-list, since the
  reasoning is general rather than emacs-specific.

## Out of scope

Other hook points (`post-switch` running `just tangle`, `pre-commit` running
`just verify-tangle`) are plausible but independent. This spec covers the one hazard that
is currently unguarded.
