{ lib, ... }:

{
  home.file.".config/dunst" = {
    source = ../files/dunst;
    recursive = true;
    force = true;
  };
}
