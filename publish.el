;;; publish.el --- Export howtos/*.org and pages/*.org to repo root via org-publish -*- lexical-binding: t -*-

;;; Commentary:
;; Site-Export für Chimik-IT.github.io (User-Page, wird direkt aus dem
;; Repo-Root ausgeliefert).
;; Ausführen:
;;   emacs --batch -l publish.el --eval '(org-publish-all t)'
;; oder interaktiv in Emacs: M-x org-publish-project RET chimik-it RET

;;; Code:

(require 'ox-publish)

(defconst chimik-it-root
  (file-name-directory (or load-file-name buffer-file-name))
  "Repo-Wurzelverzeichnis.")

(defun chimik-it--preamble (_plist)
  "Navigation oben auf jeder Seite."
  "<nav class=\"howto-nav\"><a href=\"index.html\">Home</a> · <a href=\"about.html\">About</a> · <a href=\"https://github.com/Chimik-IT\">GitHub</a></nav>")

(defun chimik-it--postamble (_plist)
  "Footer auf jeder Seite."
  "<p>Tobias Yang (楊濤比) — <a href=\"https://github.com/Chimik-IT\">github.com/Chimik-IT</a></p>")

(defconst chimik-it--favicon
  (concat "<link rel=\"icon\" href=\"data:image/svg+xml,"
          "%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'%3E"
          "%3Crect width='32' height='32' rx='7' fill='%232563eb'/%3E"
          "%3Ctext x='16' y='23' font-family='monospace' font-size='18' "
          "font-weight='bold' fill='white' text-anchor='middle'%3EC%3C/text%3E"
          "%3C/svg%3E\"/>")
  "Inline SVG Favicon, kein externer Request nötig.")

(defconst chimik-it--html-head
  (concat "<link rel=\"stylesheet\" href=\"static/css/style.css\" type=\"text/css\"/>"
          chimik-it--favicon))

(defun chimik-it--org-date-keyword (file)
  "Liest #+DATE: wörtlich aus FILE, ohne Cache/mtime-Fallback."
  (with-temp-buffer
    (insert-file-contents file)
    (goto-char (point-min))
    (if (re-search-forward "^#\\+DATE:[ \t]*\\(.+\\)$" nil t)
        (string-trim (match-string 1))
      "")))

(defun chimik-it--sitemap-entry (entry style project)
  "Sitemap-Eintrag mit Datum (aus #+DATE:) vorangestellt."
  (if (not (string= "." entry))
      (format "%s — [[file:%s][%s]]"
              (chimik-it--org-date-keyword
               (expand-file-name entry (org-publish-property :base-directory project)))
              entry
              (org-publish-find-title entry project))
    (org-publish-sitemap-default-entry entry style project)))

(setq org-publish-project-alist
      `(("chimik-it-howtos"
         :base-directory ,(expand-file-name "howtos" chimik-it-root)
         :base-extension "org"
         :publishing-directory ,chimik-it-root
         :publishing-function org-html-publish-to-html
         :recursive nil
         :with-toc t
         :section-numbers nil
         :html-head ,chimik-it--html-head
         :html-preamble chimik-it--preamble
         :html-postamble chimik-it--postamble
         :auto-sitemap t
         :sitemap-filename "index.org"
         :sitemap-title "Chimik-IT"
         :sitemap-sort-files anti-chronologically
         :sitemap-style list
         :sitemap-format-entry chimik-it--sitemap-entry)
        ("chimik-it-pages"
         :base-directory ,(expand-file-name "pages" chimik-it-root)
         :base-extension "org"
         :publishing-directory ,chimik-it-root
         :publishing-function org-html-publish-to-html
         :recursive nil
         :with-toc nil
         :section-numbers nil
         :html-head ,chimik-it--html-head
         :html-preamble chimik-it--preamble
         :html-postamble chimik-it--postamble)
        ("chimik-it-static"
         :base-directory ,(expand-file-name "static" chimik-it-root)
         :base-extension "css\\|png\\|jpg\\|svg\\|gif"
         :publishing-directory ,(expand-file-name "static" chimik-it-root)
         :publishing-function org-publish-attachment
         :recursive t)
        ("chimik-it"
         :components ("chimik-it-howtos" "chimik-it-pages" "chimik-it-static"))))

(provide 'publish)
;;; publish.el ends here
