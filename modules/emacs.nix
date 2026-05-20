{
  config,
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
    qt6.qtdeclarative
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

  # Runtime PATH injected into Emacs (contains nixd and other LSP servers)
  emacsRuntimePath = lib.makeBinPath (emacs-only-tools ++ emacs-lsp-servers);

  # Local bootstrap files (copied from external config to avoid broken wrappers)
  localBootstrapInit = "${config.home.homeDirectory}/.config/emacs/bootstrap-init.el";
  localBootstrapEarlyInit = "${config.home.homeDirectory}/.config/emacs/bootstrap-early-init.el";

  # Helper to read file and substitute variables
  substituteFile = file: replacements:
    builtins.replaceStrings
      (lib.mapAttrsToList (k: _: "@${k}@") replacements)
      (lib.mapAttrsToList (_: v: v) replacements)
      (builtins.readFile file);

  nix-init-content = substituteFile ../files/emacs/nix-init.el {
    inherit emacsRuntimePath localBootstrapInit;
  };

  nix-early-init-content = substituteFile ../files/emacs/nix-early-init.el {
    localBootstrapEarlyInit = localBootstrapEarlyInit;
    treesitGrammars = "${treesit-grammars}";
  };

  custom-el-content = substituteFile ../files/emacs/custom.el {};
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
    "emacs/init.el".text = nix-init-content;
    "emacs/init.el".force = true;

    "emacs/early-init.el".text = nix-early-init-content;
    "emacs/early-init.el".force = true;
  };

  # Create a writable custom.el so Emacs can persist safe-local-eval forms.
  # We use activation instead of xdg.configFile so the file stays mutable
  # (Emacs replaces symlinks on save, but write-region on a store symlink fails).
  home.activation.createEmacsCustom = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    customFile="$HOME/.config/emacs/custom.el"
    if [ ! -f "$customFile" ]; then
      cat > "$customFile" <<'CUSTOM_EOF'
${custom-el-content}
CUSTOM_EOF
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