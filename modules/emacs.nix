{
  lib,
  pkgs,
  inputs,
  ...
}:

let
  emacs-config = inputs.emacs-config;
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

  services.emacs = {
    enable = true;
    # Do NOT use startWithUserSession here; we define the full service below
    # to avoid attribute merging ambiguities.
    startWithUserSession = false;
  };

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
    # Runtimes (go, gradle, temurin-bin-21, maven, nodejs_24, python312 already in packages.nix)
    gnumake

    # Python tools
    basedpyright
    ruff

    # Node tools
    prettier
    typescript-language-server

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
