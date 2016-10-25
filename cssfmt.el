;;; cssfmt.el --- Cssfmt interface
;; copyright (C) 2015 κeen All rights reserved.
;; Author: κeen
;; Version: 0.0.2
;; Keywords: css code formatter
;; URL: https://github.com/KeenS/cssfmt.el
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;
;;; Commentary:
;; This is a thin wrapper of [cssfmt](https://github.com/morishitter/cssfmt)
;;
;;; Installation:
;; 1. install cssfmt. If you have installed npm, just type `npm install -g cssfmt`
;; 2 Add your init.el
;;   (load "path/to/cssfmt.el)
;;   ;optional    
;;   (add-hook 'css-mode-hook 'cssfmt-enable-on-save)
;;; Code:

(defgroup cssfmt nil
  "'cssfmt' interface."
  :group 'css)

(defcustom cssfmt-command "stylefmt"
  "The 'cssfmt' command."
  :type 'string
  :group 'cssfmt)

(defcustom cssfmt-popup-errors nil
  "Display error buffer when cssfmt fails."
  :type 'boolean)

(defun cssfmt--call (buf)
  "Format BUF using cssfmt."
  (with-current-buffer (get-buffer-create "*cssfmt*")
    (erase-buffer)
    (insert-buffer-substring buf)
    (if (zerop (call-process-region (point-min) (point-max) cssfmt-command t t nil))
        (progn (copy-to-buffer buf (point-min) (point-max))
               (kill-buffer))
      (when cssfmt-popup-errors
        (display-buffer (current-buffer)))
      (error "cssfmt failed, see *cssfmt* buffer for details"))))

;;;###autoload
(defun cssfmt-format-buffer ()
  "Format the current buffer according to the cssfmt tool."
  (interactive)
  (unless (executable-find cssfmt-command)
    (error "Could not locate executable \"%s\"" cssfmt-command))

  (let ((cur-point (point))
        (cur-win-start (window-start)))
    (cssfmt--call (current-buffer))
    (goto-char cur-point)
    (set-window-start (selected-window) cur-win-start))
  (message "Formatted buffer with cssfmt."))

;;;###autoload
(defun cssfmt-enable-on-save ()
  "Add this to .emacs to run cssfmt on the current buffer when saving:
 (add-hook 'after-save-hook 'cssfmt-after-save).

Note that this will cause css-mode to get loaded the first time
you save any file, kind of defeating the point of autoloading."

  (interactive)
  (add-hook 'after-save-hook 'cssfmt-format-buffer nil t))

(provide 'cssfmt)
;;; cssfmt.el ends here
