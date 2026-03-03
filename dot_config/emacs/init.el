;;; init.el --- Bootstrap for Literate Config -*- lexical-binding: t; byte-compile-warnings: (not free-vars unresolved); -*-

;; 1. Performance tuning for startup
(setq gc-cons-threshold (* 50 1000 1000))
(setq read-process-output-max (* 1024 1024))
(setq jit-lock-defer-time 0.05)

;; 2. Directory Structure Setup (Doom Style)
(defconst my-local-dir (expand-file-name ".local/" user-emacs-directory))
(defconst my-local-pkg-dir (expand-file-name "packages/" my-local-dir))

;; 3. Elpaca Bootstrap (Official Installer v0.11 Adapted)
(defvar elpaca-installer-version 0.11)
;; ADAPTATION: Using custom directory here
(defvar elpaca-directory (expand-file-name "elpaca/" my-local-pkg-dir))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))

(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))

(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))

(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; 4. Use-package Integration
;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
  (setq use-package-always-ensure t))

;; 5.Install Org-mode BEFORE loading configuration
;; This prevents "Org version mismatch" by ensuring org-babel
;; uses Elpaca version, not built-in Emacs version.
(elpaca org
  (require 'org))

;; --- CORE PACKAGES (init.el) ---

;; 1. Diminish
(use-package diminish :ensure t :demand t)

;; 2. Transient (Magit dependency)
(use-package transient :ensure t :demand t)

;; 3. Undo System (Must load before or with Evil)
(use-package undo-fu
  :ensure t
  :demand t
  :config
  ;; Increase memory limits to prevent Emacs from aggressively deleting old history
  ;; (Values copied from Doom Emacs)
  (setq undo-limit 6710886400 ;; 64mb
        undo-strong-limit 100663296 ;; 96mb
        undo-outer-limit 1006632960) ;; 960mb
  )

;; 4. Evil Mode (Your migrated configuration)
(use-package evil
  :ensure t
  :demand t
  :init
  ;; Essential pre-loading settings
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil) ;; Required for evil-collection
  (setq evil-want-C-u-scroll t)
  (setq evil-undo-system 'undo-fu)
  :config
  (evil-mode 1)

  ;; Cores do Cursor
  (setq evil-emacs-state-cursor    '("#649bce" box)
        evil-normal-state-cursor   '("#ebcb8b" box)
        evil-visual-state-cursor   '("#676f7d" box)
        evil-insert-state-cursor   '("#ebcb8b" bar)
        evil-replace-state-cursor  '("#ebcb8b" hbar)
        evil-operator-state-cursor '("#ebcb8b" hollow))
  )

;; --- FIM CORE ---

;; 5. Wait for Elpaca to be ready (Critical for config.org)
(elpaca-wait)

;; 6. Load Literate Configuration
(org-babel-load-file (expand-file-name "config.org" user-emacs-directory))

(elpaca-wait)

;; 7. Post-startup GC
(setq gc-cons-threshold (* 16 1024 1024))
(add-function :after after-focus-change-function
              (lambda ()
                (unless (frame-focus-state)
                  (garbage-collect))))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(safe-local-variable-values
   '((eval setq-local lsp-java-java-path
           (string-trim (shell-command-to-string "mise which java"))))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
