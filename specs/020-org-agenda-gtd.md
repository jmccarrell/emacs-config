# 020 — An Org agenda for GTD-style project management

I manage projects in Org with my own states (`TODO NEXT DOING WAITING | DONE
CANCELLED DEFERRED`), capture templates and refile, but I have no custom agenda
commands. I like a Getting Things Done flow, and I want the agenda to show me
what to do next, which projects are stuck, and what matters most by priority.
`research/org-agenda-gtd.md` (#73) found real GTD agenda setups in
steve-purcell, jwiegley, sacha-chua and my own greendog-gtd snapshot, and a
priority view in protesilaos. I want to choose among those patterns rather
than invent new configuration.

## Ask

1. Decide how a project is marked: a `PROJECT` keyword, a `project` tag, or
   structure only (a TODO with TODO children).
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
`literate-emacs.d`. My Org files may need small changes to fit (a tag or
keyword on existing projects); the plan says which. Capture, habits and
`org-edna` stay out unless a decision above needs them.

## Outcome

To be filled in once the decisions are made.
