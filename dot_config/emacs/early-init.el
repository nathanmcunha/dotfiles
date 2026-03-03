;; early-init.el -*- lexical-binding: t; -*-

;; Disable package loading at startup for faster boot
(setq package-enable-at-startup nil)
(setq inhibit-startup-message t)

;; --- Native Compilation Optimizations ---
;; Modern native compilation variables (Emacs 29+)
(eval-when-compile
  (defvar native-comp-jit-compilation)
  (defvar native-comp-async-jobs-number)
  (defvar native-comp-speed))

(setq native-comp-jit-compilation t)
(setq native-comp-async-jobs-number 4)
(setq native-comp-speed 3)
