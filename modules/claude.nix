{
  config,
  pkgs,
  lib,
  ...
}:

let
  homeDir = config.home.homeDirectory;

  # Configuration toggle - change this to switch modes
  # true = use environment variables for API configuration
  # false = use normal Claude config (you'll need to set env vars separately)
  useEnvVars = false;

  # Base configuration (shared between both modes)
  baseConfig = {
    statusLine = {
      type = "command";
      command = "bash ${homeDir}/.claude/statusline-command.sh";
    };
    enabledPlugins = {
      "github@claude-plugins-official" = true;
      "code-review@claude-plugins-official" = true;
      "antigravity-awesome-skills@antigravity-awesome-skills" = true;
    };
    extraKnownMarketplaces = {
      antigravity-awesome-skills = {
        source = {
          source = "github";
          repo = "sickn33/antigravity-awesome-skills";
        };
      };
    };
    hooks = {
      PreToolUse = [
        {
          matcher = "Bash";
          hooks = [
            {
              type = "command";
              command = "${homeDir}/.claude/hooks/rtk-rewrite.sh";
            }
          ];
        }
      ];
    };
  };

  # Environment variables configuration (Mode 1)
  envConfig = {
    env = {
      ANTHROPIC_BASE_URL = "https://api.minimax.io/anthropic";
      ANTHROPIC_AUTH_TOKEN = "$(${pkgs.pass}/bin/pass show minimax/api-key 2>/dev/null | head -1)";
      API_TIMEOUT_MS = "3000000";
      CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = 1;
      ANTHROPIC_MODEL = "MiniMax-M2.7";
      ANTHROPIC_SMALL_FAST_MODEL = "MiniMax-M2.7";
      ANTHROPIC_DEFAULT_SONNET_MODEL = "MiniMax-M2.7";
      ANTHROPIC_DEFAULT_OPUS_MODEL = "MiniMax-M2.7";
      ANTHROPIC_DEFAULT_HAIKU_MODEL = "MiniMax-M2.7";
    };
  };

  # Normal config approach (Mode 2) - uses Claude's native settings
  # Note: When using this mode, you need to set env vars in your shell or use direnv
  normalConfig = {
    # You can add Claude's native configuration options here
    # For example:
    # preferredModel = "claude-sonnet-4-20250514";
    # theme = "dark";


    # If you want to pass through specific env vars that aren't API-related:
    # env = {
    #   CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = 1;
    #   API_TIMEOUT_MS = "3000000";
    # };
  };

  # Merge base config with selected mode
  finalConfig = baseConfig // (if useEnvVars then envConfig else normalConfig);
in
{
  home.file.".claude/statusline-command.sh" = {
    source = ../files/claude/statusline-command.sh;
    executable = true;
  };

  home.file.".claude/hooks/rtk-rewrite.sh" = {
    source = ../files/claude/hooks/rtk-rewrite.sh;
    executable = true;
  };

  programs.zsh.initContent = lib.mkMerge [
    # Always set GNUPGHOME
    ''
      export GNUPGHOME="$HOME/.gnupg"
    ''
    # Only set ANTHROPIC_AUTH_TOKEN in shell when NOT using env vars mode
    # This allows you to export env vars manually or via direnv
    (lib.optionalString (!useEnvVars) ''
      export ANTHROPIC_AUTH_TOKEN=$(${pkgs.pass}/bin/pass show minimax/api-key 2>/dev/null | head -1)
    '')
  ];

  home.file.".claude/settings.json" = {
    force = true;
    text = builtins.toJSON finalConfig;
  };
}
