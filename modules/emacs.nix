{
  lib,
  pkgs,
  emacs-config,
  ...
}:

let
  myEmacs = pkgs.emacsWithPackagesFromUsePackage {
    config = emacs-config + "/config.org";
    defaultInitFile = emacs-config + "/init.el";
    package = pkgs.emacs-unstable-pgtk.override {
      withTreeSitter = true;
      withSQLite3 = true;
      withWebP = true;
    };
    alwaysEnsure = true;
    alwaysTangle = true;
    extraEmacsPackages = epkgs: [
      epkgs.diminish # implicit dep via :diminish keyword
      epkgs.jinx     # :tangle no block, parser can't see it
    ];
  };
in

{
  programs.emacs = {
    enable = true;
    package = myEmacs;
  };

  services.emacs = {
    enable = true;
    startWithUserSession = true;
  };

  systemd.user.services.emacs = {
    Service = {
      Environment = [
        "LD_LIBRARY_PATH=${pkgs.enchant_2}/lib"
      ];
      PassEnvironment = "WAYLAND_DISPLAY DISPLAY XDG_RUNTIME_DIR";
    };
  };

  xdg.configFile = {
    "emacs/init.el".source = emacs-config + "/init.el";
    "emacs/early-init.el".source = emacs-config + "/early-init.el";
  };

  home.packages = with pkgs; [
    # Runtimes
    go
    gradle
    temurin-bin-21
    maven
    nodejs_24
    python312
    gnumake

    # Python tools
    basedpyright
    ruff

    # Node tools
    prettier
    typescript-language-server

    # Rust
    rustup

    # LSP servers
    sqls
    yaml-language-server
    vscode-langservers-extracted
    dockerfile-language-server
    nixd
    qt6.qtbase.dev

    # Required by jinx (runtime library)
    enchant_2
  ];
}
