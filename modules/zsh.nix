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
      # Emacs client helpers (mantendo os seus)
      e()   { emacsclient -c "$@" }
      ec()  { emacsclient -cn "$@" }
      # ... (restante dos seus helpers emacs e envs) ...

      # --- MELHORIAS DO ZSH COMPLETION ---
      # Ativa cache para completions (deixa mais rápido)
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

      # Completions Case-insensitive e suporte a fuzzy/partial matching
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

      # Cores no menu de completion padrão (O seu LS_COLORS atual)
      zstyle ':completion:*:default' list-colors ''${(s.:.)LS_COLORS}

      # --- INICIALIZAÇÃO DE NOVAS FERRAMENTAS ---

      # Zoxide (Substituto inteligente do cd)
      eval "$(zoxide init zsh)"

      # mise e direnv (mantendo os seus)
      command -v mise &>/dev/null && eval "$(mise activate zsh)"
      command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

      # Ativando o FZF-Tab (Garante que a tecla TAB use o FZF)
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

      # Opcional: Configura o preview do fzf-tab para o comando cd/zoxide usando o eza
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
