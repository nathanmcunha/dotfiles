{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Nathan Cunha";
        email = "nathanmartins@outlook.com";
      };

      core.autocrlf = "input";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      diff.algorithm = "histogram";
      merge.conflictstyle = "zdiff3";
      rerere.enabled = true;
    };

    ignores = [
      # Secrets
      ".env"
      ".env.*"
      "*.key"
      "*.peh"
      # OS
      ".DS_Store"
      "Thumbs.db"
      "*~"
      # Editor
      "*.swp"
      "*.swo"
      "#*#"
      ".dir-locals.el"
      # Compiled
      "*.elc"
    ];
  };
}
