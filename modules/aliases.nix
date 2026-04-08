{ ... }:

{
  home.shellAliases = {
    # Modern replacements
    ls = "eza --icons=always --color=always";
    ll = "eza -al --icons=always --color=always --git";
    cat = "bat --style=plain --paging=never";

    # Nix/Home Manager
    update-externals = "bash ~/.config/home-manager/files/scripts/update-externals.sh";
    nix-update = "nix flake update ~/.config/home-manager && update-externals check && home-manager switch --flake ~/.config/home-manager#nathanmcunha";

    # Containers (Podman as Docker drop-in)
    docker = "podman";
    docker-compose = "podman-compose";
    p = "podman";
    pc = "podman-compose";
    pps = "podman ps";
    ppa = "podman ps -a";
    pimg = "podman images";
    plog = "podman logs -f";
    pex = "podman exec -it";
    prm = "podman rm";
    prmi = "podman rmi";
    pstop = "podman stop";
    ppull = "podman pull";

    # Quick open
    o = "xdg-open";
  };
}
