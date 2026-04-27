{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    history = {
      size = 100000;
      save = 100000;
      ignoreAllDups = true;
      ignoreSpace = true;
      share = true;
      extended = true;
    };

    autocd = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];

    initContent = ''
      # Load secrets if present
      [[ -f ~/.env ]] && source ~/.env

      # GPG_TTY must be set at runtime, not build time
      export GPG_TTY=$(tty)

      # Emacs client helpers
      e()   { emacsclient -c "$@" }
      ec()  { emacsclient -cn "$@" }

      # --- COMPLETION ---
      # Cache completions for faster startup
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

      # Case-insensitive and fuzzy/partial matching
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

      # Colorize the default completion menu
      zstyle ':completion:*:default' list-colors ''${(s.:.)LS_COLORS}

      # Preview directory contents when completing cd/z
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
      zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --color=always $realpath'

      # Smart open function: Handles files, URLs, and Web Searches
      open() {
        if [[ -z "$1" ]]; then
          xdg-open .
        elif [[ -f "$1" || -d "$1" || "$1" =~ ^https?:// ]]; then
          xdg-open "$1"
        else
          # Assume it's a search query if it's not a file or URL
          xdg-open "https://www.google.com/search?q=$*"
        fi
      }
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --exclude .git";
    defaultOptions = [
      "--height 50%"
      "--layout=reverse"
      "--border"
      "--info=inline"
      "--margin=1,2"
      "--color=light"
    ];
    fileWidgetCommand = "fd --type f --hidden --exclude .git";
    fileWidgetOptions = [
      "--preview 'bat -n --color=always {}'"
      "--bind 'ctrl-/:change-preview-window(down|hidden|)'"
    ];
    changeDirWidgetCommand = "fd --type d --hidden --exclude .git";
    changeDirWidgetOptions = [ "--preview 'ls --color=always -l {} | head -200'" ];
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  home.sessionVariables = {
    # GPG_TTY is set in initContent below so it evaluates at shell runtime
  };
}
