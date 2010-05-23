;;; .emacs.d/init.el

(setq column-number-mode t
      custom-file "~/.emacs.d/custom.el"
      diff-switches "-u"
      enable-recursive-minibuffers t
      frame-title-format "%b - emacs"
      help-window-select t
      indent-tabs-mode nil
      inhibit-startup-screen t
      kill-whole-line t
      show-paren-mode t
      show-trailing-whitespace t
      size-indication-mode t
      uniquify-buffer-name-style 'forward
      use-dialog-box nil
      visible-bell t)

(setq-default indicate-buffer-boundaries t
	      indicate-empty-lines t
	      save-place t)

(load custom-file)

(global-set-key "\C-xw" 'write-region)
(global-set-key "\C-ce" 'shell)
(global-set-key "\C-cf" 'find-function-other-window)
(global-set-key "\C-cj" 'compile)
(global-set-key "\C-ck" 'find-function-on-key)
(global-set-key "\C-cl" 'locate)
(global-set-key "\C-cq" 'bury-buffer)
(global-set-key "\C-cz" 'suspend-frame)
(global-set-key [C-tab] 'mode-line-other-buffer)
(global-set-key [M-left] 'backward-sexp)
(global-set-key [M-right] 'forward-sexp)

;;; scrollbar
(set-scroll-bar-mode 'right)

;;; toolbar
(tool-bar-mode)

;; ja font
(set-fontset-font t 'japanese-jisx0208 "VL ゴシック")

;;; personal lisp dir
(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp"))

;;; browse-kill-ring
(browse-kill-ring-default-keybindings)

;;; diary
(if (file-readable-p "~/diary")
    (diary 7))

;;; dired
(setq dired-keep-marker-rename ?R)

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
(define-key dired-mode-map "=e" 'dired-ediff)
(define-key dired-mode-map "=p" 'dired-epatch)

;;; dired-x
(setq dired-guess-shell-alist-user 
      '(("\\.pdf$" "evince")
	("\\.t\\(ar\\.bz2\\|bz\\)$" "tar jxvf" "tar jtvf")
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
(iswitchb-default-keybindings)
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

;; scala
;(add-to-list 'load-path "~/usr/scala/misc/scala-tool-support/emacs/")
;(require 'scala-mode-auto)

;;; server
(setenv "EDITOR" "emacsclient")
(require 'server)
(unless (server-running-p)
  (server-start))

