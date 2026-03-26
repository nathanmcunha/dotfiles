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

    shellAliases = {
      ls = "eza --icons=always --color=always";
      ll = "eza -al --icons=always --color=always --git";

      cat = "bat --style=plain --paging=never";
    };

    sessionVariables = {
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=60";
    };

    initExtra = ''
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

      # --- TOOLS ---

      # Zoxide (smart cd replacement)
      eval "$(zoxide init zsh)"

      # Runtime managers
      command -v mise &>/dev/null && eval "$(mise activate zsh)"
      command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

      # FZF-Tab: replace default TAB completion with fzf
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

      # Preview directory contents when completing cd/z
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
      zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --color=always $realpath'
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
}
