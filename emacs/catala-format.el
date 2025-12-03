;;; catala-format.el --- Utility functions to format Catala code -*- lexical-binding: t; -*-

;; Package-Requires: ((emacs "27.1"))
;; Version: 1.0.0
;; Keywords: languages, catala, formatter
;; URL: https://github.com/CatalaLang/catala-format

;; Copyright (c) 2014 The go-mode Authors. All rights reserved.
;; Portions Copyright (c) 2015-present, Facebook, Inc. All rights reserved.

;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are
;; met:

;; * Redistributions of source code must retain the above copyright
;; notice, this list of conditions and the following disclaimer.
;; * Redistributions in binary form must reproduce the above
;; copyright notice, this list of conditions and the following disclaimer
;; in the documentation and/or other materials provided with the
;; distribution.
;; * Neither the name of the copyright holder nor the names of its
;; contributors may be used to endorse or promote products derived from
;; this software without specific prior written permission.

;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;; A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;; OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;; LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
;; DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
;; THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.)

;;; Commentary:
;;
;; This package provides utilities to format Catala code using the catala-format
;; command. The recommended usage is to format before saving a file:
;;
;;   (add-hook 'before-save-hook 'catala-format-before-save)

;;; Code:

(require 'cl-lib)
(require 'vc)

(defcustom catala-format-command "catala-format"
  "The `catala-format' command."
  :type 'string
  :group 'catala-format)

(defcustom catala-format-enable 'enable
  "Enable or disable catala-format."
  :type '(choice
          (const :tag "Enable" enable)
          (const :tag "Disable" disable))
  :group 'catala-format)

(defcustom catala-format-show-errors 'buffer
  "Where to display catala-format error output.

It can either be displayed in the *compilation* buffer, in the
echo area, or not at all.  Please note that Emacs outputs to the
echo area when writing files and will overwrite catala-format's
echo output if used from inside a `before-save-hook'."
  :type '(choice
          (const :tag "*compilation* buffer" buffer)
          (const :tag "Echo area" echo)
          (const :tag "None" nil))
  :group 'catala-format)

(defcustom catala-format-disable-idempotence-check nil
  "Enable or disable idempotence check."
  :type 'boolean
  :group 'catala-format)

;;;###autoload
(defun catala-format-before-save ()
  "Add this to .emacs to run catala-format on the current buffer when saving:

\(add-hook \\='before-save-hook \\='catala-format-before-save)."
  (interactive)
  (when (eq major-mode 'catala-ts-mode) (catala-format)))

(defun catala-format--process-errors (filename tmpfile errorfile errbuf)
  "Display catala-format errors in ERRBUF, a compilation buffer.

Error messages are read from ERRORFILE, and occurrences of
TMPFILE in the error messages are replaced with FILENAME."
  (with-current-buffer errbuf
    (if (eq catala-format-show-errors 'echo)
        (message "%s" (buffer-string))
      (insert-file-contents errorfile nil nil nil)
      ;; Convert the catala-format stderr to something understood by the compilation mode.
      (goto-char (point-min))
      (while (search-forward-regexp (regexp-quote tmpfile) nil t)
        (replace-match filename))
      (compilation-mode)
      (display-buffer errbuf))))

(defun catala-format--replace-buffer-contents (outputfile)
  "Replace the current buffer's contents with the contents of OUTPUTFILE.

Uses `replace-buffer-contents'."
  (replace-buffer-contents (find-file-noselect outputfile))
  (kill-buffer (get-file-buffer outputfile)))

(defun catala-format--get-full-file-extension (file)
  (let ((ext (file-name-extension file t)))
    (if (string-equal ext ".md")
        (concat (file-name-extension (file-name-sans-extension file) t) ext)
      ext)))

(defun catala-format ()
  "Format the current buffer according to the catala-format tool."
  (interactive)
  (let* ((ext (catala-format--get-full-file-extension buffer-file-name))
         (bufferfile (file-truename (make-temp-file "catala-format" nil ext)))
         (outputfile (file-truename (make-temp-file "catala-format" nil ext)))
         (errbuf
          (cond
           ((eq catala-format-show-errors 'buffer)
            (get-buffer-create "*compilation*"))
           ((eq catala-format-show-errors 'echo)
            (get-buffer-create "*catala-format stderr*"))))
         (coding-system-for-read 'utf-8)
         (coding-system-for-write 'utf-8)
         (enable-args
          (cond
           ((equal catala-format-enable 'disable)
            (list "--disable"))
           (t '())))
         (skip-idempotence-args
          (cond
           (catala-format-disable-idempotence-check
            (list "--skip-idempotence"))
           (t '())))
         )
    (unwind-protect
        (save-restriction
          (widen)
          (write-region nil nil bufferfile)
          (if (zerop
               (apply #'call-process catala-format-command
                      nil (list :file outputfile) nil
                      (append skip-idempotence-args (list bufferfile))))
              (progn
                (catala-format--replace-buffer-contents outputfile)
                (message "Applied catala-format on %s" buffer-file-name))
            (if errbuf
                (progn
                  (with-current-buffer errbuf
                    (setq buffer-read-only nil)
                    (erase-buffer))
                  (catala-format--process-errors
                   (file-truename buffer-file-name) bufferfile outputfile errbuf)))
            (message "Could not apply catala-format on %s" buffer-file-name)))
      (delete-file bufferfile)
      (delete-file outputfile)
      )))

(provide 'catala-format)

;;; catala-format.el ends here
