(setq column-number-mode t
      custom-file "~/.emacs.d/custom.el"
      diff-switches "-u"
      enable-recursive-minibuffers t
      help-window-select t
      indent-tabs-mode nil
      inhibit-startup-screen t
      kill-whole-line t
      show-trailing-whitespace t
      use-dialog-box nil
      visible-bell t)

(load custom-file)

(global-set-key "\C-xw" 'write-region)
(global-set-key "\C-cf" 'find-function-other-window)
(global-set-key "\C-cj" 'compile)
(global-set-key "\C-ck" 'find-function-on-key)
(global-set-key "\C-cl" 'locate)
(global-set-key "\C-cq" 'bury-buffer)
(global-set-key "\C-cz" 'suspend-frame)
(global-set-key [C-tab] 'mode-line-other-buffer)
(global-set-key [M-left] 'backward-sexp)
(global-set-key [M-right] 'forward-sexp)

;;; personal elisp dir
(add-to-list 'load-path (expand-file-name "~/.emacs.d/elisp"))

;;; browse-kill-ring
(browse-kill-ring-default-keybindings)

;;; dired
(setq dired-keep-marker-rename ?R)

;;; ffap
(setq ffap-require-prefix t)
(ffap-bindings)

;;; iswitchb
(load "iswitchb")
(iswitchb-default-keybindings)
(defalias 'read-buffer 'iswitchb-read-buffer)


(unless (server-running-p)
  (server-start))
