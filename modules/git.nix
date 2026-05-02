{ pkgs, ... }:

{
  programs.git = {
    enable = true;

    signing = {
      key = "0CE73DB8ABBBE291EB8E61C363A9F4947CB3C462";
      signByDefault = true;
    };

    settings = {
      user = {
        name = "Nathan Cunha";
        email = "nathanmartins@outlook.com";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "emacsclient -c";
      credential.helper = "cache --timeout=3600";
      alias = {
        st = "status";
        co = "checkout";
        lg = "log --oneline --graph --decorate";
      };
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
      };
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };

  services.ssh-agent.enable = true;

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };
}
