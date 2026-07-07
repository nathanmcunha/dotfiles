{ config, ... }:

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
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
      };
      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentitiesOnly = "yes";
      };
      "207.180.205.47" = {
        User = "nathan";
        IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
        IdentitiesOnly = "yes";
      };
    };
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };
}
