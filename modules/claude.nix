{ config, lib, ... }:

let
  homeDir = config.home.homeDirectory;
in
{
  # Scripts tracked in git, deployed as executable files
  home.file.".claude/statusline-command.sh" = {
    source = ../files/claude/statusline-command.sh;
    executable = true;
  };

  home.file.".claude/hooks/rtk-rewrite.sh" = {
    source = ../files/claude/hooks/rtk-rewrite.sh;
    executable = true;
  };

  # Declarative settings — plugins, hooks, statusline
  # Note: Claude Code cannot write back to this file while it is Nix-managed.
  # To temporarily allow changes, run: home-manager unmanage ~/.claude/settings.json
  home.file.".claude/settings.json".text = builtins.toJSON {
    statusLine = {
      type    = "command";
      command = "bash ${homeDir}/.claude/statusline-command.sh";
    };

    enabledPlugins = {
      "github@claude-plugins-official"                          = true;
      "code-review@claude-plugins-official"                     = true;
      "antigravity-awesome-skills@antigravity-awesome-skills"   = true;
    };

    extraKnownMarketplaces = {
      antigravity-awesome-skills = {
        source = {
          source = "github";
          repo   = "sickn33/antigravity-awesome-skills";
        };
      };
    };

    hooks = {
      PreToolUse = [
        {
          matcher = "Bash";
          hooks   = [
            {
              type    = "command";
              command = "${homeDir}/.claude/hooks/rtk-rewrite.sh";
            }
          ];
        }
      ];
    };
  };
}
