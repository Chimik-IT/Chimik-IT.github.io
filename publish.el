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
  "<p>Tobias Yang — <a href=\"https://github.com/Chimik-IT\">github.com/Chimik-IT</a></p>")

(setq org-publish-project-alist
      `(("chimik-it-howtos"
         :base-directory ,(expand-file-name "howtos" chimik-it-root)
         :base-extension "org"
         :publishing-directory ,chimik-it-root
         :publishing-function org-html-publish-to-html
         :recursive nil
         :with-toc t
         :section-numbers nil
         :html-head "<link rel=\"stylesheet\" href=\"static/css/style.css\" type=\"text/css\"/>"
         :html-preamble chimik-it--preamble
         :html-postamble chimik-it--postamble
         :auto-sitemap t
         :sitemap-filename "index.org"
         :sitemap-title "Chimik-IT"
         :sitemap-sort-files anti-chronologically
         :sitemap-style list)
        ("chimik-it-pages"
         :base-directory ,(expand-file-name "pages" chimik-it-root)
         :base-extension "org"
         :publishing-directory ,chimik-it-root
         :publishing-function org-html-publish-to-html
         :recursive nil
         :with-toc nil
         :section-numbers nil
         :html-head "<link rel=\"stylesheet\" href=\"static/css/style.css\" type=\"text/css\"/>"
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
