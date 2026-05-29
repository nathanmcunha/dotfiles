{
  pkgs,
  lib,
  ...
}:

let
  gtkTheme = {
    name = "adw-gtk3";
    package = pkgs.adw-gtk3;
  };
in
{
  home.username = "nathanmcunha";
  home.homeDirectory = "/home/nathanmcunha";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableZshIntegration = true;
    pinentry.package = pkgs.pinentry-curses;
    defaultCacheTtl = 28800;
    maxCacheTtl = 28800;
  };

  gtk = {
    enable = true;
    theme = gtkTheme;
    gtk4.theme = gtkTheme;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };
  };

  home.activation.installIcons = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.icons/default"
    printf '[Icon Theme]\nName=Default\nInherits=Bibata-Modern-Classic\n' > "$HOME/.icons/default/index.theme"
  '';

  xdg.configFile = {
    "gtk-3.0/settings.ini".force = true;
    "gtk-4.0/settings.ini".force = true;
    "gtk-4.0/gtk.css".force = true;
  };

  # Pi coding agent configuration
  # Multiple providers can be configured. Set API keys via:
  #   1. Environment variables (e.g., ANTHROPIC_API_KEY, OPENAI_API_KEY)
  #   2. /login command in interactive mode (stores in auth.json)
  #   3. Manually editing ~/.pi/agent/auth.json
  #
  # Switch between configured providers with /model in interactive mode,
  # or --provider/--model CLI flags.
  programs.pi = {
    enable = true;

    # Default provider/model when starting pi without flags
    defaultProvider = "kimi-coding";
    defaultModel = "kimi-for-coding";

    # API key providers. Values use pi's key resolution:
    #   "!pass show ..."  -> shell command (recommended, secrets stay in pass)
    #   "ENV_VAR_NAME"    -> environment variable
    #   "sk-xxx"          -> literal (AVOID — leaks to nix store)
    #
    # Store these in pass first:
    #   pass insert kimi-coding/api-key
    #   pass insert minimax/api-key
    apiKeys = {
      # These must match your pass store paths exactly.
      # Run: pass show <path>  to verify before switching.
      kimi-coding = "!pass show kimi-coding/api-key";
      minimax = "!pass show minimax/api-key";
    };
    packages = [
      "https://github.com/mksglu/context-mode"
      "https://github.com/nicobailon/pi-subagents"
      "https://github.com/nicobailon/pi-web-access"
      "npm:@samfp/pi-memory"
    ];

    skills = [ ];

    # Skill repos from flake inputs — no rev needed, tracked in flake.lock.
    # Add the input to flake.nix first:
    #   superpowers = { url = "github:obra/superpowers"; flake = false; };
    # Then reference it here:
    skillsInputs = [ "superpowers" ];

    # OAuth providers (GitHub Copilot, Claude Pro, OpenAI Codex) are NOT
    # listed here. Run `pi /login` interactively and pi manages the tokens.
  };

  imports = [
    ./modules/packages.nix
    ./modules/git.nix
    ./modules/zsh.nix
    ./modules/starship.nix
    ./modules/emacs.nix
    ./modules/alacritty.nix
    ./modules/hyprland.nix
    ./modules/noctalia.nix
    ./modules/podman.nix
    ./modules/btop.nix
    ./modules/aliases.nix
    ./modules/mise.nix
    ./modules/nh.nix
    ./modules/easyeffects.nix
    ./modules/pi.nix
    ./modules/zen-browser.nix
  ];
}
