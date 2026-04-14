{
  inputs,
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
  home.packages = [
    pkgs.claude-code-router
    pkgs.claude-code
  ];
  home.file.".claude/statusline-command.sh" = {
    source = ../files/claude/statusline-command.sh;
    executable = true;
  };

  home.sessionVariables = {
    MINIMAX_API_KEY = "$(${pkgs.pass}/bin/pass show minimax/api-key 2>/dev/null | head -1)";
  };

  programs.zsh.initContent = lib.mkMerge [
    # Always set GNUPGHOME
    ''
      export GNUPGHOME="$HOME/.gnupg"
    ''
    (lib.optionalString useEnvVars ''
      export ANTHROPIC_AUTH_TOKEN=$(${pkgs.pass}/bin/pass show minimax/api-key 2>/dev/null | head -1)
    '')
    # Export MINIMAX_API_KEY so CCR can interpolate it from config.json.
    # Do NOT set ANTHROPIC_AUTH_TOKEN / ANTHROPIC_BASE_URL here — those
    # would override native Anthropic auth (OAuth / API key).
    # CCR sets ANTHROPIC_BASE_URL=http://127.0.0.1:3456 itself when you
    # run `ccr code` or `ccr start`.
    (lib.optionalString (!useEnvVars) ''
      export MINIMAX_API_KEY=$(${pkgs.pass}/bin/pass show minimax/api-key 2>/dev/null | head -1)
    '')
  ];

  home.activation.setupClaude = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "$HOME/.claude/hooks"

    # Write settings.json as a mutable file so Claude can save state (e.g. model selection)
    $DRY_RUN_CMD rm -f "$HOME/.claude/settings.json"
    $DRY_RUN_CMD cp --no-preserve=mode ${pkgs.writeText "claude-settings.json" (builtins.toJSON finalConfig)} "$HOME/.claude/settings.json"

    # Write RTK hook as a mutable file so it can be updated/touched by the system if needed
    $DRY_RUN_CMD rm -f "$HOME/.claude/hooks/rtk-rewrite.sh"
    $DRY_RUN_CMD cp --no-preserve=mode "${../files/claude/hooks/rtk-rewrite.sh}" "$HOME/.claude/hooks/rtk-rewrite.sh"
    $DRY_RUN_CMD chmod +x "$HOME/.claude/hooks/rtk-rewrite.sh"
  '';

  # Claude Code Router config — routes Claude Code requests to any provider.
  # Uses $MINIMAX_API_KEY env var (set from pass in shell init above).
  # Run via: ccr code   (starts the router + Claude Code)
  # Or:      ccr start  (start router daemon, then use `claude` normally)
  #
  # Written as a real file (not a symlink) so CCR can modify it at runtime.
  home.activation.writeCCRConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "$HOME/.claude-code-router"
    $DRY_RUN_CMD rm -f "$HOME/.claude-code-router/config.json"
    $DRY_RUN_CMD cp --no-preserve=mode ${
      pkgs.writeText "ccr-config.json" (
        builtins.toJSON {
          LOG = false;
          API_TIMEOUT_MS = 3000000;
          Providers = [
            {
              name = "minimax";
              api_base_url = "https://api.minimax.io/anthropic/v1/messages";
              api_key = "$MINIMAX_API_KEY";
              models = [ "MiniMax-M2.7" ];
              transformer = {
                use = [ "Anthropic" ];
              };
            }
          ];
          Router = {
            default = "minimax,MiniMax-M2.7";
            background = "minimax,MiniMax-M2.7";
            think = "minimax,MiniMax-M2.7";
            longContext = "minimax,MiniMax-M2.7";
          };
        }
      )
    } "$HOME/.claude-code-router/config.json"
  '';
}
