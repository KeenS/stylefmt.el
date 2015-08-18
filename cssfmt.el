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
;;   (add-hook 'after-save-hook 'cssfmt-after-save)
;;; Code:

(defcustom cssfmt-command "cssfmt"
  "The 'cssfmt' command."
  :type 'string)


(gofmt-before-save)
;;;###autoload
(defun cssfmt ()
  "Format the current buffer according to the cssfmt tool."
  (interactive)
  (save-excursion
    (call-process cssfmt-command nil nil nil (buffer-file-name (current-buffer)))
    (revert-buffer   t t)))

;;;###autoload
(defun cssfmt-after-save ()
  "Add this to .emacs to run cssfmt on the current buffer when saving:
 (add-hook 'after-save-hook 'cssfmt-after-save).

Note that this will cause css-mode to get loaded the first time
you save any file, kind of defeating the point of autoloading."

  (interactive)
  (when (member major-mode '(scss-mode less-css-mode stylus-mode css-mode)) (cssfmt)))

(provide 'cssfmt)
;;; cssfmt.el ends here
