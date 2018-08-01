;;; orglyth.el ---                     -*- lexical-binding: t; -*-

;; Copyright (C) 2017 Conao

;; Author: Conao
;; Keywords:

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

;;; Commentary:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;      Recommended settings below.
;;
;;
;; (use-package el-get :ensure t
;;   :if (or (executable-find "git")
;;           (message "'git' couldn't found.  el-get can't download any packages")
;;           (defmacro el-get (&rest arg) nil))
;;   :config
;;   (setq el-get-git-shallow-clone  t
;;         el-get-emacswiki-base-url "http://www.emacswiki.org/emacs/download/"))
;; 
;; (use-package orglyth
;;     :init (el-get-bundle conao/orglyth)
;;     :config
;;     (use-package orglyth-html
;;       :config
;;       (setq orglyth-html-enable-opiton    t
;;             orglyth-html-use-ftp          nil
;;             orglyth-html-local-root-path  "~/public_html/orglyth/"
;;             orglyth-html-remote-root-path "~/public_html/remote/"
;;             orglyth-html-ftp-root-path    "/ftp:conao3@conao3.com:~/www/orglyth/")
;;       (orglyth-html-reset-variables)))
;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;      directory tree
;;
;;
;;  1. Make org file under <root>/src/ folder freely.
;;  2. Make index.org each folder.  You may include `index.inc'
;;     `index.inc' has been writen the dirgenerated by orglyth-html
;;  3. M-x orglyth-html-load-project to load orglyth-html project.
;;  4. C-c C-e p x to publish orglyth-html project.
;;     `local' to make html files under `orglyth-html-local-root-path' preserve directory structure.
;;     `remote' to make html files under `orglyth-html-remote-root-path' if `orglyth-html-use-ftp' is nil.
;;     `remote' to make html files under `orglyth-html-ftp-root-path' if `orglyth-html-use-ftp' is t.
;;  5. Orglyth-html make category sitemap each folder as `index.inc'.
;;  Orglyth-html makes html file and sitemap file under <root>/src/ folder.
;;  Orglyth makes necessary folders under <root>/src/ folder, you need
;;  make <root>/src folder only.
;;
;; ~/public_html/orglyth/
;;    ├── index.inc
;;    ├── index.org
;;    ├── archives/
;;    ├── parts/
;;    │   └── index.html
;;    └── src/
;;        ├── index.inc
;;        └── index.org
;;        ├── elisp/
;;        │   ├── index.inc
;;        │   ├── index.org
;;        │   ├── boolean.org
;;        │   └── with-temp-file.org
;;        └── emacs/
;;            ├── index.inc
;;            ├── index.org
;;            ├── install.org
;;            └── org-mode
;;                ├── index.inc
;;                ├── index.org
;;                ├── basis-syntax.org
;;                ├── org-list.html
;;                ├── org-list.org
;;                └── ox-publish.org

;;; Code:

;; variables

(require 'orglyth)
(require 'ox-publish)
(require 'ox-html)

(defgroup orglyth-html nil
  "A orglyth-html publish your web site using orgmode."
  :group 'orglyth)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  setter
;;

(defvar orglyth-html-loaded nil
  "Manage orglyth-html loaded.
This variable is internal variable for developer.")

(defun orglyth-html-init-with-setter (var value)
  "orglyth-html reset variables."
  (set var value)
  (when orglyth-html-loaded
    (orglyth-html-init)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  option frags
;;

(defcustom orglyth-html-enable-opiton nil
  "When non-nil, enable recommended options in ox-html."
  :group 'orglyth-html
  :type 'boolean)

(defcustom orglyth-html-use-ftp nil
  "When non-nil, dest root path will be setted `orglyth-html-ftp-root-path''.

When nil, remote root path will be setted `orglyth-html-remote-root-path'
`sshfs' (if there are not, install console) can mount ssh folder as normal drive.
OS X:
  > brew cask install osxfuse
  > brew install sshfs
  > mkdir sakura
  > sshfs conao3@conao3.sakura.ne.jp:/home/conao3/www/orglyth sakura
  >
  > diskutil unmount sakura    # unmount sshfs"
  :group 'orglyth-html
  :type 'boolean
  :set 'orglyth-html-init-with-setter)

(defcustom orglyth-html-compile-for-pc t
  "Non-nil means compile html for pc."
  :group 'orglyth-html
  :type 'Boolean)

(defcustom orglyth-html-compile-for-amp nil
  "Non-nil means compile html for amp."
  :group 'orglyth-html
  :type 'boolean)

(defcustom orglyth-html-compile-for-mobile nil
  "Non-nil means compile html for mobile."
  :group 'orglyth-html
  :type 'boolean)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  custom variables
;;

(defcustom orglyth-html-local-root-path "~/public_html/orglyth/"
  "orglyth-html sorce root path."
  :group 'orglyth-html
  :type 'string
  :set #'orglyth-html-init-with-setter)

(defcustom orglyth-html-remote-root-path "~/public_html/remote/"
  "orglyth-html remote root path"
  :group 'orglyth-html
  :type 'string
  :set #'orglyth-html-init-with-setter)

(defcustom orglyth-html-ftp-root-path "/ftp:example@example.com:~/www/orglyth/"
  "orglyth-html ftp address"
  :group 'orglyth-html
  :type 'string
  :set #'orglyth-html-init-with-setter)

(defcustom orglyth-html-source-dir-name "src"
  "orglyth-html source dir name"
  :group 'orglyth-html
  :type 'string
  :set #'orglyth-html-init-with-setter)

(defcustom orglyth-html-pc-dir-name "archives"
  "orglyth-html export for pc dir name"
  :group 'orglyth-html
  :type 'string
  :set #'orglyth-html-init-with-setter)

(defcustom orglyth-html-amp-dir-name "amp"
  "orglyth-html export for amp dir name"
  :group 'orglyth-html
  :type 'string
  :set #'orglyth-html-init-with-setter)

(defcustom orglyth-html-mobile-dir-name "mobile"
  "orglyth-html export for mobile dir name"
  :group 'orglyth-html
  :type 'string
  :set #'orglyth-html-init-with-setter)

(defcustom orglyth-html-template-dir-name "parts"
  "orgluth-html template dir name"
  :group 'orglyth-html
  :type 'string
  :set #'orglyth-html-init-with-setter)

;; local path
(defvar orglyth-html-local-sorce-path
  (concat orglyth-html-local-root-path orglyth-html-source-dir-name "/")
  "orglyth-html sorce path.")

(defvar orglyth-html-local-pc-path
  (concat orglyth-html-local-root-path orglyth-html-pc-dir-name "/")
  "orglyth-html pc page path")

(defvar orglyth-html-local-amp-path
  (concat orglyth-html-local-root-path orglyth-html-amp-dir-name "/")
  "orglyth-html amp page path")

(defvar orglyth-html-local-mobile-path
  (concat orglyth-html-local-root-path orglyth-html-mobile-dir-name "/")
  "orglyth-html mobile page path (not amp)")

(defvar orglyth-html-template-parts-path
  (concat orglyth-html-local-root-path orglyth-html-template-dir-name "/")
  "orglyth-html template parts path.")

;; remote path
(defvar orglyth-html-remote-sorce-path
  (if orglyth-html-use-ftp
      (concat orglyth-html-ftp-root-path orglyth-html-source-dir-name "/")
    (concat orglyth-html-remote-root-path orglyth-html-source-dir-name "/"))
  "orglyth-html sorce path.")

(defvar orglyth-html-remote-pc-path
  (if orglyth-html-use-ftp
      (concat orglyth-html-ftp-root-path orglyth-html-pc-dir-name "/")
    (concat orglyth-html-remote-root-path orglyth-html-pc-dir-name "/"))
  "orglyth-html pc page path")

(defvar orglyth-html-remote-amp-path
  (if orglyth-html-use-ftp
      (concat orglyth-html-ftp-root-path orglyth-html-amp-dir-name "/")
    (concat orglyth-html-remote-root-path orglyth-html-amp-dir-name "/"))
  "orglyth-html amp page path")

(defvar orglyth-html-remote-mobile-path
  (if orglyth-html-use-ftp
      (concat orglyth-html-ftp-root-path orglyth-html-mobile-dir-name "/")
    (concat orglyth-html-remote-root-path orglyth-html-mobile-dir-name "/"))
  "orglyth-html mobile page path (not amp)")

(defvar orglyth-html-preamble-format '(("ja" "
<div align=right>
初稿: %d
</div>
<div align=right>
最終更新日: %C
</div>

<div align=right>
<a href=\"http://conao3.com/\">ホーム</a> |
<a href=\"index.html\">文書トップ</a> | <a href=\"sitemap.html\">目次</a>
</div>
")))

(defvar orglyth-html-postamble-format '(("ja" "
<p class=\"author\">Author: %a</p>
<p class=\"date\">Date: %d</p>
<p class=\"creator\">%c</p>")))

(defvar orglyth-html-footnotes-section "
<div id=\"footnotes\">
<h2 class=\"footnotes\">%s: </h2>
<div id=\"text-footnotes\">
%s
</div>
</div>")

(defvar orglyth-html-default-html-option
  `("default"
    ;; https://orgmode.org/manual/Publishing-options.html#Publishing-options
    :language "ja"
    :html-checkbox-type unicode
    :html-doctype "html5"
    :html-footnotes-section ,orglyth-html-footnotes-section
    ;; :html-footnote-format
    :html-head-include-default-style nil
    :html-head-include-scripts nil
    :html-preamble-format ,orglyth-html-preamble-format
    :html-postamble-format ,orglyth-html-postamble-format))

(defvar orglyth-html-default-org-option
  `("default"
    ;; https://orgmode.org/manual/Selecting-files.html#Selecting-files
    :recursive t

    ,@(cdr orglyth-html-default-html-option)
    
    :base-extension "org"
    :style ""
    :auto-sitemap t
    :sitemap-filename "sitemap.inc"
    :makeindex t
    :section-numbers t

    ;; https://orgmode.org/manual/Publishing-action.html#Publishing-action
    :publishing-function org-html-publish-to-html)
  "default options fot orglyth-html")

(defvar orglyth-html-default-resources-option
  `("default"
    :recursive t
    :base-extension "jpg\\|gif\\|png\\|css"
    :publishing-function org-publish-attachment))

(defvar orglyth-html-default-index-option
  `("default"
    ,@(cdr orglyth-html-default-html-option)

    :auto-sitemap nil
    :base-extension "org"
    :preparation-function orglyth-html-create-root-index-org
    :publishing-function org-html-publish-to-html))

(defun orglyth-html-project-init ()
  "Add orglyth-html project to org-publish-project-alist."
  (orglyth-add-list-to-list
   'org-publish-project-alist
   ;; http://technohabits.blogspot.com/2013/01/org-modepublishingweb.html
   `(
     ;; 検証用
     ("local-rootindex"
      :base-directory ,orglyth-html-local-root-path
      :publishing-directory ,orglyth-html-local-root-path
      ,@(cdr orglyth-html-default-index-option))
     ("local-orgfiles"
      :base-directory ,orglyth-html-local-sorce-path
      :publishing-directory ,orglyth-html-local-pc-path
      ,@(cdr orglyth-html-default-org-option))
     ("local-resources"
      :base-directory ,orglyth-html-local-sorce-path
      :publishing-directory ,orglyth-html-local-pc-path
      ,@(cdr orglyth-html-default-resources-option))
     ("local" :components ("local-rootindex" "local-orgfiles" "local-resources"))

     ;; 本番用
     ("web-rootindex"
      :base-directory ,orglyth-html-local-root-path
      :publishing-directory ,orglyth-html-remote-root-path
      ,@(cdr orglyth-html-default-index-option))
     ("web-orgfiles"
      :base-directory ,orglyth-html-local-sorce-path
      :publishing-directory ,orglyth-html-remote-pc-path
      ,@(cdr orglyth-html-default-org-option))
     ("web-resources"
      :base-directory ,orglyth-html-local-sorce-path
      :publishing-directory ,orglyth-html-remote-pc-path
      ,@(cdr orglyth-html-default-resources-option))
     ("web-copyorg"
      :base-directory ,orglyth-html-local-sorce-path
      :publishing-directory ,orglyth-html-remote-sorce-path
      :recursive t
      :base-extension "org"
      :publishing-function org-publish-attachment)
     ("website" :components ("web-rootindex" "web-orgfiles" "web-resources" "web-copyorg")))))

(defun orglyth-html-init ()
  (setq orglyth-html-local-sorce-path
        (concat orglyth-html-local-root-path orglyth-html-source-dir-name "/")

        orglyth-html-local-pc-path
        (concat orglyth-html-local-root-path orglyth-html-pc-dir-name "/")

        orglyth-html-local-amp-path
        (concat orglyth-html-local-root-path orglyth-html-amp-dir-name "/")

        orglyth-html-local-mobile-path
        (concat orglyth-html-local-root-path orglyth-html-mobile-dir-name "/")

        orglyth-html-template-parts-path
        (concat orglyth-html-local-root-path orglyth-html-template-dir-name "/")

        ;; remote path
        orglyth-html-remote-sorce-path
        (if orglyth-html-use-ftp
            (concat orglyth-html-ftp-root-path orglyth-html-source-dir-name "/")
          (concat orglyth-html-remote-root-path orglyth-html-source-dir-name "/"))

        orglyth-html-remote-pc-path
        (if orglyth-html-use-ftp
            (concat orglyth-html-ftp-root-path orglyth-html-pc-dir-name "/")
          (concat orglyth-html-remote-root-path orglyth-html-pc-dir-name "/"))

        orglyth-html-remote-amp-path
        (if orglyth-html-use-ftp
            (concat orglyth-html-ftp-root-path orglyth-html-amp-dir-name "/")
          (concat orglyth-html-remote-root-path orglyth-html-amp-dir-name "/"))

        orglyth-html-remote-mobile-path
        (if orglyth-html-use-ftp
            (concat orglyth-html-ftp-root-path orglyth-html-mobile-dir-name "/")
          (concat orglyth-html-remote-root-path orglyth-html-mobile-dir-name "/")))
  
  (when orglyth-html-enable-opiton
    (setq org-html-with-latex                 'mathjax
          org-html-htmlize-output-type        'css
          org-html-coding-system              'utf-8
          org-publish-timestamp-directory     (concat org-directory ".org-timestamps/")
          )
    (setq org-html-mathjax-options
          '((path "https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js?config=TeX-AMS_HTML")
            (scale "100")
            (align "center")
            (font "TeX")
            (linebreaks "false")
            (autonumber "AMS")
            (indent "0em")
            (multlinewidth "85%")
            (tagindent ".8em")
            (tagside "right")))

    (setq org-html-mathjax-template
          "<script type=\"text/x-mathjax-config\">
    MathJax.Hub.Config({
        displayAlign: \"%ALIGN\",
        displayIndent: \"%INDENT\",

        \"HTML-CSS\": { scale: %SCALE,
                        linebreaks: { automatic: \"%LINEBREAKS\" },
                        webFont: \"%FONT\"
                       },
        SVG: {scale: %SCALE,
              linebreaks: { automatic: \"%LINEBREAKS\" },
              font: \"%FONT\"},
        NativeMML: {scale: %SCALE},
        TeX: { equationNumbers: {autoNumber: \"%AUTONUMBER\"},
               MultLineWidth: \"%MULTLINEWIDTH\",
               TagSide: \"%TAGSIDE\",
               TagIndent: \"%TAGINDENT\"
             }
});
</script>
<script type=\"text/javascript\"
        src=\"%PATH\"></script>")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  functions
;;

(defun orglyth-html-write-str (str filename)
  (with-temp-buffer
    (insert str)
    (write-region (point-min) (point-max) filename)))

(defun orglyth-html-publish-sitemap-around (func &rest args)
  "Advice around `org-publish-sitemap' as FUNC.
ARGS is argument.
Override `org-publish-sitemap' when publish site.
Create a sitemap of pages in set defined by PROJECT.
Optionally set the filename of the sitemap with SITEMAP-FILENAME.
Default for SITEMAP-FILENAME is `sitemap.org'"
  ;; (let ((sitemap-builder (org-publish-property :sitemap-function project)))
  ;;   (funcall sitemap-builder project sitemap-filename)))
  
  )

(advice-add #'org-publish-sitemap :around #'orglyth-html-publish-sitemap-around)
(advice-remove #'org-publish-sitemap #'orglyth-html-publish-sitemap-around)

(defun orglyth-html-create-root-index-org (plist)
  "create root index.org"
  (catch 'orglyth-error
    (message "create-root-index-org start!!")
    (message (or (plist-get plist :base-directory)
                 (progn (warn "not set :base-directory, exit create-root-index-org")
                        (throw 'orglyth-error "not set variable"))
                 ))
    (let* ((base-dir (or (plist-get plist :base-directory)
                         (progn (warn "not set :base-directory, exit create-root-index-org")
                                (throw 'orglyth-error "not set variable"))))
           (dest-dir (or (plist-get plist :publishing-directory)
                         (progn (warn "not set :publishing-directory, exit create-root-index-org")
                                (throw 'orglyth-error "not set variable"))))
           (title (or (plist-get plist :sitemap-title)))
           (filepath (concat base-dir "index.inc")))
      (orglyth-html-write-str (concat
                               "#+title"
                               title)
                              filepath))))

(defun orglyth-html-org-publish-file-before (filename &optional project no-cache)
  "Before advice on org-publish-file."
  ;; (defun org-publish-file (filename &optional project no-cache)
  ;;   "Publish file FILENAME from PROJECT.
  ;; If NO-CACHE is not nil, do not initialize `org-publish-cache'.
  ;; This is needed, since this function is used to publish single
  ;; files, when entire projects are published (see
  ;; `org-publish-projects').")

  (let ((plist (cdr project)))
    ;; (message (format "%s" project))
    (message "%s" filename)
    (message "%s" (plist-get plist :base-directory))
    )
  ;;(message (plist-get plist :base-directory))
  )
(advice-add 'org-publish-file :before #'orglyth-html-org-publish-file-before)
;; (advice-remove 'org-publish-file 'orglyth-html-org-publish-file-before)

;; http://davidaventimiglia.com/blogging_with_emacs.html
(defun dav-org-publish-org-sitemap (project &optional sitemap-filename)
  "Create a sitemap of pages in set defined by PROJECT.
Optionally set the filename of the sitemap with SITEMAP-FILENAME.
Default for SITEMAP-FILENAME is 'sitemap.org'."
  (let* ((project-plist (cdr project))
         (dir (file-name-as-directory
               (plist-get project-plist :base-directory)))
         (localdir (file-name-directory dir))
         (indent-str (make-string 2 ?\ ))
         (exclude-regexp (plist-get project-plist :exclude))
         (files (nreverse
                 (org-publish-get-base-files project exclude-regexp)))
         (sitemap-filename (concat dir (or sitemap-filename "sitemap.org")))
         (sitemap-title (or (plist-get project-plist :sitemap-title)
                            (concat "Sitemap for project " (car project))))
         (sitemap-style (or (plist-get project-plist :sitemap-style)
                            'tree))
         (sitemap-sans-extension
          (plist-get project-plist :sitemap-sans-extension))
         (visiting (find-buffer-visiting sitemap-filename))
         (ifn (file-name-nondirectory sitemap-filename))
         file sitemap-buffer)
    (with-current-buffer
        (let ((org-inhibit-startup t))
          (setq sitemap-buffer
                (or visiting (find-file sitemap-filename))))
      (erase-buffer)
      (insert (concat "#+TITLE: " sitemap-title "\n\n"))
      (while (setq file (pop files))
        (let ((fn (file-name-nondirectory file))
              (link (file-relative-name file dir))
              (oldlocal localdir)
              ;; bind new variable prefix
              (prefix (concat
                       (format-time-string org-publish-sitemap-date-format (org-publish-find-date file))
                       " : ")))
          (when sitemap-sans-extension
            (setq link (file-name-sans-extension link)))
          ;; sitemap shouldn't list itself
          (unless (equal (file-truename sitemap-filename)
                         (file-truename file))
            (if (eq sitemap-style 'list)
                (message "Generating list-style sitemap for %s" sitemap-title)
              (message "Generating tree-style sitemap for %s" sitemap-title)
              (setq localdir (concat (file-name-as-directory dir)
                                     (file-name-directory link)))
              (unless (string= localdir oldlocal)
                (if (string= localdir dir)
                    (setq indent-str (make-string 2 ?\ ))
                  (let ((subdirs
                         (split-string
                          (directory-file-name
                           (file-name-directory
                            (file-relative-name localdir dir))) "/"))
                        (subdir "")
                        (old-subdirs (split-string
                                      (file-relative-name oldlocal dir) "/")))
                    (setq indent-str (make-string 2 ?\ ))
                    (while (string= (car old-subdirs) (car subdirs))
                      (setq indent-str (concat indent-str (make-string 2 ?\ )))
                      (pop old-subdirs)
                      (pop subdirs))
                    (dolist (d subdirs)
                      (setq subdir (concat subdir d "/"))
                      (insert (concat indent-str
                                      " + "
                                      prefix  ;; insert prefix
                                      d "\n"))
                      (setq indent-str (make-string
                                        (+ (length indent-str) 2) ?\ )))))))
            ;; This is common to 'flat and 'tree
            (let ((entry
                   ;; Invoke new helper function
                   (dav-org-publish-format-file-entry
                    org-publish-sitemap-file-entry-format file project-plist))
                  (regexp "\\(.*\\)\\[\\([^][]+\\)\\]\\(.*\\)"))
              (cond ((string-match-p regexp entry)
                     (string-match regexp entry)
                     (insert (concat indent-str
                                     " + " (match-string 1 entry)
                                     prefix  ;; insert prefix
                                     "[[file:" link "]["
                                     (match-string 2 entry)
                                     "]]" (match-string 3 entry) "\n")))
                    (t
                     (insert (concat indent-str
                                     " + "
                                     prefix  ;; insert prefix
                                     "[[file:" link "]["
                                     entry
                                     "]]\n"))))))))
      (save-buffer))
    (or visiting (kill-buffer sitemap-buffer))))

;; turn on frg, loaded.
(setq orglyth-html-loaded t)

(provide 'orglyth-html)
;;;orglyth-html.el ends here
