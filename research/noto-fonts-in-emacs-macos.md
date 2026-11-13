# The Noto fonts in Emacs on macOS

**Question** ([#63](https://github.com/jmccarrell/emacs-config/issues/63), map
[#62](https://github.com/jmccarrell/emacs-config/issues/62)). Which Homebrew
casks provide Noto Sans, Noto Serif and Noto Sans Mono, and do they install
variable or static files? How does the NS build of Emacs see them: family
names, which `:weight` and `:width` values a face can select, and whether a
variable font's named instances are reachable? Which org-modern and
markdown-mode glyphs does each one lack?

**Scope.** GNU Emacs 31.1, NS (Cocoa) build, on the Mark43 Mac. Nothing was
installed system-wide. The cask archives were downloaded into a scratch
directory (SHA-256 matched the casks) and inspected two ways:

- with fontTools (`name`, `fvar`, `OS/2`, `post`, `cmap`, `hmtx`);
- with CoreText itself, by registering the files **process-scoped**
  (`CTFontManagerRegisterFontsForURL(..., kCTFontManagerScopeProcess)`) in a
  PyObjC process and listing the descriptors CoreText returns for each family.
  That descriptor list is exactly what `macfont.m` turns into font entities.
  Each descriptor's weight and width trait was then put through macfont's own
  interpolation tables.

The Emacs side was checked in the running Emacs (via `emacsclient`, read-only)
against fonts already on the system. **Noto Sans Syriac** ships with macOS as a
variable font with the same `wght` 100–900 axis. Run through the PyObjC
harness, it gives exactly the weights `list-fonts` reports for it in the live
Emacs. So the harness's predictions for the uninstalled Noto files carry over.

## Answer

| Cask | Files it installs | Family name Emacs sees | `:weight` reachable | `:width` reachable | Italic |
|---|---|---|---|---|---|
| `font-noto-sans` | **both** the static TTFs (every weight × width × italic) **and** the variable pair `NotoSans[wdth,wght].ttf` / `NotoSans-Italic[wdth,wght].ttf` | `Noto Sans` | thin, ultra-light, light, regular, medium, semi-bold, bold, extra-bold, black | normal, semi-condensed, condensed, extra-condensed (from the static files) | real |
| `font-noto-serif` | variable only: `NotoSerif[wdth,wght].ttf` and its italic | `Noto Serif` | same set of weights | **normal only** | real |
| `font-noto-sans-mono` | variable only: `NotoSansMono[wdth,wght].ttf`, no italic file | `Noto Sans Mono` | same set of weights | normal, semi-condensed, condensed, extra-condensed (named instances) | synthetic (Emacs slants it) |
| `font-noto-sans-symbols-2` (already installed) | static `NotoSansSymbols2-Regular.ttf` | `Noto Sans Symbols 2` | regular (bold is synthetic) | normal | synthetic |

Install `font-noto-sans`, `font-noto-serif` and `font-noto-sans-mono`. Face
specs use the plain family names: `:family "Noto Sans"`, `:family "Noto Serif"`,
`:family "Noto Sans Mono"`. No `-Regular` suffix and no width-specific family
names are needed.

### Glyph coverage

Glyphs checked: the org-modern defaults (fold stars `org-modern-fold-stars`,
list bullets `org-modern-list`, checkboxes `org-modern-checkbox`), the `…`
ellipsis, and the markdown-mode glyphs drawn when `markdown-hide-markup` is on
(`markdown-list-item-bullets`, `markdown-definition-display-char`,
`markdown-blockquote-display-char`, `markdown-hr-display-char`). The static and
variable Noto Sans files have the same `cmap`.

| Font | Lacks (org-modern + `…`) | Lacks (markdown hide-markup) |
|---|---|---|
| Noto Sans | ▶ ▼ ▷ ▽ ⯈ ⯆ ▹ ▿ ▸ ▾, ◦, ☑ □ | ● ◎ ○ ◆ ◇ ►, ▌ ┃ ─ |
| Noto Serif | same as Noto Sans | same as Noto Sans |
| Noto Sans Mono | ⯈ ⯆, ☑ | nothing |
| Noto Sans Symbols 2 | nothing | ⁘ ▌ ┃ ─ |

So Noto Sans and Noto Serif supply only `–`, `•` and `…` (plus markdown's `•`
and `⁘`). Every fold star, `◦` and both checkboxes come from fallback. Noto
Sans Mono covers everything except `⯈ ⯆ ☑`. However, it draws `▶ ▷ ▽ ◆ ◇` at
**double width** (1200 units against a 600-unit cell).

## How the NS build handles variable fonts

**Named instances are reachable; arbitrary axis values are not.** `macfont.m`
contains no font-variation code (no `kCTFontVariationAttribute`). It builds one
entity per descriptor CoreText enumerates for a family, and CoreText enumerates
each `fvar` named instance as its own descriptor
([macfont.m `macfont_descriptor_entity`](https://github.com/emacs-mirror/emacs/blob/a2d49cab4db0c498cca73026e1e178503bc8eef1/src/macfont.m#L942-L985)).
In the live Emacs, `list-fonts` on Noto Sans Syriac and on Skia (a variable
font with width instances) returns an entity per named instance. Face
realization picks the nearest one: `:weight bold` opens the Bold instance and
`:width condensed` opens Skia's Condensed instance. The glyph advances differ
per instance, so these are genuinely different outlines, not one face relabeled.

Consequences:

- **Noto Serif has no condensed widths in Emacs.** Its `wdth` axis
  (62.5–100) exists, but every named instance sits at `wdth=100`, and Emacs
  never sets an axis value itself.
- **Noto Sans gets its widths only from the static files** in the same cask.
  Its variable font, like Noto Serif's, has named instances only at
  `wdth=100`.
- **Noto Sans Mono's variable font names its width instances**
  (SemiCondensed, Condensed and ExtraCondensed at every weight), so
  `:width condensed` works.

**Weight mapping.** macfont interpolates CoreText's `kCTFontWeightTrait` and
`kCTFontWidthTrait` through fixed tables
([macfont.m L857-L913](https://github.com/emacs-mirror/emacs/blob/a2d49cab4db0c498cca73026e1e178503bc8eef1/src/macfont.m#L857-L913)).
For these Noto files CoreText reports weight traits that land exactly on that
table's points:

| Noto instance | Thin | ExtraLight | Light | Regular | Medium | SemiBold | Bold | ExtraBold | Black |
|---|---|---|---|---|---|---|---|---|---|
| CoreText weight | −0.6 | −0.4 | −0.23 | 0 | 0.2 | 0.3 | 0.4 | 0.6 | 0.8 |
| Emacs `:weight` | `thin` | `ultra-light` | `light` | `regular` | `medium` | `semi-bold` | `bold` | `extra-bold` | `black` |

So each weight symbol selects one distinct instance. Note that `ultra-light`,
not `extra-light`, is the symbol for ExtraLight. `semi-light` and `ultra-heavy`
have no instance and fall to the nearest one. Widths map the same way: −0.1,
−0.2 and −0.3 become `semi-condensed`, `condensed` and `extra-condensed`.

This is not true of every variable font. Noto Sans Syriac, and static
Helvetica Neue, report Apple's `NSFontWeight` values instead (Thin −0.8,
ExtraLight −0.6, Light −0.4, Medium 0.23, ExtraBold 0.56, Black 0.62). That
collapses pairs onto one symbol: Thin and ExtraLight both become `thin`, and
ExtraBold and Black both become `extra-bold`. Measured advances show the
first-listed entity wins, so ExtraLight and Black are unreachable for those
families. The Noto Latin fonts do not have this problem.

**`find-font` is strict, faces are not.** `(find-font (font-spec :family F
:weight 'light))` returns nil when no entity has exactly that weight. A face
with the same `:weight` gets the nearest instance. Test weights with a face
(or `font-at` on propertized text), not with `find-font`, `font-info` or
`x-list-fonts`. `font-info` ignored `:weight` entirely, even for static fonts.

**Family names come from the typographic family.** CoreText's
`kCTFontFamilyNameAttribute` uses name ID 16 when present. The static file
`NotoSans-SemiCondensedBold.ttf` has legacy family `Noto Sans SemiCondensed`
and typographic family `Noto Sans`; CoreText reports `Noto Sans` with a width
trait. The installed Avenir Next and FiraCode Nerd Font files behave the same
way in `(font-family-list)`. Expect `Noto Sans`, `Noto Serif` and
`Noto Sans Mono` only.

## Wrinkles

- **`font-noto-sans` registers every normal-width style twice.** The static
  `NotoSans-Bold.ttf` and the variable font's Bold instance both report
  PostScript name `NotoSans-Bold`. CoreText lists both, so `list-fonts` will
  show duplicates and Font Book may flag them. They are the same design at the
  same version (2.015): Regular's advance widths are identical across all
  glyphs, and Bold differs in a handful of advances out of thousands. Leave
  the duplicates alone. Do not hand-delete files from the cask.

- **Noto Sans Mono's Regular is not flagged monospace.** The font's
  `post.isFixedPitch` is 0. CoreText marks every named instance with
  `kCTFontTraitMonoSpace` except the default (Regular), which macfont stores as
  `:spacing` proportional
  ([macfont.m L920-L929](https://github.com/emacs-mirror/emacs/blob/a2d49cab4db0c498cca73026e1e178503bc8eef1/src/macfont.m#L920-L929)).
  Columns still align, because macfont rounds each glyph's advance on its own
  for proportional fonts
  ([L1296-L1305](https://github.com/emacs-mirror/emacs/blob/a2d49cab4db0c498cca73026e1e178503bc8eef1/src/macfont.m#L1294-L1305))
  and every ASCII glyph is 600 units. Don't put `:spacing` in the
  `fixed-pitch` spec, or Regular won't match.

- **A face's own font wins for symbols, ahead of any fontset rule.** With
  `use-default-font-for-symbols` at its default `t`, a character whose script
  is `symbol` is drawn from the face's own font whenever that font has the
  glyph, before the fontset is consulted
  ([fontset.c L929-L953](https://github.com/emacs-mirror/emacs/blob/a2d49cab4db0c498cca73026e1e178503bc8eef1/src/fontset.c#L929-L953)).
  Every glyph above is `symbol` in `char-script-table`. A `set-fontset-font`
  pin to Noto Sans Symbols 2 therefore applies only where the face's font
  lacks the glyph. That is everything in the coverage table under Noto Sans
  and Serif, but only `⯈ ⯆ ☑` under Noto Sans Mono.

- **Which face draws what.** Under mixed-pitch, `org-checkbox` is in
  `mixed-pitch-fixed-pitch-faces`, so `☑ □` are drawn in `fixed-pitch`. Fold
  stars and list bullets take the surrounding (variable-pitch) face, so they
  never reach Noto Sans Mono and its double-width glyphs.

- **Today's fallback is a mix of fonts.** With Helvetica Neue / Monospace
  (which resolves to Courier here), the running Emacs draws `▶ ▷ ▽ ▹ ▿ ▸ ▾ ☑`
  from Arial Unicode MS, `▼ ◦ □` from Andale Mono, and only `⯈ ⯆` from Noto
  Sans Symbols 2. `⯈ ⯆` are the only glyphs here in the Miscellaneous Symbols
  and Arrows block (U+2B00–2BFF). The rest are in Geometric Shapes
  (U+25A0–25FF), plus `☑` in Miscellaneous Symbols (U+2600–26FF).

- **`org-modern-label`'s `:width condensed` is currently inert.** The config's
  `:custom-face` spec replaces the defface (the live value is `unspecified`).
  If it were restored, Noto Sans Mono would actually narrow the labels, which
  Hack and Menlo cannot do.

- **No restart needed to see a new font.** macfont drops its family cache on
  `kCTFontManagerRegisteredFontsChangedNotification`
  ([L1080-L1103](https://github.com/emacs-mirror/emacs/blob/a2d49cab4db0c498cca73026e1e178503bc8eef1/src/macfont.m#L1080-L1103)).
  But the config's `jwm/font-exists-p` guards run at load, so the face settings
  need a re-eval or restart after installing.

## Sources

- Casks (`brew info --json=v2 --cask …`):
  [font-noto-sans](https://github.com/Homebrew/homebrew-cask/blob/HEAD/Casks/font/font-n/font-noto-sans.rb)
  2.015,
  [font-noto-serif](https://github.com/Homebrew/homebrew-cask/blob/HEAD/Casks/font/font-n/font-noto-serif.rb)
  2.015,
  [font-noto-sans-mono](https://github.com/Homebrew/homebrew-cask/blob/HEAD/Casks/font/font-n/font-noto-sans-mono.rb)
  2.014. Each downloads a release zip from
  [notofonts/latin-greek-cyrillic](https://github.com/notofonts/latin-greek-cyrillic/releases)
  (`NotoSans-v2.015.zip`, `NotoSerif-v2.015.zip`, `NotoSansMono-v2.014.zip`)
  and installs files from its `unhinted/` tree.
- Emacs source at `emacs-31` commit `a2d49cab`:
  [src/macfont.m](https://github.com/emacs-mirror/emacs/blob/a2d49cab4db0c498cca73026e1e178503bc8eef1/src/macfont.m),
  [src/fontset.c](https://github.com/emacs-mirror/emacs/blob/a2d49cab4db0c498cca73026e1e178503bc8eef1/src/fontset.c).
  Emacs 31.1's `etc/NEWS*` say nothing about variable fonts.
- Package defaults: `org-modern-20260722.1411/org-modern.el`
  (`org-modern-fold-stars`, `org-modern-list`, `org-modern-checkbox`,
  `org-modern-label`), and `markdown-mode-20260827.909/markdown-mode.el`
  (`markdown-list-item-bullets` and the `*-display-char` options, all gated on
  `markdown-hide-markup`, default nil).
- Live Emacs 31.1 (NS) via `emacsclient`: `font-family-list`, `list-fonts`,
  `find-font`, `font-at` and `font-get-glyphs` on Noto Sans Syriac, Skia,
  Helvetica Neue, Avenir Next and Noto Sans Symbols 2; `char-script-table`;
  `use-default-font-for-symbols`; `mixed-pitch-fixed-pitch-faces`.
