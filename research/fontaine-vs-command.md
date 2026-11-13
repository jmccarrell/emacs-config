# fontaine versus a small command for switching fonts live

**Question** (#64, under map #62): how should `variable-pitch` and
`fixed-pitch` be switched in a running Emacs while the Noto candidates are
compared, and possibly for good?  The options are Protesilaos's `fontaine`
and a small `jwm/` command that calls `set-face-attribute` after a
`completing-read` over `(font-family-list)`.

**Scope.** Facts and trade-offs only.  The choice belongs to #67.  Nothing
was installed and Jeff's Emacs was not changed.  The fontaine claims below
come from reading its source.  They were not checked by running it.

Sources: fontaine at
[`b497b86`](https://github.com/protesilaos/fontaine/tree/b497b86ff0502715c15757716df75fee01e3cfd4)
(version 3.1.0, 2026-06-29), installed `mixed-pitch-20210304.1900` (the same
as upstream HEAD
[`519e05f`](https://gitlab.com/jabranham/mixed-pitch/-/blob/519e05f74825abf04b7d2e0e38ec040d013a125a/mixed-pitch.el)),
installed `zenburn-theme-20260901.1544`, the `faces.el` and `custom.el`
shipped with Emacs 31.1, and `literate-emacs.d` at
[`ceb2d0f`](https://github.com/jmccarrell/literate-emacs.d/blob/ceb2d0fb1f428dc3f335c14a71b9edc82b828197/jeff-emacs-config.org).

## Short answer

- **fontaine can leave `default` alone**, but only if every preset leaves
  out the `:default-*` keys *and* a non-empty `t` preset exists.  If there
  is no `t` preset, or it is empty, fontaine falls back to built-in generic
  families and sets `default` to "Monospace".
- **fontaine comes from GNU ELPA** (3.1.0 in the local archive cache).
  MELPA does not carry it.  It requires Emacs 29.1.
- **Persistence:** fontaine saves only the *name* of the last preset, in
  `~/.emacs.d/fontaine-latest-state.eld`.  That file belongs to one machine
  and is not tracked.  A `jwm/` command saves nothing unless it is written
  to.  For both, the permanent setting is whatever the literate config sets
  at startup.
- **Theme reload:** zenburn has no spec for `variable-pitch` or
  `fixed-pitch`, so reloading it leaves either approach's settings in place.
  fontaine also survives a theme that *does* set those faces, because it
  applies its specs through a theme of its own.
- **mixed-pitch limits both options the same way, and the current setup
  shows the same limits:**
  1. It copies the `variable-pitch` family when the mode turns on, so
     buffers already open keep the old font until the mode is toggled.
  2. It ignores `variable-pitch`'s `:height` unless `mixed-pitch-set-height`
     is set.  So today's `:height 1.1` has no effect in org buffers.
  3. It keeps code and tables on the **`default`** family, not on
     `fixed-pitch`.  The details are in the mixed-pitch section below.

## fontaine

### Archive and install

- The config's archives are GNU ELPA and MELPA (both through MirrorService),
  with priorities MELPA 30 and GNU 5.  NonGNU is removed
  ([config L186-L213](https://github.com/jmccarrell/literate-emacs.d/blob/ceb2d0fb1f428dc3f335c14a71b9edc82b828197/jeff-emacs-config.org#L186-L213)).
- The local GNU archive cache (`~/.emacs.d/elpa/archives/gnu/archive-contents`,
  refreshed 2026-11-12) lists `fontaine` 3.1.0, needing `((emacs (29 1)))`.
  The MELPA cache has no `fontaine` entry, so the archive priorities make
  no difference: it would come from GNU.  The manual names GNU ELPA as the
  source ([README.org § GNU ELPA package](https://github.com/protesilaos/fontaine/blob/b497b86ff0502715c15757716df75fee01e3cfd4/README.org#gnu-elpa-package)).
- It is not installed and has no Info manual in `literate-emacs.d/info-dir.txt`.
  Adopting it means adding `fontaine` to `jwm/required-packages`
  ([config L236-L246](https://github.com/jmccarrell/literate-emacs.d/blob/ceb2d0fb1f428dc3f335c14a71b9edc82b828197/jeff-emacs-config.org#L236-L246)).

### Which faces it sets

`fontaine-faces` lists `default`, `fixed-pitch`, `fixed-pitch-serif`,
`variable-pitch`, `mode-line-active`, `mode-line-inactive`, `header-line`,
`line-number`, `tab-bar`, `tab-line`, `bold` and `italic`
([fontaine.el L123](https://github.com/protesilaos/fontaine/blob/b497b86ff0502715c15757716df75fee01e3cfd4/fontaine.el#L123)).
Each face takes family, weight, slant, width and height keys, named
`:<face>-family` and so on.

`fontaine--get-face-spec` builds a spec for a face only if one of those
keys is non-nil.  A face with no keys gets no spec and is left alone
([L378](https://github.com/protesilaos/fontaine/blob/b497b86ff0502715c15757716df75fee01e3cfd4/fontaine.el#L378)).
One special case: if `fixed-pitch` has no family, it falls back to
`:default-family`.  If that key is unset as well, the fallback is nil.

### Leaving `default` alone: yes, with a condition

To build a preset's properties, fontaine takes the preset's own list,
then the list of the preset it `:inherit`s, then
`(or (alist-get t presets) fontaine-generic-face-families)`
([L361](https://github.com/protesilaos/fontaine/blob/b497b86ff0502715c15757716df75fee01e3cfd4/fontaine.el#L361)).
`fontaine-generic-face-families` is `:default-family "Monospace"`,
`:fixed-pitch-family "Monospace"`, `:fixed-pitch-serif-family "Monospace"`,
`:variable-pitch-family "Sans"`
([L354](https://github.com/protesilaos/fontaine/blob/b497b86ff0502715c15757716df75fee01e3cfd4/fontaine.el#L354)).

So:

| `fontaine-presets` shape | what happens to `default` |
|---|---|
| named presets plus a `t` preset with at least one property, and no `:default-*` key anywhere | not touched |
| no `t` preset | `:family "Monospace"` from the generic fallback |
| `(t)` with an empty plist | the same: `alist-get` returns nil, so the `or` falls through to the generic fallback |

A shape that keeps `default` out (an illustration, not a recommendation):

```elisp
(setq fontaine-presets
      '((helvetica)                                   ; baseline: uses only the t values
        (noto-sans  :variable-pitch-family "Noto Sans")
        (noto-serif :variable-pitch-family "Noto Serif")
        (t :variable-pitch-family "Helvetica Neue"
           :variable-pitch-height 1.1
           :fixed-pitch-family "Hack")))
```

Prot's own presets all set `:default-*`
([prot-emacs-theme.el L198-L289](https://github.com/protesilaos/dotfiles/blob/937ecb5f33c2f95d4016a6e3f19d75ea949eb0a9/emacs/.emacs.d/prot-emacs-modules/prot-emacs-theme.el#L198-L289)),
and so does every example in the manual.  Leaving `default` out is allowed
by the code but is not a pattern any reference config uses.

### How it applies faces

`fontaine--set-faces` calls `custom-theme-set-faces 'fontaine` with specs
limited to `((type graphic))`.  `fontaine` is a synthetic theme that is
enabled and then removed from `custom-enabled-themes`, so "disable all
themes" loops skip it
([L49](https://github.com/protesilaos/fontaine/blob/b497b86ff0502715c15757716df75fee01e3cfd4/fontaine.el#L49),
[L403](https://github.com/protesilaos/fontaine/blob/b497b86ff0502715c15757716df75fee01e3cfd4/fontaine.el#L403)).
It binds `frame-inhibit-implied-resize`, so font changes do not resize the
frame (CHANGELOG 3.1.0).

Side effects:

- **`line-spacing`.** Every `fontaine-set-preset` runs
  `(setq-default line-spacing <preset's :line-spacing>)`, and the value is
  nil when the preset has none
  ([L417](https://github.com/protesilaos/fontaine/blob/b497b86ff0502715c15757716df75fee01e3cfd4/fontaine.el#L417)).
  The config never sets `line-spacing`, so this changes nothing today.
- **Terminal.** In a non-graphical, non-daemon Emacs it shows a warning and
  does nothing
  ([L487](https://github.com/protesilaos/fontaine/blob/b497b86ff0502715c15757716df75fee01e3cfd4/fontaine.el#L487)).
- **Existing `set-face-attribute` lines.** A theme spec is applied through
  `face-spec-recalc`, which first resets the face (see below).  So the
  config's current `set-face-attribute` values for `variable-pitch` and
  `fixed-pitch` are wiped when a preset is applied, and any
  `set-face-attribute` that runs later overrides the preset until the next
  recalc.  Mixing the two needs a fixed order, or one of them removed.

### Persistence

- `fontaine-mode` (global) adds `fontaine-store-latest-preset` to
  `kill-emacs-hook` and to `fontaine-set-preset-hook`
  ([L548](https://github.com/protesilaos/fontaine/blob/b497b86ff0502715c15757716df75fee01e3cfd4/fontaine.el#L548)).
- The store function writes the symbol at the head of
  `fontaine-preset-history` to `fontaine-latest-state-file`, which defaults
  to `(locate-user-emacs-file "fontaine-latest-state.eld")`
  ([L321](https://github.com/protesilaos/fontaine/blob/b497b86ff0502715c15757716df75fee01e3cfd4/fontaine.el#L321),
  [L517](https://github.com/protesilaos/fontaine/blob/b497b86ff0502715c15757716df75fee01e3cfd4/fontaine.el#L517)).
  It saves the preset's name, not its fonts.
- `fontaine-restore-latest-preset` only *reads* that symbol back
  ([L534](https://github.com/protesilaos/fontaine/blob/b497b86ff0502715c15757716df75fee01e3cfd4/fontaine.el#L534)).
  Init has to apply it, and the documented line is
  `(fontaine-set-preset (or (fontaine-restore-latest-preset) 'regular))`
  ([README.org L202](https://github.com/protesilaos/fontaine/blob/b497b86ff0502715c15757716df75fee01e3cfd4/README.org?plain=1#L202)).
- The state file is in `~/.emacs.d/`: Emacs state that git does not track
  and that stays on one machine.  The workspace CLAUDE.md asks for
  disclosure of such state.  The two Macs would each remember their own
  last preset.  Calling `fontaine-set-preset` with a fixed preset and not
  restoring leaves the literate config as the only source of truth.

### Theme reload

The manual says `fontaine-apply-current-preset` has been obsolete since 3.0.0
"because Fontaine is now implemented as a 'theme' and thus does not get
overwritten by other themes"
([README.org § Persist font configurations on theme switch](https://github.com/protesilaos/fontaine/blob/b497b86ff0502715c15757716df75fee01e3cfd4/README.org#persist-font-configurations-on-theme-switch)).
Emacs's own code backs this up:

- `enable-theme` recalculates only the faces the enabled theme lists
  (`custom.el`, `enable-theme`, the `theme-face` branch calls
  `custom-theme-recalc-face`).
- `face-spec-recalc` resets the face, then applies **every** enabled
  theme's spec for it, lowest precedence first, attribute by attribute
  (`faces.el`, `face-spec-recalc`).  The `fontaine` theme's spec is
  therefore applied again whenever any theme recalculates a face fontaine
  sets.  A higher-precedence theme would win only for attributes it sets
  itself.

## mixed-pitch (affects both options)

The config runs `mixed-pitch-mode` from `org-mode-hook` and leaves
`mixed-pitch-set-height` unset
([config L1546-L1572](https://github.com/jmccarrell/literate-emacs.d/blob/ceb2d0fb1f428dc3f335c14a71b9edc82b828197/jeff-emacs-config.org#L1546-L1572)).
In the installed `mixed-pitch.el` (upstream HEAD, last commit 2021-03-05),
the mode body does the following
([mixed-pitch.el L151-L203](https://gitlab.com/jabranham/mixed-pitch/-/blob/519e05f74825abf04b7d2e0e38ec040d013a125a/mixed-pitch.el#L151-203)):

1. It reads `(face-attribute mixed-pitch-face :family)`, which is
   `variable-pitch`'s family, **as a string at the moment the mode turns
   on**.  Then it calls `face-remap-add-relative 'default :family <string>`.
   The remap holds a copy of the name, not a reference to the face.
   Changing `variable-pitch` later has no effect on buffers already open
   until `mixed-pitch-mode` runs again.  Running `(mixed-pitch-mode 1)` in
   a buffer where it is already on removes the old remap and adds a fresh
   one; the 2021-03-05 commit "Avoid applying remap multiple times" added
   that.
2. Height is passed only when `mixed-pitch-set-height` is non-nil.  With
   the current config, `variable-pitch`'s `:height 1.1` **is not applied
   in org buffers**.  It does apply where `variable-pitch` is used
   directly, as with `variable-pitch-mode`.
3. For each face in `mixed-pitch-fixed-pitch-faces` (which includes
   `org-block`, `org-code`, `org-table`, `org-verbatim`, `org-meta-line`,
   `markdown-code-face` and `markdown-inline-code-face`), it adds a remap
   to **`default`'s family** (`fix-pitch` is
   `(face-attribute 'default :family)`).  It never reads `fixed-pitch`.
   Org code and tables are therefore drawn in the frame font (Hack-14 or
   Monaco-12,
   [config L612-L626](https://github.com/jmccarrell/literate-emacs.d/blob/ceb2d0fb1f428dc3f335c14a71b9edc82b828197/jeff-emacs-config.org#L612-L626)),
   whatever `fixed-pitch` is set to.  Only faces that inherit `fixed-pitch`
   themselves would show a `fixed-pitch` change, for example the config's
   `org-modern-label`.

Points 1 and 2 hold whichever way the fonts are switched.  Under fontaine
the refresh fits on `fontaine-set-preset-hook`.  Under a `jwm/` command it
is a loop at the end of the command.

## zenburn

`zenburn-theme.el` has no spec for `variable-pitch` or `fixed-pitch`.  Its
`default` spec sets only foreground and background (line 250), and
`zenburn-variable-pitch` inherits `default` unless `zenburn-use-variable-pitch`
is set (lines 71, 116, 266).  Its `org-block` and `org-table` specs set
colours only (lines 1665, 1697).  So `load-theme 'zenburn` never
recalculates `variable-pitch` or `fixed-pitch`, and values set with
`set-face-attribute` stay.  They would be wiped by a theme that *does* set
those faces, such as the modus or ef themes.

## The `jwm/` command

A sketch, to compare against (not a recommendation):

```elisp
(defun jwm/set-pitch-family (face family)
  "Set FACE (variable-pitch or fixed-pitch) to FAMILY on all frames."
  (interactive
   (let ((face (intern (completing-read "Face: " '("variable-pitch" "fixed-pitch") nil t))))
     (list face (completing-read (format "%s family: " face)
                                 (delete-dups (font-family-list)) nil t))))
  (set-face-attribute face nil :family family)
  ;; mixed-pitch copies the family when it turns on; re-run it
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (bound-and-true-p mixed-pitch-mode)
        (mixed-pitch-mode 1)))))
```

- `set-face-attribute` with FRAME nil sets every existing frame and the
  defaults for new frames (`faces.el`, docstring of `set-face-attribute`).
  It never touches `default`.
- **Persistence:** none by default.  The choice lasts until the next
  restart, which is enough for comparing.  To keep a choice, the options
  are: write it into the literate config (the current shape); add a `jwm/`
  variable to `savehist-additional-variables` (savehist is already on,
  [config L1036-L1044](https://github.com/jmccarrell/literate-emacs.d/blob/ceb2d0fb1f428dc3f335c14a71b9edc82b828197/jeff-emacs-config.org#L1036-L1044))
  and apply it at init; or save a face spec into `custom-file`
  (`settings.el`, loaded early at L116-L118, so the later `set-face-attribute`
  lines in Org Prose Display would override it).
- **Theme reload:** survives zenburn (see above).  It would not survive a
  theme that sets these faces.
- **Height:** easy to add as an extra prompt.  It is moot in org buffers
  unless `mixed-pitch-set-height` is turned on (mixed-pitch point 2).

## Side by side

| | fontaine | `jwm/` command |
|---|---|---|
| Source | GNU ELPA 3.1.0, a new dependency | about 15 lines in the config |
| What you pick from | named presets you define in advance | any installed family, chosen live |
| Faces | any of `fontaine-faces`; `default` untouched only with the `t`-preset condition | exactly `variable-pitch` / `fixed-pitch` |
| Applied as | specs in a `fontaine` theme | frame face attributes |
| Survives zenburn reload | yes | yes (zenburn has no spec for these faces) |
| Survives a theme that sets these faces | yes | no |
| Persistence | preset name in `~/.emacs.d/fontaine-latest-state.eld`, one per machine, untracked | none, unless savehist, custom-file or the config is used |
| Refreshing mixed-pitch buffers | `fontaine-set-preset-hook` | loop in the command |
| Side effects | resets `line-spacing`; overrides the config's existing `set-face-attribute` lines | none beyond the face |
| Height | `:variable-pitch-height` (float) | an extra prompt if wanted |

## Reference configs

Tracked repos checked: every local clone under `reference-emacs-configs/`
(grepped), plus the tracked repos that are not cloned locally, checked
upstream (`protesilaos-dotfiles`, `oantolin-emacs-config`,
`andreyorst-dotfiles`).

- **protesilaos-dotfiles** uses fontaine with `fontaine-mode`, `C-c f` /
  `C-c F`, presets that all set `:default-*`, and restore at startup
  ([prot-emacs-theme.el L184-L295](https://github.com/protesilaos/dotfiles/blob/937ecb5f33c2f95d4016a6e3f19d75ea949eb0a9/emacs/.emacs.d/prot-emacs-modules/prot-emacs-theme.el#L184-L295)).
  He uses fontaine to change the font size of the whole frame, which is
  not the use case here.
- **sacha-chua-dotemacs** uses fontaine only for `default` height
  (`regular` at 100, `presentation` at 140), switched by her streaming mode
  (`Sacha.org` lines 36952, 36959, 36972).
- **oantolin-emacs-config** does not use fontaine.  It sets
  `(set-face-attribute 'variable-pitch nil :family "Noto Sans")` once at
  startup
  ([init.el L21](https://github.com/oantolin/emacs-config/blob/80527ac7789ae70cd6519cac4537c7fce9cf9276/init.el#L21)).
  That is the plain `set-face-attribute` shape, with the Noto Sans
  candidate.
- No other tracked repo uses fontaine.

## Notes for #67

- If fontaine is used without touching `default`, the presets need a
  non-empty `t` entry, and no preset may carry a `:default-*` key.
- Neither option can change org code or table fonts while `mixed-pitch`
  stays as it is: those faces follow `default`'s family, not `fixed-pitch`.
  That affects how Noto Sans Mono as `fixed-pitch` can be judged in #62.
- `variable-pitch`'s `:height` does nothing in org buffers today because
  `mixed-pitch-set-height` is nil.  This touches the map's "Not yet
  specified: height" item.
- Both options have to re-run `mixed-pitch-mode` in open buffers for a
  change to show without reopening files.
- Prot's fontaine repository has an `AGENTS.md` asking LLM agents not to
  generate contributions to it.  It doesn't apply to reading or using the
  package; it would apply to any bug report or patch sent upstream.
