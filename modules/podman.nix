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
      "default": [{"type": "reject"}],
      "transports": {
        "docker": {
          "": [{"type": "insecureAcceptAnything"}]
        },
        "docker-daemon": {
          "": [{"type": "insecureAcceptAnything"}]
        }
      }
    }
  '';

  # Podman API socket for docker-compose compatibility
  systemd.user.services.podman = {
    Unit = {
      Description = "Podman API Service";
      Documentation = [ "man:podman-system-service(1)" ];
    };
    Service = {
      RuntimeDirectory = "podman";
      ExecStart = "${pkgs.podman}/bin/podman system service --time=0 unix://%t/podman/podman.sock";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
