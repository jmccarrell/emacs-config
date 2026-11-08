# 017 — How Emacs runs and monitors parallel agent work

I want AI to help Emacs help me write code, PostgreSQL in particular (spec 015).
What I don't understand, and see as a real limitation, is that Emacs runs its Lisp
on one thread. If agents are to work in parallel, streaming results back while
Emacs manages or monitors them, Emacs must have primitives that make that
possible.

## Ask

1. Find the Emacs primitives for asynchronous work: what each one lets run at the
   same time as the editor, and what still blocks it.
2. Find how every reference config in `reference-repos.list` talks to its AI
   packages, and which of those primitives the packages use underneath.
   jwiegley in particular.
3. From that evidence, decide how my setup should launch and monitor parallel
   agent work.

## Scope

Planning only: the outcome is a decision recorded in this spec, not configuration
in `literate-emacs.d`. A PostgreSQL-aware agent workflow is the motivating use
case and comes after the decision.

Related: spec 010 covers the opposite direction, an external agent calling into
Emacs.

## Outcome

<!-- filled in when the decision ticket closes -->
