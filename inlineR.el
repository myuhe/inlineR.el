;;; inlineR.el

;; Filename: inlineR.el
;; Description: support inline view of R_graphic
;; Author: myuhe <yuhei.maeda_at_gmail.com>
;; Maintainer: myuhe
;; Copyright (C) :2010, myuhe , all rights reserved.
;; Created: :11-02-08
;; Version: 0.1
;; Keywords: convenience, iimage.el, cacoo.el

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published byn
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING. If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 0:110-1301, USA.

;;; Commentary:
;;
;; cacoo.el is very useful.
;; You should install cacoo.el.
;; In detail, 
;; https://github.com/kiwanami/emacs-cacoo

;;; Installation:
;;
;; Put the inlineR.el to your
;; load-path.
;; Add to .emacs:
;; (require 'inlineR)
;;
;;; Changelog:
;;

(require 'ess-site)

(defvar inlineR-re-funcname "plot\\|image\\|hist\\|matplot\\|barplot\\|pie\\|boxplot\\|pairs\\contour\\|persp")
(defvar inlineR-default-image "png")
(defvar inlineR-default-dir nil)
(defvar inlineR-cairo-p nil)
(defvar inlineR-image-size nil)

(defun inlineR-get-start ()
  (if (region-active-p)
      (mark)
    (re-search-backward inlineR-re-funcname)))

(defun inlineR-get-end ()
  (if (region-active-p)
      (point)
    (re-search-forward ".*(.*)")))

(defun inlineR-dir-concat (file)
  (if inlineR-default-dir
      (concat  inlineR-default-dir file) 
    file))

(defun inlineR-tag-concat (file)
  (if (boundp 'cacoo-minor-mode)
      (concat "\n##[img:" file "]")
    (concat "\n##[[" file "]]")))

(defun inlineR-get-dir ()
  (unless inlineR-default-dir
    (file-name-directory (buffer-file-name))))

(defun inlineR-execute (pred format fun)
  (if inlineR-cairo-p
      (cond
       ((string= format "svg")  
        (ess-command 
         (concat 
          "CairoSVG(\"" inlineR-default-dir filename "." format "\", 3, 3)\n"
          fun "\n"
          "dev.off()\n")))
       (t (ess-command
           (concat
            "Cairo(600, 600, \"" inlineR-default-dir filename "." format "\", type=\"" format "\", bg =\"white\" )\n"
            fun "\n"
            "dev.off()\n"))))
    (ess-command
     (concat
      format "(\"" inlineR-default-dir filename "." format "\")\n"
      fun "\n"
      "dev.off()\n"))))

(defun inlineR-format-alist (pred)
  (if pred
      '(("png" 1) ("jpeg" 2) ("svg" 3))
    '(("png" 1) ("jpeg" 2) ("bmp" 3))))

(defun inlineR-insert-tag ()
  "insert image tag"
  (interactive)
  (let* ((start (inlineR-get-start))
         (end (inlineR-get-end))
         (fun (buffer-substring start end))
         (format 
          (completing-read
           "Image format: "
           (inlineR-format-alist inlineR-cairo-p) nil t inlineR-default-image))
         (filename (read-string "filename: " nil))
         (file (concat filename "." format)))
    (inlineR-execute inlineR-cairo-p format fun)
    (insert (inlineR-tag-concat
             (inlineR-dir-concat file)))))

(provide 'inlineR)

