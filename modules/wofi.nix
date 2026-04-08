{ lib, ... }:

{
  home.file.".config/wofi" = {
    source = ../files/wofi;
    recursive = true;
    force = true;
  };
}