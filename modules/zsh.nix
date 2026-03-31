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
      update-externals = "bash ~/.config/home-manager/files/scripts/update-externals.sh";

      nix-update = "nix flake update ~/.config/home-manager && update-externals check && home-manager switch --flake ~/.config/home-manager#nathanmcunha";

      # Quick open
      o = "xdg-open";
    };

    sessionVariables = {
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=60";

      # XDG-aligned tool homes (moved from ~/.*)
      CARGO_HOME = "$HOME/.config/cargo";
      DOCKER_CONFIG = "$HOME/.config/docker";
      DENO_DIR = "$HOME/.config/deno";
      RUSTUP_HOME = "$HOME/.config/rustup";
      BUN_INSTALL = "$HOME/.config/bun";
      GRADLE_USER_HOME = "$HOME/.config/gradle";
    };

    initContent = ''
      # --- PATH ---
      path=(
        "$HOME/.local/bin"
        "$HOME/.config/emacs/bin"
        "$HOME/.config/cargo/bin"
        $path
        "$HOME/.lmstudio/bin"
      )

      # Load secrets if present
      [[ -f ~/.env ]] && source ~/.env

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

      # --- OPENING THINGS ---
      # Suffix aliases: Open files by typing their name directly
      alias -s {pdf,PDF}='xdg-open'
      alias -s {png,jpg,jpeg,gif,svg,PNG,JPG,JPEG,GIF,SVG}='xdg-open'
      alias -s {mp4,mkv,mov,avi,webm,MP4,MKV,MOV,AVI,WEBM}='xdg-open'
      alias -s {mp3,flac,wav,ogg,MP3,FLAC,WAV,OGG}='xdg-open'
      alias -s {html,htm,HTML,HTM}='xdg-open'

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
}
