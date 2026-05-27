{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    lexend
    atkinson-hyperlegible-mono
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.symbols-only
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [
      "Atkinson Hyperlegible Mono"
      "JetBrainsMono Nerd Font"
    ];
    sansSerif = [
      "Lexend"
      "Noto Sans"
    ];
    serif = [ "Noto Serif" ];
    emoji = [ "Noto Color Emoji" ];
  };
}
