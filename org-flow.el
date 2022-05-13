;;; org-flow.el --- User Interface for Org-Mode -*- coding: utf-8; lexical-binding: t; -*-

;; Copyright (C) 2022 Alessandro Wollek

;; Author: Alessandro Wollek <https://github.com/AlessandroW>
;; Maintainer: Alessandro Wollek <a@wollek.dev>
;; Created: May 13, 2022
;; Modified: May 13, 2022
;; Version: 0.0.1
;; Keywords: calendar files outlines
;; Homepage: https://github.com/AlessandroW/org-flow
;; Package-Requires: ((emacs "27.1") (simple-httpd "20191103.1446") (websocket "1.13") (org-ql " 0.7-pre"))

;; This file is not part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; Org-Flow provides a web interface for org-mode.

;;; Code:
;;;; Dependencies
(require 'json)
(require 'simple-httpd)
(require 'websocket)
(require 'org-ql)

(defvar org-flow-root-dir
  (concat (file-name-directory
           (expand-file-name (or
                    load-file-name
                    buffer-file-name)))
          ".")
  "Root directory of the org-flow project.")

(defvar org-flow-app-build-dir
  (expand-file-name "./out/" org-flow-root-dir)
  "Directory containing org-flow's web build.")

(defvar org-flow-port
  15187
  "Port to serve the org-flow web-interface.")

(defvar org-flow-ws-port
  15188
  "Websocket server port for org-flow.")

(defcustom org-flow-inbox "~/org/inbox.org"
  "The path to the inbox using the getting things done (GTD) terminology."
  :group 'org-flow
  :type 'string)

;; Internal vars

(defvar org-flow-ws-socket nil
  "The websocket for org-flow.")

(defvar org-flow-ws-server nil
  "The websocket server for org-flow.")

;;;###autoload
(define-minor-mode
  org-flow-mode
  "Enable org-flow.
This serves the web-build and API over HTTP."
  :lighter " org-flow"
  :global t
  :group 'org-flow
  :init-value nil
  (cond
   (org-flow-mode
   ;;; check if the default keywords actually exist on `orb-preformat-keywords'
   ;;; else add them
    (setq-local httpd-port org-flow-port)
    (setq httpd-root org-flow-app-build-dir)
    (httpd-start)
    (setq org-flow-ws-server
          (websocket-server org-flow-ws-port
                            :host 'local
                            :on-open #'org-flow--ws-on-open
                            :on-message #'org-flow--ws-on-message
                            :on-close #'org-flow--ws-on-close))
    (org-flow-open))
   (t
    (progn
      (websocket-server-close org-flow-ws-server)
      (httpd-stop)))))
  ;; "Start the http and websocket server for org-flow."
  ;; (setq-local httpd-port org-flow-port)
  ;; (setq httpd-root org-flow-app-build-dir)
  ;; (httpd-start)
  ;; (setq org-flow-ws-server
  ;;       (websocket-server
  ;;               org-flow-ws-port
  ;;               :host 'local
  ;;               :on-open #'org-flow--ws-on-open
  ;;               :on-message #'org-flow--ws-on-message
  ;;               :on-close #'org-flow--ws-on-close)))

(defun org-flow--ws-on-open (ws)
  "Open the websocket WS to org-flow and send initial data."
  (progn
    (setq org-flow-ws-socket ws)))

(defun org-flow--ws-on-message (_ws frame)
  "Functions to run when the org-flow server receives a message.
Takes _WS and FRAME as arguments."
  (let* ((msg (json-parse-string
               (websocket-frame-text frame) :object-type 'alist))
         (command (alist-get 'command msg))
         (data (alist-get 'data msg)))
    (cond
     ((string= command "inbox")
      (websocket-send-text _ws (json-encode-alist (list (cons 'inbox
                                                              (org-ql-query :select '(org-get-heading t t t t)
                                                                            :from org-flow-inbox))
                                                        (cons "result" "inbox")))))
     ((string= command "todo")
      (websocket-send-text _ws (json-encode-list (org-ql-query :select '(org-get-heading t t t t) :from (org-agenda-files) :where '(todo "TODO")))))
     (t
      (message "Message %S" msg)))))

(defun org-flow--ws-on-close (_websocket)
  "What to do when _WEBSOCKET to org-flow is closed."
  (message "Connection with org-flow closed."))

(defcustom org-flow-browser-function #'browse-url
  "When non-nil launch org-flow with a different browser function.
Takes a function name, such as #'browse-url-chromium.
Defaults to #'browse-url."
  :group 'org-flow
  :type 'function)

;;; interactive commands
;;;###autoload
(defun org-flow-open ()
  "Ensure `org-flow' is running, then open the `org-flow' webpage."
  (interactive)
  (funcall org-flow-browser-function
           (format "http://localhost:%d" org-flow-port)))


(provide 'org-flow)
;;; org-flow.el ends here
