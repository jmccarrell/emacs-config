# 020 — An Org agenda for GTD-style project management

I manage projects in Org with my own states (`TODO NEXT DOING WAITING | DONE
CANCELLED DEFERRED`), capture templates and refile, but I have no custom agenda
commands. I like a Getting Things Done flow, and I want the agenda to show me
what to do next, which projects are stuck, and what matters most by priority.
`research/org-agenda-gtd.md` (#73) found real GTD agenda setups in
steve-purcell, jwiegley, sacha-chua and my own greendog-gtd snapshot, and a
priority view in protesilaos. I want to choose among those patterns rather
than invent new configuration.

Each agenda file splits into `* Tasks` and `* Projects`, and I don't find the
distinction helpful: what goes under each is arbitrary, and the file is
already the work stream. I want to replace it.

## Ask

1. Replace the Tasks/Projects split. The proposed layout:
   - One file per work stream, as `lab.org`, `emacs.org` and `jeff-ci.org`
     already are.
   - Top-level headings are projects, each with its next actions beneath it,
     plus one `* Misc` heading for tasks that belong to no project.
   - `todo.org` mixes several work streams; its top-level headings become
     areas (home, family and estate, finance and investing, learning and AI),
     or the larger ones move to files of their own.
   - `someday.org` takes the same layout, so moving a project in or out stays
     one refile.
   - Decide how a project is marked: a non-inherited `project` tag is
     proposed, over a `PROJECT` keyword or structure only (a TODO with TODO
     children).
2. Decide what `DEFERRED` means: Someday/Maybe as a live state, or closed for
   now as it is today.
3. Decide whether context tags (`@home`, `@work`, …) are worth adding, or
   whether my file layout already serves as the context.
4. Decide the priority range and default, and how priority shows in the
   agenda: a separate block for important undated items, sorting only, or
   both.
5. Decide whether the first slice uses only built-in Org, or also tries
   `org-super-agenda` or `org-ql`.
6. From those decisions, list the config changes, each sized to its own
   `literate-emacs.d` worktree and pull request. The starting candidates are
   `org-stuck-projects`, one GTD block agenda, a weekly-review command, and
   the refile settings from steve-purcell.

## Scope

Planning only: the outcome is the list of changes, not configuration in
`literate-emacs.d`. The plan includes restructuring my Org files under
`~/jwm/todo`: which files change, in what order, and whether
`org-refile-targets` changes with them. Capture, habits and `org-edna` stay
out unless a decision above needs them.

## Outcome

### Decided

- **Projects** carry a `project` tag that children don't inherit (listed in
  `org-tags-exclude-from-inheritance`), as in sacha-chua.
- **`DEFERRED` becomes a live state.** It moves left of the `|`, so deferred
  items stay open and can have their own block in the weekly review.
- **Priority**: `A` to `C` with `B` as the default. The dashboard opens with
  protesilaos's block of `[#A]` tasks that have no scheduled date or deadline;
  the rest of the agenda keeps the default urgency sort.
- **Built-in Org only** for the first slice; `org-super-agenda` and `org-ql`
  wait until a built-in view falls short.

- **No context tags.** The file is the work stream, and the agenda groups and
  filters by it. The tags already on headings in `someday.org` (`emacs`,
  `read_review`, `@train`, `org`, and others) are removed, so `project` is the
  only tag in the agenda files.

### Open

- The build order.
