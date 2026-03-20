{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    extraPackages = epkgs: [ epkgs.jinx ]; # Nix compiles jinx correctly
  };

  services.emacs = {
    enable = true;
    startWithUserSession = true;
  };

  # Tell the emacs service where to find Nix enchant library
  systemd.user.services.emacs.Service.Environment = [
    "LD_LIBRARY_PATH=${pkgs.enchant_2}/lib"
    "PKG_CONFIG_PATH=${pkgs.enchant_2}/lib/pkgconfig"
  ];

  home.packages = with pkgs; [
    # Runtimes (replacing mise)
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
    nodePackages.prettier
    nodePackages.typescript-language-server

    # Rust
    rustup

    # SQL LSP
    sqls

    # Required by jinx (spell checker)
    enchant_2
  ];

  home.shellAliases = {
    e   = "emacsclient -n .";
    ec  = "emacsclient -c -a ''";
    et  = "emacsclient -t";
    edk = "emacsclient -e '(kill-emacs)'";
  };
}
