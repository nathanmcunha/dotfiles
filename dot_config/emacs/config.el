;;; config.el --- Tangled Configuration -*- lexical-binding: t -*-

(if (>= emacs-major-version 31)
    (progn
      (message "Running on Emacs 31 - Enabling experimental features...")
      ;; Add Emacs 31 specific tweaks here
      ;; Example: (setq some-new-emacs-31-variable t)
      )
  (message "Running on Emacs %d" emacs-major-version))

;; 1. Define the function in a utilities section or at the top of the file
 ;; --- Smart TAB Dispatcher (Doom Style) ---
(defun my/yas-try-expand-first ()
  "Try to expand a yasnippet, then handle completion or indentation.
Following Doom Emacs priority: Minibuffer > Yasnippet > Corfu > Indent."
  (interactive)
  (cond
    ;; 1. Minibuffer: Keep Vertico completion behavior
    ((active-minibuffer-window)
    (if (and (bound-and-true-p vertico-mode) vertico--candidates)
        (vertico-insert)
      (minibuffer-complete)))

    ;; 2. DOOM PRIORITY: Try to expand snippet BEFORE menu navigation
    ((and (bound-and-true-p yas-minor-mode) (yas-expand))
    t)

    ;; 3. Corfu: If menu is open, TAB navigates between candidates
    ((and (bound-and-true-p corfu-mode) corfu--candidates)
    (corfu-next))

    ;; 4. Support for Magit (Toggle sections)
    ((derived-mode-p 'magit-mode)
    (magit-section-toggle (magit-current-section)))

    ;; 5. Final fallback: Standard indentation
    (t
    (indent-for-tab-command))))

 ;; --- Global and Evil Mapping ---
(global-set-key (kbd "TAB") 'my/yas-try-expand-first)

 ;; Ensure Evil Mode in Insert State uses this logic
  (with-eval-after-load 'evil
    (define-key evil-insert-state-map (kbd "TAB") 'my/yas-try-expand-first))

;; --- Doom-like "K" Documentation Lookup ---
(defun my/smart-lookup ()
  "Lookup documentation for the thing at point.
   1. Elisp: describe-symbol
   2. Org Src Block (Elisp): describe-symbol
   3. Eglot: eglot-help-at-point
   4. Fallback: evil-lookup"
  (interactive)
  (cond
   ;; 1. Emacs Lisp Mode
   ((derived-mode-p 'emacs-lisp-mode)
    (let ((sym (thing-at-point 'symbol)))
      (if sym (describe-symbol sym)
        (message "No symbol at point"))))

   ;; 2. Org Mode Source Blocks
   ((and (eq major-mode 'org-mode) (org-in-src-block-p))
    (let ((lang (car (org-babel-get-src-block-info)))
          (sym (thing-at-point 'symbol t)))
      (if (and (string= lang "emacs-lisp") sym)
          (describe-symbol (intern sym))
        (call-interactively #'evil-lookup))))

   ;; 3. LSP / Eglot
   ((bound-and-true-p eglot--managed-mode)
    (eglot-help-at-point))

   ;; 4. Fallback
   (t
    (call-interactively #'evil-lookup))))

(with-eval-after-load 'evil
  (define-key evil-motion-state-map (kbd "K") #'my/smart-lookup))

;; Doom-like utility functions for file operations
(defun my/copy-this-file ()
  "Copy the current file to a new location."
  (interactive)
  (let* ((filename (buffer-file-name))
         (new-name (read-file-name "Copy file to: " filename)))
    (copy-file filename new-name 1)
    (find-file new-name)
    (message "Copied '%s' to '%s'" filename new-name)))

(defun my/move-this-file ()
  "Move/rename the current file to a new location."
  (interactive)
  (let* ((filename (buffer-file-name))
         (new-name (read-file-name "Move file to: " filename)))
    (rename-file filename new-name 1)
    (find-file new-name)
    (set-visited-file-name new-name)
    (message "Moved '%s' to '%s'" filename new-name)))

(defun my/delete-this-file ()
  "Delete the current file and kill its buffer."
  (interactive)
  (let ((filename (buffer-file-name)))
    (when (and filename (y-or-n-p (format "Really delete '%s'?" filename)))
      (delete-file filename)
      (kill-current-buffer)
      (message "Deleted '%s'" filename))))

(defun my/copy-file-path ()
  "Copy the current file's path to the kill ring."
  (interactive)
  (let ((filename (or (buffer-file-name) (error "Buffer not visiting a file"))))
    (kill-new filename)
    (message "Copied: %s" filename)))

(defun my/copy-file-path-relative-to-project ()
  "Copy the current file's path relative to project root to the kill ring."
  (interactive)
  (let* ((filename (or (buffer-file-name) (error "Buffer not visiting a file")))
         (project-root (or (and (project-current) (project-root (project-current))) default-directory))
         (relative-path (file-relative-name filename project-root)))
    (kill-new relative-path)
    (message "Copied: %s" relative-path)))

(defun my/kill-all-buffers ()
  "Kill all buffers except the current one and special buffers."
  (interactive)
  (let ((current-buffer (current-buffer)))
    (dolist (buffer (buffer-list))
      (unless (or (eq buffer current-buffer)
                  (string-match-p "\*.*\*" (buffer-name buffer)))
        (kill-buffer buffer))))
    (message "Killed all buffers"))

(defun my/kill-other-buffers ()
  "Kill all buffers except the current one."
  (interactive)
  (let ((current-buffer (current-buffer)))
    (dolist (buffer (buffer-list))
      (unless (eq buffer current-buffer)
        (kill-buffer buffer))))
    (message "Killed other buffers"))

;; Terminal Launchers
(defun my/launch-alacritty (dir) (call-process-shell-command (format "alacritty --working-directory %s" (shell-quote-argument dir)) nil 0))

(defun my/open-terminal-here () (interactive) (my/launch-alacritty default-directory))
(defun my/open-terminal-in-project ()
  "Launch Alacritty terminal in the current project root."
  (interactive)
  (let ((project (project-current)))
    (if project
        (my/launch-alacritty (project-root project))
      (message "Not in a project"))))

;; --- Emacs Build Information ---
(defun my/emacs-build-info ()
  "Display detailed information about Emacs build and features."
  (interactive)
  (with-output-to-temp-buffer "*Emacs Build Info*"
    (princ (format "Emacs Version: %s\n\n" emacs-version))
    (princ (format "System Configuration: %s\n\n" system-configuration))
    (princ "Compilation Options:\n")
    (princ "====================\n")
    (dolist (opt (split-string system-configuration-options))
      (princ (format "  %s\n" opt)))
    (princ "\n\nNative Compilation:\n")
    (princ "===================\n")
    (princ (format "  Available: %s\n" (if (featurep 'native-compile) "Yes" "No")))
    (when (featurep 'native-compile)
      (princ (format "  Version: %s\n" native-comp-version))
      (princ (format "  ELN Load Path: %s\n" native-comp-eln-load-path)))
    (princ "\n\nFeatures:\n")
    (princ "=========\n")
    (dolist (feature features)
      (when (string-match-p "^\\(jansson\\|libxml2\\|sqlite\\|json\\|tree-sitter\\|gnutls\\|imagemagick\\)" (symbol-name feature))
        (princ (format "  %s\n" feature))))
    (switch-to-buffer "*Emacs Build Info*")
    (view-mode)))

;; Remove GUI clutter
(setq inhibit-startup-message t)
(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 25)        ; Give some breathing room
(menu-bar-mode -1)          ; Disable the menu bar

;; Fix frame gap and maximize for emacsclient (GNOME behavior)
(setq frame-resize-pixelwise t)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

 ;; Line Numbers & Visuals
(global-display-line-numbers-mode t)
(setopt display-line-numbers-type t)       ; Use 'relative for Doom style
(setopt display-line-numbers-grow-only t)  ; Prevent jitter

;; Indentation (2 Spaces)
(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)

;; Visual column indicator (100 characters)
(setopt display-fill-column-indicator-column 100)
(setq-default display-fill-column-indicator-character ?|)
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)
;; (set-face-attribute 'fill-column-indicator nil :foreground "grey90" :background "transparent")

;; Disable line numbers in specific modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook
                eat-mode-hook
                gemini-cli-mode-hook
                dirvish-mode-hook
                dirvish-side-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Zoom shortcuts
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "C-0") 'text-scale-adjust)

(defun my/open-personal-folder()
  (interactive)
  (dired (expand-file-name "~/.config/emacs/")))


 ;; Recent files tracking
(use-package recentf
   :ensure nil
   :init
   (recentf-mode 1)
   :config
   (setopt recentf-max-saved-items 200)
   (setopt recentf-exclude '("\.git/" "\.emacs\.d/eln-cache/" "/tmp/" "/elpa/")))

;; Save Place (Restore cursor position)
(use-package saveplace
  :ensure nil
  :init (save-place-mode 1))

 ;; Super Save (Auto-save on focus change)
(use-package super-save
   :ensure t
   :defer t
   :config
   (super-save-mode +1)
  (setopt super-save-auto-save-when-idle nil)
  (setopt super-save-idle-duration 60.0)
  (setopt super-save-triggers
         '(evil-window-next evil-window-prev balance-windows other-window)))

(use-package project
  :ensure nil
  :config
  (setq project-list-file (expand-file-name "projects" user-emacs-directory))

  ;; 0. Project Type Detection
  (defun my/project-type (dir)
    "Return the project type for DIR (gradle, maven, npm, rust, python)."
    (cond
     ((or (file-exists-p (expand-file-name "build.gradle" dir))
          (file-exists-p (expand-file-name "build.gradle.kts" dir))) 'gradle)
     ((file-exists-p (expand-file-name "pom.xml" dir)) 'maven)
     ((file-exists-p (expand-file-name "package.json" dir)) 'npm)
     ((file-exists-p (expand-file-name "Cargo.toml" dir)) 'rust)
     ((or (file-exists-p (expand-file-name "pyproject.toml" dir))
          (file-exists-p (expand-file-name "setup.py" dir))
          (file-exists-p (expand-file-name "requirements.txt" dir))) 'python)
     (t nil)))

  (defun my/project-type-current ()
    "Return the project type for the current project."
    (let ((project (project-current)))
      (when project
        (my/project-type (project-root project)))))

  ;; 1. Add More Project Markers (as fallback)
  (defun my/project-try-local (dir)
    "Detect project by common markers (Gemfile, package.json, etc.)."
    (catch 'found
      (let ((home (expand-file-name "~")))
        (dolist (file '("Gemfile" "package.json" "Cargo.toml" "go.mod"
                        "pom.xml" "build.gradle" "build.gradle.kts" "settings.gradle"
                        "pyproject.toml" "setup.py" "Makefile" "CMakeLists.txt"
                        "meson.build" "project.clj" "deps.edn" "mix.exs"
                        "shard.yml" "pubspec.yaml" "Platformio.ini" "platformio.ini"))
          (let ((path (locate-dominating-file dir file)))
            (when (and path (not (file-equal-p path home)))
              (throw 'found (cons 'transient path))))))))

  ;; Append to hook so VC backend (git) is tried first
  (add-hook 'project-find-functions 'my/project-try-local 100)

  ;; 2. Smart Find File (fallback to find-file if not in project)
  (defun my/project-find-file ()
    "Find file in project or current directory."
    (interactive)
    (if (project-current)
        (project-find-file)
      (call-interactively 'find-file)))

  ;; 3. Project-aware Recent Files
  (defun my/project-recent-files ()
    "Show recent files in current project using consult."
    (interactive)
    (let* ((project (project-current))
           (root (and project (project-root project)))
           (recent-files (and root (seq-filter (lambda (f) (string-prefix-p root f)) recentf-list))))
      (if recent-files
          (find-file (completing-read "Recent (project): " recent-files))
        (message "No recent files in this project."))))

  ;; 4. Improve project switching (mimic Projectile)
  (setq project-switch-commands
        '((project-find-file "Find file" "f")
          (project-dired "Dired" "d")
          (project-vc-dir "VC Dir" "v")
          (project-eshell "Eshell" "e")
          (my/project-dispatch "Menu" "m")))

  ;; 5. Project Command Palette
  (defun my/project-dispatch ()
    "Projectile-like command dispatcher for project.el."
    (interactive)
    (let ((choices '(("f" "Find file" project-find-file)
                     ("b" "Switch buffer" project-switch-to-buffer)
                     ("s" "Search in project" project-search)
                     ("R" "Recent files" my/project-recent-files)
                     ("d" "Dired" project-dired)
                     ("v" "VC Dir" project-vc-dir)
                     ("k" "Kill buffers" project-kill-buffers)
                     ("r" "Find regexp" project-find-regexp)
                     ("e" "Eshell" project-eshell))))
      (let* ((choice (completing-read "Project action: " choices nil t))
             (action (nth 2 (assoc choice choices))))
        (call-interactively action)))))

  ;; 5. Benchmark Current Project
  (defun my/benchmark-current-project ()
    "Run performance benchmarks on the current project."
    (interactive)
    (let ((project-root (or (and (project-current) (project-root (project-current)))
                            default-directory)))
      (let ((buffer (get-buffer-create "*Benchmark Results*"))
            (script (expand-file-name "scripts/benchmark-project.el" user-emacs-directory)))
        (if (file-exists-p script)
            (progn
              (message "Running benchmark on %s..." project-root)
              (with-current-buffer buffer
                (read-only-mode -1)
                (erase-buffer)
                (call-process (concat invocation-directory invocation-name)
                              nil buffer t
                              "-Q" "--script" script "--" project-root)
                (goto-char (point-min))
                (read-only-mode 1))
              (display-buffer buffer)
              (message "Benchmark complete! See *Benchmark Results* buffer."))
          (message "Benchmark script not found: %s" script)))))

  ;; 6. Project Compilation and Testing (Like Projectile)
  (defun my/project-compile ()
    "Compile the current project."
    (interactive)
    (let* ((project (project-current t))
           (root (project-root project))
           (type (my/project-type root))
            (command (cond
                      ((eq type 'gradle) "./gradlew build")
                      ((eq type 'maven) "mvn compile")
                      ((eq type 'npm) "npm run build")
                      ((eq type 'rust) "cargo build")
                      ((eq type 'python) "black .")
                      (t (read-string "Compile command: " "make -k ")))))
      (let ((default-directory root))
        (compile command))))

  (defun my/project-test ()
    "Run tests for the current project."
    (interactive)
    (let* ((project (project-current t))
           (root (project-root project))
           (type (my/project-type root))
            (command (cond
                      ((eq type 'gradle) "./gradlew test")
                      ((eq type 'maven) "mvn test")
                      ((eq type 'npm) "npm test")
                      ((eq type 'rust) "cargo test")
                      ((eq type 'python) "pytest")
                      (t (read-string "Test command: " "make test ")))))
      (let ((default-directory root))
        (compile command))))

  (defun my/project-run ()
    "Run the current project."
    (interactive)
    (let* ((project (project-current t))
           (root (project-root project))
           (type (my/project-type root))
           (command (cond
                     ((eq type 'gradle) "./gradlew run")
                     ((eq type 'maven) "mvn exec:java")
                     ((eq type 'npm) "npm start")
                     ((eq type 'rust) "cargo run")
                     (t (read-string "Run command: ")))))
      (let ((default-directory root))
        (compile command))))

(use-package perspective
  :bind ("C-x k" . persp-kill-buffer*)
  :init
  (persp-mode)
  :custom
  (persp-mode-prefix-key (kbd "C-c M-p"))
  (persp-show-modestring nil)
  :config
  (with-eval-after-load 'consult
    (consult-customize consult-source-buffer :hidden t :default nil)
    (add-to-list 'consult-buffer-sources 'persp-consult-source)))

(defun my/project-workspace-switch (dir)
  "Switch to a perspective for the project in DIR."
  (let ((name (file-name-nondirectory (directory-file-name dir))))
    (persp-switch name)))

;; Automatically switch perspective when switching projects via SPC p p
(setq project-switch-commands
      (append project-switch-commands
              '((my/project-workspace-switch "Workspace" "w"))))

(use-package server
  :ensure nil
  :config
  (unless (server-running-p)
    (server-start)))

;; Repeat Mode (Emacs 28+) - Repeat commands without prefix keys
(repeat-mode 1)

(defvar my-leader-map (make-sparse-keymap)
  "Keymap for my leader bindings.")

;; Define a helper function to bind keys in our leader map
(defun my/bind-leader (key command &optional description)
  "Bind KEY to COMMAND in `my-leader-map` with DESCRIPTION."
  (keymap-set my-leader-map key
              (if description
                  `(menu-item ,description ,command)
                command)))

;; Bind the leader map to SPC in Evil states
(with-eval-after-load 'evil
  (keymap-set evil-normal-state-map "SPC" my-leader-map)
  (keymap-set evil-visual-state-map "SPC" my-leader-map)
  (keymap-set evil-motion-state-map "SPC" my-leader-map))

;; Bind to M-SPC globally
(keymap-global-set "M-SPC" my-leader-map)

;; Add prefix labels for which-key
(with-eval-after-load 'which-key
  (which-key-add-keymap-based-replacements my-leader-map
    "h"   "help/config"
    "b"   "buffer"
    "c"   "code"
    "c j" "java project"
    "c C" "coverage"
    "d"   "debug"
    "e"   "errors"
    "E"   "explorer"
    "f"   "file"
    "g"   "git"
    "g l" "log"
    "j"   "jump"
    "n"   "notes"
    "n d" "dailies"
    "o"   "open"
    "o t" "open terminal"
    "p"   "project"
    "s"   "search"
    "w"   "window"
    "W"   "workspaces"
    "a"   "AI Assistant"))

(use-package which-key
  :ensure nil
  :init (which-key-mode)
  :config
  (setq which-key-idle-delay 0.3))

(use-package popper
  :ensure t
  :bind (("C-`"   . popper-toggle)
         ("M-`"   . popper-cycle)
         ("C-M-`" . popper-toggle-type))
  :init
  (setq popper-reference-buffers
        '("\\*Messages\\*"
          "Output\\*$"
          "\\*Async Shell Command\\*"
          "\\*Help\\*"
          "\\*compilation\\*"
          "\\*Flymake diagnostics\\*"
          "\\*Warnings\\*"
          help-mode
          compilation-mode))
  :config
  (popper-mode +1)
  (popper-echo-mode +1)) ; Show status in echo area

(use-package emacs
  :ensure nil
  :config
  ;; Prevent some buffers from taking over the whole frame
  (setq display-buffer-alist
        '(
          ;; Bottom side buffers (Height 0.3)
          ("\\*\\(Output\\|Injector\\|Async Shell Command\\).*"
           (display-buffer-reuse-window display-buffer-at-bottom)
           (window-height . 0.3))
          
          ;; Help buffers
          ("\\*Help.*"
           (display-buffer-reuse-window display-buffer-at-bottom)
           (window-height . 0.4))
          
          ;; Magit: Let it do its own thing (it manages windows well)
          ("Magit.*"
           (display-buffer-same-window))
          )))

(use-package evil
      :ensure nil
      :after (evil)
      :config
      ;; Bind TAB in insert state to trigger completion
      (define-key evil-insert-state-map (kbd "TAB") 'my/yas-try-expand-first)
      (define-key evil-insert-state-map (kbd "<tab>") 'my/yas-try-expand-first)
      ;; Set cursor colors
      (setq evil-emacs-state-cursor    '("#649bce" box)
            evil-normal-state-cursor   '("#ebcb8b" box)
            evil-visual-state-cursor   '("#676f7d" box)
            evil-insert-state-cursor   '("#ebcb8b" bar)
            evil-replace-state-cursor  '("#ebcb8b" hbar)
            evil-operator-state-cursor '("#ebcb8b" hollow)))
(use-package evil-collection
  :after evil
  :ensure t
  :custom
  ;; (Optional) If you want evil-collection to configure the minibuffer (vim behavior in M-x)
  ; (setq evil-collection-setup-minibuffer t)
  (evil-collection-magit-use-z-for-folds nil)       ;; Use default Magit fold key (TAB) instead of 'z'
  (evil-collection-magit-want-horizontal-movement t) ;; Enable h/l for movement
  :config
  ;; The essential list for a complete Doom/Spacemacs experience
  (evil-collection-init
    '(magit           ; Git Interface
      dired           ; File Manager
      ibuffer         ; Buffer Manager
      help            ; Help screens (C-h v, C-h f)
      info            ; Info manuals
      dashboard       ; Welcome screen
      eshell          ; Emacs Terminal
      vterm           ; Visual Terminal (if using)
      corfu           ; Autocomplete (if using)
      vertico         ; Minibuffer completion (if using)
      consult         ; Enhanced search commands
      flycheck        ; Syntax highlighting
      profiler        ; Emacs Profiler
      man
                    org
                    )))          ; Man pages

;; 1. Evil Surround
(use-package evil-surround
  :ensure t
  :after evil
  :config (global-evil-surround-mode 1))

;; 2. Evil Embrace
(use-package evil-embrace
  :ensure t
  :after evil-surround
  :config (evil-embrace-enable-evil-surround-integration))

;; 3. Evil Nerd Commentary
(use-package evil-nerd-commenter
  :ensure t
  :config
  (with-eval-after-load 'evil
    (evil-define-key '(normal visual) 'global "gc" 'evilnc-comment-operator)))

;; 4. Evil Snipe
(use-package evil-snipe
  :ensure t
  :after evil
  :config
  (evil-snipe-mode 1)
  (evil-snipe-override-mode 1)
  (setq evil-snipe-smart-case t
        evil-snipe-scope 'buffer
        evil-snipe-repeat-scope 'buffer
        evil-snipe-char-fold t
        evil-snipe-show-prompt nil)
  
  ;; Fix visual mode mappings
  (evil-define-key 'visual evil-snipe-mode-map "s" 'evil-snipe-s)
  (evil-define-key 'visual evil-snipe-mode-map "S" nil))

;; 5. Evil Escape
(use-package evil-escape
  :ensure t
  :after evil
  :config
  (evil-escape-mode 1)
  (setq evil-escape-key-sequence "jf"
        evil-escape-delay 0.2
        evil-escape-unordered-key-sequence t))

;; 6. Evil Exchange
(use-package evil-exchange
  :ensure t
  :config
  (evil-exchange-install)
  (with-eval-after-load 'evil
    (evil-define-key 'normal 'global "gx" 'evil-exchange)
    (evil-define-key 'normal 'global "gX" 'evil-exchange-cancel)))

;; 7. Evil Lion (Alignment)
(use-package evil-lion
  :ensure t
  :config (evil-lion-mode))

;; 8. Evil Numbers
(use-package evil-numbers
  :ensure t
  :config
  (with-eval-after-load 'evil
    (evil-define-key '(normal visual) 'global "g+" 'evil-numbers/inc-at-pt)
    (evil-define-key '(normal visual) 'global "g-" 'evil-numbers/dec-at-pt)))

;; 9. Evil Visualstar
(use-package evil-visualstar
  :ensure t
  :after evil
  :config (global-evil-visualstar-mode))

;; 10. Evil Vimish Fold
(use-package evil-vimish-fold
  :ensure t
  :after evil
  :init (global-evil-vimish-fold-mode)
  :config
  (with-eval-after-load 'evil
    (evil-define-key '(normal visual) 'global "zf" 'evil-vimish-fold/create)
    (evil-define-key '(normal visual) 'global "zd" 'evil-vimish-fold/delete)
    (evil-define-key '(normal visual) 'global "zE" 'evil-vimish-fold/delete-all)))

;; 11. Evil Indent Plus
(use-package evil-indent-plus
  :ensure t
  :after evil
  :config (evil-indent-plus-default-bindings))

;; 12. Evil Easymotion
(use-package evil-easymotion
  :ensure t
  :after evil
  :demand t
  :config
  (evilem-default-keybindings "gs"))

(use-package undo-fu
   :ensure nil
   :config
   ;; Increase memory limits to prevent Emacs from aggressively deleting old history
   ;; (Values copied from Doom Emacs)
   (setq undo-limit 6710886400 ;; 64mb
         undo-strong-limit 100663296 ;; 96mb
         undo-outer-limit 1006632960) ;; 960mb
   )

(use-package undo-fu-session
  :ensure t
  :init
  (undo-fu-session-global-mode)
  :config
  (setq undo-fu-session-incompatible-files '("/COMMIT_EDITMSG\\'" "/git-rebase-todo\\'")))

 (use-package vundo
   :ensure t
   :commands (vundo)
   :config
   ;; Use beautiful Unicode symbols for the tree
   (setq vundo-glyph-alist vundo-unicode-symbols)
   (setq vundo-compact-display t))

(use-package doom-themes
  :demand t
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-solarized-light t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

(use-package nerd-icons
  :ensure t
  :demand t
  :config
  (defun my-nerd-icons-faicon-small (name &rest args)
    (apply #'nerd-icons-faicon name (plist-put (copy-sequence args) :height 0.8)))
  (defun my-nerd-icons-devicon-small (name &rest args)
    (apply #'nerd-icons-devicon name (plist-put (copy-sequence args) :height 0.8)))

  (add-to-list 'nerd-icons-extension-icon-alist '("gradle" my-nerd-icons-devicon-small "nf-dev-gradle"))
  (add-to-list 'nerd-icons-extension-icon-alist '("kts" my-nerd-icons-devicon-small "nf-dev-gradle"))
  (add-to-list 'nerd-icons-extension-icon-alist '("properties" my-nerd-icons-faicon-small "nf-fa-cog"))
  (add-to-list 'nerd-icons-extension-icon-alist '("project" nerd-icons-octicon "nf-oct-file_code"))
  (add-to-list 'nerd-icons-extension-icon-alist '("classpath" nerd-icons-octicon "nf-oct-file_code")))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-hud t)
  (setq doom-modeline-buffer-file-name-style 'relative-from-project)
  (setq doom-modeline-height 25)
  (setq doom-modeline-checker-enable t)
  (setq doom-modeline-checker-simple-format nil)
  (setq doom-modeline-support-mouse nil)
  (setq doom-modeline-column-number nil)
  (setq doom-modeline-percent-position nil)
  (setq doom-modeline-position-line-format '("%l"))
  (setq doom-modeline-buffer-encoding nil)
  (setq doom-modeline-major-mode-icon t)
  (setq doom-modeline-major-mode-hide-name t)
  (setq doom-modeline-project-name t)
  
  (column-number-mode -1)

  ;; Click integration for Flymake
  (defun my/doom-modeline-flymake-click ()
    (interactive)
    (if (bound-and-true-p flymake-mode)
        (flymake-show-buffer-diagnostics)
      (message "Flymake not active")))
  
  (define-key doom-modeline-mode-map (kbd "<mode-line> <flymake> <mouse-1>") 'my/doom-modeline-flymake-click))

;; Ansi Colors for Compilation
(use-package ansi-color
  :ensure nil
  :hook (compilation-filter . ansi-color-compilation-filter))

;; Rainbow Identifiers
(use-package rainbow-identifiers
  :ensure t
  :hook (prog-mode . rainbow-identifiers-mode)
  :config
  (setq rainbow-identifiers-cie-l-saturation 45
        rainbow-identifiers-cie-l-lightness 70
        rainbow-identifiers-choose-face-function #'rainbow-identifiers-cie-l*a*b*-choose-face))

(use-package vertico
  :demand t
  :init (vertico-mode)
  :custom (vertico-cycle t)
  :bind (:map vertico-map
              ("C-j" . vertico-next)
              ("C-k" . vertico-previous)
              ("C-f" . vertico-scroll-down)
              ("C-b" . vertico-scroll-up)))

(use-package savehist
  :ensure nil
  :init (savehist-mode))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion))))
  :config
  (defun my/orderless-dispatch (pattern _index _total)
    (cond
     ((string-prefix-p "!" pattern) `(orderless-without-literal . ,(substring pattern 1)))
     ((string-suffix-p "=" pattern) `(orderless-literal . ,(substring pattern 0 -1)))
     ((string-prefix-p "," pattern) `(orderless-initialism . ,(substring pattern 1)))
     ((string-suffix-p "~" pattern) `(orderless-flex . ,(substring pattern 0 -1)))))
  (setq orderless-style-dispatchers '(my/orderless-dispatch)))

(use-package marginalia
  :after vertico
  :custom
  (marginalia-max-relative-age 0)
  (marginalia-align 'right)
  :init (marginalia-mode)
  :bind (:map minibuffer-local-map ("M-A" . marginalia-cycle)))

(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package consult
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :init
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  (setq consult-narrow-key "<")
  (setq consult-widen-key ">")
  (setq consult-preview-key 'any)
  (setq consult-project-function (lambda (_) (project-root (project-current)))))

(use-package consult-dir
  :bind (("C-x C-d" . consult-dir)
         :map minibuffer-local-completion-map
         ("C-x C-d" . consult-dir)
         ("C-x C-j" . consult-dir-jump-file)))

;; Wgrep enables editing the results of grep/ripgrep
(use-package wgrep :ensure t)

(use-package embark
  :ensure t
  :bind
  (("C-;" . embark-act)
   ("C-:" . embark-dwim)
   ("C-h B" . embark-bindings))
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  (add-to-list 'display-buffer-alist
               '("\`\*Embark Collect \(Live\|Completions\)\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult)

(use-package corfu
  :demand t
  :custom
  (corfu-auto t)                 ;; Enable auto completion
  (corfu-auto-delay 0.1)         ;; Small delay to prevent stuttering
  (corfu-auto-prefix 2)          ;; Minimum length to trigger
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  (corfu-preselect 'prompt)      ;; Always preselect the prompt (first candidate is not auto-selected)
  (corfu-quit-no-match 'separator) ;; Auto-quit if no match, helps with separator insertion
  (corfu-popupinfo-delay 0.5)    ;; Delay before showing docs
  (corfu-max-width 80)
  (corfu-preview-current nil)    ;; Disable previewing current candidate (can be distracting)

  :init
  (global-corfu-mode)

  :config
  (corfu-popupinfo-mode)

  :bind
  (:map corfu-map
        ("TAB" . corfu-next)
        ([tab] . corfu-next)
        ("S-TAB" . corfu-previous)
        ([backtab] . corfu-previous)
        ("C-j" . corfu-next)
        ("C-k" . corfu-previous)
        ("RET" . corfu-insert)
        ("C-e" . corfu-send-shell)    ;; Send candidate to shell/minibuffer
        ("SPC" . corfu-insert-separator))) ;; Helps filtering with Orderless

;; Pretty icons for Corfu
(use-package nerd-icons-corfu
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package yasnippet
    :ensure t
    :hook ((prog-mode . yas-minor-mode)
           (conf-mode . yas-minor-mode)
             (org-mode . yas-minor-mode)
           )
    :config
    (setq yas-snippet-dirs (list (expand-file-name "snippets" user-emacs-directory)))
    (setq yas-triggers-in-field t))

  (use-package yasnippet-snippets
    :ensure t
    :after yasnippet
    :config
    (require 'yasnippet-snippets)
    (add-to-list 'yas-snippet-dirs yasnippet-snippets-dir t)
    (yas-reload-all))

(use-package yasnippet-capf
  :ensure t
  :after yasnippet
  :config
  (add-to-list 'completion-at-point-functions #'yasnippet-capf))

(use-package cape
  :ensure t
  :init
  ;; Add `completion-at-point-functions`, used by `corfu`.
  ;; Note: We omit 't' (append) for cape-file so it takes precedence over normal code completion.
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev t)
  (add-to-list 'completion-at-point-functions #'cape-keyword t)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  (add-to-list 'completion-at-point-functions #'yasnippet-capf)

  :config
  (setq pcomplete-ignore-case t)
  (setq cape-dabbrev-check-other-buffers t))

(use-package magit
:ensure t
:commands (magit-status magit-get-current-branch)
:custom
;; --- Appearance and Behavior ---
;; Show refined diffs (highlight changed words)
(magit-diff-refine-hunk t)
;; Automatically save repository buffers when opening status
(magit-save-repository-buffers 'dontask)
;; Open Magit in current window (full screen style), except for diffs
(magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
;; Show gravatars in log (optional, Doom visual style)
(magit-revision-show-gravatars '("^Author:     " . "^Commit:     "))

;; --- Performance and Security ---
;; Remove confirmation for "safe" or reversible actions
(magit-no-confirm '(discard stage-all-changes unstage-all-changes))

:config
;; Ensure the default directory is respected
(setq magit-repository-directories '(("~/Projects" . 2) ("~/org" . 0)))

;; Doom tip: Close Magit window and restore previous when pressing 'q'
(setq magit-bury-buffer-function #'magit-mode-quit-window))

(use-package dirvish
  :demand t
  :custom ;; Visual attributes for normal buffers (Full Dired)
  (dirvish-attributes '(vc-state nerd-icons file-size collapse subtree-state git-msg))
  ;; Sidebar (Side) Configuration
  (dirvish-side-width 30)
  (dirvish-side-display-alist `((side . left) (slot . -1))) ;; Always force to the extreme left

:config
;; Enable Dirvish globally (replacing default Dired)
(dirvish-override-dired-mode)
;; Enable file preview and "follow mode" (sync with open buffer)
(dirvish-peek-mode)
(dirvish-side-follow-mode)

;; --- TREEMACS-STYLE VISUAL ---
;; In the sidebar, show ONLY icons and name (no size, date, etc.)
(setq dirvish-side-attributes '(nerd-icons collapse subtree-state))

;; Fine-tuned Dired adjustments
(setq dired-listing-switches "-agho --group-directories-first"
      dired-recursive-deletes 'always
      dired-recursive-copies 'always
      delete-by-moving-to-trash t)

(defun my/dirvish-project ()
  "Open Dirvish at project root (if available) or current directory."
  (interactive)
  (let ((root (project-root (project-current))))
    (if root
        (dirvish root)
      (dirvish))))

;; Navigation within Dirvish buffer (Keep as is)
(with-eval-after-load 'dirvish
  (evil-define-key 'normal dirvish-mode-map
    "q" 'dirvish-quit
    "h" 'dired-up-directory
    "l" 'dired-find-file
    "TAB" 'dirvish-subtree-toggle)))

(use-package apheleia
  :ensure t
  :init (apheleia-global-mode +1)
  :config
   (setq apheleia-log-only-errors nil)
   (setf (alist-get 'google-java-format apheleia-formatters)
         '("/home/nathanmcunha/.local/bin/google-java-format" "-"))
   (setf (alist-get 'black apheleia-formatters)
         '("black" "-" "-"))
   (push '(java-mode . google-java-format) apheleia-mode-alist)
   (push '(java-ts-mode . google-java-format) apheleia-mode-alist)
   (push '(python-mode . black) apheleia-mode-alist)
    (push '(python-ts-mode . black) apheleia-mode-alist))

;; Simple flymake configuration - avoid eval-after-load to prevent macro expansion errors
(add-hook 'prog-mode-hook #'flymake-mode)

;; Configure flymake when loaded
(eval-after-load 'flymake
  '(progn
     (setq flymake-fringe-indicator-position 'left-fringe)
     
      ;; 1. Window Configuration (Clean Popup at Bottom)
     (add-to-list 'display-buffer-alist
                  '("\*Flymake diagnostics.*"
                    (display-buffer-reuse-window display-buffer-in-side-window)
                    (side . bottom)
                    (slot . 0)
                    (window-height . 0.25)
                    (preserve-size . (nil . t))
                    (window-parameters . ((no-other-window . nil)
                                          (mode-line-format . none)))))
     
      ;; 2. Diagnostics buffer visuals
     (add-hook 'flymake-project-diagnostics-mode-hook
               (lambda ()
                 (setq header-line-format nil) 
                 (setq tabulated-list-use-header-line nil)
                 (setq tabulated-list-gui-sort-indicator-mode nil)
                 (display-line-numbers-mode 0)
                 (hl-line-mode 1)))))

 ;; 3. Search function for Consult (simplified to avoid macro expansion issues)
 (defun my/consult-flymake-project ()
   "Search project errors via Consult, extracting data from Flymake."
   (interactive)
   (flymake-show-project-diagnostics)
   (let ((diag-buffer (get-buffer "*Flymake diagnostics*")))
     (if (not diag-buffer)
         (message "Please wait... Eglot is still indexing errors.")
       (with-current-buffer diag-buffer
         (let ((entries-raw (if (functionp tabulated-list-entries)
                                (funcall tabulated-list-entries)
                              tabulated-list-entries))
               candidates)
           (dolist (entry entries-raw)
             (let* ((diag (car entry))
                    (buffer (flymake-diagnostic-buffer diag)))
               (when (buffer-live-p buffer)
                 (let* ((line (line-number-at-pos (flymake-diagnostic-beg diag)))
                        (type (flymake-diagnostic-type diag))
                        (text (flymake-diagnostic-text diag))
                        (file (buffer-name buffer))
                        (face (flymake-diagnostic-type-face type))
                        (type-str (propertize (symbol-name type) 'face face))
                        (cand-str (format "%-20s %-8s %s" 
                                          (propertize file 'face 'font-lock-variable-name-face)
                                          type-str
                                          (propertize text 'face 'shadow))))
                   (push (propertize cand-str 
                                     'consult--candidate 
                                     (cons (set-marker (make-marker) (flymake-diagnostic-beg diag)) buffer))
                         candidates)))))
           (if candidates
               (consult--read (nreverse candidates)
                              :prompt "Project Issues: "
                              :category 'consult-location
                              :sort nil
                              :lookup #'consult--lookup-candidate)
             (message "No errors found in project.")))))))

(use-package treesit
  :ensure nil
  :config
   (setq treesit-language-source-alist
         '((java "https://github.com/tree-sitter/tree-sitter-java")
           (javascript "https://github.com/tree-sitter/tree-sitter-javascript")
           (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
           (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
           (python "https://github.com/tree-sitter/tree-sitter-python")))

  (defun my/install-java-tree-sitter ()
    "Install the Java tree-sitter grammar."
    (interactive)
    (treesit-install-language-grammar 'java)
    (message "Java grammar installed! Restart Emacs or reload the mode.")))

(use-package eglot-java
  :ensure t
  :hook (((java-mode java-ts-mode) . eglot-java-mode))
   :config
   ;; Increase eglot timeout to give JDTLS time to start up (common in Java)
   (setq eglot-connect-timeout 120)
   (setq eglot-request-timeout 60)

  (defun my/eglot-java-init-opts (server jdt)
    (let ((debug-jar "/home/nathanmcunha/.config/emacs/java-debug/debug-plugin.jar"))
      `(:bundles [,debug-jar]
        :extendedClientCapabilities (:classFileContentsSupport t
                                     :generateToStringPromptSupport t
                                     :supportsDebugger t)
        :settings (:java (:import (:gradle (:enabled t))
                          :configuration (:runtimes []))))))

  (setq eglot-java-user-init-opts-fn 'my/eglot-java-init-opts))

(use-package pyvenv
  :ensure t
  :config
  (setq pyvenv-mode-line-indicator
        '(pyvenv-virtual-env-name (" [venv:" pyvenv-virtual-env-name "] ")))
  (pyvenv-mode 1)
  
  (defun my/pyvenv-auto-activate ()
    "Auto-activate venv if specified in .dir-locals.el or found in project."
    (when (derived-mode-p 'python-mode 'python-ts-mode)
      (let ((project-root (or (locate-dominating-file default-directory ".dir-locals.el")
                               (locate-dominating-file default-directory ".git")
                               (locate-dominating-file default-directory "pyproject.toml")
                               (locate-dominating-file default-directory "pyrightconfig.json")
                               default-directory)))
        (when project-root
          (let ((venv-spec (and (boundp 'pyvenv-workon) pyvenv-workon))
                venv-path)
            (setq venv-path
                  (cond
                   (venv-spec
                    (expand-file-name venv-spec project-root))
                   ((file-exists-p (expand-file-name ".venv" project-root))
                    (expand-file-name ".venv" project-root))
                   ((file-exists-p (expand-file-name "venv" project-root))
                    (expand-file-name "venv" project-root))
                   ((file-exists-p (expand-file-name "env" project-root))
                    (expand-file-name "env" project-root))))
            (when (and venv-path (not (string= venv-path pyvenv-virtual-env)))
              (pyvenv-activate venv-path)
              (message "Activated venv: %s" venv-path))))))
  
  (add-hook 'python-mode-hook 'my/pyvenv-auto-activate)
  (add-hook 'python-ts-mode-hook 'my/pyvenv-auto-activate))

(use-package eglot
   :ensure nil
   :config
   ;; Configure Eglot for Python with Pyright
   ;; Pyright automatically reads from your virtual environment if activated
   ;; Run: source .venv/bin/activate && emacs
   (add-to-list 'eglot-server-programs
                '((python-mode python-ts-mode)
                  . ("pyright-langserver" "--stdio")))
   
  (defun my/python-eglot-ensure ()
    "Activate venv then start Eglot for Python."
    (my/pyvenv-auto-activate)
    (let ((project-root (or (locate-dominating-file default-directory ".dir-locals.el")
                             (locate-dominating-file default-directory ".git")
                             (locate-dominating-file default-directory "pyproject.toml")
                             (locate-dominating-file default-directory "pyrightconfig.json")
                             default-directory)))
     (setq-local eglot-workspace-configuration
                 `(:python (:venvPath ,project-root
                            :venv ".venv"
                            :analysis (:typeCheckingMode "strict"
                                       :autoSearchPaths t
                                       :useLibraryCodeForTypes t
                                       :diagnosticMode "workspace"))))
     (cd project-root)
     (eglot-ensure)))
   
   (add-hook 'python-mode-hook 'my/python-eglot-ensure)
   (add-hook 'python-ts-mode-hook 'my/python-eglot-ensure))

  ;; Note: Eglot keybindings are available via leader keys (SPC c prefix)
  ;; to avoid python-mode-map void errors when eglot loads for other modes.
)

(use-package flymake
  :ensure nil
  :hook
  ((python-mode python-ts-mode) . flymake-mode)
  :config
  (setq flymake-fringe-indicator-position 'left-fringe))

;; Ruff linter configuration
(defun my/python-ruff-diagnostics (source callback)
  "Run Ruff as a Flymake backend for Python."
  (let ((buffer (current-buffer)))
    (unless (executable-find "ruff")
      (funcall callback '())
      (cl-return-from my/python-ruff-diagnostics))
    
    (when-let ((file (buffer-file-name buffer)))
      (make-process
       :name "ruff-flymake"
       :buffer (generate-new-buffer " *ruff-flymake*")
       :command (list "ruff" "check" "--output-format=json" file)
       :sentinel
       (lambda (process _event)
         (when (eq (process-status process) 'exit)
           (unwind-protect
               (with-current-buffer (process-buffer process)
                 (let ((json-array-type 'list))
                   (let ((diagnostics
                          (mapcar
                           (lambda (item)
                             (let* ((start-line (1- (alist-get 'start_line item)))
                                    (start-col (alist-get 'start_column item))
                                    (end-line (1- (alist-get 'end_line item)))
                                    (end-col (alist-get 'end_column item))
                                    (message (alist-get 'message item))
                                    (code (alist-get 'code item))
                                    (severity (alist-get 'severity item))
                                    (type (cond
                                           ((string= severity "error") :error)
                                           ((string= severity "warning") :warning)
                                           (t :note))))
                               (flymake-make-diagnostic
                                (current-buffer)
                                (flymake-diag-region buffer start-line start-col end-line end-col)
                                type
                                message
                                :code code
                                :source "Ruff"))))
                           (condition-case nil
                               (json-read-from-string
                                (buffer-string))
                             (error '())))))
                     (funcall callback diagnostics)))
             (kill-buffer (process-buffer process)))))))))

;; Register Ruff as a Flymake backend
(add-hook 'python-mode-hook
          (lambda ()
            (add-hook 'flymake-diagnostic-functions 'my/python-ruff-diagnostics nil t)))
(add-hook 'python-ts-mode-hook
          (lambda ()
            (add-hook 'flymake-diagnostic-functions 'my/python-ruff-diagnostics nil t)))

;; pytest integration
(defun my/python-run-pytest-file ()
  "Run pytest on the current file."
  (interactive)
  (let ((file (buffer-file-name)))
    (compile (format "pytest %s" file))))

(defun my/python-run-pytest-function ()
  "Run pytest on the function at point."
  (interactive)
  (save-excursion
    (beginning-of-defun)
    (let* ((func-name (python-info-current-defun))
           (file (buffer-file-name)))
      (compile (format "pytest %s::%s" file func-name)))))

;; Python keybindings
(with-eval-after-load 'python
  (define-key python-mode-map (kbd "C-c C-t") 'my/python-run-pytest-file)
  (define-key python-mode-map (kbd "C-c C-f") 'my/python-run-pytest-function)
  (define-key python-mode-map (kbd "C-c C-l") 'consult-flymake-project))

;; Note: Python project test/format now handled by global my/project-test
;; and my/project-compile functions, which detect Python projects automatically.

(use-package adaptive-wrap
  :ensure t
  :config
  ;; Define how much EXTRA indentation to add on wrapped lines (default is 0).
  ;; Setting to 2 helps visually distinguish the wrap from a new indented line.
  (setq-default adaptive-wrap-extra-indent 2))

;; Hook to automatically activate in programming
(add-hook 'prog-mode-hook
          (lambda ()
            (visual-line-mode 1)          ;; Enable line wrapping at window edge
            (adaptive-wrap-prefix-mode 1))) ;; Enable smart indentation correction

;; 1. Dependencies (Eat and Popup)
     (use-package eat
       :ensure t
       :defer t
       :hook (eat-mode . (lambda () 
                           (evil-local-mode 1)
                           (evil-define-key* 'insert eat-mode-map (kbd "C-c C-k") #'eat-reset)))
       :config
       (setq eat-kill-buffer-on-exit t)
       (add-hook 'eat-mode-hook (lambda () 
                                  (add-hook 'evil-insert-state-entry-hook #'eat-emulate-es-mode nil t)
                                  (add-hook 'evil-normal-state-entry-hook #'eat-emulate-scroll-mode nil t))))

     ;; Force loading popup to ensure it exists before gemini-cli
     (use-package popup
       :ensure t
       :demand t)

     ;; 2. Gemini CLI Wrapper
     (use-package gemini-cli
       :ensure (:host github :repo "linchen2chris/gemini-cli.el")
       ;; HERE IS THE FIX: We added 'popup' to the :after list
       :after (eat popup)
       :config
       ;; Try to find the executable automatically (same code I gave you before)
       (let ((gemini-path (string-trim (shell-command-to-string "mise which gemini"))))
         (if (and (not (string-empty-p gemini-path))
                  (file-executable-p gemini-path))
             (setq gemini-cli-command gemini-path)
           (setq gemini-cli-command (or (executable-find "gemini")
                                        "~/.local/share/mise/installs/node/20.19.6/bin/gemini")))))

;; Eletric Pair (for brackets)
    (use-package elec-pair
      :ensure nil
      :hook (prog-mode . electric-pair-mode)
      :config
      (setq electric-pair-inhibit-predicate
            `(lambda (c)
               (if (char-equal c ?<) t (electric-pair-default-inhibit c)))))

(use-package shell-maker
  :ensure t
  :demand t)

(use-package acp
  :ensure t
  :demand t)

(use-package agent-shell
  :ensure t
  :after (shell-maker acp)
  :config
  ;; === Gemini Configuration ===
  (setq agent-shell-google-authentication
        (agent-shell-google-make-authentication
         :api-key (lambda () (getenv "GEMINI_API_KEY"))))
  
   (setq agent-shell-google-gemini-environment
         (agent-shell-make-environment-variables
          :inherit-env t))

   ;; === Model Selection Configuration ===
   (defvar my-agent-shell-google-gemini-models
     '("auto"
       "gemini-3-pro-preview"
       "gemini-3-flash-preview"
       "gemini-2.5-pro"
       "gemini-2.5-flash"
       "gemini-2.5-flash-lite")
     "Available Gemini models for selection.")

   (defvar my-agent-shell-use-yolo t
     "Whether to use --yolo flag in ACP mode.")

   (defvar my-agent-shell-google-gemini-model "auto"
     "Currently selected Gemini model.")

   (defun my-agent-shell-google-update-gemini-command ()
     "Update `agent-shell-google-gemini-acp-command' with the current model."
     (let ((cmd (list "gemini" "--experimental-acp" "-m" my-agent-shell-google-gemini-model)))
       (when my-agent-shell-use-yolo
         (setq cmd (append cmd (list "--yolo"))))
       (setq agent-shell-google-gemini-acp-command cmd)
       (setq agent-shell-google-gemini-command nil)
       (message "Updated command: %S" agent-shell-google-gemini-acp-command)))

   (defun my-agent-shell-toggle-yolo ()
     "Toggle YOLO mode for agent-shell."
     (interactive)
     (setq my-agent-shell-use-yolo (not my-agent-shell-use-yolo))
     (my-agent-shell-google-update-gemini-command)
     (message "YOLO mode: %s" (if my-agent-shell-use-yolo "enabled" "disabled")))

   (defun my-agent-shell-google-select-gemini-model (model)
     "Select a Gemini model and update the command."
     (interactive (list (completing-read "Select Gemini model: " my-agent-shell-google-gemini-models nil t)))
     (setq my-agent-shell-google-gemini-model model)
     (my-agent-shell-google-update-gemini-command)
     (message "Gemini model set to: %s (Restart agent-shell for changes to take effect)" model))

   (defun my-agent-shell (arg)
     "Launch agent-shell. With prefix ARG, select Gemini model first."
     (interactive "P")
     (when arg
       (call-interactively 'my-agent-shell-google-select-gemini-model))
     (agent-shell))

  (defun my-agent-shell-restart ()
    "Restart agent-shell with current model."
    (interactive)
    (let ((buffers (buffer-list)))
      (dolist (buf buffers)
        (when (string-match-p "\\*agent-shell" (buffer-name buf))
          (when (buffer-live-p buf)
            (let ((proc (get-buffer-process buf)))
              (when proc
                (delete-process proc)))
            (kill-buffer buf))))
    (agent-shell))

   (defun my-agent-shell-status ()
     "Show current agent-shell configuration."
     (interactive)
     (message "Current Gemini model: %s | YOLO: %s | Command: %S"
              my-agent-shell-google-gemini-model
              my-agent-shell-use-yolo
              agent-shell-google-gemini-acp-command))

   ;; === Model Persistence ===
   (defconst my-agent-shell-model-file
     (expand-file-name "agent-shell-model" user-emacs-directory)
     "File to persist the selected Gemini model.")

   (defun my-agent-shell-save-model ()
     "Save the current model to disk."
     (with-temp-file my-agent-shell-model-file
       (insert my-agent-shell-google-gemini-model)))

   (defun my-agent-shell-load-model ()
     "Load the saved model from disk, if it exists."
     (when (file-exists-p my-agent-shell-model-file)
       (with-temp-buffer
         (insert-file-contents my-agent-shell-model-file)
         (let ((saved-model (string-trim (buffer-string))))
           (when (member saved-model my-agent-shell-google-gemini-models)
             (setq my-agent-shell-google-gemini-model saved-model)
             (my-agent-shell-google-update-gemini-command))))))

   (add-hook 'kill-emacs-hook 'my-agent-shell-save-model)

   ;; === Opencode Configuration ===
  (setq agent-shell-opencode-authentication
        (agent-shell-opencode-make-authentication :none t))
  
  (setq agent-shell-opencode-environment
         (agent-shell-make-environment-variables
          :inherit-env t))
  
  ;; === Keybindings ===
  ;; Main menu: M-x agent-shell (start/reuse agent)
  ;; Specific agents: M-x agent-shell-google-start-gemini
  ;;             M-x agent-shell-opencode-start-agent
  
  ;; === Evil Mode Integration ===
  (with-eval-after-load 'evil
    ;; Evil state-specific RET behavior: insert mode = newline, normal mode = send
    (evil-define-key 'insert agent-shell-mode-map (kbd "RET") #'newline)
    (evil-define-key 'normal agent-shell-mode-map (kbd "RET") #'comint-send-input)
    
    ;; Configure *agent-shell-diff* buffers to start in Emacs state
    (add-hook 'diff-mode-hook
              (lambda ()
                (when (string-match-p "\\\\*agent-shell-diff\\\\\*" (buffer-name))
                  (evil-emacs-state)))))
  
  ;; === Display Configuration ===
  ;; Show welcome message
  (setq agent-shell-show-welcome-message t)
  
  ;; Show context usage indicator
  (setq agent-shell-show-context-usage-indicator t)
  
  ;; Show usage at turn end
  (setq agent-shell-show-usage-at-turn-end t)
  
   ;; Enable file completion
   (setq agent-shell-file-completion-enabled t)

   ;; === Initialize Model ===
   (my-agent-shell-load-model)
   (my-agent-shell-google-update-gemini-command)
   (setq agent-shell-preferred-agent-config (agent-shell-google-make-gemini-config))))

(use-package org
        :ensure nil
        :hook ((org-mode . visual-line-mode)
               (org-mode . org-indent-mode))
        :config
    (require 'org-tempo)
        (setq org-ellipsis " ▾"
              org-hide-emphasis-markers t
              org-src-fontify-natively t
              org-fontify-quote-and-verse-blocks t
              org-src-tab-acts-natively t
              org-edit-src-content-indentation 2
              org-hide-block-startup nil
              org-src-preserve-indentation nil
              org-startup-folded 'content)
(defun my/org-tab-dwim ()
    (interactive)
    (or (and (bound-and-true-p yas-minor-mode)
             (yas-expand))
        (and (fboundp 'completion-at-point)
             (completion-at-point))
        (org-cycle)))

        )

  (use-package org-modern
        :ensure t
        :hook (org-mode . org-modern-mode)
        :config
        (setq org-modern-star '("◉" "○" "◈" "◇" "✳" "◆" "□")
              org-modern-table-vertical 1
              org-modern-table-horizontal 0.2
              org-modern-list '((43 . "➤") (45 . "–") (42 . "•"))
              org-modern-todo nil org-modern-tag nil org-modern-priority nil))

      (use-package mixed-pitch
        :hook (org-mode . mixed-pitch-mode)
        :config (setq mixed-pitch-set-height t))

      (use-package ob-mermaid :ensure t :after org
        :config (org-babel-do-load-languages 'org-babel-load-languages '((mermaid . t) (emacs-lisp . t))))

      (use-package org-roam
        :ensure t
        :init
        (setq org-roam-v2-ack t)
        :custom
        (org-roam-directory (file-truename "~/org"))
        (org-roam-completion-everywhere nil)
        :config (org-roam-db-autosync-mode))

(use-package markdown-mode
  :ensure t
  :mode ("README\.md\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown")
  :config (setq markdown-fontify-code-blocks-natively t))

(use-package mise
  :ensure t
  :hook (after-init . global-mise-mode)
  :config (add-to-list 'exec-path (expand-file-name "~/.local/bin")))

(require 'which-func)
(which-function-mode 1)

(defun my/get-java-full-test-target (is-gradle)
  "Return the test target with the full package (e.g., com.foo.Bar.test)."
  (let* ((package-name (save-excursion
                         (goto-char (point-min))
                         (when (re-search-forward "^package \\(.+\\);" nil t)
                           (match-string 1))))
         (class-name (file-name-base (buffer-file-name)))
         (method-name (which-function))
         (clean-method (when (stringp method-name)
                         (car (last (split-string method-name "\\.")))))
         ;; Build the FQN (Fully Qualified Name)
         (full-class (if package-name (concat package-name "." class-name) class-name)))
    (cond
     ((not clean-method) full-class)
     (is-gradle (format "*%s.%s" class-name clean-method))
     (t (format "%s#%s" full-class clean-method)))))

(defun my/java-debug-test-at-point ()
  "Initialize JVM in debug mode only for the method or class under cursor."
  (interactive)
  (unless (project-current)
    (user-error "Not in a project"))

  (let* ((project-root (project-root (project-current)))
         (is-gradle (file-exists-p (expand-file-name "gradlew" project-root)))
         (test-target (my/get-java-full-test-target is-gradle))
         (buf-name " *java-test-debug-process*")
         ;; Build the specific command
         (cmd (if is-gradle
                  (format "./gradlew test --tests \"%s\" --rerun-tasks --debug-jvm" test-target)
                (format "mvn -Dmaven.surefire.debug test -Dtest=\"%s\"" test-target))))

    ;; Clean up previous processes
    (when (get-buffer buf-name)
      (ignore-errors (delete-process (get-buffer-process buf-name)))
      (kill-buffer buf-name))

    (message "Launching JVM for: %s..." test-target)
    
    (let* ((default-directory project-root)
           (proc (start-process-shell-command "java-debug-proc" buf-name cmd)))
      
      (set-process-filter
       proc
       (lambda (process output)
         (when (buffer-live-p (process-buffer process))
           (with-current-buffer (process-buffer process)
             (save-excursion
               (goto-char (point-max))
               (insert output))))
         
         (when (string-match-p "Listening for transport dt_socket" output)
           (message "JVM ready for [%s]! Use Dape to attach." test-target)))))))

(defun my/show-java-debug-log ()
  "Show the log buffer of the current debug process."
  (interactive)
  (if (get-buffer " *java-test-debug-process*")
      (display-buffer " *java-test-debug-process*")
    (message "No active debug log.")))

(use-package dape
  :ensure t
  :config
  (setq dape-buffer-window-arrangement 'right)
  
  (add-to-list 'dape-configs
               `(java-attach
                 modes (java-mode java-ts-mode)
                 ensure (lambda (&rest _) (eglot-current-server))
                 ;; Increase port resilience
                 port (lambda ()
                        (let ((port (eglot-execute-command
                                     (eglot-current-server)
                                     "vscode.java.startDebugSession" nil)))
                          ;; A brief pause to prevent the Eglot Sentinel from getting lost
                          (sit-for 0.2)
                          port))
                 :type "java"
                 :request "attach"
                 :hostName "127.0.0.1"
                 :port 5005)))

(defvar my/java-coverage-overlays nil "Global list of active overlays.")
(defvar-local my/java-coverage-visible nil "Coverage state in the buffer.")

(defface my/jacoco-lens-face
  '((t :inherit shadow :slant italic :height 0.9 :foreground "green"))
  "Face for the coverage percentage above methods.")

(defface my/jacoco-missed-line-face
  '((t :underline (:style wave :color "orange")))
  "Subtle face (orange wave) for uncovered lines.")

(defun my/java-get-jacoco-path ()
  "Locate the JaCoCo XML report via project.el."
  (let ((gradle-path "build/reports/jacoco/test/jacocoTestReport.xml")
        (maven-path "target/site/jacoco/jacocoTestReport.xml")
        (root (project-root (project-current))))
    (cond
     ((and root (file-exists-p (expand-file-name gradle-path root)))
      (expand-file-name gradle-path root))
     ((and root (file-exists-p (expand-file-name maven-path root)))
      (expand-file-name maven-path root))
     (t nil))))

(defun my/java-coverage-browse-report ()
  "Open the JaCoCo HTML report in the browser."
  (interactive)
  (let ((gradle-html "build/reports/jacoco/test/html/index.html")
        (maven-html "target/site/jacoco/index.html")
        (root (project-root (project-current))))
    (cond
     ((and root (file-exists-p (expand-file-name gradle-html root)))
      (browse-url (expand-file-name gradle-html root)))
     ((and root (file-exists-p (expand-file-name maven-html root)))
      (browse-url (expand-file-name maven-html root)))
     (t (message "HTML report not found.")))))

(defun my/java-coverage-clear ()
  "Remove all overlays and clear the list."
  (interactive)
  (when (boundp 'my/java-coverage-overlays)
    (mapc #'delete-overlay my/java-coverage-overlays)
    (setq my/java-coverage-overlays nil)))

(defun my/java-coverage-toggle ()
  "Toggle the coverage visualization."
  (interactive)
  (if my/java-coverage-visible
      (progn
        (my/java-coverage-clear)
        (setq-local my/java-coverage-visible nil)
        (message "Coverage disabled."))
    (setq-local my/java-coverage-visible t)
    (my/java-apply-subtle-coverage)
    (message "Coverage enabled.")))

(defun my/java-apply-subtle-coverage ()
  "Apply lenses to the signature and orange highlights with tooltips in the body."
  (let ((report-path (my/java-get-jacoco-path))
        (root (project-root (project-current))))
    (when (and report-path root)
      (let* ((relative-path (file-relative-name (buffer-file-name) root))
             (xml (xml-parse-file report-path))
             (report (car xml)))
        (my/java-coverage-clear)

        (dolist (pkg (xml-get-children report 'package))
          ;; 1. Signature Lenses
          (dolist (cls (xml-get-children pkg 'class))
            (when (string-suffix-p (concat (xml-get-attribute cls 'name) ".java") relative-path)
              (dolist (method (xml-get-children cls 'method))
                (let* ((line-num (string-to-number (xml-get-attribute method 'line)))
                       (counters (xml-get-children method 'counter))
                       (line-c (seq-find (lambda (c) (string= (xml-get-attribute c 'type) "LINE")) counters))
                       (m (string-to-number (or (xml-get-attribute line-c 'missed) "0")))
                       (c (string-to-number (or (xml-get-attribute line-c 'covered) "0")))
                       (pct (if (> (+ m c) 0) (/ (* c 100) (+ m c)) 0))
                       (icon (if (= pct 100) (nerd-icons-faicon "nf-fa-check_circle" :face 'success) ""))
                       (text (format "%s Coverage: %d%%" icon pct)))
                  (my/java--create-lens-at-signature line-num text)))))

          ;; 2. Orange Highlights on missed lines with Tooltip
          (dolist (src (xml-get-children pkg 'sourcefile))
            (when (string-suffix-p (xml-get-attribute src 'name) relative-path)
              (dolist (line (xml-get-children src 'line))
                (let ((missed (string-to-number (xml-get-attribute line 'mi)))
                      (covered (string-to-number (xml-get-attribute line 'ci)))
                      (line-num (string-to-number (xml-get-attribute line 'nr))))
                  (when (> missed 0)
                    (my/java--highlight-missed-line 
                     line-num 
                     (format "JaCoCo: Missed %s instructions (Covered: %s)" missed covered))))))))))))

(defun my/java--create-lens-at-signature (line text)
  (save-excursion
    (goto-char (point-min))
    (forward-line (1- line))
    (while (and (> (line-number-at-pos) 1)
                (looking-at "^[[:space:]]*\\(\{\\|$\\|@\\)"))
      (forward-line -1))
    (let ((ov (make-overlay (line-beginning-position) (line-beginning-position))))
      (overlay-put ov 'before-string 
                   (propertize (format "%s%s\n" (make-string (current-indentation) ?\s) text) 
                               'face 'my/jacoco-lens-face))
      (push ov my/java-coverage-overlays))))

(defun my/java--highlight-missed-line (line tooltip-text)
  "Apply orange underline and add a help-echo (tooltip)."
  (save-excursion
    (goto-char (point-min))
    (when (= 0 (forward-line (1- line)))
      (let ((ov (make-overlay (line-beginning-position) (line-end-position))))
        (overlay-put ov 'face 'my/jacoco-missed-line-face)
        (overlay-put ov 'help-echo tooltip-text) ;; This is the native Tooltip
        (push ov my/java-coverage-overlays)))))

;; Auto-refresh integration
(advice-add 'my/project-test :after 
            (lambda (&rest _) (when my/java-coverage-visible (my/java-apply-subtle-coverage))))

;; Ephemeral/Secrets Configuration
  (use-package auth-source
    :ensure nil
    :custom
    (auth-sources '("~/.authinfo.gpg")))

;; Ensure Emacs asks for GPG password in minibuffer
(setq epa-pinentry-mode 'loopback)
(setq epa-file-cache-passphrase-for-symmetric-encryption t)

;; 2. Gptel configuration with Z.ai as Default
(use-package gptel
  :ensure t
  :config
  ;; Configure Z.ai Coding using key from ~/.authinfo.gpg
  (gptel-make-openai "Z.ai-Coding"
    :host "api.z.ai"
    :endpoint "/api/coding/paas/v4/chat/completions"
    :stream t
    :key 'gptel-api-key ;; gptel will search auth-source for host 'api.z.ai'
    :models '(glm-4.7-plus
              glm-4.7
              glm-4-plus))

  ;; SET Z.AI AS DEFAULT
  (setq gptel-model 'glm-4.7-plus
        gptel-backend (gptel-get-backend "Z.ai-Coding")))

(my/bind-leader "SPC" 'execute-extended-command "M-x")

;; --- Help & Config (h) ---
(my/bind-leader "h b i" 'my/emacs-build-info "Emacs build info")
(my/bind-leader "h b p" 'my/benchmark-current-project "benchmark project")
(my/bind-leader "h r r" (lambda () (interactive) (load-file user-init-file)) "reload config")

;; --- Buffer (b) ---
(my/bind-leader "."   'find-file "find file")
(my/bind-leader ","   'switch-to-buffer "switch buffer")
(my/bind-leader "`"   'evil-switch-to-windows-last-buffer "last buffer")

(my/bind-leader "b b" 'project-switch-to-buffer "switch buffer")
(my/bind-leader "b B" 'switch-to-buffer "switch buffer (all)")
(my/bind-leader "b i" 'ibuffer "ibuffer")
(my/bind-leader "b n" 'next-buffer "next buffer")
(my/bind-leader "b p" 'previous-buffer "previous buffer")
(my/bind-leader "b s" 'save-buffer "save buffer")
(my/bind-leader "b S" 'evil-write-all "save all buffers")
(my/bind-leader "b r" 'revert-buffer "revert buffer")
(my/bind-leader "b k" 'kill-current-buffer "kill buffer")
(my/bind-leader "b K" 'my/kill-all-buffers "kill all buffers")
(my/bind-leader "b O" 'my/kill-other-buffers "kill other buffers")
(my/bind-leader "b N" 'evil-buffer "new buffer")
(my/bind-leader "b y" 'my/copy-this-file "copy file contents")
(my/bind-leader "b R" 'rename-buffer "rename buffer")
(my/bind-leader "b Y" 'bury-buffer "bury buffer")

;; --- Code & LSP (c) ---
(my/bind-leader "c a" 'eglot-code-actions "code action")
(my/bind-leader "c r" 'eglot-rename "rename")
(my/bind-leader "c f" 'apheleia-format-buffer "format")
(my/bind-leader "c d" 'xref-find-definitions "definition")
(my/bind-leader "c D" 'xref-find-references "references")

;; Java Specific
(my/bind-leader "c j n" 'eglot-java-create-project "new project")
(my/bind-leader "c j i" 'eglot-java-organize-imports "organize imports")
(my/bind-leader "c j r" 'my/eglot-restart "restart eglot")
(my/bind-leader "c j t" 'my/switch-to-java-ts-mode "switch to java-ts-mode")
(my/bind-leader "c j I" 'my/install-java-tree-sitter "install java grammar")

;; Java Coverage
(my/bind-leader "c C t" 'my/java-coverage-toggle "toggle coverage lenses")
(my/bind-leader "c C h" 'my/java-coverage-browse-report "open html report")

;; --- Debug (d) ---
(my/bind-leader "d t"  'my/java-debug-test-at-point "Debug Test")
(my/bind-leader "d b"  'dape-breakpoint-toggle "Toggle Breakpoint")
(my/bind-leader "d c"  'dape-continue "Continue")
(my/bind-leader "d n"  'dape-next "Next (Step Over)")
(my/bind-leader "d i"  'dape-step-in "Step In")
(my/bind-leader "d o"  'dape-step-out "Step Out")
(my/bind-leader "d r"  'dape-restart "Restart")
(my/bind-leader "d l"  'dape-info-setup "Show Layout")
(my/bind-leader "d Q"  'dape-kill "Quit Debugger")

;; --- Errors/Flymake (e) ---
(my/bind-leader "e p" 'flymake-show-project-diagnostics "panel (project)")
(my/bind-leader "e b" 'flymake-show-buffer-diagnostics "panel (buffer)")
(my/bind-leader "e l" 'consult-flymake "search buffer")
(my/bind-leader "e L" 'my/consult-flymake-project "search project")
(my/bind-leader "e n" 'flymake-goto-next-error "next")
(my/bind-leader "e N" 'flymake-goto-prev-error "prev")

;; --- Explorer (E) ---
(my/bind-leader "E e" 'my/dirvish-project "project root")
(my/bind-leader "E f" 'dirvish-fd "find files (fd)")
(my/bind-leader "E ." 'dirvish "current dir")

;; --- File (f) ---
(my/bind-leader "f f" 'my/project-find-file "find file in project")
(my/bind-leader "f F" 'find-file "find file anywhere")
(my/bind-leader "f r" 'consult-recent-file "recent files")
(my/bind-leader "f s" 'save-buffer "save file")
(my/bind-leader "f S" 'write-file "save as...")
(my/bind-leader "f R" 'my/move-this-file "rename/move file")
(my/bind-leader "f D" 'my/delete-this-file "delete file")
(my/bind-leader "f y" 'my/copy-file-path "copy file path")
(my/bind-leader "f Y" 'my/copy-file-path-relative-to-project "copy relative path")
(my/bind-leader "f p" (lambda () (interactive) (find-file (expand-file-name "config.org" user-emacs-directory))) "open config")
(my/bind-leader "f e" (lambda () (interactive) (find-file (expand-file-name "early-init.el" user-emacs-directory))) "open early-init")
(my/bind-leader "f E" (lambda () (interactive) (dired (expand-file-name user-emacs-directory))) "browse emacs.d")

;; --- Git (g) ---
(my/bind-leader "g s" 'magit-status "magit status")
(my/bind-leader "g S" 'magit-status-here "magit status here")
(my/bind-leader "g /" 'magit-dispatch "Magit dispatch")
(my/bind-leader "g ." 'magit-file-dispatch "Magit file dispatch")
(my/bind-leader "g f" 'magit-find-file "Find file")
(my/bind-leader "g b" 'magit-blame-addition "Blame")
(my/bind-leader "g t" 'git-timemachine-toggle "Time machine")
(my/bind-leader "g i" 'magit-init "Initialize repo")
(my/bind-leader "g M" 'consult-global-mark "jump to global mark")

(my/bind-leader "g l c" 'magit-log-current "Log current branch")
(my/bind-leader "g l f" 'magit-log-buffer-file "Log current file")
(my/bind-leader "g l g" 'magit-log-all "Log all branches")

(my/bind-leader "g m" 'magit-file-dispatch "Git selection menu")
(my/bind-leader "g r" (lambda () (interactive) (call-interactively 'magit-discard)) "Git discard selection")

;; --- Jump (j) ---
(my/bind-leader "j w" 'evilem-motion-forward-word-begin "word")
(my/bind-leader "j l" 'evilem-motion-next-line "line")
(my/bind-leader "j c" 'evilem-motion-find-char "char")
(my/bind-leader "j s" 'evilem-motion-find-char-timer "find (timer)")
(my/bind-leader "j j" 'evilem-motion-next-line "line")

;; --- Notes (n) ---
(my/bind-leader "n r" 'org-roam-buffer-toggle "roam toggle")
(my/bind-leader "n f" 'org-roam-node-find "find node")
(my/bind-leader "n i" 'org-roam-node-insert "insert node")
(my/bind-leader "n d t" 'org-roam-dailies-capture-today "capture today")

;; --- Open (o) ---
(my/bind-leader "o p" 'popper-toggle "toggle popup")
(my/bind-leader "o t h" 'my/open-terminal-here "here")
(my/bind-leader "o t p" 'my/open-terminal-in-project "project")

;; --- Project (p) ---
(my/bind-leader "p p" 'project-switch-project "switch project")
(my/bind-leader "p b" 'project-switch-to-buffer "switch buffer")
(my/bind-leader "p f" 'project-find-file "find file")
(my/bind-leader "p r" 'my/project-recent-files "recent files")
(my/bind-leader "p c" 'my/project-compile "compile")
(my/bind-leader "p t" 'my/project-test "run tests")
(my/bind-leader "p x" 'my/project-run "run project")
(my/bind-leader "p k" 'project-kill-buffers "kill buffers")
(my/bind-leader "p d" 'project-dired "dired")
(my/bind-leader "p v" 'project-vc-dir "vc dir")
(my/bind-leader "p s" 'project-search "search (native)")
(my/bind-leader "p /" 'consult-ripgrep "search (ripgrep)")
(my/bind-leader "p !" 'project-shell-command "shell command")
(my/bind-leader "p &" 'project-async-shell-command "async shell command")
(my/bind-leader "p R" 'project-query-replace-regexp "query replace")
(my/bind-leader "p w" 'my/project-workspace-switch "switch workspace")
(my/bind-leader "p m" 'my/project-dispatch "project palette")
(my/bind-leader "p B" 'my/benchmark-current-project "benchmark project")

;; --- Search (s) ---
(my/bind-leader "s s" 'consult-line "search buffer")
(my/bind-leader "s S" 'consult-line-multi "search all buffers")
(my/bind-leader "s g" 'consult-goto-line "goto line")
(my/bind-leader "s i" 'consult-imenu "jump to symbol")
(my/bind-leader "s h" 'consult-outline "jump to heading")
(my/bind-leader "s f" 'consult-find "find file (live)")
(my/bind-leader "s k" 'consult-yank-pop "yank pop")

;; --- Undo (u) ---
(my/bind-leader "u" 'vundo "undo tree (visual)")

;; --- Window (w) ---
(my/bind-leader "w h"  'evil-window-left "left")
(my/bind-leader "w j"  'evil-window-down "down")
(my/bind-leader "w k"  'evil-window-up "up")
(my/bind-leader "w l"  'evil-window-right "right")
(my/bind-leader "w w"  'evil-window-next "next window")
(my/bind-leader "w H"  'evil-window-move-far-left "move left")
(my/bind-leader "w J"  'evil-window-move-very-bottom "move down")
(my/bind-leader "w K"  'evil-window-move-very-top "move up")
(my/bind-leader "w L"  'evil-window-move-far-right "move right")
(my/bind-leader "w s"  'evil-window-split "split horizontal")
(my/bind-leader "w v"  'evil-window-vsplit "split vertical")
(my/bind-leader "w c"  'evil-window-delete "close window")
(my/bind-leader "w o"  'delete-other-windows "close others")
(my/bind-leader "w ="  'balance-windows "balance")

;; --- Workspace (W) ---
(my/bind-leader "W s" 'persp-switch "switch workspace")
(my/bind-leader "W n" 'persp-switch "new/switch")
(my/bind-leader "W k" 'persp-kill "kill workspace")
(my/bind-leader "W r" 'persp-rename "rename workspace")

;; --- AI Assistant (a) ---
(my/bind-leader "a g" 'agent-shell-google-start-gemini "Gemini CLI")
(my/bind-leader "a o" 'agent-shell-opencode-start-agent "Opencode")
(my/bind-leader "a s" 'agent-shell "Agent Shell Menu")
(my/bind-leader "a q" 'gptel-send "Gptel Send")

;; --- Other ---
(my/bind-leader ";"   'embark-act "act (embark)")
(my/bind-leader "A"   'embark-act "actions (embark)")
