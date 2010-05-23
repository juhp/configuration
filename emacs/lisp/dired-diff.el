;; -*-Emacs-Lisp-*-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; File:           dired-diff.el
;; RCS:
;; Dired Version:  7.13
;; Description:    Support for diff and related commands.
;; Author:         Sandy Rutherford <sandy@ibm550.sissa.it>
;; Created:        Fri Jun 24 08:50:20 1994 by sandy on ibm550
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; This program is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 1, or (at your option)
;;; any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; A copy of the GNU General Public License can be obtained from this
;;; program's author (send electronic mail to sandy@ibm550.sissa.it) or
;;; from the Free Software Foundation, Inc., 675 Mass Ave, Cambridge,
;;; MA 02139, USA.

(provide 'dired-diff)
(require 'dired)
(require 'diff-mode)

(defvar emerge-last-dir-input)
(defvar emerge-last-dir-output)
(defvar emerge-last-dir-ancestor)
(defvar diff-switches)

(defun dired-diff-read-file-name (prompt)
  ;; Read and return a file name for diff.
  (let* ((mark-active t)
	 (default (and (mark)
		       (save-excursion
			 (goto-char (mark))
			 (dired-get-filename nil t)))))
    (read-file-name (format "%s %s with: %s"
			    prompt (dired-get-filename 'no-dir)
			    (if default
				(concat "["
					(dired-make-relative
					 default
					 (dired-current-directory) t)
					"] ")
			      ""))
		    default-directory default t)))

(defun dired-diff-read-switches (switchprompt)
  ;; Read and return a list of switches
  (let* ((default (if (listp diff-switches)
		      (mapconcat 'identity diff-switches " ")
		    diff-switches))
	 (switches
	  (read-string (format switchprompt default) default)))
    (let (result (start 0))
      (while (string-match "\\(\\S-+\\)" switches start)
	(setq result (cons (substring switches (match-beginning 1)
				      (match-end 1))
			   result)
	      start (match-end 0)))
      (nreverse result))))

;;;###autoload
(defun dired-diff (file &optional switches)
  "Compare file at point with file FILE using `diff'.
FILE defaults to the file at the mark.
The prompted-for file is the first file given to `diff'.
With a prefix allows the switches for the diff program to be edited."
  (interactive
   (list
    (dired-diff-read-file-name "Diff") 
    (and current-prefix-arg (dired-diff-read-switches "Options for diff: "))))
  (if switches
      (diff file (dired-get-filename) switches)
    (diff file (dired-get-filename))))

;;;###autoload
(defun dired-backup-diff (&optional switches)
  "Diff this file with its backup file or vice versa.
Uses the latest backup, if there are several numerical backups.
If this file is a backup, diff it with its original.
The backup file is the first file given to `diff'."
  (interactive (list (and current-prefix-arg
			  (dired-diff-read-switches "Diff with switches: "))))
  (if switches
      (diff-backup (dired-get-filename) switches)
    (diff-backup (dired-get-filename))))

;;;###autoload
(defun dired-emerge (arg file out-file)
  "Merge file at point with FILE using `emerge'.
FILE defaults to the file at the mark."
  (interactive
   (let ((file (dired-diff-read-file-name "Merge")))
     (list
      current-prefix-arg
      file
      (and current-prefix-arg (emerge-read-file-name
			       "Output file"
			       emerge-last-dir-output
			       (dired-abbreviate-file-name file) file)))))
  (emerge-files arg file (dired-get-filename) out-file))

;;;###autoload
(defun dired-emerge-with-ancestor (arg file ancestor file-out)
  "Merge file at point with FILE, using a common ANCESTOR file.
FILE defaults to the file at the mark."
  (interactive
   (let ((file (dired-diff-read-file-name "Merge")))
     (list
      current-prefix-arg
      file
      (emerge-read-file-name "Ancestor file" emerge-last-dir-ancestor nil file)
      (and current-prefix-arg (emerge-read-file-name
			       "Output file"
			       emerge-last-dir-output
			       (dired-abbreviate-file-name file) file)))))
  (emerge-files-with-ancestor arg file (dired-get-filename)
			      ancestor file-out))

;;;###autoload
(defun dired-ediff (file)
  "Ediff file at point with FILE.
FILE defaults to the file at the mark.
`ediff-directories' is used if both files are directories."
  (interactive (list (dired-diff-read-file-name "Ediff")))
  (let
      ((file-at-mark-is-dir
        (file-directory-p
         (file-name-as-directory file)))
       (file-at-point-is-dir
        (file-directory-p
         (file-name-as-directory (dired-get-filename)))))
    (cond
     ((and file-at-mark-is-dir file-at-point-is-dir)
      (ediff-directories file (dired-get-filename) ""))
     ((and (not file-at-mark-is-dir) (not file-at-point-is-dir))
      (ediff-files file (dired-get-filename)))
     (t
      (apply
       'warn
       "Cannot compare file %s with directory %s"
       (if file-at-mark-is-dir
           (list (dired-get-filename) file)
         (list file (dired-get-filename))))))))

;;;###autoload
(defun dired-epatch (file)
  "Patch file at point using `epatch'."
  (interactive
   (let ((file (dired-get-filename)))
     (list
      (and (or (memq 'patch dired-no-confirm)
	       (y-or-n-p (format "Patch %s? "
				(file-name-nondirectory file))))
	   file))))
  (if file
      (ediff-patch-file file)
    (message "No file patched.")))

;;; Autoloads

;;; Diff (diff)

(autoload 'diff "diff" "Diff two files." t)
(autoload 'diff-backup "diff"
	  "Diff this file with its backup or vice versa." t)

;;; Emerge

(autoload 'emerge-files "emerge" "Merge two files." t)
(autoload 'emerge-files-with-ancestor "emerge"
	 "Merge two files having a common ancestor." t)
(autoload 'emerge-read-file-name "emerge")

;; Ediff

(autoload 'ediff-files "ediff" "Ediff two files." t)
(autoload 'ediff-patch-file "ediff" "Patch a file." t)

;;; end of dired-diff.el
