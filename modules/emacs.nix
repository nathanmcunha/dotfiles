{
  lib,
  pkgs,
  inputs,
  ...
}:

let
  emacs-config = inputs.emacs-config;

  # Tree-sitter grammars from Nix (avoids manual compilation at runtime)
  grammarNames = [
    "bash"
    "c"
    "cpp"
    "css"
    "dockerfile"
    "html"
    "go"
    "java"
    "javascript"
    "json"
    "json5"
    "lua"
    "make"
    "markdown"
    "nix"
    "org"
    "php"
    "python"
    "ruby"
    "rust"
    "sql"
    "sshclientconfig"
    "textproto"
    "toml"
    "tsx"
    "typescript"
    "yaml"
  ];
  treesit-grammars = pkgs.linkFarm "emacs-treesit-grammars"
    (lib.filter (g: g != null)
      (map (name:
        let grammar = pkgs.tree-sitter.builtGrammars."tree-sitter-${name}" or null;
        in if grammar != null then {
          name = "libtree-sitter-${name}.so";
          path = "${grammar}/parser";
        } else null
      ) grammarNames));

  # Tools Emacs shells out to — only in daemon PATH, not your shell
  emacs-only-tools = with pkgs; [
    coreutils
    gnugrep
    gnused
    findutils
    gawk
    file
    unzip
    zip
    gnutar
    gzip
    diffutils
    patch
    tree-sitter
    ispell
    qt6.qtbase
  ];

  # Tools you also want available in your terminal
  emacs-shared-tools = with pkgs; [
    ripgrep
    fd
    git
    zsh
    alacritty
    opencode
  ];

  # LSP servers — only in emacs daemon PATH, not your shell
  emacs-lsp-servers = with pkgs; [
    basedpyright
    ruff
    prettier
    typescript-language-server
    sqls
    yaml-language-server
    vscode-langservers-extracted
    dockerfile-language-server
    nixd
    clang-tools
  ];

  myEmacs = pkgs.emacsWithPackagesFromUsePackage {
    config = emacs-config + "/config.org";
    defaultInitFile = false;
    package = pkgs.emacs-unstable-pgtk.override {
      withTreeSitter = true;
      withSQLite3 = true;
      withWebP = true;
    };
    alwaysEnsure = true;
    alwaysTangle = true;
    extraEmacsPackages = epkgs: [
      epkgs.diminish # implicit dep via :diminish keyword
      epkgs.jinx # :tangle no block, parser can't see it
      epkgs.gcmh
      epkgs.org-appear
      epkgs.valign
      epkgs.popper
    ];
  };

  emacsInit = pkgs.writeText "emacs-init.el" ''
    (require 'cl-lib)

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
      (load-file "${emacs-config}/init.el"))
  '';

  emacsEarlyInit = pkgs.writeText "emacs-early-init.el" ''
    (load-file "${emacs-config}/early-init.el")

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
  '';
in

{
  programs.emacs = {
    enable = true;
    package = myEmacs;
  };

  # Custom systemd service — NOT using HM's services.emacs to avoid ExecStart conflicts
  systemd.user.services.emacs = {
    Unit = {
      Description = "Emacs: the extensible, self-documenting text editor";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "forking";
      ExecStart = "${myEmacs}/bin/emacs --daemon";
      ExecStop = "${myEmacs}/bin/emacsclient --eval '(kill-emacs)'";
      Restart = "on-failure";
      Environment = [
        "LD_LIBRARY_PATH=${pkgs.enchant_2}/lib"
        "PATH=/run/current-system/sw/bin:${lib.concatMapStringsSep ":" (p: "${p}/bin") (emacs-only-tools ++ emacs-shared-tools ++ emacs-lsp-servers)}"
      ];
      PassEnvironment = "WAYLAND_DISPLAY DISPLAY XDG_RUNTIME_DIR";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # xdg.configFile = {
  #   "emacs/init.el".source = emacsInit;
  #   "emacs/early-init.el".source = emacsEarlyInit;
  # };

  # Create a writable custom.el so Emacs can persist safe-local-eval forms
  # and load Nix-managed tree-sitter grammars.  We use activation instead of
  # xdg.configFile so the file stays mutable (Emacs replaces symlinks on save,
  # but write-region on a store symlink fails, so we start with a real file).
  home.activation.createEmacsCustom = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    customFile="$HOME/.config/emacs/custom.el"
    if [ ! -f "$customFile" ]; then
      cat > "$customFile" <<'EOF'
;;; custom.el --- Local customizations -*- lexical-binding: t -*-
;; This file is writable — Emacs saves safe-local-variable values here.

;; Nix-managed tree-sitter grammars (C/C++ and others missing from manual install)
(setq treesit-extra-load-path
      (append (list "${treesit-grammars}")
              (when (boundp 'treesit-extra-load-path)
                treesit-extra-load-path)))

;; Mark C++ compile-command eval in .dir-locals.el as safe
(add-to-list 'safe-local-eval-forms
             '(setq-local compile-command
                (concat "g++ -std=c++23 -Wall -Wextra -O2 -o "
                 (file-name-sans-extension (file-name-nondirectory buffer-file-name))
                 " "
                 (shell-quote-argument buffer-file-name))))

;; Match the Noctalia-generated terminal palette.
(load-theme 'modus-operandi t)

(provide 'custom)
;;; custom.el ends here
EOF
    fi
  '';

  home.packages = with pkgs; [
    # CLI tools Emacs needs (also available in your shell)
  ] ++ emacs-shared-tools ++ [
    # Runtimes (go, gradle, temurin-bin-21, maven, nodejs_24, python312 already in packages.nix)
    gnumake

    # Qt runtime (qmlls for QML LSP)
    # qt6.qtbase moved to emacs-only-tools

    # Required by jinx (runtime library)
    enchant_2
  ];
}
