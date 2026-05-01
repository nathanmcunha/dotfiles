{
  pkgs,
  inputs,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default

    # dependencies required by noctalia plugins and features
    gpu-screen-recorder
    grim
    slurp
    wl-clipboard
    (tesseract.override {
      enableLanguages = [ "eng" ];
    })
    imagemagick
    zbar
    curl
    translate-shell
    wf-recorder
    ffmpeg
    gifski
    wl-mirror
  ];

  home.file = {
    ".config/noctalia/settings.json".source = ../files/noctalia/settings.json;
    ".config/noctalia/plugins.json".source = ../files/noctalia/plugins.json;
    ".config/noctalia/hooks/theme-sync.sh" = {
      source = ../files/noctalia/hooks/theme-sync.sh;
      executable = true;
    };
  };
}
