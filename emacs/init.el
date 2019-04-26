;;; .emacs.d/init.el


(require 'package)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(setq column-number-mode t
      custom-file "~/.emacs.d/custom.el"
      diff-switches "-u"
      enable-recursive-minibuffers t
      frame-title-format "%b - emacs"
      help-window-select t
      inhibit-startup-screen t
      kill-do-not-save-duplicates t
      kill-ring-max 128
      kill-whole-line t
      save-place-file "~/.emacs.d/saveplaces.el"
      save-place-limit 1000
      show-paren-mode t
      size-indication-mode t
      tar-mode-show-date t
      uniquify-buffer-name-style 'forward
      use-dialog-box nil
      visible-bell t)

(setq-default indent-tabs-mode nil
	      indicate-buffer-boundaries 'left
	      indicate-empty-lines t
	      save-place t)

(load custom-file)

(global-set-key "\C-xw" 'write-region)
(global-set-key "\C-ce" 'shell)
(global-set-key "\C-cf" 'find-function-other-window)
(global-set-key "\C-cg" 'magit-status)
(global-set-key "\C-cj" 'compile)
(global-set-key "\C-ck" 'find-function-on-key)
(global-set-key "\C-cl" 'magit-log-current)
(global-set-key "\C-cq" 'bury-buffer)
(global-set-key "\C-c0" '(lambda () (interactive) (shell "*shell*")))
(global-set-key "\C-c1" '(lambda () (interactive) (shell "*shell*<1>")))
(global-set-key "\C-c2" '(lambda () (interactive) (shell "*shell*<2>")))
(global-set-key "\C-c3" '(lambda () (interactive) (shell "*shell*<3>")))
(global-set-key "\C-c4" '(lambda () (interactive) (shell "*shell*<4>")))
(global-set-key "\C-c5" '(lambda () (interactive) (shell "*shell*<5>")))
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
(defun juhp-eshell-hook-fn ()
  (define-key eshell-mode-map "\C-u" 'eshell-kill-input)
  (define-key eshell-mode-map "\C-w" 'backward-kill-word)
  ;(setq pcomplete-cycle-completions nil)
  )
;(add-hook 'eshell-mode-hook
;	  'juhp-eshell-hook-fn)

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
;(iswitchb-default-keybindings)
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

;; scala
;(add-to-list 'load-path "~/usr/scala/misc/scala-tool-support/emacs/")
;(require 'scala-mode-auto)

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

;;; show-wspace
;; (require 'show-wspace)
;; (add-hook 'font-lock-mode-hook 'show-ws-highlight-tabs)
;; (add-hook 'font-lock-mode-hook 'show-ws-highlight-trailing-whitespace)

;;; whitespace
(setq-default whitespace-style '(tabs trailing space-before-tab newline indentation empty space-after-tab))
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

;;; git
;(add-to-list 'load-path "~/.emacs.d/lisp/git-emacs")
;(require 'git-emacs-autoloads)

;;; magit
(setq magit-omit-untracked-dir-contents t)
(put 'scroll-left 'disabled nil)
(autoload 'magit-display-log "magit" nil t)

;;; browse-url
(setq browse-url-browser-function 'browse-url-xdg-open)

;; Intero
(package-install 'intero)
;(add-hook 'haskell-mode-hook 'intero-mode)
