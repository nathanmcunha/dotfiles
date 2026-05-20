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

;; Load the local bootstrap directly (bypasses broken external wrappers).
(cl-letf (((symbol-function 'package-install) (lambda (&rest _args) nil))
          ((symbol-function 'package-vc-install) (lambda (&rest _args) nil))
          ((symbol-function 'package-vc-install-from-checkout) (lambda (&rest _args) nil))
          ((symbol-function 'package-vc-install-selected-packages) (lambda (&rest _args) nil)))
  (load-file "@localBootstrapInit@"))

;; Ensure runtime PATH stays available even if imported config changes PATH.
(add-hook 'after-init-hook #'nm/apply-emacs-runtime-path)