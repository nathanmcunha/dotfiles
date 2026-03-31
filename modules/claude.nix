{ config, lib, ... }:

let
  homeDir = config.home.homeDirectory;
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

  home.activation.injectMinimaxKey = ''
    export GPG_TTY=$(tty 2>/dev/null || echo "")
    export HOME=''${HOME:-/home/nathanmcunha}
    MINIMAX_API_KEY=$(pass show minimax/api-key 2>/dev/null | head -1)
    if [ -n "$MINIMAX_API_KEY" ]; then
      SETTINGS_FILE="$HOME/.claude/settings.json"
      if [ -f "$SETTINGS_FILE" ]; then
        jq --arg key "$MINIMAX_API_KEY" ".env.ANTHROPIC_API_KEY = $key" "$SETTINGS_FILE" > /tmp/settings.json.tmp
        mv /tmp/settings.json.tmp "$SETTINGS_FILE"
      fi
    fi
  '';

  home.sessionVariables.ANTHROPIC_API_KEY = "REPLACED_AT_ACTIVATION";

  home.file.".claude/settings.json" = {
    force = true;
    text = builtins.toJSON {
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
  };
}
