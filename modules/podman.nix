{ pkgs, ... }:

{
  # Rootless podman configuration
  home.file.".config/containers/registries.conf".text = ''
    [registries.search]
    registries = ["docker.io", "quay.io", "ghcr.io"]

    [registries.insecure]
    registries = []

    [registries.block]
    registries = []
  '';

  home.file.".config/containers/policy.json".text = ''
    {
      "default": [{"type": "insecureAcceptAnything"}]
    }
  '';

  # Useful aliases
  home.shellAliases = {
    # Podman as docker drop-in
    docker          = "podman";
    docker-compose  = "podman-compose";

    # Shortcuts
    p    = "podman";
    pc   = "podman-compose";
    pps  = "podman ps";
    ppa  = "podman ps -a";
    pimg = "podman images";
    plog = "podman logs -f";
    pex  = "podman exec -it";
    prm  = "podman rm";
    prmi = "podman rmi";
    pstop = "podman stop";
    ppull = "podman pull";
  };
}