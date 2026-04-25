# Workspace-level recipes for managing reference Emacs configs.
#
# The registry of tracked repos lives in `reference-repos.list`
# (one line per repo: "name url"). Use the recipes below to read
# and modify it; don't edit the list by hand if you can avoid it.
#
# See `reference-configs.md` for what each tracked repo is for.

# Default: print the recipe list.
@_:
    just --list

# Print the current registry.
ref-list:
    @cat reference-repos.list

# Add a repo to the registry. Use `just ref-sync` after to clone it.
# Usage: just ref-add NAME URL
ref-add name url:
    @if awk -v n='{{name}}' '$1 == n { exit 0 } END { exit 1 }' reference-repos.list; then \
       echo "ref-add: '{{name}}' is already registered" >&2; \
       exit 1; \
     fi
    @echo '{{name}} {{url}}' >> reference-repos.list
    @echo "ref-add: added {{name}} -> {{url}}"

# Ensure every registered repo is present in reference-emacs-configs/
# and forced to match upstream's current default branch. Clones if
# missing. For existing repos: fetches, then `git checkout -B` to
# upstream's default branch tip — handles both master->main renames
# and divergent history. Any local commits in reference repos are
# silently discarded (these are caches; we never edit them).
# Warns and continues on individual failures.
ref-sync:
    @mkdir -p reference-emacs-configs
    @while read name url; do \
        if [ -d "reference-emacs-configs/${name}" ]; then \
          echo "==> sync ${name}"; \
          dir="reference-emacs-configs/${name}"; \
          if ! git -C "$dir" fetch origin --prune --quiet; then \
            echo "WARN: fetch failed for ${name} (continuing)" >&2; continue; \
          fi; \
          git -C "$dir" remote set-head origin --auto >/dev/null 2>&1 || true; \
          default=$(git -C "$dir" rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's|^origin/||'); \
          if [ -z "$default" ]; then \
            echo "WARN: cannot determine default branch for ${name}; skipping" >&2; continue; \
          fi; \
          git -C "$dir" checkout -B "$default" --quiet "origin/$default" \
            || echo "WARN: checkout failed for ${name} (continuing)" >&2; \
        else \
          echo "==> clone ${name}"; \
          git clone --quiet "${url}" "reference-emacs-configs/${name}" \
            || echo "WARN: clone failed for ${name} (continuing)" >&2; \
        fi; \
      done < reference-repos.list
    @echo "ref-sync: done"
