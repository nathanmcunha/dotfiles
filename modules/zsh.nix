{ ... }:

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

    sessionVariables = {
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=60";
      LS_COLORS = "di=34:ln=36:so=35:pi=33:ex=32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43";
    };

    shellAliases = {
      ll  = "ls -l --color=auto";
      ls  = "ls --color=auto";
    };

    initContent = ''
      # Emacs client helpers
      e()   { emacsclient -c "$@" }
      ec()  { emacsclient -cn "$@" }
      et()  { emacsclient -t "$@" }
      edk() { emacsclient -e '(kill-emacs)' }
      er()  { edk && sleep 2 && ec }

      # Extra PATH
      export PATH="$HOME/.config/emacs/bin:$PATH"
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$PATH:$HOME/.lmstudio/bin"

      # Load secrets if present
      [[ -f ~/.env ]] && source ~/.env

      # LS_COLORS for completions
      zstyle ':completion:*:default' list-colors ''${(s.:.)LS_COLORS}

      # mise (project-level runtime manager)
      command -v mise &>/dev/null && eval "$(mise activate zsh)"

      # direnv (auto-activate .envrc on cd)
      command -v direnv &>/dev/null && eval "$(direnv hook zsh)"
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
