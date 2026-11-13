# What mixed-pitch keeps monospace in gfm-mode

**Question** (#65, under map #62): with `mixed-pitch-mode` on in `gfm-mode`,
which markdown elements stay fixed-pitch, which go proportional and break
alignment, and how do the reference configs handle it?  How do
`markdown-fontify-code-blocks-natively` and `markdown-header-scaling`, both
on in the config, interact with it?

**Scope.** Facts only; the choice belongs to #68.  Jeff's Emacs and
`~/.emacs.d` were not changed.

Sources: installed `mixed-pitch-20210304.1900` (upstream HEAD
[`519e05f`](https://gitlab.com/jabranham/mixed-pitch/-/blob/519e05f74825abf04b7d2e0e38ec040d013a125a/mixed-pitch.el)),
installed `markdown-mode-20260827.909` (revision `c6843032aa95`), installed
`zenburn-theme-20260901.1544`, the Elisp manual shipped with Emacs 31.1
(`(elisp) Face Remapping`), and `literate-emacs.d` at
[`ceb2d0f`](https://github.com/jmccarrell/literate-emacs.d/blob/ceb2d0fb1f428dc3f335c14a71b9edc82b828197/jeff-emacs-config.org).
`info-dir.txt` lists no manual for either package, so their source is the
reference.

**Verified** means a GUI `emacs -Q` (Emacs 31.1, macOS) loaded the installed
packages, set the faces the way the config does (`variable-pitch` Helvetica
Neue at 1.1, `fixed-pitch` Hack if installed, zenburn), opened a sample GFM
file in `gfm-mode` with native code blocks and header scaling, turned on
`mixed-pitch-mode`, redisplayed, and read `(font-at pos)` on each element.
Default fonts tried: Monaco-12 (the Mark43 Mac's frame font, Hack absent)
and Menlo-12 (has a bold face, to see weight).

## Short answer

Under `mixed-pitch-mode` in `gfm-mode` with the config's markdown settings:

| Stays monospace | Goes proportional |
| --- | --- |
| fenced code blocks, with or without a language, including the fence lines | body prose, bold, italic, strike-through |
| indented (4-space) code blocks | list markers (`-`, `*`, `1.`) and list-item text |
| inline code | leading indentation of nested list items and continuation lines |
| tables, whole line, including bold, links and markup inside cells | link text, `<plain-url>` links, footnote markers |
| YAML front matter (keys and values) | HTML comments, footnote text, link titles |
| GFM checkboxes `[ ]` / `[x]` | header delimiters `#`, emphasis markup, `***` rules |
| the URL part of `[text](url)` | headings (already variable-pitch via header scaling) |
| **blockquotes, prose and `>` alike** | |

Every element that needs column alignment (code, tables, front matter)
stays monospace with the stock `mixed-pitch-fixed-pitch-faces`; no markdown
face has to be added.  What turns proportional and can misalign is
whitespace-built layout outside those blocks: nested-list indentation,
hand-aligned continuation lines, ASCII art in plain paragraphs.

Three side effects #68 should know (details below):

1. Kept faces use the **`default`** family, not `fixed-pitch`.
2. Kept faces are forced to `default`'s **weight**: zenburn's bold keywords
   in code blocks turn regular.
3. Headings stay proportional only because `markdown-header-scaling` is
   non-nil **when markdown-mode loads**.  Set later, headings go monospace.

## How mixed-pitch decides

`mixed-pitch-mode` remaps `default` to the `variable-pitch` family and
weight, then adds a relative remap of `:family <default's family> :weight
<default's weight>` to each face in `mixed-pitch-fixed-pitch-faces`
([mixed-pitch.el L157-L196](https://gitlab.com/jabranham/mixed-pitch/-/blob/519e05f74825abf04b7d2e0e38ec040d013a125a/mixed-pitch.el#L157-L196)).
Any face that sets no family of its own falls through to the remapped
`default` and goes proportional.

The remap is seen through `:inherit`: a face that inherits from a listed
face picks up the listed face's remapped family.  The manual only implies
this (its "face remapping is non-recursive" note describes an `:inherit`
reference to a remapped face); the probe confirms it, since
`markdown-table-face` and `markdown-pre-face` are not listed yet render
monospace only when `mixed-pitch-mode` is on.

The stock list's markdown entries are `markdown-code-face`,
`markdown-gfm-checkbox-face`, `markdown-inline-code-face`,
`markdown-language-info-face`, `markdown-language-keyword-face` and
`markdown-math-face`
([L57-L116](https://gitlab.com/jabranham/mixed-pitch/-/blob/519e05f74825abf04b7d2e0e38ec040d013a125a/mixed-pitch.el#L57-L116)).
The list also holds most `font-lock-*` faces, but **not**
`font-lock-comment-face` (only `font-lock-comment-delimiter-face`).  Most
markdown faces inherit from one of those font-lock faces, which decides the
rest.

## Face by face

markdown-mode defines no `:family` on any face; each inherits
(`markdown-mode.el` L1967-L2153).  Zenburn defines no markdown faces.

| markdown face | inherits | result |
| --- | --- | --- |
| `markdown-code-face` | `fixed-pitch` | listed: mono |
| `markdown-inline-code-face` | `markdown-code-face`, `font-lock-constant-face` | listed: mono |
| `markdown-pre-face` | `markdown-code-face`, `font-lock-constant-face` | mono via inherit |
| `markdown-table-face` | `markdown-code-face` | mono via inherit |
| `markdown-language-keyword-face` | `font-lock-type-face` | listed: mono |
| `markdown-language-info-face` | `font-lock-string-face` | listed: mono |
| `markdown-gfm-checkbox-face` | `font-lock-builtin-face` | listed: mono |
| `markdown-math-face` | `font-lock-string-face` | listed: mono |
| `markdown-metadata-key-face` | `font-lock-variable-name-face` | mono via inherit |
| `markdown-metadata-value-face` | `font-lock-string-face` | mono via inherit |
| `markdown-url-face` | `font-lock-string-face` | mono via inherit |
| `markdown-blockquote-face` | `font-lock-doc-face` | mono via inherit |
| `markdown-line-break-face` | `font-lock-constant-face` | mono via inherit |
| `markdown-html-tag-name-face`, `-attr-name-`, `-attr-value-`, `-entity-` | type / variable-name / string faces | mono via inherit |
| `markdown-missing-link-face` | `font-lock-warning-face` | proportional (not listed) |
| `markdown-header-face` | `variable-pitch` (when scaling at load), `font-lock-function-name-face` | proportional; see headings |
| `markdown-markup-face` and its children: `-list-`, `-header-delimiter-`, `-header-rule-`, `-hr-`, `-reference-`, `-footnote-marker-`, `-html-tag-delimiter-` | `shadow` | proportional |
| `markdown-comment-face`, `-footnote-text-`, `-link-title-` | `font-lock-comment-face` | proportional |
| `markdown-link-face`, `-plain-url-` | `link` | proportional |
| `markdown-bold-face`, `-italic-`, `-strike-through-`, `-highlight-` | `bold`, `italic`, none, `highlight` | proportional |

How the faces land on text decides the block-level results:

- **Fenced code blocks** get `markdown-code-face` *appended* across the
  whole block, fence lines included
  ([`markdown-fontify-code-blocks-generic`, L9327-L9352](https://github.com/jrblevin/markdown-mode/blob/c6843032aa95/markdown-mode.el#L9327-L9352)).
  Every character in the block therefore ends in a fixed face.
- **Tables** get `markdown-table-face` appended to each whole line
  ([`markdown-fontify-tables`, L3672-L3681](https://github.com/jrblevin/markdown-mode/blob/c6843032aa95/markdown-mode.el#L3672-L3681)),
  so bold, links and markup inside cells stay monospace too (verified).
- **Blockquotes** get `markdown-blockquote-face` appended to the whole quote
  ([L3683-L3695](https://github.com/jrblevin/markdown-mode/blob/c6843032aa95/markdown-mode.el#L3683-L3695)).
  It inherits `font-lock-doc-face`, which is listed, so quoted prose is
  monospace: a visual oddity, not an alignment problem.
- **List markers** get `markdown-list-face` (proportional); the indentation
  before them is plain text in the remapped `default`
  ([L3697-L3708](https://github.com/jrblevin/markdown-mode/blob/c6843032aa95/markdown-mode.el#L3697-L3708)).
  Nested items still indent, by proportional space widths.

## Native code-block fontification

With `markdown-fontify-code-blocks-natively` on,
`markdown-fontify-code-block-natively` copies the language mode's `face`
properties into the block, then the generic function appends
`markdown-code-face`.  A Python `def` ends up as
`(font-lock-keyword-face markdown-code-face)`; unhighlighted text such as
`(x)` as `(markdown-code-face)`.

- **Family:** monospace throughout.  Even a language face missing from the
  fixed list (`font-lock-comment-face`, say) sets no family of its own, so
  the appended `markdown-code-face` supplies it.  A language mode whose faces
  set `:family` or inherit `variable-pitch` would break this; none in the
  common modes do.
- **Weight:** the remap forces `default`'s weight onto every listed face.
  Zenburn makes `font-lock-keyword-face` and `font-lock-builtin-face` bold;
  with Menlo-12 as default, `def` and `return` were **bold** with
  `mixed-pitch-mode` off and **regular** with it on.  The same happens to
  org source blocks today.  (Monaco has no bold face, so on the Mark43 Mac
  keywords are regular either way.)

Without native fontification, the block is `markdown-pre-face` plus
`markdown-code-face`: monospace too.

## Headings and `markdown-header-scaling`

`markdown-header-face` reads `markdown-header-scaling` **once, at defface
time**: its `:inherit` is `(variable-pitch font-lock-function-name-face)`
when the variable is non-nil then, and `(font-lock-function-name-face)`
otherwise
([L2188-L2192](https://github.com/jrblevin/markdown-mode/blob/c6843032aa95/markdown-mode.el#L2188-L2192)).
The variable's `:set` only updates the heights of
`markdown-header-face-1..6`
([L2155-L2167, L2208-L2218](https://github.com/jrblevin/markdown-mode/blob/c6843032aa95/markdown-mode.el#L2155-L2218)).

- **The config's load order gives variable-pitch headings.**  `:mode`
  defers loading, and `:custom` sets the value before markdown-mode loads.
  A batch replica of the `use-package` form gave inherit
  `(variable-pitch font-lock-function-name-face)` and an H1 height of 2.0.
- **Set after markdown-mode is loaded**, the inherit lacks `variable-pitch`.
  Headings then inherit `font-lock-function-name-face`, which is on the fixed
  list, so under `mixed-pitch-mode` they render **monospace** (verified: Menlo,
  scaled, bold).  This would happen if another package loaded markdown-mode
  before the `use-package` form ran.  To check a live session, evaluate
  `(face-attribute 'markdown-header-face :inherit)`.
- Heading size: `variable-pitch`'s `:height 1.1` multiplies the scaling
  factor (H1 at 12pt measured 26 = 12 × 1.1 × 2.0, with or without
  mixed-pitch).  Body prose under mixed-pitch stays at 12, because
  mixed-pitch ignores `variable-pitch`'s height unless
  `mixed-pitch-set-height` is set.
- Headings are proportional **today**, without mixed-pitch, because of the
  `variable-pitch` inherit.

## Which monospace family

mixed-pitch remaps kept faces to **`default`'s family**, read when the mode
turns on, not to `fixed-pitch`.  `markdown-code-face` inherits
`fixed-pitch`, but the remap's `:family` overrides that inherit.  Measured
on the Monaco-12 default with Hack absent (the Mark43 Mac):

| | code, tables, inline code | front matter, blockquote, checkbox |
| --- | --- | --- |
| `gfm-mode` today (no mixed-pitch) | **Courier** (`fixed-pitch`'s generic "Monospace") | Monaco (`default`) |
| with `mixed-pitch-mode` | Monaco (`default`) | Monaco (`default`) |

So on that Mac, markdown code blocks and tables render in Courier today,
and a `fixed-pitch` pin (Hack, or Noto Sans Mono from the map's candidates)
reaches markdown code only while mixed-pitch is **off**.  Under mixed-pitch
the pin does nothing for markdown; the frame font does.  The same holds in
org buffers.  Where Hack is installed and is the frame font, both paths give
Hack.

## Reference configs

None of the cached configs runs `mixed-pitch` in markdown today, and none
adds markdown faces to `mixed-pitch-fixed-pitch-faces`.

- **minemacs** used to enable `mixed-pitch-mode` in `markdown-mode` (and
  `rst-mode`, `org-mode`) through its `+writing-mode`
  (`modules/obsolete/me-writing-mode.el`, `+writing-mixed-pitch-modes`).  Its
  `modules/obsolete/me-mixed-pitch.el` appended org faces and
  `font-lock-comment-face` to the fixed list but nothing markdown-specific,
  relying on the stock entries.  It sets `mixed-pitch-variable-pitch-cursor`
  to nil because the bar cursor hid.  Both modules are now obsolete
  (changelog: "make `mixed-pitch` obsolete", `60624cb`).
- **oantolin** (fetched from GitHub at
  [`80527ac`](https://github.com/oantolin/emacs-config/blob/80527ac7789ae70cd6519cac4537c7fce9cf9276/init.el);
  not in the local cache) hooks `variable-pitch-mode` on `text-mode`, which
  covers his `markdown-ts-mode`, with `variable-pitch` set to **Noto Sans**.
  No mixed-pitch; his theme decides what stays fixed.
- **protesilaos** (fetched at
  [`937ecb5`](https://github.com/protesilaos/dotfiles/tree/937ecb5f33c2f95d4016a6e3f19d75ea949eb0a9);
  not cached) turns on `variable-pitch-mode` in `text-mode` buffers (except
  `mhtml-mode`, `nxml-mode`, `yaml-mode`) when `modus-themes-mixed-fonts` is on, and leaves the fixed faces to the
  theme (`prot-emacs-theme.el`, `prot/enable-variable-pitch`;
  `prot-emacs-modus-themes.el`).  He sets
  `markdown-fontify-code-blocks-natively t` (`prot-emacs-langs.el`).  The
  map already notes that zenburn has no such mixed-fonts option.
- **jwiegley** scales `markdown-header-face-1..4` with `:custom-face` and
  uses no variable pitch in markdown.  **yqrashawn** uses mixed-pitch only
  in eww and elfeed.  Purcell, bbatsov, Sacha, munen, redguardtoo,
  MatthewZMD, danielmai, scimax: no mixed-pitch or variable-pitch in
  markdown.

## What this means for #68

- The stock fixed list already keeps code, tables, front matter and
  checkboxes monospace in `gfm-mode`; turning mixed-pitch on there needs no
  additions to the list for alignment.
- What does turn proportional and can look misaligned: nested-list
  indentation and hand-aligned continuation lines.
- Blockquotes go monospace, an artifact of `font-lock-doc-face` being
  listed.  Leaving it is the default; changing it means a buffer-local
  edit of the fixed list or a remap of `markdown-blockquote-face`.  (Doc
  strings inside code blocks would stay monospace either way, through the
  appended `markdown-code-face`.)
- The family question is shared with org: under mixed-pitch, monospace
  text uses `default`'s font, so the `fixed-pitch` choice from the map
  reaches neither mode while mixed-pitch is on, unless `default` changes too
  (out of scope in #62) or the kept faces are pointed at `fixed-pitch`.
