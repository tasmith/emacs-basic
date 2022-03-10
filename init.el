;;; init.el --- Init File -*- lexical-binding: t -*-

;;; Commentary:
;;  This file is loaded after early-init.el; the most significant difference
;;  is that early-init.el is loaded before downloaded and installed packages
;;  are made available to the Emacs session.

;;; About packages
;;
;;  Once a package is downloaded and installed, it is made available
;;  to the current Emacs session. Making a package available adds its
;;  directory to load-path and loads its autoloads. This happens after
;;  early-init.el is loaded and before processing init.el (this file).
;;  Note, however, that when Emacs is started with the '-q' or
;;  '--no-init-file' options these packages are not made available at
;;  startup.
;;
;;  Emacs can be kept from making packages available automatically by
;;  setting the variable 'package-enable-at-startup' to nil within
;;  early-init.el. Later, packages can be made available by calling the
;;  (interactive) function 'package-activate-all'.
;;
;;  See the online Emacs Manual section titled Package Installation for
;;  complete details.

;;; About use-package
;;  
;;  use-package is a macro that makes organizing package configuration
;;  neater and easier.
;;
;;  The two keywords ':init' and ':config' are similar, but ':init
;;  always runs before packages are loaded and ':config' runs after
;;  packages are loaded. Packing loading happens for different
;;  reasons. If a ':commands' entry is present in use-package, the
;;  package loading will be defered until the command is used.
;;  Likewise ':bind', ':bind*', ':bind-keymap', ':bind-keymap*',
;;  ':mode', ':interpreter', ':hook', ':magic' and ':defer' all defer
;;  package loading.

;;; About key bindings
;;
;;  The use-package macro provides the handy :bind tag that can be
;;  used to simplify key binding to commands. See examples throughout
;;  the Emacs Lisp below. In Emacs, every keystroke is bound to the
;;  invocation of an Emacs function. Simply typing a character invokes
;;  the function `self-insert' that inserts the corresponding character
;;  into the current Emacs buffer at the point (i.e. where the cursor
;;  is located. Any key (including modifiers, function keys, etc.) can
;;  be bound to any of the appropriate available functions defined
;;  by Emacs or the installed packages or the Emacs Lisp code loaded
;;  during the current session (usually in the user's configuration
;;  code). This makes Emacs the most flexible editing environment,
;;  a construction kit that the user can program to do anything
;;  a computer can do.
;;
;;  The default key-bindings for Emacs and its third-party packages
;;  are ordinarily organized by convention:
;;    -  C-x is reserved as a prefix for Emacs key bound functions
;;    -  C-c followed by C-<letter> is reserved for major modes.
;;       Here <letter> means any alphabetic letter.
;;    -  C-c followed by a letter is reserved for users own
;;       keybindings, usually assigned in the user configuration.
;;    -  The function keys F5 through F9 are reserved for users.
;;  Although it is possible to rebind any key, some important keys
;;  can't be rebound without ruining the Emacs user experience, so
;;  especially don't be tempted to rebind the following.
;;    - C-g is essential for canceling a partially entered, perhaps
;;      misspelled or mistyped command.
;;    - C-h can't be rebound without breaking the Emacs help system
;;    - ESC is used on terminals where meta (alt) key is not available.
;;      (ESC-x is synonymous with M-x) Further, the sequence ESC ESC ESC
;;      can be used to escape from the current state of Emacs. For
;;      example to escape from a query-replace command or incremental
;;      search or from entering a parameter in the mini-buffer or even
;;      to escape back to single window mode!

;;; Code:

(package-initialize)

;;; Customize settings
;; Override the default location for storing settings made though
;; the Emacs 'M-x customize' commands.

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;;; Show version Emacs version in frame title; I usually have more than
;;; one Emacs installed so this helps avoid confusion.
(setq frame-title-format '("%f (%b)  [Emacs" emacs-version "]"))

;;; Look for packages on melpa too.
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;;; I'll be using 'use-package' so conditionally refresh package archive and
;;; install use-package package if needed.
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package-ensure)
(setq use-package-always-ensure t)

;;;; Tweak Emacs setting
;;;; a bunch of unnecessary but still useful changes

;;; Greeting from scratch buffer
(setq initial-scratch-message ";; Welcome to Todd's Emacs configuration\n")

;;; Revert buffers to actively reflect the content of files that have changed.
(global-auto-revert-mode 1)

;; Indent with spaces not tabs by default.
(setq-default indent-tabs-mode nil)

;; tab key first indents and then completes
(setq tab-always-indent 'complete)

;; Wrap lines for display
(visual-line-mode 1)

;; Selections are deleted with a keypress
(delete-selection-mode 1)

;;; Turn on recentf, use 'recentf-open-files'
(recentf-mode 1)

;;; Minibuffer command history mode, use 'M-p', 'M-n', etc.
(savehist-mode 1)
(setq history-length 500)

;; Save location of cursor to return to the next time the file is opened
(save-place-mode 1)

;;; Backups and Autosave
;;; Don't scatter the files around in every location,
;;; just keep them centralized in hidden directories within
;;; the home directory.

;;; Backups and Autosave
(setq
  ;; Modern storage is large, so save lots of backups
  delete-old-versions t
  kept-old-versions 0
  kept-new-versions 20
  ;; Number the filenames of backup files (~17~ not just ~ suffix)
  version-control t
  ;; And make backups even of version controlled files
  vc-make-backup-files t)

(let ((my-auto-save-dir (expand-file-name "autosave/" user-emacs-directory))
      (my-backups-dir  (expand-file-name "backups/" user-emacs-directory)))

  ;; create the dirs if necessary, since Emacs won't
  (unless (file-directory-p my-auto-save-dir)
    (make-directory my-auto-save-dir t))
  (unless (file-directory-p my-backups-dir)
    (make-directory my-backups-dir t))

  ;; Stash the backups and auto-save files in their own directories
  ;; don't leave the files scattered everywhere
  (setq auto-save-file-name-transforms `((".*" ,my-auto-save-dir t))
        backup-directory-alist `((".*" . ,my-backups-dir))))

;;; Move files to trash on delete
(setq delete-by-moving-to-trash t)

;;; Show empty lines at end of buffer
(setq-default indicate-empty-lines t)

;;; Word-by-word movement in CammelCase
(global-subword-mode 1)

;;; Restore previous window configurations with C-c <left> and C-c <right>
(winner-mode 1)

;;; Automatically uncompress and recompress files
(auto-compression-mode 1)

;; Don't save duplicate kills in kill ring.
(setq kill-do-not-save-duplicates t)

;; I like line and column numbers on mode-line
(setq line-number-mode t
      column-number-mode t
      size-indication-mode t)

;; Affects 'fill-region', 'fill-paragraph', 'auto-fill-mode'
;; Originally value was 70, make it 80 by default
;; Becomes a buffer local variable when set to some other value
(setq-default fill-column 80)

;; Display command keystrokes while typing them
(setq echo-keystrokes 0.1)

;; UTF-8 is my prefered coding system everywhere so I can
;; use the simple 'prefer-coding-system' setting that
;; Givs UTF-8 highest priority for automatic detection
;; and sets UTF-8 as default for
;;   - coding system of new buffers
;;   - coding system for subprocess I/O
;;   - default for file name coding system
;;   - default for non-graphical termial output
;;   - default for non-graphical terminal keyboard input
;; There are separate Emacs functions for setting all
;; of these preferences, but the single invocation
;; below takes care of all of it.
(prefer-coding-system 'utf-8)

;; Sentences don't need to end with two spaces
;; M-a, M-e, and filling are affected
(setq-default sentence-end-double-space nil)

;; Make buffer names unique
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

;; Ediff -- some better settings I found in user Magnars Emacs configuration
(use-package ediff
  :commands (magit-status projectile-vc)
  :config
  (setq ediff-diff-options "-w"
        ediff-split-window-function 'split-window-horizontally))

;; Electric indent mode doesn't work in python-mode or org-mode
;; properly: hitting return can cause previous line to be reindented.
;; Best to inhibit the undesirable behavior of indenting previous line.
(setq-default electric-indent-inhibit t)

;; When (pretty) printing elisp values, ellipsis are used once
;; a certain depth is reached, make it a big depth
(setq eval-expression-print-level 100)

;; These settings are purported to improve aspects of the scrolling experience
(setq auto-window-vscroll nil             ; don't automatically scroll to view tall lines
      fast-but-imprecise-scrolling t      ; don't fontify portions of buffer scrolled past
      scroll-conservatively 101           ; scroll upto 101 lines to bring point into view
      scroll-margin 1                     ; leave 1 line buffer between point and buffer top/bottom
      scroll-preserve-screen-position t)  ; e.g. moving by full screens keeps
                                          ; point at same screen location

(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)) ; one line at a time
      mouse-wheel-follow-mouse 't)                ; scroll window under mouse

;; Settings for long line support and simpler bi-directional operation.
;; I hope these two simplifying assignments make Emacs faster

;; don't try to figure out direction
;; and inhibit bidi-parentheses algorithm
(setq-default bidi-paragraph-direction 'left-to-right
              bidi-inhibit-bpa t)

;; Make Shebang files executable when saved so I don't need to chmod.
(add-hook 'after-save-hook #'executable-make-buffer-file-executable-if-script-p)

;; Useful packages

;; Project commands
;; ... defaults might be modified here
;; see which key after C-x p
  
;; Install screencast support; try it with keycast-mode
(use-package keycast)

;; Vterm
;; This is a very nice terminal emulator.
;; On Ubuntu, I needed to install cmake and libtool-bin:
;; $ sudo apt install cmake
;; $ sudo apt install libtool-bin
(use-package vterm)

;; Undo Tree
(use-package undo-tree
  :init (global-undo-tree-mode 1))

;; Navigation between windows (i.e. panes)
(use-package windmove
  :bind (("<S-left>"  . windmove-left)
         ("<S-right>" . windmove-right)
         ("<S-up>"    . windmove-up)
         ("<S-down>"  . windmove-down)))

;;; Visual appearance

;; Fonts

(let ((fonts (font-family-list)))
  (cond
   ((member "Hack Nerd Font" fonts)
    (set-face-attribute 'default nil :font "Hack Nerd Font"))
   ((member "GoMono Nerd Font" fonts)
    (set-face-attribute 'default nil :font "GoMono Nerd Font"))
   ((member "DaddyTimeMono NF" fonts)
    (set-face-attribute 'default nil :font "DaddyTimeMono NF"))))

;; Add some icons
(use-package all-the-icons)
;; NOTE run this command, only need to do it once:
;; (all-the-icons-install-fonts)

;; Themes
(use-package doom-themes)
(use-package solarized-theme)
(use-package modus-themes
  :init
  ;; set these values before loading the themes
  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs t
        modus-themes-region '(accented no-extend))
  (modus-themes-load-themes)
  :config
  ;; here, load the themes
  ;; (modus-themes-load-operandi)
  (modus-themes-load-vivendi)
  :bind ("<f5>" . modus-themes-toggle))

;;; Mode-line
(use-package telephone-line
  :init (telephone-line-mode 1))

(use-package smart-mode-line :disabled
  :init
  (setq sml/theme 'light)
  (sml/setup))

(use-package minions        ;; hmmm...is this working?
  :init
  (minions-mode 1))

;;; Nice visible bell

(use-package mode-line-bell
  :config
  (mode-line-bell-mode 1))

;;; Highlight current line
(global-hl-line-mode 1)

;;; environment variables from shell
(use-package exec-path-from-shell     :disabled
  :custom
  (exec-path-from-shell-variables '("PATH"
                                    "MANPATH"
                                    "TMPDIR"
                                    "GOPATH"))
  (exec-path-from-shell-arguments '("-l"))
  (exec-path-from-shell-check-startup-files nil)
  (exec-path-from-shell-debug nil)

  :config
  (when (memq window-system '(mac ns x pgtk))
    (exec-path-from-shell-initialize)))

;;; Completion

(use-package vertico
  :init (vertico-mode 1)
  :bind (:map vertico-map
              ("RET" .   vertico-directory-enter)
              ("DEL" .   vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word)
              ("C-l" .   vertico-directory-up)
              ("M-q" . vertico-quick-insert)
              ("C-q" . vertico-quick-exit)))

(use-package orderless
  :custom (completion-styles '(orderless)))

(use-package marginalia
  :init
  (marginalia-mode))

(use-package embark
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :init

  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  :config

  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package consult
  ;; Replace bindings. Lazily loaded due by `use-package'.
  :bind (;; C-c bindings (mode-specific-map)
         ("C-c h" . consult-history)
         ("C-c m" . consult-mode-command)
         ("C-c k" . consult-kmacro)
         ;; C-x bindings (ctl-x-map)
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ("<help> a" . consult-apropos)            ;; orig. apropos-command
         ;; M-g bindings (goto-map)
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings (search-map)
         ("M-s d" . consult-find)
         ("M-s D" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s m" . consult-multi-occur)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi))           ;; needed by consult-line to detect isearch

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

    ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Optionally replace `completing-read-multiple' with an enhanced version.
  (advice-add #'completing-read-multiple :override #'consult-completing-read-multiple)

  ;; Use Consult to select xref locations with preview
  ;; (setq xref-show-xrefs-function #'consult-xref
  ;;      xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key (kbd "M-."))
  ;; (setq consult-preview-key (list (kbd "<S-down>") (kbd "<S-up>")))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme
   :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-recent-file
   consult--source-project-recent-file
   :preview-key (kbd "M-."))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; (kbd "C-+")

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  ;; By default `consult-project-function' uses `project-root' from project.el.
  ;; Optionally configure a different project root function.
  ;; There are multiple reasonable alternatives to chose from.
  ;;;; 1. project.el (the default)
  ;; (setq consult-project-function #'consult--default-project--function)
  ;;;; 2. projectile.el (projectile-project-root)
  ;; (autoload 'projectile-project-root "projectile")
  ;; (setq consult-project-function (lambda (_) (projectile-project-root)))
  ;;;; 3. vc.el (vc-root-dir)
  ;; (setq consult-project-function (lambda (_) (vc-root-dir)))
  ;;;; 4. locate-dominating-file
  ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
)

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :after (embark consult)
  :demand t ; only necessary if you have the hook below
  ;; if you want to have consult previews as you move around an
  ;; auto-updating embark collect buffer
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package which-key
  :init
  (which-key-mode)
  :config
  ;(which-key-setup-side-window-right-bottom)
  (setq which-key-sort-order 'which-key-key-order-alpha
        which-key-side-window-max-width 0.33
        which-key-idle-delay 0.05)
  :diminish which-key-mode)

;; the mighty magit

(use-package magit
  :bind (("C-c g" . magit-file-dispatch)))

;; org mode the all powerful

(use-package org
  :config
  (setq org-default-notes-file (expand-file-name "notes.org" org-directory))
  (setq org-insert-mode-line-in-empty-file t)
  :bind (("C-c o a" . org-agenda)
         ("C-c o c" . org-capture)
         ("C-c o l" . org-store-link)))

;; yasnippet

(use-package yasnippet
  :init
  (yas-global-mode 1)
  :hook ((emacs-lisp-mode . yas-minor-mode)
         (org-mode . yas-minor-mode)))

(use-package yasnippet-snippets
  :after yasnippet)

;; lsp

(use-package lsp-mode
  :commands lsp)

;; corfu -- a completion at point

(use-package corfu
  :init
  (corfu-global-mode))

;; Add extensions
(use-package cape
  ;; Bind dedicated completion commands
  :bind (("C-c p p" . completion-at-point) ;; capf
         ("C-c p t" . complete-tag)        ;; etags
         ("C-c p d" . cape-dabbrev)        ;; or dabbrev-completion
         ("C-c p f" . cape-file)
         ("C-c p k" . cape-keyword)
         ("C-c p s" . cape-symbol)
         ("C-c p a" . cape-abbrev)
         ("C-c p i" . cape-ispell)
         ("C-c p l" . cape-line)
         ("C-c p w" . cape-dict)
         ("C-c p \\" . cape-tex)
         ("C-c p _" . cape-tex)
         ("C-c p ^" . cape-tex)
         ("C-c p &" . cape-sgml)
         ("C-c p r" . cape-rfc1345))
  :init
  ;; Add `completion-at-point-functions', used by `completion-at-point'.
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-tex)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  ;;(add-to-list 'completion-at-point-functions #'cape-sgml)
  ;;(add-to-list 'completion-at-point-functions #'cape-rfc1345)
  ;;(add-to-list 'completion-at-point-functions #'cape-abbrev)
  ;;(add-to-list 'completion-at-point-functions #'cape-ispell)
  ;;(add-to-list 'completion-at-point-functions #'cape-dict)
  ;;(add-to-list 'completion-at-point-functions #'cape-symbol)
  ;;(add-to-list 'completion-at-point-functions #'cape-line)
)

;; company -- shou I be using company instead of corfu? Does corfu work with gopls fo go-mode?

;; go-mode

(use-package go-mode
  :mode (("\\.go\\'" . go-mode))  ; \\' matches end of string
  :hook ((go-mode . lsp)
         (go-mode . yas-minor-mode)
         (go-mode . (lambda() (setq tab-width 4)))
         (before-save . lsp-format-buffer)
         (before-save . lsp-organize-imports)))

;; flycheck
;; https://www.flycheck.org/en/latest/index.html
;; https://www.masteringemacs.org/article/spotlight-flycheck-a-flymake-replacement

(use-package flycheck
  :init (global-flycheck-mode 1))

;; flyspell
;; http://www-sop.inria.fr/members/Manuel.Serrano/flyspell/flyspell.html

(use-package flyspell
  :hook (text-mode . flyspell-mode)
  :config (setq ispell-program-name "aspell"))

;; docview
;; Improve sharpness of docview

(setq-default doc-view-resolution 300)

;;; init.el ends here
