;;; nix-init.el --- Nix Environment Injector -*- lexical-binding: t -*-

(require 'cl-lib)

;; Make Nix-managed tools (including LSP servers) available inside Emacs
;; regardless of daemon/non-daemon startup, without exposing them globally.
(defun nm/apply-emacs-runtime-path ()
  "Inject Nix-provided tools into Emacs PATH and exec-path."
  (let ((emacs-runtime-path "@emacsRuntimePath@"))
    (setenv "PATH" (concat emacs-runtime-path path-separator (or (getenv "PATH") "")))
    (dolist (p (reverse (split-string emacs-runtime-path path-separator t)))
      (add-to-list 'exec-path p))))

;; Apply immediately for daemon mode
(nm/apply-emacs-runtime-path)

;; Ensure runtime PATH stays available even if imported config changes PATH.
(add-hook 'after-init-hook #'nm/apply-emacs-runtime-path)