(require 'cl-lib)

;; Make Nix-managed tools (including LSP servers) available inside Emacs
;; regardless of daemon/non-daemon startup, without exposing them globally.
(let ((emacs-runtime-path "@emacsRuntimePath@"))
  (setenv "PATH" (concat emacs-runtime-path path-separator (or (getenv "PATH") "")))
  (dolist (p (reverse (split-string emacs-runtime-path path-separator t)))
    (add-to-list 'exec-path p)))

;; Load the imported init file, but suppress package-manager installs so
;; Nix-provided packages never trigger Elpaca/package-vc prompts.
(cl-letf (((symbol-function 'package-install)
           (lambda (&rest _args) nil))
          ((symbol-function 'package-vc-install)
           (lambda (&rest _args) nil))
          ((symbol-function 'package-vc-install-from-checkout)
           (lambda (&rest _args) nil))
          ((symbol-function 'package-vc-install-selected-packages)
           (lambda (&rest _args) nil)))
  (load-file "@emacsConfigPath@/init.el"))
