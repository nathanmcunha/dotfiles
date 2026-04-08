{ ... }:

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
}
