{ config, lib, pkgs, ... }:

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

programs.zsh.initExtra = ''
  export GNUPGHOME="$HOME/.gnupg"
  export GPG_AGENT_INFO="/run/user/1000/gnupg/S.gpg-agent:0:1"
  export ANTHROPIC_API_KEY=$(${pkgs.pass}/bin/pass show minimax/api-key 2>/dev/null | head -1)
'';

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
