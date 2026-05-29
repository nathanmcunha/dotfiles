{
  pkgs,
  inputs,
  ...
}:
{

  home.packages = with pkgs; [
    # CLI essentials
    bat
    tree
    eza
    ripgrep
    fd
    jq
    pass
    rtk

    # Dev tools
    neovim
    gcc
    cmake
    gnupg
    go
    temurin-bin-21
    nodejs_24
    python312
    rustup

    # Nix tools
    nixfmt
    nix-tree

    # Container & K8s
    podman
    podman-compose
    kubectl
    kubernetes-helm
    k9s
    kubectx
    kind

    # AI CLIs
    pi-coding-agent
    opencode
    (pkgs.callPackage ../derivations/antigravity-cli.nix { })
    google-java-format

    # System
    fastfetch

    (bun.overrideAttrs (old: {
      version = "1.3.14";
      src = pkgs.fetchurl {
        url = "https://github.com/oven-sh/bun/releases/download/bun-v1.3.14/bun-linux-x64.zip";
        hash = "sha256-lR7iruhV8IWVruxiJSJqKY0/6oOj3NZGXAnLzN9+hI8=";
      };
    }))
    wireshark
    (writeShellScriptBin "omp" ''
      exec ${bun}/bin/bunx @oh-my-pi/pi-coding-agent "$@"
    '')
  ];
}
