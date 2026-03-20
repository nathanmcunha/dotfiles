{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Nathan Cunha";
      user.email = "nathanmartins@outlook.com";
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
      ".env" ".env.*" "*.key" "*.pem"
      # OS
      ".DS_Store" "Thumbs.db" "*~"
      # Editor
      "*.swp" "*.swo" "#*#" ".dir-locals.el"
      # Compiled
      "*.elc"
    ];
  };
}
