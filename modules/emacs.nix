{
  lib,
  pkgs,
  inputs,
  ...
}:

let
  emacs-config = inputs.emacs-config;

  # Build a single org file for Nix use-package parsing so declarations in
  # modular org files are always visible to emacsWithPackagesFromUsePackage.
  nixParsedConfig = pkgs.writeText "emacs-nix-config.org" ''
    #+TITLE: Emacs config for Nix package extraction
    #+PROPERTY: header-args:emacs-lisp :results silent

    ${builtins.readFile (emacs-config + "/core.org")}

    ${builtins.readFile (emacs-config + "/ui.org")}

    ${builtins.readFile (emacs-config + "/theme.org")}

    ${builtins.readFile (emacs-config + "/completion.org")}

    ${builtins.readFile (emacs-config + "/tools.org")}

    ${builtins.readFile (emacs-config + "/bindings.org")}

    ${builtins.readFile (emacs-config + "/notes.org")}

    ${builtins.readFile (emacs-config + "/ai.org")}

    ${builtins.readFile (emacs-config + "/containers.org")}

    ${builtins.readFile (emacs-config + "/eca.org")}
  '';

  # Tree-sitter grammars from Nix (avoids manual compilation at runtime)
  # Grammars matching treesit-language-source-alist in tools.org + org-mode + markdown + sql
  grammarNames = [
    "bash"
    "c"
    "cpp"
    "css"
    "dockerfile"
    "html"
    "java"
    "javascript"
    "json"
    "markdown"
    "nix"
    "org"
    "python"
    "sql"
    "toml"
    "tsx"
    "typescript"
    "yaml"
  ];
  treesit-grammars = pkgs.linkFarm "emacs-treesit-grammars" (
    lib.filter (g: g != null) (
      map (
        name:
        let
          grammar = pkgs.tree-sitter.builtGrammars."tree-sitter-${name}" or null;
        in
        if grammar != null then
          {
            name = "libtree-sitter-${name}.so";
            path = "${grammar}/parser";
          }
        else
          null
      ) grammarNames
    )
  );

  # Tools Emacs shells out to — only in daemon PATH, not your shell
  emacs-only-tools = with pkgs; [
    coreutils
    gnugrep
    gnused
    findutils
    gawk
    file
    unzip
    zip
    gnutar
    gzip
    diffutils
    patch
    tree-sitter
    ispell
    qt6.qtbase
    gnumake # magit calls make for some operations
    openssh # consistent SSH binary for TRAMP control sockets
    google-cloud-sdk # gcloud compute ssh / TRAMP gcloud method
    awscli2 # AWS CLI for SSM Session Manager / TRAMP aws method
    ssm-session-manager-plugin # AWS SSM SSH proxy (TRAMP aws method)
  ];

  # LSP servers available to Emacs runtime only (not exposed in shell PATH)
  emacs-lsp-servers = with pkgs; [
    basedpyright
    ruff
    prettier
    typescript-language-server
    sqls
    yaml-language-server
    vscode-langservers-extracted
    dockerfile-language-server
    qt6.qtdeclarative
    nixd
    clang-tools
  ];

  myEmacs = pkgs.emacsWithPackagesFromUsePackage {
    config = nixParsedConfig;
    defaultInitFile = true;
    package = pkgs.emacs30-pgtk.override {
      withNativeCompilation = true;
      withTreeSitter = true;
      withSQLite3 = true;
      withWebP = true;
    };
    alwaysEnsure = true;
    alwaysTangle = true;
    extraEmacsPackages = epkgs: [
      # Packages the use-package parser cannot discover:
      epkgs.jinx # disabled spell-check, kept for easy re-enable
      epkgs.ghostel # terminal emulator (native module auto-downloads)
    ];
  };

  # Runtime PATH injected into Emacs (contains nixd and other LSP servers)
  emacsRuntimePath = lib.makeBinPath (emacs-only-tools ++ emacs-lsp-servers);

  # Helper to read file and substitute variables
  substituteFile =
    file: replacements:
    builtins.replaceStrings (lib.mapAttrsToList (k: _: "@${k}@") replacements) (lib.mapAttrsToList (
      _: v: v
    ) replacements) (builtins.readFile file);

  nix-init-content = substituteFile ../files/emacs/nix-init.el {
    inherit emacsRuntimePath;
  };

  nix-early-init-content = substituteFile ../files/emacs/nix-early-init.el {
    inherit emacsRuntimePath;
    treesitGrammars = "${treesit-grammars}";
  };

  custom-el-content = substituteFile ../files/emacs/custom.el { };
in
{

  # services.emacs handles package installation and systemd unit + socket.
  # programs.emacs is redundant — removing it avoids a no-op package drop.
  services.emacs = {
    enable = true;
    package = myEmacs;
    startWithUserSession = "graphical";
  };

  # Keep daemon runtime dependencies explicit and isolated from shell config.
  # DOCKER_HOST is exported here so it's available to every child process
  # Emacs spawns (docker.el, async-shell-command, TRAMP containers).
  # Uses %U (systemd specifier) which expands to the user's numeric UID at runtime.
  systemd.user.services.emacs.Service = {
    Environment = [
      "LD_LIBRARY_PATH=${pkgs.enchant_2}/lib"
      "PATH=${emacsRuntimePath}"
      "DOCKER_HOST=unix:///run/user/%U/podman/podman.sock"
    ];
    PassEnvironment = [ "WAYLAND_DISPLAY" "DISPLAY" "XDG_RUNTIME_DIR" ];
    RestartSec = 5; # Wait 5s before restarting to let display settle
  };

  # Socket activation — start Emacs daemon on first emacsclient connection
  systemd.user.sockets.emacs = {
    Unit.Description = "Emacs server socket";
    Socket.ListenStream = "%t/emacs/server";
    Socket.SocketMode = "0600";
    Socket.DirectoryMode = "0700";
    Install.WantedBy = [ "sockets.target" ];
  };

  # init.el and early-init.el are Nix-generated trampolines that inject
  # runtime PATH and early-init settings. `force = true` fights existing
  # Nix store symlinks on every `home-manager switch` — dropping it lets
  # home-manager manage the symlinks without unnecessary churn.
  xdg.configFile = {
    "emacs/init.el".text = nix-init-content;
    "emacs/early-init.el".text = nix-early-init-content;
  };

  # Create a writable custom.el so Emacs can persist safe-local-eval forms.
  # We use activation instead of xdg.configFile so the file stays mutable
  # (Emacs replaces symlinks on save, but write-region on a store symlink fails).
  home.activation.createEmacsCustom = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        customFile="$HOME/.config/emacs/custom.el"
        if [ ! -f "$customFile" ]; then
          cat > "$customFile" <<'CUSTOM_EOF'
    ${custom-el-content}
    CUSTOM_EOF
        fi
  '';
  # Runtime libraries needed by Emacs packages (not in shell PATH, only in daemon env)
  # enchant_2: jinx spell-check (in LD_LIBRARY_PATH above)
  home.packages = with pkgs; [
    enchant_2
    myEmacs
  ];
}
