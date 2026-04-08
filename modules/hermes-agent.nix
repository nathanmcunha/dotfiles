{
  config,
  pkgs,
  hermes-agent,
  ...
}:

let
  homeDir = config.home.homeDirectory;
  hermesPkg = hermes-agent.packages.${pkgs.system}.default;
in
{
  home.packages = [ hermesPkg ];

  programs.zsh.initContent = ''
    export ANTHROPIC_API_KEY=$(${pkgs.pass}/bin/pass show anthropic/api-key 2>/dev/null | head -1)
    export MINIMAX_API_KEY=$(${pkgs.pass}/bin/pass show minimax/api-key 2>/dev/null | head -1)
    export OPENCODE_GO_API_KEY=$(${pkgs.pass}/bin/pass show opencode/api-key 2>/dev/null | head -1)
  '';

  # Main Hermes configuration
  xdg.configFile."hermes/config.yaml" = {
    text = ''
      # Default model for general use
      model:
        default: "anthropic/claude-sonnet-4"
        base_url: "https://api.anthropic.com/v1"
        
      # Available toolsets
      toolsets: ["all"]

      # Terminal configuration
      terminal:
        backend: "local"
        timeout: 180
        
      # Conversation limits
      max_turns: 100

      # Memory and context
      memory:
        memory_enabled: true
        user_profile_enabled: true
        
      # Compression for long conversations
      compression:
        enabled: true
        threshold: 0.85
        summary_model: "anthropic/claude-3-haiku-20240307"
        
      # Display settings
      display:
        compact: false
        personality: "professional"
    '';
  };

  # User profile
  home.file.".hermes/USER.md" = {
    text = ''
      # User Profile

      **Name:** Nathan Cunha
      **Role:** Software Engineer

      ## Preferences
      - Prefers concise, technical responses
      - Works primarily with Nix, Linux, and containerized applications
      - Uses Fedora Workstation with Hyprland
      - Values reproducibility and declarative configurations

      ## Common Workflows
      - Nix/Home Manager configuration management
      - Container orchestration (Podman, Kubernetes)
      - Emacs-centric development workflow
      - AI-assisted coding and automation
    '';
  };

  # Personality instructions
  home.file.".hermes/SOUL.md" = {
    text = ''
      # Hermes Agent Personality

      You are a helpful AI assistant integrated into Nathan's development workflow.

      ## Behavioral Guidelines
      - Be concise and accurate in responses
      - Prioritize reproducibility and declarative solutions
      - Suggest Nix-first solutions when appropriate
      - Explain reasoning for complex decisions
      - Proactively offer to create commits, PRs, or run tests
      - Respect user's preference for minimal, efficient tooling

      ## Technical Context
      - User is experienced with Nix, Linux, and devops
      - Prefers Home Manager for user-space configuration
      - Uses systemd user services for background tasks
      - Values security best practices (secrets management, etc.)

      ## Communication Style
      - Use structured output (tables, lists, code blocks)
      - Avoid excessive preamble/postamble
      - Link to relevant documentation when introducing new concepts
      - Acknowledge uncertainty explicitly
    '';
  };

  # Shell wrapper to load keys from pass at runtime (for systemd service)
  home.file.".hermes/hermes-env.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      export ANTHROPIC_API_KEY="$(${pkgs.pass}/bin/pass show anthropic/api-key 2>/dev/null || echo "")"
      export MINIMAX_API_KEY="$(${pkgs.pass}/bin/pass show minimax/api-key 2>/dev/null || echo "")"
      export OPENCODE_GO_API_KEY="$(${pkgs.pass}/bin/pass show opencode/api-key 2>/dev/null || echo "")"
      export HERMES_DEFAULT_MODEL="anthropic/claude-sonnet-4"
      export HERMES_FALLBACK_MODEL="anthropic/claude-3-haiku-20240307"
      export HERMES_MEMORY_ENABLED="true"
      export HERMES_USER_PROFILE_ENABLED="true"
      exec "${hermesPkg}/bin/hermes" gateway run --replace
    '';
  };

  # Systemd service
  systemd.user.services.hermes-agent = {
    Unit = {
      Description = "Hermes Agent Gateway - Multi-Provider AI Assistant";
      After = [ "network.target" ];
    };

    Service = {
      ExecStart = "%h/.hermes/hermes-env.sh";
      Restart = "on-failure";
      RestartSec = "5";

      # Environment
      Environment = "HERMES_HOME=%h/.hermes";

      # Security hardening
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ReadWritePaths = [ "%h/.hermes" ];
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Solarized Light skin
  home.file.".hermes/skins/solarized-light.yaml" = {
    source = ../files/hermes/solarized-light.yaml;
  };

  # Convenience aliases
  home.shellAliases = {
    hermes-start = "systemctl --user start hermes-agent";
    hermes-stop = "systemctl --user stop hermes-agent";
    hermes-logs = "journalctl --user -u hermes-agent -f";
    hermes-status = "systemctl --user status hermes-agent";
  };
}
