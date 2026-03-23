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
    nodePackages.prettier
    nodePackages.typescript-language-server

    # Rust
    rustup

    # LSP servers
    sqls                                          # SQL
    yaml-language-server                          # YAML
    nodePackages.vscode-langservers-extracted     # HTML + CSS + JSON
    nodePackages.dockerfile-language-server-nodejs # Dockerfile

    # Required by jinx
    enchant_2
  ];
programs.zsh.initContent= ''
  e()   { emacsclient -c "$@" }
  ec()  { emacsclient -cn "$@" }
  et()  { emacsclient -t "$@"}
  edk() { emacsclient -e '(kill-emacs)' }
  er()  { edk && sleep 2 && ec }
'';
}
