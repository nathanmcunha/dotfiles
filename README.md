# Nathan's Dotfiles

Personal development environment managed with [Nix](https://nixos.org/) and [Home Manager](https://github.com/nix-community/home-manager).

## Overview

This repository contains my full user-space configuration for an `x86_64-linux` workstation running [Hyprland](https://hyprland.org/) (Wayland compositor). Everything is declared in Nix, so the entire environment is reproducible and version-controlled.

## Features

| Area | Tool |
|---|---|
| Window Manager | Hyprland |
| Terminal | Alacritty |
| Shell | Zsh (syntax-highlighting, auto-suggestions, fzf) |
| Prompt | Starship (Solarized theme) |
| Editor | Emacs (pgtk, daemon mode) |
| App Launcher | Walker |
| Status Bar | Hyprpanel |
| Color Theming | Matugen |
| Containers | Podman (rootless, docker drop-in) |
| AI tools | Claude Code, Gemini CLI |

## Repository Structure

```
dotfiles/
├── flake.nix          # Nix flake: inputs & outputs
├── home.nix           # Home Manager entry point
├── modules/           # Individual configuration modules
│   ├── alacritty.nix  # Terminal emulator
│   ├── emacs.nix      # Editor + LSP runtimes
│   ├── git.nix        # Git settings & global ignores
│   ├── hyprland.nix   # Hyprland / Wayland config files
│   ├── packages.nix   # System-wide packages
│   ├── podman.nix     # Rootless container setup
│   ├── starship.nix   # Shell prompt
│   └── zsh.nix        # Shell + fzf integration
└── files/             # Static config files (linked by Home Manager)
    ├── hypr/          # Hyprland, hypridle, hyprlock, hyprpaper, rules, scripts
    ├── hyprpanel/     # Hyprpanel config
    ├── matugen/       # Matugen templates (colors, wofi CSS)
    └── walker/        # Walker app-launcher config
```

## Modules

### `packages.nix` — CLI & Dev Packages
Core CLI tools (`fzf`, `fd`, `bat`, `ripgrep`, `btop`, `curl`, `wget`, `tree`), dev helpers (`neovim`, `gcc`, `cmake`, `mise`), Nix tools (`nixfmt-rfc-style`, `nix-tree`), and Kubernetes tooling (`kubectl`, `helm`, `k9s`, `kubectx`, `kind`).

### `emacs.nix` — Editor & Language Runtimes
Emacs `pgtk` build running as a systemd user service. Includes runtimes (Go, Java 21, Node.js 24, Python 3.12, Rust) and LSP servers (basedpyright, ruff, typescript-language-server, prettier, sqls, yaml-language-server, and more). Convenience shell aliases: `e`, `ec`, `et`, `edk`, `er`.

### `git.nix` — Git Configuration
Sensible defaults: histogram diff, `zdiff3` merge style, `rerere`, auto-setup remote, global ignores for secrets, OS files, and editor artefacts.

### `zsh.nix` — Shell
Zsh with a 100,000-line history, syntax highlighting, auto-suggestions, and deep `fzf` integration (file, directory and preview bindings). Activates `mise` and `direnv` when available.

### `starship.nix` — Prompt
Powerline-style Starship prompt with a full Solarized palette, showing username, directory, git branch/status, and language version segments (Node.js, Rust, Go, PHP).

### `alacritty.nix` — Terminal
Alacritty with FiraCode Nerd Font (12 pt), Solarized Light colors, near-opaque background (`0.99`), and a 10,000-line scroll buffer.

### `hyprland.nix` — Window Manager
Symlinks all Hyprland configuration files (`hyprland.conf`, `colors.conf`, `hypridle.conf`, `hyprlock.conf`, `hyprpaper.conf`, `rules.conf`) along with screenshot and wallpaper-rotation scripts, Hyprpanel, Walker, and Matugen templates.

### `podman.nix` — Containers
Rootless Podman configured as a `docker` drop-in (aliases `docker` → `podman`, `docker-compose` → `podman-compose`). Searches `docker.io`, `quay.io`, and `ghcr.io`.

## Prerequisites

- [Nix](https://nixos.org/download/) with **flakes** and **nix-command** experimental features enabled
- A running Linux system (the flake targets `x86_64-linux`)

Enable flakes permanently by adding to `/etc/nix/nix.conf` (or `~/.config/nix/nix.conf`):
```
experimental-features = nix-command flakes
```

## Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/nathanmcunha/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Apply the Home Manager configuration**
   ```bash
   nix run nixpkgs#home-manager -- switch --flake .#nathanmcunha
   ```

3. **Subsequent updates**
   ```bash
   home-manager switch --flake ~/dotfiles#nathanmcunha
   ```

## Updating Flake Inputs

```bash
nix flake update
home-manager switch --flake .#nathanmcunha
```
