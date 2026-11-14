;;; noto-font-variants.el --- PROTOTYPE: compare prose-font patterns -*- lexical-binding: t; -*-

;; Throwaway, for map #62 ticket #69.  Never part of the config.
;; Load into a running Emacs, step through variants, then restart Emacs:
;; it changes the theme and faces of the whole session.
;;
;;   M-x noto-proto-next / noto-proto-prev / noto-proto-goto
;;
;; Every setting is one the patterns chosen in #67 use: A is mixed-pitch on
;; zenburn with Doom zen's face list, B is oantolin's variable-pitch-mode with
;; ef-autumn and modus-themes-mixed-fonts.

(require 'mixed-pitch)
(require 'org)

(defvar noto-proto-files
  '("~/mark43/notes/todo.org"
    "~/jwm/proj/emacs-config/reference-configs.md"))

;; Doom's zen module additions to mixed-pitch's monospace list.
(defvar noto-proto-doom-zen-faces
  '(org-date org-footnote org-special-keyword org-property-value
    org-tag org-todo org-done font-lock-comment-face))

(defvar noto-proto-variants
  '((A "Helvetica Neue" nil)
    (A "Noto Sans" nil)
    (A "Noto Serif" nil)
    (A "Noto Sans" set-height)
    (A "Noto Serif" set-height)
    (B "Helvetica Neue" nil)
    (B "Noto Sans" nil)
    (B "Noto Serif" nil)
    (B "Noto Sans" mono)
    (B "Noto Serif" mono)))

(defvar noto-proto--orig
  (list :faces mixed-pitch-fixed-pitch-faces
        :fixed (face-attribute 'fixed-pitch :family)))

(defvar noto-proto--index -1)

(defun noto-proto--label (v)
  (pcase-let ((`(,pattern ,family ,extra) v))
    (format "%s  %s  %s%s"
            (if (eq pattern 'A) "A mixed-pitch / zenburn" "B variable-pitch-mode / ef-autumn")
            family
            (pcase extra
              ('set-height "mixed-pitch-set-height t")
              ('mono "fixed-pitch Noto Sans Mono")
              (_ "defaults"))
            "")))

(defun noto-proto--theme (theme)
  (mapc #'disable-theme custom-enabled-themes)
  (when (eq theme 'ef-autumn)
    (setq modus-themes-mixed-fonts t)
    (require 'ef-themes)
    (ef-themes-take-over-modus-themes-mode 1))
  (load-theme theme t))

(defun noto-proto-apply (v)
  (pcase-let ((`(,pattern ,family ,extra) v))
    (noto-proto--theme (if (eq pattern 'A) 'zenburn 'ef-autumn))
    (set-face-attribute 'variable-pitch nil :family family)
    (set-face-attribute 'fixed-pitch nil :family
                        (if (eq extra 'mono) "Noto Sans Mono"
                          (plist-get noto-proto--orig :fixed)))
    (setq mixed-pitch-fixed-pitch-faces
          (append (plist-get noto-proto--orig :faces)
                  (and (eq pattern 'A) noto-proto-doom-zen-faces)))
    (setq mixed-pitch-set-height (eq extra 'set-height))
    (dolist (f noto-proto-files)
      (with-current-buffer (find-file-noselect (expand-file-name f))
        (variable-pitch-mode -1)
        (mixed-pitch-mode -1)
        (if (eq pattern 'A) (mixed-pitch-mode 1) (variable-pitch-mode 1))
        (setq-local header-line-format
                    (format " PROTOTYPE %d/%d  %s"
                            (1+ noto-proto--index) (length noto-proto-variants)
                            (noto-proto--label v)))))
    (message "noto-proto: %s" (noto-proto--label v))))

(defun noto-proto--go (i)
  (setq noto-proto--index (mod i (length noto-proto-variants)))
  (noto-proto-apply (nth noto-proto--index noto-proto-variants)))

(defun noto-proto-next () (interactive) (noto-proto--go (1+ noto-proto--index)))
(defun noto-proto-prev () (interactive) (noto-proto--go (1- noto-proto--index)))
(defun noto-proto-goto ()
  (interactive)
  (let* ((labels (mapcar #'noto-proto--label noto-proto-variants))
         (pick (completing-read "Variant: " labels nil t)))
    (noto-proto--go (seq-position labels pick))))

;;; noto-font-variants.el ends here
