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

  # LSP servers available to Emacs runtime only (not exposed in shell PATH)
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
      withNativeCompilation = true;
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

  emacsInit = pkgs.replaceVars ../files/emacs/emacs-init.el {
    emacsRuntimePath = lib.makeBinPath (emacs-only-tools ++ emacs-lsp-servers);
    emacsConfigPath = emacs-config;
  };

  emacsEarlyInit = pkgs.replaceVars ../files/emacs/emacs-early-init.el {
    emacsConfigPath = emacs-config;
    treesitGrammarsPath = treesit-grammars;
  };
in

{
  programs.emacs = {
    enable = true;
    package = myEmacs;
  };

  services.emacs = {
    enable = true;
    package = myEmacs;
    startWithUserSession = "graphical";
  };

  # Keep daemon runtime dependencies explicit and isolated from shell config.
  systemd.user.services.emacs.Service = {
    Environment = [
      "LD_LIBRARY_PATH=${pkgs.enchant_2}/lib"
      "PATH=%h/.nix-profile/bin:/etc/profiles/per-user/%u/bin:/run/current-system/sw/bin:${lib.concatMapStringsSep ":" (p: "${p}/bin") (emacs-only-tools ++ emacs-lsp-servers)}"
    ];
    PassEnvironment = "WAYLAND_DISPLAY DISPLAY XDG_RUNTIME_DIR";
  };

  xdg.configFile = {
    "emacs/init.el".source = emacsInit;
    "emacs/init.el".force = true;
    "emacs/early-init.el".source = emacsEarlyInit;
    "emacs/early-init.el".force = true;
  };

  # Create a writable custom.el so Emacs can persist safe-local-eval forms.
  # We use activation instead of
  # xdg.configFile so the file stays mutable (Emacs replaces symlinks on save,
  # but write-region on a store symlink fails, so we start with a real file).
  home.activation.createEmacsCustom = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    customFile="$HOME/.config/emacs/custom.el"
    if [ ! -f "$customFile" ]; then
      cat > "$customFile" <<'EOF'
;;; custom.el --- Local customizations -*- lexical-binding: t -*-
;; This file is writable — Emacs saves safe-local-variable values here.

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
  ] ++ [
    # Runtimes (go, gradle, temurin-bin-21, maven, nodejs_24, python312 already in packages.nix)
    gnumake

    # Qt runtime (qmlls for QML LSP)
    # qt6.qtbase moved to emacs-only-tools

    # Required by jinx (runtime library)
    enchant_2
  ];
}
