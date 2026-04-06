(add-to-list 'treesit-extra-load-path
             (expand-file-name "~/.config/doom/local/grammars"))

(defface maude-type-face
  '((t :foreground "#a855f7" :weight bold))
  "Purple color for types")

(defface maude-module-face
  '((t :foreground "#F52727" :weight bold))
  "Red color for modules")

(defface maude-attr-face
  '((t :foreground "#E82CC6" :weight bold))
  "color for attr")

(defvar maude-ts-font-lock-rules
  '(:language maude
    :feature keyword
    ((keyword) @font-lock-keyword-face)

    :language maude
    :feature keyword
    ((module_type) @maude-module-face)

    :language maude
    :feature keyword
    ((module_end) @maude-module-face)

    :language maude
    :feature op-attr
    ((op_attr) @maude-attr-face)

    :language maude
    :feature identifier
    ((identifier) @font-lock-variable-name-face)

    :language maude
    :feature type
    ((base_type) @maude-type-face)))

(defvar maude-ts-indent-rules
  '((maude
     ((node-is "module_end") column-0 0)
     ((node-is "module_type") column-0 0)
     ((parent-is "module_entry") column-0 2)
     (no-node column-0 0))))

(defun maude-ts-setup ()
  (setq-local tab-width 2)
  (setq-local treesit-simple-indent-rules maude-ts-indent-rules)
  (setq-local treesit-font-lock-settings
              (apply #'treesit-font-lock-rules maude-ts-font-lock-rules))
  (setq-local treesit-font-lock-feature-list '((keyword type op-attr identifier)))
  (treesit-major-mode-setup))

(define-derived-mode maude-ts-mode prog-mode "Maude"
  (when (treesit-ready-p 'maude)
    (treesit-parser-create 'maude)
    (maude-ts-setup))
  (eglot-ensure))

(add-to-list 'auto-mode-alist '("\\.maude\\'" . maude-ts-mode))

(defun maude-load-file ()
  (interactive)
  (if (not (buffer-file-name))
      (message "Buffer has no associated file")
    (save-buffer)
    (maude-open-repl)
    (comint-send-string "*maude*"
                        (format "in %s .\n" (buffer-file-name)))))

(defun maude-open-repl ()
  (interactive)
  (if (get-buffer "*maude")
      (unless (get-buffer-process "*maude*")
        (kill-buffer "*maude")
        (make-comint "maude" "maude" nil "-interactive"))
    (make-comint "maude" "maude" nil "-interactive"))
  (switch-to-buffer-other-window "*maude*"))

(define-key maude-ts-mode-map (kbd "C-c C-r") #'maude-open-repl)
(define-key maude-ts-mode-map (kbd "C-c C-l") #'maude-load-file)
