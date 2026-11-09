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

Decided in "Choose how Emacs launches and monitors parallel agent work"
(#36), on the wayfinder map #31. The evidence is in that map's research
tickets (#32-#35).

- **No Lisp threads, no child Emacs.** Agents always run as outside
  processes. Emacs follows them through process filters, sentinels and
  timers, which is what every reference config and AI package does.
- **Short requests go to gptel.** One prompt, one streamed answer into a
  buffer; several may run at once in different buffers.
- **Long-running coding agents go to claude-code-ide.** The `claude` CLI runs
  in a **vterm** buffer, one or more sessions per project, so my existing
  Claude Code settings, skills and CLAUDE.md files apply. Through its
  WebSocket connection Claude opens files, reads the selection and
  diagnostics, and proposes edits as ediff sessions.
  - Claude Code's permission prompts and allow-lists stay on; no
    `--dangerously-skip-permissions`.
  - It loads on any machine where `claude` is on `PATH`, not only where
    `jwm/personal-mac-p` is true.
  - vterm builds its native module with cmake on each machine.
- **Monitoring starts with what the package gives:** its session list,
  switching, and stopping one or all sessions. A status list fed by Claude
  Code hooks (finished, waiting for input) comes later.
- **Tools.** Turn on the built-in Emacs tools
  (`claude-code-ide-emacs-tools-setup`). PostgreSQL tools (run a query in the
  SQL session, read the schema, fetch an EXPLAIN plan) come later, on the
  spec 015 setup. Each tool is written once and offered to both Claude and
  gptel.
- **No blocking calls in agent code I write.** Every tool or helper is
  asynchronous: `make-process` with a callback, a timeout timer, and a
  callback that runs only once. No `call-process`,
  `shell-command-to-string` or `url-retrieve-synchronously`.

Open decisions on the map: how Claude Code session status reaches Emacs,
which PostgreSQL tools an agent gets, and how one tool definition serves
both gptel and claude-code-ide.
