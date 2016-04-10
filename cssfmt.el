;;; cssfmt.el --- Cssfmt interface
;; copyright (C) 2015 κeen All rights reserved.
;; Use of this source code is governed by a BSD-style
;; license that can be found in the LICENSE file.
;; Author: κeen
;; Version: 0.0.1
;; Keywords: css code formatter
;; URL: https://github.com/KeenS/cssfmt.el
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;; This is a thin wrapper of [cssfmt](https://github.com/morishitter/cssfmt)
;;
;;; Installation:
;; 1. install cssfmt. If you have installed npm, just type `npm install -g cssfmt`
;; 2 Add your init.el
;;   (load "path/to/cssfmt.el)
;;   ;optional
;;   (add-hook 'css-mode-hook 'cssfmt-before-save)
;;; Code:

(require cssfmt-patch)

(defgroup cssfmt nil
  "'cssfmt' interface."
  :group 'css)

(defcustom cssfmt-command "cssfmt"
  "The 'cssfmt' command."
  :type 'string
  :group 'cssfmt)

(defcustom cssfmt-show-errors nil
  ""
  :type 'symbol
  :group 'cssfmt)

(defcustom cssfmt-args '()
  ""
  :type 'list
  :group 'cssfmt)

(defun cssfmt ()
  "Format the current buffer according to the cssfmt tool."
  (interactive)
  (let ((tmpfile (make-temp-file "cssfmt" nil ".css"))
        (patchbuf (get-buffer-create "*Cssfmt patch*"))
        (errbuf (if cssfmt-show-errors (get-buffer-create "*Cssfmt Errors*")))
        (coding-system-for-read 'utf-8)
        (coding-system-for-write 'utf-8)
        our-cssfmt-args)
    (unwind-protect
        (save-restriction
          (widen)
          (if errbuf
              (with-current-buffer errbuf
                (setq buffer-read-only nil)
                (erase-buffer)))
          (with-current-buffer patchbuf
            (erase-buffer))

          (write-region nil nil tmpfile)
          (setq our-cssfmt-args (append our-cssfmt-args
                                       cssfmt-args
                                       (list tmpfile)))
          (message "Calling cssfmt: %s %s" cssfmt-command our-cssfmt-args)
          ;; We're using errbuf for the mixed stdout and stderr output. This
          ;; is not an issue because cssfmt -w does not produce any stdout
          ;; output in case of success.
          (if (zerop (apply #'call-process cssfmt-command nil errbuf nil our-cssfmt-args))
              (progn
                (if (zerop (call-process-region (point-min) (point-max) "diff" nil patchbuf nil "-n" "-" tmpfile))
                    (message "Buffer is already cssfmted")
                  (cssfmt-patch-apply-rcs-patch patchbuf)
                  (message "Applied cssfmt"))
                (if errbuf (cssfmt--kill-error-buffer errbuf)))
            (message "Could not apply cssfmt")
            (if errbuf (cssfmt--process-errors (buffer-file-name) tmpfile errbuf))))

      (kill-buffer patchbuf)
      (delete-file tmpfile))))


(defun cssfmt--process-errors (filename tmpfile errbuf)
  (with-current-buffer errbuf
    (if (eq cssfmt-show-errors 'echo)
        (progn
          (message "%s" (buffer-string))
          (cssfmt--kill-error-buffer errbuf))
      ;; Convert the cssfmt stderr to something understood by the compilation mode.
      (goto-char (point-min))
      (insert "cssfmt errors:\n")
      (let ((truefile
             (if (cssfmt--is-cssimports-p)
                 (concat (file-name-directory filename) (file-name-nondirectory tmpfile))
               tmpfile)))
        (while (search-forward-regexp (concat "^\\(" (regexp-quote truefile) "\\):") nil t)
          (replace-match (file-name-nondirectory filename) t t nil 1)))
      (compilation-mode)
      (display-buffer errbuf))))

(defun cssfmt--kill-error-buffer (errbuf)
  (let ((win (get-buffer-window errbuf)))
    (if win
        (quit-window t win)
      (kill-buffer errbuf))))

;;;###autoload
(defun cssfmt-before-save ()
  "Add this to .emacs to run cssfmt on the current buffer when saving:
 (add-hook 'before-save-hook 'cssfmt-before-save).
Note that this will cause css-mode to get loaded the first time
you save any file, kind of defeating the point of autoloading."

  (interactive)
  (when (eq major-mode 'css-mode) (cssfmt)))

(provide 'cssfmt)
;;; cssfmt.el ends here
