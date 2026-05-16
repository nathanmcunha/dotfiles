(load-file "@emacsConfigPath@/early-init.el")

;; Make Nix-provided tree-sitter grammars available at startup so Emacs
;; doesn't try to compile/install them at runtime.
(setq treesit-extra-load-path
      (append (list "@treesitGrammarsPath@")
              (when (boundp 'treesit-extra-load-path) treesit-extra-load-path)))

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
