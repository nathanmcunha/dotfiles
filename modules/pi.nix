{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.programs.pi;

  settingsFile = "${config.home.homeDirectory}/.pi/agent/settings.json";
  authFile = "${config.home.homeDirectory}/.pi/agent/auth.json";

  # Build auth.json entries from apiKeys option.
  authJsonEntries = lib.mapAttrs (_: key: {
    type = "api_key";
    inherit key;
  }) cfg.apiKeys;

  authJsonText = builtins.toJSON authJsonEntries;

  # Paths for skills written by skillsDir (relative to ~/.pi/agent/)
  skillsDirPaths = lib.mapAttrsToList (name: _: "skills/${name}") cfg.skillsDir;

  # Paths for skills from flake inputs (relative to ~/.pi/agent/)
  skillsInputPaths = map (name: "skills/${name}") cfg.skillsInputs;

  allSkillPaths = cfg.skills ++ skillsDirPaths ++ skillsInputPaths;

  # home.file entries for skillsDir (inline skills)
  skillsDirFiles = lib.mapAttrs' (name: content: {
    name = ".pi/agent/skills/${name}/SKILL.md";
    value = { text = content; };
  }) cfg.skillsDir;

  # home.file entries for skillsInputs (flake input symlinks)
  skillsInputFiles = lib.listToAttrs (map (name: {
    name = ".pi/agent/skills/${name}";
    value = { source = inputs.${name}; };
  }) cfg.skillsInputs);

  # Build the declarative settings object for settings.json merge.
  piSettingsBase = {
    defaultProvider = cfg.defaultProvider;
    defaultModel = cfg.defaultModel;
    theme = cfg.theme;
    terminal = {
      showTerminalProgress = true;
    };
  };

  piSettingsWithLists = piSettingsBase
    // lib.optionalAttrs (cfg.packages != [ ]) { packages = cfg.packages; }
    // lib.optionalAttrs (allSkillPaths != [ ]) { skills = allSkillPaths; };
in
{
  options.programs.pi = {
    enable = lib.mkEnableOption "pi coding agent declarative config";

    defaultProvider = lib.mkOption {
      type = lib.types.str;
      default = "kimi-coding";
      description = "Default provider to use (must have credentials configured).";
    };

    defaultModel = lib.mkOption {
      type = lib.types.str;
      default = "kimi-for-coding";
      description = "Default model ID from the default provider.";
    };

    theme = lib.mkOption {
      type = lib.types.str;
      default = "light";
      description = "Pi UI theme.";
    };

    apiKeys = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = ''
        API key entries for auth.json. Values are written directly to the
        "key" field and resolved by pi at runtime. Use one of these formats:

        - Shell command (RECOMMENDED): "!pass show api/kimi-coding"
        - Environment variable: "KIMI_API_KEY"
        - Literal value: "sk-xxx" (leaks to nix store — avoid)

        OAuth providers (GitHub Copilot, Claude Pro, OpenAI Codex) should
        NOT be listed here. Use `pi /login` interactively instead.
      '';
      example = lib.literalExpression ''
        {
          kimi-coding = "!pass show api/kimi-coding";
          minimax = "!pass show api/minimax";
        }
      '';
    };

    customProviders = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Custom provider definitions written to ~/.pi/agent/models.json.";
      example = lib.literalExpression ''
        {
          ollama = {
            baseUrl = "http://localhost:11434/v1";
            api = "openai-completions";
            apiKey = "ollama";
            compat = {
              supportsDeveloperRole = false;
              supportsReasoningEffort = false;
            };
            models = [
              { id = "llama3.1:8b"; }
              { id = "qwen2.5-coder:7b"; }
            ];
          };
        }
      '';
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.anything;
      default = [ ];
      description = ''
        Pi packages to install globally. Each entry is a package source string
        or a filter object. Pi auto-installs missing packages on startup.

        Supported sources:
          - npm: "npm:@scope/pkg@1.2.3"  (pinned, skipped by pi update)
          - git:  "git:github.com/user/repo@v1"
          - url:  "https://github.com/user/repo"
          - local: "/absolute/path" or "./relative/path"
      '';
      example = lib.literalExpression ''
        [
          "npm:@earendil-works/pi-web-design-guidelines"
          "git:github.com/user/my-pi-skills@v1.0.0"
        ]
      '';
    };

    skills = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Paths to local skill files or directories. Added to the `skills`
        array in settings.json. Paths resolve relative to ~/.pi/agent/.
        Use absolute paths for directories outside ~/.pi/agent/.
      '';
      example = lib.literalExpression ''
        [ "skills/my-custom-skill" "/home/nathanmcunha/dotfiles/pi-skills/review" ]
      '';
    };

    skillsDir = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = ''
        Inline skill definitions. Each attribute name becomes a directory under
        ~/.pi/agent/skills/<name>/ with a SKILL.md file. Added to skills array.
      '';
      example = lib.literalExpression ''
        {
          review = '''
            # Review Skill
            When reviewing code, check for:
            - Memory safety issues
            - Proper error handling
            - Test coverage
          ''';
        }
      '';
    };

    skillsInputs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Names of flake inputs to use as skill directories. Each input is
        symlinked to ~/.pi/agent/skills/<name>/ and added to the skills
        array in settings.json.

        Define the input in flake.nix:
          superpowers = {
            url = "github:obra/superpowers";
            flake = false;
          };

        Then reference it here:
          skillsInputs = [ "superpowers" ];

        The commit is tracked in flake.lock — update with `nix flake update`.
      '';
      example = lib.literalExpression ''
        [ "superpowers" ]
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ pi-coding-agent ];

    home.file = lib.mkMerge [
      skillsDirFiles
      skillsInputFiles
      (lib.mkIf (cfg.customProviders != { }) {
        ".pi/agent/models.json".text = builtins.toJSON { providers = cfg.customProviders; };
      })
    ];

    # Idempotently merge declarative settings into pi's mutable settings.json.
    home.activation.piSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      _pi_base='${builtins.toJSON piSettingsWithLists}'

      if [[ -f "${settingsFile}" ]]; then
        ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "${settingsFile}" \
          <(printf '%s\n' "$_pi_base") \
          > "${settingsFile}.tmp" && mv "${settingsFile}.tmp" "${settingsFile}"
      else
        mkdir -p "$(dirname "${settingsFile}")"
        printf '%s\n' "$_pi_base" > "${settingsFile}"
        chmod 600 "${settingsFile}"
      fi
    '';

    # Merge API key entries into auth.json without overwriting existing entries.
    home.activation.piAuth = lib.mkIf (cfg.apiKeys != { }) (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      _pi_auth='${authJsonText}'

      if [[ -f "${authFile}" ]]; then
        ${pkgs.jq}/bin/jq -s '
          .[0] as $existing |
          .[1] as $wanted |
          reduce ($wanted | keys_unsorted[]) as $k (
            $existing;
            if has($k) then . else .[$k] = $wanted[$k] end
          )
        ' "${authFile}" <(printf '%s\n' "$_pi_auth") \
          > "${authFile}.tmp" && mv "${authFile}.tmp" "${authFile}"
      else
        mkdir -p "$(dirname "${authFile}")"
        printf '%s\n' "$_pi_auth" > "${authFile}"
        chmod 600 "${authFile}"
      fi
    '');
  };
}
