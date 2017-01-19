;;; Generic emacs settings I cannot live without

;; Use command as the meta key; option key as super
(setq ns-command-modifier 'meta)
(setq ns-option-modifier  'super)

;; Don't show the startup screen
(setq inhibit-startup-message t)

;; "y or n" instead of "yes or no"
(fset 'yes-or-no-p 'y-or-n-p)

;; Highlight regions and add special behaviors to regions.
;; "C-h d transient" for more info
(setq transient-mark-mode t)
(pending-delete-mode t)

;; Display line and column numbers
;;(setq line-number-mode    t)
;;(setq column-number-mode  t)
;;(global-linum-mode 1)
(add-hook 'mrh-code-modes-hook
          (lambda () (linum-mode 1)))
(add-hook 'ruby-mode-hook
          (lambda () (run-hooks 'mrh-code-modes-hook)))
;; Modeline info
(display-time-mode 1)
;; (display-battery-mode 1)

;; Small fringes
(set-fringe-mode '(1 . 1))

;; Emacs gurus don't need no stinking scroll bars
(when (fboundp 'toggle-scroll-bar)
  (toggle-scroll-bar -1))

;; Explicitly show the end of a buffer
(set-default 'indicate-empty-lines t)

;; Line-wrapping
(set-default 'fill-column 78)

;; Prevent the annoying beep on errors
;; (setq visible-bell t)

;; Make sure all backup files only live in one place
;;(setq make-backup-files nil)
;;(setq auto-save-default nil)

;; get rid of .# files
(setq create-lockfiles nil)

;; Put autosave files (ie #foo#) and backup files (ie foo~) in ~/.emacs.d/.
(custom-set-variables
  '(auto-save-file-name-transforms '((".*" "~/.emacs.d/autosaves/\\1" t)))
  '(backup-directory-alist '((".*" . "~/.emacs.d/backups/"))))

;; create the autosave dir if necessary, since emacs won't.
(make-directory "~/.emacs.d/autosaves/" t)

;; Gotta see matching parens
(show-paren-mode t)

;; Don't truncate lines
(setq truncate-lines t)
(setq truncate-partial-width-windows nil)

;; For emacsclient
(server-start)

;; Trailing whitespace is unnecessary
;;(defvar whitespace-cleanup-on-save t)
;; (setq whitespace-cleanup-on-save nil)
;;(add-hook 'before-save-hook
;;	  (lambda ()
;;	    (if whitespace-cleanup-on-save (whitespace-cleanup))))

;; Trash can support
(setq delete-by-moving-to-trash t)

;; `brew install aspell --lang=en` (instead of ispell)
(setq-default ispell-program-name "aspell")
(setq ispell-list-command "list")
(setq ispell-extra-args '("--sug-mode=ultra"))

;; zap-up-to-char, forward-to-word, backward-to-word, etc
(require 'misc)

;; me old eyes
(set-frame-font "Menlo-14")

;; remove toolbar crap
(if window-system
  (tool-bar-mode -1)
)

;; set default tab spacing
(setq-default indent-tabs-mode nil)
(setq tab-width 2)
(setq c-basic-indent 2)

;; easier movement between windows
(windmove-default-keybindings)

;; just set ido-mode damn it
(ido-mode 1)


;; Set column number in mode line
(setq line-number-mode t)
(setq column-number-mode t)

(global-hl-line-mode 1)

;; Highlight current line
(set-face-background 'hl-line "#6F7238")
(set-face-foreground 'highlight nil)

;; Ruby flymake mode
(eval-after-load 'ruby-mode
  '(progn
     (require 'flymake)

     ;; Invoke ruby with '-c' to get syntax checking
     (defun flymake-ruby-init ()
       (let* ((temp-file (flymake-init-create-temp-buffer-copy
                          'flymake-create-temp-inplace))
              (local-file (file-relative-name
                           temp-file
                           (file-name-directory buffer-file-name))))
         (list "ruby" (list "-c" local-file))))

     (push '(".+\\.rb$" flymake-ruby-init) flymake-allowed-file-name-masks)
     (push '("Rakefile$" flymake-ruby-init) flymake-allowed-file-name-masks)

     (push '("^\\(.*\\):\\([0-9]+\\): \\(.*\\)$" 1 2 nil 3)
           flymake-err-line-patterns)

     (add-hook 'ruby-mode-hook
               (lambda ()
                 (when (and buffer-file-name
                            (file-writable-p
                             (file-name-directory buffer-file-name))
                            (file-writable-p buffer-file-name))
                   (local-set-key (kbd "C-c d")
                                  'flymake-display-err-menu-for-current-line)
                   (flymake-mode t))))))

;; Showing and hiding code
(eval-after-load "hideshow"
  '(add-to-list 'hs-special-modes-alist
                 `(ruby-mode
                   ,(rx (or "def" "class" "module" "{" "[")) ; Block start
                   ,(rx (or "}" "]" "end"))                  ; Block end
                   ,(rx (or "#" "=begin"))                   ; Comment start
                   ruby-forward-sexp nil)))

;; Make commenting lots easier
(global-set-key (kbd "C-c #")  'comment-or-uncomment-region)

(defadvice comment-or-uncomment-region (before slick-comment activate compile)
   "When called interactively with no active region, comment a single line instead."
   (interactive   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)   (line-beginning-position 2)))))

(global-set-key "\C-cm" 'magit-status)

(setq ido-decorations (quote ("\n-> " "" "\n   " "\n   ..." "[" "]" " [No match]" " [Matched]" " [Not readable]" " [Too big]" " [Confirm]")))
 (defun ido-disable-line-truncation () (set (make-local-variable 'truncate-lines) nil))
 (add-hook 'ido-minibuffer-setup-hook 'ido-disable-line-truncation)
 (defun ido-define-keys () ;; C-n/p is more intuitive in vertical layout
   (define-key ido-completion-map (kbd "C-n") 'ido-next-match)
   (define-key ido-completion-map (kbd "C-p") 'ido-prev-match))
 (add-hook 'ido-setup-hook 'ido-define-keys)

(require 'robe)
(add-hook 'ruby-mode-hook 'robe-mode)
(eval-after-load 'company
  '(push 'company-robe company-backends))
(add-hook 'robe-mode-hook 'ac-robe-setup)

(require 'rbenv)
(global-rbenv-mode)
(rbenv-use-corresponding)
