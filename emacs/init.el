;;; .emacs.d/init.el


(require 'package)
;; (add-to-list 'package-archives
;;              '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))

(setq column-number-mode t
      custom-file "~/.emacs.d/custom.el"
      delete-trailing-lines t
      diff-switches "-u"
      enable-recursive-minibuffers t
      frame-title-format "%b - emacs"
      help-window-select t
      inhibit-startup-screen t
      ispell-dictionary "english" ; needed for C locale
      kill-do-not-save-duplicates t
      kill-ring-max 128
      kill-whole-line t
      save-place-file "~/.emacs.d/saveplaces.el"
      save-place-limit 1000
      ; show-trailing-whitespace t
      show-paren-mode t
      size-indication-mode t
      tar-mode-show-date t
      uniquify-buffer-name-style 'forward
      use-dialog-box nil
      visible-bell t)

;;; whitespace
(add-hook 'before-save-hook
          (lambda ()
            (unless (eq major-mode 'diff-mode)
              (delete-trailing-whitespace))))

;;; mode-line: reduce whitespace
(setq-default mode-line-format
              '("%e" mode-line-front-space mode-line-mule-info mode-line-client mode-line-modified mode-line-remote mode-line-frame-identification mode-line-buffer-identification "  " mode-line-position (vc-mode vc-mode) " "
                mode-line-modes mode-line-misc-info mode-line-end-spaces)

              mode-line-buffer-identification
              '(#("%b" 0 2
                  (mouse-face mode-line-highlight face mode-line-buffer-id))))

(setq mode-line-frame-identification " " ; (:eval (mode-line-frame-control))
      mode-line-front-space nil)

(setq-default indent-tabs-mode nil
	      indicate-buffer-boundaries 'left
	      indicate-empty-lines t)

(save-place-mode t)

(load custom-file)

(global-set-key "\C-xw" 'write-region)
(global-set-key "\C-cb" 'magit-checkout)
;;(global-set-key "\C-ce" 'shell)
(global-set-key "\C-cf" 'find-function-other-window)
(global-set-key "\C-cg" 'magit-status)
(global-set-key "\C-cj" 'compile)
(global-set-key "\C-ck" 'find-function-on-key)
(global-set-key "\C-cl" 'magit-log-current)
(global-set-key "\C-cq" 'bury-buffer)
(global-set-key "\C-ct" 'vterm-toggle)
(global-set-key "\C-cv" 'multi-vterm-project)
;; (global-set-key "\C-c0" '(lambda () (interactive) (shell "*shell*")))
;; (global-set-key "\C-c1" '(lambda () (interactive) (shell "*shell*<1>")))
;; (global-set-key "\C-c2" '(lambda () (interactive) (shell "*shell*<2>")))
;; (global-set-key "\C-c3" '(lambda () (interactive) (shell "*shell*<3>")))
;; (global-set-key "\C-c4" '(lambda () (interactive) (shell "*shell*<4>")))
;; (global-set-key "\C-c5" '(lambda () (interactive) (shell "*shell*<5>")))
(global-set-key "\C-z" 'isearchb-activate)
(global-set-key [C-tab] 'mode-line-other-buffer)
(global-set-key [M-left] 'backward-sexp)
(global-set-key [M-right] 'forward-sexp)

;;; scrollbar
(set-scroll-bar-mode 'right)

;;; toolbar
(tool-bar-mode 0)

;;; personal lisp dir
(add-to-list 'load-path "~/.emacs.d/lisp")

;;; browse-kill-ring (emacs-goodies)
(if (commandp 'browse-kill-ring-default-keybindings)
    (browse-kill-ring-default-keybindings))

;;; diary
(if (file-readable-p "~/diary")
    (diary 7))

;;; dired
(setq dired-keep-marker-rename ?R)

(defun ora-ediff-files ()
  (interactive)
  (let ((files (dired-get-marked-files)))
    (if (<= (length files) 2)
        (let ((file1 (car files))
              (file2 (if (cdr files)
                         (cadr files)
                       (read-file-name
                        "file: "
                        ))))
          (ediff-files file2 file1))
      (error "no more than 2 files should be marked"))))

;; dired-diff
(autoload 'dired-diff "dired-diff" nil t)
(autoload 'dired-backup-diff "dired-diff" nil t)
(autoload 'dired-ediff "dired-diff" nil t)
(require 'dired)
(define-key dired-mode-map "=" nil)
(define-key dired-mode-map "=d" 'dired-diff)
(define-key dired-mode-map "=b" 'dired-backup-diff)
(define-key dired-mode-map "=m" 'dired-emerge)
(define-key dired-mode-map "=a" 'dired-emerge-with-ancestor)
(define-key dired-mode-map "=e" 'ora-ediff-files)
(define-key dired-mode-map "=p" 'dired-epatch)

;;; dired-x
(setq dired-guess-shell-alist-user
      '(("\\.pdf$" "evince")
	("\\.tar.*$" "tar tvf" "tar xvf")
	))
(require 'dired-x)

;;; ediff
(setq ediff-window-setup-function 'ediff-setup-windows-plain
      ediff-split-window-function 'split-window-horizontally)

;;; eshell
(setq eshell-buffer-shorthand t
      eshell-hist-ignoredups t
      eshell-term-name "eterm-color")

(defun eshell/less (&rest args)
    "Invoke `view-file' on a file."
    (while args
      (view-file (pop args))))

;;; ffap
(setq dired-at-point-require-prefix t
      ffap-require-prefix t)
(ffap-bindings)

;;; iswitchb
(require 'iswitchb)
(iswitchb-mode)
(setq read-buffer-function 'iswitchb-read-buffer)
(defalias 'read-buffer 'iswitchb-read-buffer)

;;; w3m
(setq w3m-use-cookies t
      w3m-key-binding 'info
      w3m-default-display-inline-images t)
;(setq browse-url-browser-function 'w3m-browse-url)
(eval-after-load "w3m-search"
            '(progn
               (add-to-list 'w3m-search-engine-alist
                            '("RH bugzilla bug no"
                              "https://bugzilla.redhat.com/show_bug.cgi?id=%s"
                              nil))
               (add-to-list 'w3m-uri-replace-alist
                            '("\\`bz:" w3m-search-uri-replace "RH bugzilla bug no"))))

;;; savehist
(require 'savehist)

;;; saveplace
(require 'saveplace)

;;; server
(setenv "EDITOR" "emacsclient")
(require 'server)
(unless (server-running-p)
  (server-start))

;;; uniquify
(require 'uniquify)

;;; ack
(add-to-list 'load-path "~/.emacs.d/lisp/ShellArchive")
(autoload 'ack "ack" nil t)

;;; whitespace
;; newline causes _ in *compilation*
(setq-default whitespace-style '(face tabs trailing space-before-tab newline indentation empty space-after-tab tab-mark))
(setq whitespace-global-modes '(not compilation-mode comint-mode dired-mode vterm-mode))
(global-whitespace-mode)

;;; haskell-mode
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
(eval-after-load 'haskell-mode
  '(define-key haskell-mode-map "\C-ch" 'haskell-hoogle))
(setq haskell-hoogle-command "hoogle")

;;; calendar
(add-hook 'calendar-move-hook 'calendar-update-mode-line)
(setq calendar-mode-line-format
  (list
   '(let* ((year (calendar-extract-year date))
           (d (calendar-day-number date))
           (days-remaining
            (- (calendar-day-number (list 12 31 year)) d)))
      (format "day %d (%d left)" d days-remaining))
   '(let* ((d (calendar-absolute-from-gregorian date))
           (iso-date (calendar-iso-from-absolute d)))
      (format "ISO week %d of %d"
        (calendar-extract-month iso-date)
        (calendar-extract-year iso-date)))))

;;; magit
(setq magit-omit-untracked-dir-contents t)
(put 'scroll-left 'disabled nil)

;;; browse-url
(setq browse-url-browser-function 'browse-url-xdg-open)

;;; git-ps1
(let ((file "/usr/share/git-core/contrib/completion/git-prompt.sh"))
  (when (file-exists-p file)
    (setq git-ps1-mode-ps1-file file
          vc-handled-backends '(Git))
    (make-variable-buffer-local 'git-ps1-mode)
    (add-hook 'dired-mode-hook 'git-ps1-mode)))

(savehist-mode)

;;; projectile
(require 'projectile)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
(projectile-mode +1)
(defun projectile-my-mode-line ()
  "Report project name and type in the modeline."
  " Prj")
(setq projectile-mode-line-function 'projectile-my-mode-line)

; eglot
(use-package eglot
  :config
  (add-to-list 'eglot-server-programs '(haskell-mode . ("haskell-language-server-wrapper" "--lsp"))))

;;; use flycheck instead of flymake (to avoid process flood)
(use-package flycheck)
;; https://gist.github.com/purcell/ca33abbea9a98bb0f8a04d790a0cadcd
    (defvar-local flycheck-eglot-current-errors nil)

    (defun flycheck-eglot-report-fn (diags &rest _)
      (setq flycheck-eglot-current-errors
            (mapcar (lambda (diag)
                      (save-excursion
                        (goto-char (flymake--diag-beg diag))
                        (flycheck-error-new-at (line-number-at-pos)
                                               (1+ (- (point) (line-beginning-position)))
                                               (pcase (flymake--diag-type diag)
                                                 ('eglot-error 'error)
                                                 ('eglot-warning 'warning)
                                                 ('eglot-note 'info)
                                                 (_ (error "Unknown diag type, %S" diag)))
                                               (flymake--diag-text diag)
                                               :checker 'eglot)))
                    diags))
      (flycheck-buffer))

    (defun flycheck-eglot--start (checker callback)
      (funcall callback 'finished flycheck-eglot-current-errors))

    (defun flycheck-eglot--available-p ()
      (bound-and-true-p eglot--managed-mode))

    (flycheck-define-generic-checker 'eglot
      "Report `eglot' diagnostics using `flycheck'."
      :start #'flycheck-eglot--start
      :predicate #'flycheck-eglot--available-p
      :modes '(prog-mode text-mode))

    (push 'eglot flycheck-checkers)

    (defun sanityinc/eglot-prefer-flycheck ()
      (when eglot--managed-mode
        (flycheck-add-mode 'eglot major-mode)
        (flycheck-select-checker 'eglot)
        (flycheck-mode)
        (flymake-mode -1)
        (setq eglot--current-flymake-report-fn 'flycheck-eglot-report-fn)))

    (add-hook 'eglot--managed-mode-hook 'sanityinc/eglot-prefer-flycheck)

;; grep
(eval-after-load "grep"
  '(progn
    (add-to-list 'grep-find-ignored-files "*_flymake.*")
    (add-to-list 'grep-find-ignored-directories "dist")
    (add-to-list 'grep-find-ignored-directories "dist-newstyle")
    ))

;;; undo-tree
(global-undo-tree-mode)

;; (require 'ansi-color)
;; (defun colorize-compilation-buffer ()
;;   (when (eq major-mode 'compilation-mode)
;;     (ansi-color-process-output nil)
;;     (setq-local comint-last-output-start (point-marker))))
;; (add-hook 'compilation-filter-hook
;;           #'colorize-compilation-buffer)

;;; git-gutter
(global-git-gutter-mode +1)
