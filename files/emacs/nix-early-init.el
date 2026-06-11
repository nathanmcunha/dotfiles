;;; nix-early-init.el --- Nix Pre-flight Setup -*- lexical-binding: t -*-

(require 'cl-lib)

;; Disable package loading at startup for faster boot
(setq package-enable-at-startup nil)
(setq inhibit-startup-message t)

;; --- Native Compilation Optimizations ---
(eval-when-compile
  (defvar native-comp-jit-compilation)
  (defvar native-comp-async-jobs-number)
  (defvar native-comp-speed))

(setq native-comp-jit-compilation t)
(setq native-comp-async-jobs-number 4)
(setq native-comp-speed 3)

;; Make Nix-provided tree-sitter grammars available at startup so Emacs
;; doesn't try to compile/install them at runtime.
(setq treesit-extra-load-path
      (append (list "@treesitGrammars@")
              (when (boundp 'treesit-extra-load-path) treesit-extra-load-path)))
(add-to-list 'custom-theme-load-path
             (expand-file-name "emacs/themes/"
                               (or (getenv "XDG_CONFIG_HOME")
                                   (expand-file-name "~/.config"))))

;; Keep startup-sensitive caches in XDG cache instead of the config tree.
(let ((eln-cache (expand-file-name "emacs/eln-cache/"
                                   (or (getenv "XDG_CACHE_HOME")
                                       (expand-file-name "~/.cache")))))
  (setq native-comp-eln-load-path
        (cons eln-cache
              (if (boundp 'native-comp-eln-load-path)
                  native-comp-eln-load-path
                nil))))

;; Common startup tuning used by the community for large Emacs configs.
(setq gc-cons-threshold (* 128 1024 1024))
(setq gc-cons-percentage 0.6)
(setq read-process-output-max (* 4 1024 1024))
(setq process-adaptive-read-buffering nil)

;; UI PGTK/WAYLAND optimizations
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(setq-default frame-background-mode 'dark)
;; Force X11 backend to avoid PGTK/GTK3 display disconnection crashes
;; on Wayland.  PGTK Emacs on GTK3 cannot survive display disconnects
;; (e.g. plugging/unplugging monitors, sleep).
;; Also set GDK_BACKEND=x11 in emacs.nix systemd service Environment
;; so the running Emacs process itself uses X11.
(setenv "GDK_BACKEND" "x11")

;; Safe local variable values — avoid repeated prompts in project repos
(add-to-list 'safe-local-eval-forms
             '(setq-local compile-command
                (concat "g++ -std=c++23 -Wall -Wextra -O2 -o "
                 (file-name-sans-extension (file-name-nondirectory buffer-file-name))
                 " "
                 (shell-quote-argument buffer-file-name))))