# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## 📖 Overview

- **Author:** Nathan Martins Cunha
- **Target OS:** Fedora Linux
- **Manager:** chezmoi (declarative, template-aware dotfile manager)

## ✨ Tools Configured

| Tool | Purpose |
| :--- | :--- |
| **zsh + zinit** | Shell with fast plugin management |
| **Starship** | Cross-shell prompt |
| **fzf** | Fuzzy finder (files, history, directories) |
| **Emacs** | Primary editor (Doom-like vanilla config) |
| **Hyprland + wofi** | Wayland compositor and launcher |
| **Alacritty / Kitty** | Terminal emulators |
| **btop** | System resource monitor |
| **mise** | Runtime version manager |
| **Git** | Version control with sane defaults |

## 🚀 Bootstrap on a Fresh Fedora Machine

```bash
# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# Apply dotfiles directly from GitHub
chezmoi init --apply nathanmcunha
```

## 📦 Dependencies / Prerequisites

Install the required packages before or after applying:

```bash
sudo dnf install -y $(cat ~/fedora_packages.txt)
```

Key dependencies include: `zsh`, `git`, `fzf`, `fd-find`, `bat`, `starship`, `mise`, `hyprland`, `wofi`, `alacritty`, `kitty`, `btop`.

## 📂 Repository Structure

```text
dotfiles/
├── dot_zshrc              # Zsh configuration (zinit, aliases, PATH, fzf)
├── dot_gitconfig          # Git configuration
├── dot_gitignore_global   # Global gitignore patterns
├── .chezmoignore          # Files chezmoi should not manage
├── fedora_packages.txt    # DNF package list for bootstrapping
├── dot_config/
│   ├── emacs/             # Doom-like vanilla Emacs config (literate org)
│   ├── hypr/              # Hyprland compositor config
│   ├── starship.toml      # Starship prompt theme
│   ├── alacritty/         # Alacritty terminal config
│   ├── kitty/             # Kitty terminal config
│   ├── wofi/              # Wofi launcher config
│   ├── btop/              # btop monitor config
│   ├── mise/              # mise runtime config
│   └── ...                # Other tool configs
└── private_dot_local/     # Private local files (not tracked publicly)
```

## 🔧 Common chezmoi Commands

```bash
chezmoi status          # Show pending changes
chezmoi apply           # Apply dotfiles to home directory
chezmoi edit ~/.zshrc   # Edit a managed file
chezmoi update          # Pull latest changes and apply
chezmoi diff            # Preview changes before applying
```

## 📝 License

Provided as-is for personal use and inspiration.
