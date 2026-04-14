{ ... }:

{
  home.shellAliases = {
    # Modern replacements
    ls = "eza --icons=always --color=always";
    ll = "eza -al --icons=always --color=always --git";
    cat = "bat --style=plain --paging=never";

    # Nix/Home Manager
    update-externals = "bash ~/dotfiles/files/scripts/update-externals.sh";
    nix-update = "nix flake update ~/dotfiles && update-externals check && sudo nixos-rebuild switch --flake ~/dotfiles#nathanmcunha-nixos";

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

    # Suffix aliases: Open files by extension
    "pdf" = "xdg-open";
    "PDF" = "xdg-open";
    "png" = "xdg-open";
    "jpg" = "xdg-open";
    "jpeg" = "xdg-open";
    "gif" = "xdg-open";
    "svg" = "xdg-open";
    "PNG" = "xdg-open";
    "JPG" = "xdg-open";
    "JPEG" = "xdg-open";
    "GIF" = "xdg-open";
    "SVG" = "xdg-open";
    "mp4" = "xdg-open";
    "mkv" = "xdg-open";
    "mov" = "xdg-open";
    "avi" = "xdg-open";
    "webm" = "xdg-open";
    "MP4" = "xdg-open";
    "MKV" = "xdg-open";
    "MOV" = "xdg-open";
    "AVI" = "xdg-open";
    "WEBM" = "xdg-open";
    "mp3" = "xdg-open";
    "flac" = "xdg-open";
    "wav" = "xdg-open";
    "ogg" = "xdg-open";
    "MP3" = "xdg-open";
    "FLAC" = "xdg-open";
    "WAV" = "xdg-open";
    "OGG" = "xdg-open";
    "html" = "xdg-open";
    "htm" = "xdg-open";
    "HTML" = "xdg-open";
    "HTM" = "xdg-open";

  };
}
