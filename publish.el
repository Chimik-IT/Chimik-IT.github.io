;;; publish.el --- Build Chimik-IT.github.io from src/howtos/*.org -*- lexical-binding: t -*-

;;; Commentary:
;; Nur der generierte Output (index.html, howtos/*.html, static/) wird
;; gepusht. Die Org-Quellen unter src/howtos/ bleiben lokal (siehe
;; .gitignore) — wir brauchen im Repo nur die fertigen statischen Seiten.
;;
;; Ausführen:
;;   emacs --batch -l publish.el --eval '(chimik-it-build)'

;;; Code:

(require 'ox-publish)

(defconst chimik-it-root
  (file-name-directory (or load-file-name buffer-file-name))
  "Repo-Wurzelverzeichnis.")

(defun chimik-it--prefix (plist)
  "Relativer Pfad-Präfix zum Repo-Root: leer auf Root-Seiten, ../ unter howtos/."
  (if (string-match-p "/src/howtos/" (or (plist-get plist :input-file) ""))
      "../"
    ""))

(defun chimik-it--preamble (plist)
  "Navigation oben auf jeder Seite."
  (let ((p (chimik-it--prefix plist)))
    (format (concat "<nav class=\"howto-nav\">"
                     "<a href=\"%1$sindex.html\" class=\"logo\"><img src=\"%1$sstatic/favicon.png\" alt=\"Logo\"/></a>"
                     "<a href=\"https://github.com/Chimik-IT\">About</a>"
                     "<button id=\"theme-toggle\" aria-label=\"Toggle color theme\">◐</button>"
                     "</nav>")
            p)))

(defconst chimik-it--theme-script
  (concat "<script>(function(){"
          "var b=document.getElementById('theme-toggle');if(!b)return;"
          "function apply(t){document.documentElement.setAttribute('data-theme',t);}"
          "b.addEventListener('click',function(){"
          "var sys=window.matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light';"
          "var now=document.documentElement.getAttribute('data-theme')||sys;"
          "var next=now==='dark'?'light':'dark';"
          "apply(next);localStorage.setItem('theme',next);"
          "});"
          "})();</script>")
  "Klick-Handler für den Theme-Toggle-Button.")

(defun chimik-it--postamble (_plist)
  "Footer auf jeder Seite."
  (concat "<p>Tobias Yang (楊濤比) · <a href=\"https://github.com/Chimik-IT\">github.com/Chimik-IT</a></p>"
          chimik-it--theme-script))

(defun chimik-it--html-head-string (p)
  "html-head mit Pfad-Präfix P (org-publish erlaubt hier nur Strings, keine Funktion)."
  (format (concat "<link rel=\"stylesheet\" href=\"%1$sstatic/css/style.css\" type=\"text/css\"/>"
                   "<link rel=\"icon\" type=\"image/png\" href=\"%1$sstatic/favicon.png\"/>"
                   "<script>(function(){"
                   "var t=localStorage.getItem('theme');"
                   "if(t)document.documentElement.setAttribute('data-theme',t);"
                   "})();</script>")
          p))

(defconst chimik-it--html-head-root (chimik-it--html-head-string ""))
(defconst chimik-it--html-head-nested (chimik-it--html-head-string "../"))

(defun chimik-it--org-keyword (file keyword)
  "Liest #+KEYWORD: wörtlich aus FILE."
  (with-temp-buffer
    (insert-file-contents file)
    (goto-char (point-min))
    (if (re-search-forward (format "^#\\+%s:[ \t]*\\(.+\\)$" keyword) nil t)
        (string-trim (match-string 1))
      "")))

(defun chimik-it--write-index ()
  "Baut index-src/index.org aus den Artikeln in src/howtos/, nach Datum sortiert."
  (let* ((howtos-dir (expand-file-name "src/howtos" chimik-it-root))
         (index-dir (expand-file-name "index-src" chimik-it-root))
         (files (directory-files howtos-dir t "\\.org\\'"))
         (entries (mapcar (lambda (f)
                             (list (chimik-it--org-keyword f "DATE")
                                   (chimik-it--org-keyword f "TITLE")
                                   (file-name-base f)))
                           files)))
    (setq entries (sort entries (lambda (a b) (string> (nth 0 a) (nth 0 b)))))
    (unless (file-directory-p index-dir) (make-directory index-dir t))
    (with-temp-file (expand-file-name "index.org" index-dir)
      (insert "#+TITLE: Chimik-IT\n\n")
      (dolist (e entries)
        (insert (format "- %s · [[file:howtos/%s.html][%s]]\n" (nth 0 e) (nth 2 e) (nth 1 e)))))))

(setq org-publish-project-alist
      `(("chimik-it-articles"
         :base-directory ,(expand-file-name "src/howtos" chimik-it-root)
         :base-extension "org"
         :publishing-directory ,(expand-file-name "howtos" chimik-it-root)
         :publishing-function org-html-publish-to-html
         :recursive nil
         :with-toc t
         :section-numbers nil
         :html-head ,chimik-it--html-head-nested
         :html-preamble chimik-it--preamble
         :html-postamble chimik-it--postamble)
        ("chimik-it-index"
         :base-directory ,(expand-file-name "index-src" chimik-it-root)
         :base-extension "org"
         :publishing-directory ,chimik-it-root
         :publishing-function org-html-publish-to-html
         :recursive nil
         :with-toc nil
         :section-numbers nil
         :html-head ,chimik-it--html-head-root
         :html-preamble chimik-it--preamble
         :html-postamble chimik-it--postamble)
        ("chimik-it-static"
         :base-directory ,(expand-file-name "static" chimik-it-root)
         :base-extension "css\\|png\\|jpg\\|svg\\|gif"
         :publishing-directory ,(expand-file-name "static" chimik-it-root)
         :publishing-function org-publish-attachment
         :recursive t)
        ("chimik-it"
         :components ("chimik-it-articles" "chimik-it-index" "chimik-it-static"))))

(defun chimik-it-build ()
  "Kompletter Build: Index aus den Artikeln generieren, dann alles publizieren."
  (interactive)
  (chimik-it--write-index)
  (org-publish-all t))

(provide 'publish)
;;; publish.el ends here
