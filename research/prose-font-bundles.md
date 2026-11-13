# Prose-font patterns in the reference configs, as whole bundles

**Question** (#71, under map #62): how does each reference config that sets
a proportional prose font do it, as one whole pattern: how families are set,
which mode turns prose proportional and on which hooks, what keeps code and
tables monospace, the height and heading handling that comes with it, and
which families it names?  For each bundle, what would it take to work under
zenburn?

**Scope.** Facts only; the choice belongs to the decision ticket.  Every
setting below is quoted from a reference config, a framework it opts into,
or a theme package, with file, line and SHA.  Nothing is invented: where a
bundle needs something more under zenburn, it is listed as a **gap**.
Jeff's Emacs, `~/.emacs.d` and the main checkouts were not changed.

## Sources

Every tracked repo was shallow-cloned at the SHA in `reference-repos.list`
into a scratch directory (the local cache under `reference-emacs-configs/`
is older than the inventory for most repos) and grepped for
`variable-pitch`, `mixed-pitch`, `buffer-face`, `fixed-pitch`, `fontaine`,
`mixed-fonts` and `Noto`.

| repo | SHA read |
|---|---|
| oantolin-emacs-config | [`80527ac`](https://github.com/oantolin/emacs-config/tree/80527ac7789ae70cd6519cac4537c7fce9cf9276) |
| protesilaos-dotfiles | [`937ecb5`](https://github.com/protesilaos/dotfiles/tree/937ecb5f33c2f95d4016a6e3f19d75ea949eb0a9) |
| abougouffa-minemacs | [`4c0ca66`](https://github.com/abougouffa/minemacs/tree/4c0ca6607e8336c721e098b0539106b2968e6d3b) |
| yqrashawn-yqdotfiles | [`50538ae`](https://github.com/yqrashawn/yqdotfiles/tree/50538aea1cc91c6fee592c49263e1bdceebfd88d) |
| jwiegley-dotemacs | [`5234fca`](https://github.com/jwiegley/dot-emacs/tree/5234fca5fdeb42285b10c4af0bbfe07ccf4ffb12) |
| steve-purcell-dotemacs | [`f499b88`](https://github.com/purcell/emacs.d/tree/f499b88806f4d7976ae1a3eea90750b6aa8cdc04) |
| andreyorst-dotfiles | [`5ccdbe0`](https://gitlab.com/andreyorst/dotfiles/-/tree/5ccdbe0ca2fae3012f26d2dbf4c23caf1e16b9e7) |
| sacha-chua, bbatsov, munen, redguardtoo, matthewzmd | inventory SHAs; nothing beyond the notes at the end |

Also read: `modus-themes` 5.3.0 at
[`7827434`](https://github.com/protesilaos/modus-themes/tree/782743415b3eedac0b99db2342fb35703deb752f)
(Emacs 31.1 ships 5.2.0 with the same mechanism), `ef-themes` 2.2.1 at
[`716d365`](https://github.com/protesilaos/ef-themes/tree/716d365d0cf2ad3d855c6879a476857bc5fa57d2),
Doom's `modules` repo at
[`152f385`](https://github.com/doomemacs/modules/tree/152f3857970f6768c4bdaddf23dce53ef2286547)
and core at
[`7ccac7f`](https://github.com/doomemacs/doomemacs/tree/7ccac7f643ad67baa25b216717cf8617a0903c69)
(HEAD; yqrashawn's pinned Doom version is not recorded in his repo), the
installed `zenburn-theme-20260901.1544`, `markdown-mode-20260827.909`, Org
9.8.7 and `faces.el` / `use-package-core.el` from Emacs 31.1.  Prior
findings: [#64](https://github.com/jmccarrell/emacs-config/blob/research/fontaine-vs-command/research/fontaine-vs-command.md)
and [#65](https://github.com/jmccarrell/emacs-config/blob/research/mixed-pitch-gfm-mode/research/mixed-pitch-gfm-mode.md).

**Verified** means a GUI `emacs -Q` (Emacs 31.1, macOS, separate
`--init-directory`, installed packages activated read-only) with `default`
Menlo 12, `variable-pitch` Helvetica Neue at 1.1 and `fixed-pitch` left
unpinned, turned on `variable-pitch-mode` in a sample org file and a sample
GFM file, and read `(font-at pos)` on each element.

## Short answer

The reference configs hold three mechanisms, and they split cleanly on
**who keeps code monospace**:

| bundle | mechanism | what keeps code fixed | under zenburn |
|---|---|---|---|
| oantolin | `variable-pitch-mode` on `text-mode` | the theme (`ef-themes` with `modus-themes-mixed-fonts`) | **gap** in org |
| protesilaos | fontaine + `variable-pitch-mode` on `text-mode`, gated on `modus-themes-mixed-fonts` | the theme (modus / ef / standard with mixed fonts) | **gap** in org; the gate keeps it off |
| minemacs (obsolete) | `mixed-pitch-mode` in a manual writing mode | mixed-pitch's face list, extended | works |
| Doom `zen`, used by yqrashawn | `mixed-pitch-mode` when `writeroom-mode` is on | mixed-pitch's face list, extended | works |
| jwiegley | `buffer-face-mode` in Info and writeroom only | nothing (Info); a duospaced font (writeroom) | not an org/markdown pattern |
| purcell | `buffer-face-mode` in a manual `prose-mode` | nothing | **gap** everywhere |

- **The `variable-pitch-mode` bundles depend on the theme.**  modus, ef and
  standard themes add `:inherit fixed-pitch` to org and markdown code,
  table and metadata faces when `modus-themes-mixed-fonts` is non-nil.
  zenburn has no such option.  Verified: under zenburn, every org element
  probed (verbatim, `~code~`, tables, source blocks, `#+` lines, drawers,
  dates, checkboxes) went proportional.
- **markdown is mostly fine under zenburn without the theme.**
  `markdown-code-face` inherits `fixed-pitch` in markdown-mode's own
  `defface`, and zenburn does not theme it, so fenced code, inline code and
  tables stayed monospace in `gfm-mode`.  Front matter and checkboxes went
  proportional.
- **No reference config fills the org gap under a non-modus theme.**  The
  face list exists in `modus-themes.el`, and oantolin's `:custom-face …
  :inherit fixed-pitch` shape exists for other faces, but nobody applies it
  to org faces outside a modus-family theme.  Part of the list is themed by
  zenburn, which matters for how a fill could be written (see the zenburn
  section).
- **The `mixed-pitch` bundles work under any theme**, with the limits #64
  and #65 found: kept faces take `default`'s family and weight, not
  `fixed-pitch`'s, and `variable-pitch`'s height is ignored unless
  `mixed-pitch-set-height` is set.  Both reference users turn it on from a
  manual writing mode, not from `org-mode-hook`.  minemacs has made it
  obsolete.
- **Noto:** only oantolin names `"Noto Sans"` for `variable-pitch`.
  yqrashawn has `"Noto Serif"` in a commented-out line.

## The mechanism zenburn lacks

`modus-themes-mixed-fonts` is documented as enabling "inheritance from
`fixed-pitch` in some faces" so that "Org tables and code blocks … remain
monospaced when users opt for something like the command
`variable-pitch-mode`"
([modus-themes.el L364-L378](https://github.com/protesilaos/modus-themes/blob/782743415b3eedac0b99db2342fb35703deb752f/modus-themes.el#L364-L378)).
The implementation is one function that returns `(:inherit fixed-pitch)`
when the option is on
([L4486-L4489](https://github.com/protesilaos/modus-themes/blob/782743415b3eedac0b99db2342fb35703deb752f/modus-themes.el#L4486-L4489)),
used through the `modus-themes-fixed-pitch` face
([L164](https://github.com/protesilaos/modus-themes/blob/782743415b3eedac0b99db2342fb35703deb752f/modus-themes.el#L164),
[L4587](https://github.com/protesilaos/modus-themes/blob/782743415b3eedac0b99db2342fb35703deb752f/modus-themes.el#L4587)).
Faces that inherit it, within org and markdown:

- **org** ([L6480-L6550](https://github.com/protesilaos/modus-themes/blob/782743415b3eedac0b99db2342fb35703deb752f/modus-themes.el#L6480-L6550)):
  `org-block`, `org-block-begin-line`, `org-block-end-line`,
  `org-checkbox`, `org-code`, `org-column-title`, `org-date`,
  `org-document-info-keyword`, `org-drawer`, `org-formula`, `org-macro`,
  `org-meta-line`, `org-property-value`, `org-quote`,
  `org-special-keyword`, `org-table`, `org-table-header`, `org-verbatim`,
  `org-verse`.  `org-indent` inherits `fixed-pitch` unconditionally
  ([L6515](https://github.com/protesilaos/modus-themes/blob/782743415b3eedac0b99db2342fb35703deb752f/modus-themes.el#L6515)).
- **markdown-mode** ([L6138-L6158](https://github.com/protesilaos/modus-themes/blob/782743415b3eedac0b99db2342fb35703deb752f/modus-themes.el#L6138-L6158)):
  `markdown-code-face`, `markdown-inline-code-face`,
  `markdown-language-keyword-face`, `markdown-pre-face`,
  `markdown-table-face`; the `markdown-ts-*` code, table and HTML faces
  follow (L6163-L6188).
- Elsewhere: `Info-quoted`, `shr-code`, `line-number`, key-binding faces
  and others; no `font-lock-*` face is on the list.

ef-themes 2.x and standard-themes 3.x are built on modus-themes 5
(`Package-Requires: … (modus-themes "5.0.0")`,
[ef-themes.el L9](https://github.com/protesilaos/ef-themes/blob/716d365d0cf2ad3d855c6879a476857bc5fa57d2/ef-themes.el#L9))
and alias their own options to the modus ones, `mixed-fonts` included
([ef-themes.el L279-L289](https://github.com/protesilaos/ef-themes/blob/716d365d0cf2ad3d855c6879a476857bc5fa57d2/ef-themes.el#L279-L289)).
So one option, `modus-themes-mixed-fonts`, drives all three families.

### Verified: what `variable-pitch-mode` leaves monospace

`fixed-pitch` unpinned resolves to Courier on this Mac.

| element | zenburn | modus-operandi, mixed fonts on | modus-operandi, mixed fonts off |
|---|---|---|---|
| org prose | proportional | proportional | proportional |
| org `=verbatim=`, `~code~` | **proportional** | Courier | proportional |
| org table | **proportional** | Courier | proportional |
| org `#+begin_src` line, source body | **proportional** | Courier | proportional |
| org `#+TITLE` line, drawer, property, date, checkbox | **proportional** | Courier | proportional |
| gfm prose | proportional | proportional | proportional |
| gfm fenced code, inline code, table | Courier | Courier | **proportional** |
| gfm front matter, checkbox | proportional | proportional | proportional |

Two facts explain the zenburn column:

1. **Org's own faces never inherit `fixed-pitch`** (no occurrence in Org
   9.8.7's `org-faces.el`), so org needs the theme.  markdown-mode's
   `markdown-code-face` does (`'((t (:inherit fixed-pitch)))`,
   `markdown-mode.el` L2007-L2008), and `-inline-code-`, `-pre-` and
   `-table-face` inherit it.
2. **A theme spec replaces the `defface` spec entirely.**
   `face-spec-recalc` applies the `defface` spec only when no theme spec
   matched (`faces.el` L1725-L1770).  zenburn does not theme any markdown
   face, so markdown-mode's inherit survives; modus with mixed fonts off
   *does* theme `markdown-code-face`, without the inherit, so markdown code
   went proportional there.

Height, verified in `gfm-mode` under zenburn: without `variable-pitch-mode`,
code measured 12 px; with it, prose and code both measured 13.
`variable-pitch-mode` remaps `default` to `variable-pitch`, so
`variable-pitch`'s `:height 1.1` scales the whole buffer, code included.
Under `mixed-pitch` the height is ignored unless `mixed-pitch-set-height` is
set (#64).

## Bundle: oantolin

`variable-pitch-mode` in every `text-mode` buffer, with the theme keeping
code fixed.

**Families**

- `(set-face-attribute 'variable-pitch nil :family "Noto Sans")`, once at
  startup
  ([init.el L21](https://github.com/oantolin/emacs-config/blob/80527ac7789ae70cd6519cac4537c7fce9cf9276/init.el#L21)).
- `fixed-pitch` and `default` are not set anywhere, so `fixed-pitch` is the
  generic "Monospace".
- Emoji: `(set-fontset-font "fontset-default" 'emoji (font-spec :family "Noto Color Emoji"))`
  ([L23-L24](https://github.com/oantolin/emacs-config/blob/80527ac7789ae70cd6519cac4537c7fce9cf9276/init.el#L23-L24)).

**Mode and hooks**

- `(use-package text-mode :hook (text-mode . variable-pitch-mode) …)`
  ([L714-L718](https://github.com/oantolin/emacs-config/blob/80527ac7789ae70cd6519cac4537c7fce9cf9276/init.el#L714-L718)).
  Org (`org-mode` ← `outline-mode` ← `text-mode`) and his markdown
  (built-in `markdown-ts-mode`, a `text-mode` derivative,
  [L1020-L1028](https://github.com/oantolin/emacs-config/blob/80527ac7789ae70cd6519cac4537c7fce9cf9276/init.el#L1020-L1028))
  are covered by the one hook.  So are other `text-mode` buffers, such as
  magit commit messages (`git-commit-major-mode` defaults to `text-mode`),
  which map #62 puts out of scope.
- Toggle: `C-c x v` → `variable-pitch-mode`
  ([L145](https://github.com/oantolin/emacs-config/blob/80527ac7789ae70cd6519cac4537c7fce9cf9276/init.el#L145)).

**What keeps code fixed**

- The theme: `ef-themes` with `(ef-themes-take-over-modus-themes-mode)` and
  `:custom (modus-themes-mixed-fonts t)`, toggling `ef-autumn` / `ef-cyprus`
  ([L171-L182](https://github.com/oantolin/emacs-config/blob/80527ac7789ae70cd6519cac4537c7fce9cf9276/init.el#L171-L182)).
- Explicit face settings, for faces outside org and markdown bodies:
  `(org-modern-label ((t (:height 0.8 :inherit fixed-pitch))))`
  ([L1191](https://github.com/oantolin/emacs-config/blob/80527ac7789ae70cd6519cac4537c7fce9cf9276/init.el#L1191)),
  `(Info-quoted ((t :inherit fixed-pitch)))`
  ([L221](https://github.com/oantolin/emacs-config/blob/80527ac7789ae70cd6519cac4537c7fce9cf9276/init.el#L221)),
  `(shr-code ((t (:inherit fixed-pitch))))`
  ([L757](https://github.com/oantolin/emacs-config/blob/80527ac7789ae70cd6519cac4537c7fce9cf9276/init.el#L757)),
  all through `use-package :custom-face`.  Jeff's config already carries
  the `org-modern-label` line verbatim.

**Height and headings:** no `:height` on `variable-pitch`; no
`modus-themes-headings`.  The org display settings beside it are
`org-startup-indented`, `org-hide-emphasis-markers`,
`org-hide-leading-stars`, `org-pretty-entities`
([L1052-L1060](https://github.com/oantolin/emacs-config/blob/80527ac7789ae70cd6519cac4537c7fce9cf9276/init.el#L1052-L1060));
Jeff already sets the last three.

**Families named:** Noto Sans, Noto Color Emoji.

**Under zenburn:** **gap.** Code, tables and metadata in org go
proportional (verified).  In `gfm-mode`, code and tables stay monospace
through markdown-mode's own inherit; front matter and checkboxes go
proportional.  Monospace text uses `fixed-pitch`, so the `fixed-pitch` pin
(Hack, or Noto Sans Mono) reaches code in this bundle, unlike under
mixed-pitch.  oantolin's config shows the face-setting shape but applies it
to no org body face.

## Bundle: protesilaos

fontaine for the families, `variable-pitch-mode` on `text-mode`, and a
modus-family theme with mixed fonts.  The hook is **gated** on that theme
option.

**Families**

- fontaine, global `fontaine-mode`, `C-c f` / `C-c F`, restore at startup
  ([prot-emacs-theme.el L184-L295](https://github.com/protesilaos/dotfiles/blob/937ecb5f33c2f95d4016a6e3f19d75ea949eb0a9/emacs/.emacs.d/prot-emacs-modules/prot-emacs-theme.el#L184-L295)).
- The `t` preset: `:default-family "Aporetic Sans Mono"`,
  `:fixed-pitch-family "Aporetic Sans Mono"`,
  `:variable-pitch-family "Aporetic Serif"`, both pitch heights `1.0`
  ([L214-L240](https://github.com/protesilaos/dotfiles/blob/937ecb5f33c2f95d4016a6e3f19d75ea949eb0a9/emacs/.emacs.d/prot-emacs-modules/prot-emacs-theme.el#L214-L240)).
  The `medium` preset swaps to `"Aporetic Serif Mono"` / `"Aporetic Sans"`
  (L202-L206).
- Every preset sets `:default-*`, which map #62 puts out of scope; #64
  found fontaine can leave `default` alone only with a non-empty `t`
  preset and no `:default-*` keys, a shape no reference config uses.

**Mode and hooks**

```elisp
(defun prot/enable-variable-pitch ()
  (unless (derived-mode-p 'mhtml-mode 'nxml-mode 'yaml-mode)
    (when (bound-and-true-p modus-themes-mixed-fonts)
      (variable-pitch-mode 1))))
```

on `text-mode-hook`, `notmuch-show-mode-hook` and `elfeed-show-mode-hook`;
`C-x x v` toggles
([L309-L322](https://github.com/protesilaos/dotfiles/blob/937ecb5f33c2f95d4016a6e3f19d75ea949eb0a9/emacs/.emacs.d/prot-emacs-modules/prot-emacs-theme.el#L309-L322)).
markdown is plain `markdown-mode` with
`markdown-fontify-code-blocks-natively t`
([prot-emacs-langs.el L91-L94](https://github.com/protesilaos/dotfiles/blob/937ecb5f33c2f95d4016a6e3f19d75ea949eb0a9/emacs/.emacs.d/prot-emacs-modules/prot-emacs-langs.el#L91-L94)).

**What keeps code fixed:** the theme.  `prot-emacs-load-theme-family`
defaults to `modus`
([init.el L11](https://github.com/protesilaos/dotfiles/blob/937ecb5f33c2f95d4016a6e3f19d75ea949eb0a9/emacs/.emacs.d/init.el#L11)),
and each of the modus, ef and standard modules sets
`modus-themes-mixed-fonts t`
([modus L34](https://github.com/protesilaos/dotfiles/blob/937ecb5f33c2f95d4016a6e3f19d75ea949eb0a9/emacs/.emacs.d/prot-emacs-modules/prot-emacs-modus-themes.el#L34),
[ef L14](https://github.com/protesilaos/dotfiles/blob/937ecb5f33c2f95d4016a6e3f19d75ea949eb0a9/emacs/.emacs.d/prot-emacs-modules/prot-emacs-ef-themes.el#L14),
[standard L14](https://github.com/protesilaos/dotfiles/blob/937ecb5f33c2f95d4016a6e3f19d75ea949eb0a9/emacs/.emacs.d/prot-emacs-modules/prot-emacs-standard-themes.el#L14)).
No explicit face settings for org or markdown.

**Height and headings** (heading sizes are out of scope in #62; recorded
for completeness): the modus module sets `modus-themes-headings` to
`(t . (regular 1.15))` with variable-pitch only for agenda headings
([L40-L43](https://github.com/protesilaos/dotfiles/blob/937ecb5f33c2f95d4016a6e3f19d75ea949eb0a9/emacs/.emacs.d/prot-emacs-modules/prot-emacs-modus-themes.el#L40-L43));
the ef and standard modules make every level `variable-pitch` at 1.1 to 1.9
([ef L18-L29](https://github.com/protesilaos/dotfiles/blob/937ecb5f33c2f95d4016a6e3f19d75ea949eb0a9/emacs/.emacs.d/prot-emacs-modules/prot-emacs-ef-themes.el#L18-L29)).

**Families named:** Aporetic Sans Mono, Aporetic Serif Mono, Aporetic
Serif, Aporetic Sans (his own).  No Noto.

**Under zenburn:** **gap**, the same org gap as oantolin.  The gate makes
it visible: with zenburn loaded, `modus-themes-mixed-fonts` is unbound
in `emacs -Q` (the modus library is never loaded), so `prot/enable-variable-pitch` never
turns the mode on.  The bundle as written does nothing under zenburn.

## Bundle: minemacs (obsolete)

`mixed-pitch-mode`, turned on by a manual writing mode.

**Families**

- `minemacs-fonts-plist`: the first installed of a list per face, applied
  with `(custom-theme-set-faces 'user …)` from `window-setup-hook`
  ([core/me-lib.el L960-L1000, L1090-L1125](https://github.com/abougouffa/minemacs/blob/4c0ca6607e8336c721e098b0539106b2968e6d3b/core/me-lib.el#L960-L1125)).
- `:variable-pitch` tries `"Iosevka Comfy Motion Duo"`, `"Geist"` (110),
  `"Lato"`, `"Roboto"`, `"Inter"` (120), then `"San Francisco"`,
  `"Helvetica Neue"`, `"Helvetica"`, … (L989-L1000).
- `:fixed-pitch ((:inherit default))` (L985-L986), matching what
  mixed-pitch does anyway (kept faces take `default`'s family).

**Mode and hooks**

- `+writing-mode` (olivetti, text scale 2.0, and mixed-pitch) turns on
  `mixed-pitch-mode` when the buffer derives from one of
  `+writing-mixed-pitch-modes`: `rst-mode`, `markdown-mode`, `org-mode`
  ([modules/obsolete/me-writing-mode.el L38-L47, L84-L110](https://github.com/abougouffa/minemacs/blob/4c0ca6607e8336c721e098b0539106b2968e6d3b/modules/obsolete/me-writing-mode.el#L38-L110)).
  Nothing in the repo enables it from a hook; it is a command.

**What keeps code fixed**

- mixed-pitch's stock list, extended with `font-lock-comment-face`,
  `font-lock-comment-delimiter-face` and org faces (`org-block`,
  `org-code`, `org-table`, `org-verbatim`, `org-meta-line`, `org-date`,
  `org-drawer`, `org-property-value`, `org-tag`, `org-todo`, `org-done`,
  `org-link`, …), and `mixed-pitch-variable-pitch-cursor nil`
  ([modules/obsolete/me-mixed-pitch.el L15-L31](https://github.com/abougouffa/minemacs/blob/4c0ca6607e8336c721e098b0539106b2968e6d3b/modules/obsolete/me-mixed-pitch.el#L15-L31)).
- org-modern tags and TODO keywords are forced monospace by inheriting
  `org-verbatim` ([modules/me-org.el L76, L82-L91](https://github.com/abougouffa/minemacs/blob/4c0ca6607e8336c721e098b0539106b2968e6d3b/modules/me-org.el#L76-L91)),
  a module that is still live.

**Height and headings:** absolute `:height` 110 / 120 on `variable-pitch`,
which mixed-pitch ignores without `mixed-pitch-set-height`;
`+writing-text-scale 2.0` scales the whole buffer instead.  No heading
settings.

**Status:** "make `mixed-pitch` obsolete" in v11.3.0, 2024-11-21
([docs/changelog.md L2879, L2896](https://github.com/abougouffa/minemacs/blob/4c0ca6607e8336c721e098b0539106b2968e6d3b/docs/changelog.md?plain=1#L2879-L2896)).
Default theme `doom-one-light` (`core/me-vars.el` L156).

**Families named:** the lists above.  No Noto for text (Noto Color Emoji
for emoji).

**Under zenburn:** works; mixed-pitch is theme-independent.  The #64/#65
limits apply (default's family and weight for code, height ignored).

## Bundle: Doom `zen`, used by yqrashawn

`mixed-pitch-mode` while `writeroom-mode` is on, from the Doom framework
module yqrashawn enables.

**Families** (yqrashawn's own settings)

- `doom-font` `"PragmataPro Mono Liga"` size 18 medium;
  `doom-variable-pitch-font (font-spec :family "Lucida Grande")`;
  `doom-serif-font` PragmataPro; commented-out alternatives include
  `"Times Newer Roman"` and `(font-spec :family "Noto Serif" :size 16 :weight 'medium)`
  ([.doom.d/config.el L33-L43](https://github.com/yqrashawn/yqdotfiles/blob/50538aea1cc91c6fee592c49263e1bdceebfd88d/.doom.d/config.el#L33-L43)).
- Doom applies these with `set-face-attribute` plus a `user` theme spec,
  and sets **`fixed-pitch` to `doom-font`** as well as `default`
  ([doom-emacs.el L1108-L1120](https://github.com/doomemacs/doomemacs/blob/7ccac7f643ad67baa25b216717cf8617a0903c69/lisp/doom-emacs.el#L1108-L1120), framework HEAD).

**Mode and hooks**

- `zen` in his Doom modules
  ([.doom.d/init.el L161](https://github.com/yqrashawn/yqdotfiles/blob/50538aea1cc91c6fee592c49263e1bdceebfd88d/.doom.d/init.el#L161)).
  The module adds `+zen-enable-mixed-pitch-mode-h` to
  `writeroom-local-effects`, turning on `mixed-pitch-mode` in modes
  derived from `+zen-mixed-pitch-modes`: `adoc-mode`, `rst-mode`,
  `markdown-mode`, `org-mode`
  ([modules/ui/zen/config.el L3-L6, L41-L48](https://github.com/doomemacs/modules/blob/152f3857970f6768c4bdaddf23dce53ef2286547/modules/ui/zen/config.el#L3-L48)).
  `writeroom-mode` is a command; yqrashawn hooks it only on eww and elfeed.
- Directly: `mixed-pitch-mode` on `eww-after-render-hook` and
  `elfeed-show-mode-hook`, both with `writeroom-mode`
  ([better-default.el L752-L755](https://github.com/yqrashawn/yqdotfiles/blob/50538aea1cc91c6fee592c49263e1bdceebfd88d/.doom.d/better-default.el#L752-L755),
  [read.el L41-L42](https://github.com/yqrashawn/yqdotfiles/blob/50538aea1cc91c6fee592c49263e1bdceebfd88d/.doom.d/read.el#L41-L42)).

**What keeps code fixed:** mixed-pitch's list, extended by the zen module
with `org-date`, `org-footnote`, `org-special-keyword`,
`org-property-value`, `org-tag`, `org-todo`, `org-done`, the
`org-todo-keyword-*` faces and `font-lock-comment-face`
([L49-L66](https://github.com/doomemacs/modules/blob/152f3857970f6768c4bdaddf23dce53ef2286547/modules/ui/zen/config.el#L49-L66)).
His theme is `ef-day` / `ef-cherie` with `modus-themes-mixed-fonts t`
([config.el L50-L57](https://github.com/yqrashawn/yqdotfiles/blob/50538aea1cc91c6fee592c49263e1bdceebfd88d/.doom.d/config.el#L50-L57),
[visual.el L114-L121](https://github.com/yqrashawn/yqdotfiles/blob/50538aea1cc91c6fee592c49263e1bdceebfd88d/.doom.d/visual.el#L114-L121)),
but under mixed-pitch the theme's inherits are redundant.

**Height and headings:** `+zen-text-scale` 1.0 (module default, L8-L11);
no heading settings.

**Families named:** PragmataPro Mono Liga, Lucida Grande; Noto Serif only
commented out.

**Under zenburn:** works, as minemacs.

## Bundle: jwiegley

A serif `variable-pitch` and `buffer-face-mode`, but not in org or
markdown.

- `variable-pitch` `((t (:height 1.2 :family "Bookerly")))` through
  `:custom-face` in his `emacs` block
  ([init.org L561-L567](https://github.com/jwiegley/dot-emacs/blob/5234fca5fdeb42285b10c4af0bbfe07ccf4ffb12/init.org?plain=1#L561-L567)).
- `Info-mode-hook`: `buffer-face-mode-face '(:family "Bookerly")`,
  `buffer-face-mode`, `text-scale-adjust 1`
  ([L4115-L4119](https://github.com/jwiegley/dot-emacs/blob/5234fca5fdeb42285b10c4af0bbfe07ccf4ffb12/init.org?plain=1#L4115-L4119)).
- `writeroom-mode` (a command) sets `my-writing-face`,
  `(:height 1.5 :family "ia Writer Duo S")`, with `buffer-face-set` and
  `line-spacing 4`
  ([L7197-L7221](https://github.com/jwiegley/dot-emacs/blob/5234fca5fdeb42285b10c4af0bbfe07ccf4ffb12/init.org?plain=1#L7197-L7221)).
  iA Writer Duo is duospaced, near-monospace, so nothing needs to be kept
  fixed.
- No `variable-pitch-mode` or `mixed-pitch` anywhere; markdown headings
  are only rescaled (L4710-L4713).  His `org-modern` block is commented
  out (L12690).

**Under zenburn:** not applicable to org or markdown as written.

## Bundle: purcell

A manual `prose-mode` that turns on `buffer-face-mode`
([lisp/init-org.el L67-L102](https://github.com/purcell/emacs.d/blob/f499b88806f4d7976ae1a3eea90750b6aa8cdc04/lisp/init-org.el#L67-L102)),
with writeroom, word wrap, a bar cursor and `line-spacing 0.2`.
`buffer-face-mode-face` keeps its default, `variable-pitch`, whose family
is never set.  An `org-mode-hook` line is commented out (L104).  The
`(eq major-mode 'org)` test at L80 can never be true (the mode is
`org-mode`).  Theme `sanityinc-tomorrow-bright` (`lisp/init-themes.el`
L13).

**Under zenburn:** **gap** in org, the same as the `variable-pitch-mode`
bundles (buffer-face with `variable-pitch` is what `variable-pitch-mode`
does); markdown code stays fixed through markdown-mode's inherit.

## Not bundles

- **andreyorst** sets `(set-face-attribute 'variable-pitch nil :font "DejaVu Sans")`
  when installed
  ([.config/emacs/init.el L253-L254](https://gitlab.com/andreyorst/dotfiles/-/blob/5ccdbe0ca2fae3012f26d2dbf4c23caf1e16b9e7/.config/emacs/init.el#L253-L254))
  and turns no prose mode on.
- **sacha-chua** binds `C-c x v` to `variable-pitch-mode`, "Inspired by"
  oantolin (`Sacha.org` L5564-L5573), with no family and no hook; fontaine
  only changes `default` height for streaming (#64).
- **bbatsov, munen, redguardtoo, matthewzmd:** no prose font (munen sets
  only Noto Color Emoji).

## Under zenburn: what a fill would have to reach

No reference config shows a fill for org under a non-modus theme.  The
facts a fill would rest on:

- **The face list** exists only in a theme: modus's org list above.  The
  mixed-pitch lists in minemacs and Doom name a similar set for the other
  mechanism.
- **`use-package :custom-face` writes the `defface` spec**
  (`face-spec-set … 'face-defface-spec`, `use-package-core.el`
  L1623-L1631), and a theme spec replaces the `defface` spec (above).  So
  oantolin's shape reaches only faces zenburn does not theme.
- **zenburn themes part of the list** (`zenburn-theme.el`): `org-block`
  (L1665), `org-checkbox` (L1666), `org-date` (L1668), `org-formula`
  (L1671), `org-quote` (L1691), `org-special-keyword` (L1696, itself
  `:inherit font-lock-comment-face`), `org-table` (L1697),
  `org-column-title` (L1704).  It leaves `org-code`, `org-verbatim`,
  `org-meta-line`, `org-block-begin-line`, `org-block-end-line`,
  `org-drawer`, `org-property-value`, `org-document-info-keyword`,
  `org-macro`, `org-verse`, `org-table-header`, `org-indent`,
  `org-modern-label` and every markdown face alone.
- zenburn's only pitch option, `zenburn-use-variable-pitch`, makes headings
  (`org-level-N`, `outline-N`, `org-document-title`) inherit
  `variable-pitch` (L71, L266, L1674-L1744); it keeps nothing fixed.

## Comparison

| bundle | families set by | prose mode | hooks | keeps code fixed | `fixed-pitch` reaches code | height | works under zenburn |
|---|---|---|---|---|---|---|---|
| oantolin | `set-face-attribute` (Noto Sans) | `variable-pitch-mode` | `text-mode` (covers org and markdown) | theme: ef + `modus-themes-mixed-fonts`; explicit `org-modern-label`, `Info-quoted`, `shr-code` | yes | none set; would scale code too | **gap:** org code, tables, metadata go proportional; gfm front matter and checkboxes too; no config shows the fill |
| protesilaos | fontaine presets (Aporetic), sets `default` | `variable-pitch-mode` | `text-mode`, gated on `modus-themes-mixed-fonts` | theme: modus / ef / standard with mixed fonts | yes | 1.0 in the `t` preset | **gap:** as oantolin; the gate leaves the mode off under zenburn |
| minemacs (obsolete) | `custom-theme-set-faces 'user`, first installed of a list | `mixed-pitch-mode` | none; `+writing-mode` command in org, markdown, rst | mixed-pitch list + org faces + comments | no (`default`'s family) | ignored; text scale 2.0 instead | yes |
| Doom zen (yqrashawn) | Doom font variables (Lucida Grande) | `mixed-pitch-mode` | none for org/markdown; `writeroom-mode` command | mixed-pitch list + zen's org faces | no (`default`'s family) | ignored; text scale 1.0 | yes |
| jwiegley | `:custom-face` (Bookerly 1.2) | `buffer-face-mode` | Info; writeroom command | none needed (duospaced writing font) | n/a | 1.2 / 1.5 | n/a for org/markdown |
| purcell | none (default `variable-pitch`) | `buffer-face-mode` | none; `prose-mode` command | nothing | yes, where a face inherits it | none | **gap:** as oantolin |

Jeff's current setup (Org Prose Display) is the mixed-pitch shape on
`org-mode-hook` with oantolin's `org-modern-label` line; no reference
config hooks mixed-pitch on an org or markdown mode hook.

## Which settings belong together

- **A `variable-pitch-mode` bundle is family + mode + hook + theme
  option.**  The theme option is not optional: oantolin and protesilaos both
  ship it, and protesilaos makes the mode conditional on it.  Under zenburn
  the theme part is missing for org, and nothing in the references replaces
  it.  `fixed-pitch`'s family and `variable-pitch`'s height then apply to
  code as well.
- **A `mixed-pitch` bundle is family + mode + an extended face list.**  It
  is theme-independent.  Both reference users extend the stock list with
  org faces and `font-lock-comment-face`, and both turn it on in org and
  markdown from a writing-mode command rather than a major-mode hook.  `fixed-pitch` and
  the height do not reach code unless `mixed-pitch-set-height` is set or
  `default` changes.
- **Family setting is separable** from either: `set-face-attribute`
  (oantolin, Jeff today), fontaine (protesilaos), framework variables
  (Doom, minemacs).  #64 compared the first two.
- **Hook scope differs:** the `variable-pitch-mode` bundles hook
  `text-mode`, which also reaches commit messages and other text buffers
  outside #62's scope; the mixed-pitch bundles name modes (org, markdown,
  rst, adoc).
