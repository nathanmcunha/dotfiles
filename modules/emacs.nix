{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
  };

  services.emacs = {
    enable = true;
    startWithUserSession = true;
  };
  systemd.user.services.emacs = {
    Service = {
      Environment = [
        "LD_LIBRARY_PATH=${pkgs.enchant_2}/lib"
        "PKG_CONFIG_PATH=${pkgs.enchant_2}/lib/pkgconfig"
      ];
      PassEnvironment = "WAYLAND_DISPLAY DISPLAY XDG_RUNTIME_DIR";
    };
  };

  home.packages = with pkgs; [
    # Runtimes
    go
    gradle
    temurin-bin-21
    maven
    nodejs_24
    python312

    # Python tools
    basedpyright
    ruff

    # Node tools
    prettier
    typescript-language-server

    # Rust
    rustup

    # LSP servers
    sqls # SQL
    yaml-language-server # YAML
    vscode-langservers-extracted # HTML + CSS + JSON
    dockerfile-language-server # Dockerfile
    nixd
    qt6.qtbase.dev
    # Required by jinx
    enchant_2
  ];
}
