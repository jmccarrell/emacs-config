While working on spec 003 and 006, it was suggested in some AI chat workflow or other that a more useful connection
between AI running in an external process and emacs itself could be established.
The ability to query live emacs state, such as keymaps, loaded packages, etc. would shorten the cycle that now uses emacs in batch mode.

The goal of this spec is to explore that space.

Areas to research:
- What have other emacs devotees in our reference repos done in this regard, if anything.
- Is the concept of an MCP server relevant and applicable to this use case?
- Given the gptel interface, could we connect AI running locally or in the cloud through some other emacs layer plumbing?
