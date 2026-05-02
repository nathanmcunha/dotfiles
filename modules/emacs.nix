{
  lib,
  pkgs,
  inputs,
  ...
}:

let
  emacs-config = inputs.emacs-config;

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
    ];
  };
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

  xdg.configFile = {
    "emacs/init.el".source = emacs-config + "/init.el";
    "emacs/early-init.el".source = emacs-config + "/early-init.el";
  };

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
