(add-to-list 'treesit-extra-load-path
             (expand-file-name "~/.config/doom/local/grammars"))

(defface maude-type-face
  '((t :foreground "#a855f7" :weight bold))
  "Purple color for types")


(defface maude-attr-face
  '((t :foreground "#FA0021" :weight bold))
  "color for attr")

(defvar maude-ts-font-lock-rules
  '(:language maude
    :feature keyword
    ((keyword) @font-lock-keyword-face)

    :language maude
    :feature identifier
    ((identifier) @font-lock-type-face)

    :language maude
    :feature op-attr
    ((op_attr) @maude-attr-face)

    :language maude
    :feature type
    ((base_type) @maude-type-face)
    ))

(defun maude-ts-setup ()
  (setq-local treesit-font-lock-settings
              (apply #'treesit-font-lock-rules maude-ts-font-lock-rules))
  (setq-local treesit-font-lock-feature-list '((keyword type op_attr identifier)))
  (treesit-major-mode-setup))

(define-derived-mode maude-ts-mode prog-mode
  "Maude"
  (when (treesit-ready-p 'maude)
    (maude-ts-setup))
  (eglot-ensure))

(add-to-list 'auto-mode-alist '("\\.maude\\'" . maude-ts-mode))

(defun maude-load-file ()
  (interactive)
  (let ((file (buffer-file-name)))
    (maude-open-repl)
    (comint-send-string "*maude*"
                        (format "in %s .\n" file))))

(defun maude-open-repl()
  (interactive)
  (unless (get-buffer "*maude*")
    (make-comint "maude" "maude" nil "-interactive"))
  (switch-to-buffer-other-window "*maude*"))

(define-key maude-ts-mode-map (kbd "C-c C-r") #'maude-open-repl)
(define-key maude-ts-mode-map (kbd "C-c C-l") #'maude-load-file)
