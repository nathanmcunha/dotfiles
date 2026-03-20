{ ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      format = "[](#eee8d5)$os$username[](bg:#b58900 fg:#eee8d5)$directory[](fg:#b58900 bg:#eee8d5)$git_branch$git_status[](fg:#eee8d5 bg:#d6d6d6)$nodejs$rust$golang$php[](fg:#d6d6d6)\n$character";

      palette = "solarized";

      palettes.solarized = {
        base03  = "#002b36";
        base02  = "#073642";
        base01  = "#586e75";
        base00  = "#657b83";
        base0   = "#839496";
        base1   = "#93a1a1";
        base2   = "#eee8d5";
        base3   = "#fdf6e3";
        yellow  = "#b58900";
        orange  = "#cb4b16";
        red     = "#dc322f";
        magenta = "#d33682";
        violet  = "#6c71c4";
        blue    = "#268bd2";
        cyan    = "#2aa198";
        green   = "#859900";
        grey_bg = "#d6d6d6";
      };

      username = {
        show_always = true;
        style_user = "bg:#eee8d5 fg:#586e75";
        style_root = "bg:#eee8d5 fg:#dc322f";
        format = "[$user ]($style)";
      };

      directory = {
        style = "bg:#b58900 fg:#fdf6e3";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        substitutions = {
          "Documents" = " ";
          "Downloads" = " ";
          "Music"     = " ";
          "Pictures"  = " ";
        };
      };

      git_branch = {
        symbol = "";
        style  = "bg:#eee8d5";
        format = "[[ $symbol $branch ](fg:#2aa198 bg:#eee8d5)]($style)";
      };

      git_status = {
        style  = "bg:#eee8d5";
        format = "[[($all_status$ahead_behind )](fg:#dc322f bg:#eee8d5)]($style)";
      };

      nodejs = {
        symbol = "";
        style  = "bg:#d6d6d6";
        format = "[[ $symbol ($version) ](fg:#859900 bg:#d6d6d6)]($style)";
      };

      rust = {
        symbol = "";
        style  = "bg:#d6d6d6";
        format = "[[ $symbol ($version) ](fg:#dc322f bg:#d6d6d6)]($style)";
      };

      golang = {
        symbol = "";
        style  = "bg:#d6d6d6";
        format = "[[ $symbol ($version) ](fg:#268bd2 bg:#d6d6d6)]($style)";
      };

      php = {
        symbol = "";
        style  = "bg:#d6d6d6";
        format = "[[ $symbol ($version) ](fg:#6c71c4 bg:#d6d6d6)]($style)";
      };

      character = {
        success_symbol = "[➜](bold #859900)";
        error_symbol   = "[➜](bold #dc322f)";
      };
    };
  };
}
