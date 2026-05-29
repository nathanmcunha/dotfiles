# Nathan's NixOS Dotfiles

Personal Nix Flake for a full **NixOS + Home Manager** setup focused on a Hyprland desktop workflow, unified theming, and developer tooling.

## What this repo configures

- **NixOS host:** `nathanmcunha-nixos`
- **Home Manager user:** `nathanmcunha`
- **Window manager:** Hyprland (Wayland)
- **Desktop stack:** Waybar, Wofi, Dunst, wlogout, Hyprlock
- **Theming:** Noctalia Shell — unified palette across Hyprland, Alacritty, Wofi, Dunst, Hyprlock, Emacs, and OpenCode
- **GTK / Icons:** adw-gtk3 + Papirus-Dark icons + Bibata cursor
- **Fonts:** Iosevka Nerd Font, JetBrains Mono Nerd Font, Cascadia Code NF
- **Browsers:** Brave, Google Chrome, Zen Browser
- **Audio:** EasyEffects (Home Manager service)
- **Editors:** Emacs (daemon), Neovim, VS Code, JetBrains IDEA
- **AI CLIs:** Claude Code, Pi, Antigravity CLI (Gemini), GitHub Copilot CLI, OpenCode, Oh-My-Pi
- **Tooling:** container/K8s tools, RTK (token proxy), mise, Git, GPG

## Repository layout

```
flake.nix                   Inputs and outputs (nixosConfigurations, homeConfigurations)
home.nix                    User-level Home Manager entrypoint
hosts/
  nathanmcunha-nixos/
    configuration.nix       Machine-level NixOS config
modules/                    Reusable Home Manager modules
  packages.nix              All user packages
  noctalia.nix              Noctalia theming templates and plugins
  pi.nix                    Pi coding agent (providers, skills, packages)
  emacs.nix                 Emacs daemon + emacs-overlay
  hyprland.nix              Hyprland window manager config
  zen-browser.nix           Zen Browser from flake input
  easyeffects.nix           EasyEffects audio service
  nh.nix                    nh Nix helper (auto-clean old generations)
  aliases.nix               Shell aliases (eza, bat, podman, nix shortcuts)
  zsh.nix                   Zsh + plugins
  starship.nix              Starship prompt
  alacritty.nix             Alacritty terminal
  podman.nix                Podman container runtime
  btop.nix                  Btop system monitor
  git.nix                   Git config
  mise.nix                  Mise version manager
derivations/
  antigravity-cli.nix       Antigravity CLI (Gemini agentic coding tool)
overlays/
  rtk.nix                   RTK — Rust Token Killer (Claude Code token proxy)
  bun.nix                   Bun runtime overlay
files/
  hypr/                     Hyprland configs and scripts
  noctalia/                 Noctalia settings, plugins, and templates
  scripts/                  Helper scripts
  assets/                   Theme/icon tarballs extracted at activation
.github/workflows/ci.yml    CI — nix flake check on push/PR
```

## Apply configuration

### NixOS (system + home, recommended on this machine)

```bash
sudo nixos-rebuild switch --flake ~/dotfiles#nathanmcunha-nixos
```

Or using the shell alias:

```bash
nixos
```

### Home Manager only

```bash
home-manager switch --flake ~/dotfiles#nathanmcunha
```

Or:

```bash
hm
```

### Full update (flake inputs + rebuild)

```bash
nxfull
```

This runs `nix flake update`, then `nixos-rebuild switch`, then `home-manager switch`.

## Noctalia theming

[Noctalia Shell](https://github.com/noctalia-dev/noctalia-shell) provides a unified colour palette across the desktop. Theme templates are defined in `modules/noctalia.nix` and source files live in `files/noctalia/templates/`.

Targets:

| Target     | Template                   | Output                                |
|------------|----------------------------|---------------------------------------|
| Hyprland   | `hyprland-colors.conf`     | `~/.config/hypr/colors.conf`          |
| Wofi       | `wofi-style.css`           | `~/.config/wofi/style.css`            |
| Dunst      | `dunstrc`                  | `~/.config/dunst/dunstrc`             |
| Alacritty  | `alacritty-colors.toml`    | `~/.config/alacritty/theme-colors.toml` |
| Hyprlock   | `hyprlock.conf`            | `~/.config/hypr/hyprlock.conf`        |
| Emacs      | `emacs-theme.el`           | `~/.config/emacs/noctalia-theme.el`   |
| OpenCode   | `opencode-theme.json`      | `~/.config/opencode/themes/noctalia.json` |

Settings and plugin config are in `files/noctalia/settings.json` and `files/noctalia/plugins.json`.

## Emacs

Emacs is managed through Home Manager + `emacs-overlay` and runs as a daemon via `services.emacs`.

- Config source: external `emacs-config` repo pinned in `flake.lock`
- Runtime support: Nix-managed Tree-sitter grammars and LSP servers
- Local state: writable `~/.config/emacs/custom.el`
- Startup tuning: early-init wrapper keeps ELN cache and GC settings optimized for large configs
- Noctalia integration: theme auto-applied via `emacsclient` post-hook

## Pi coding agent

Declaratively configured in `modules/pi.nix` and `home.nix`. Features:

- Multiple AI providers (Kimi Coding, MiniMax) with API keys from `pass`
- Skill repos loaded from flake inputs (e.g. `superpowers`)
- Community packages: context-mode, subagents, web-access, memory

Switch providers interactively with `/model` or via `--provider`/`--model` CLI flags.

## Custom derivations and overlays

| Package          | Source                      | Description                                       |
|------------------|-----------------------------|---------------------------------------------------|
| `rtk`            | `overlays/rtk.nix`          | Rust Token Killer — token-optimized CLI proxy      |
| `antigravity-cli`| `derivations/antigravity-cli.nix` | Gemini's agentic coding tool (binary + bun) |
| `bun`            | `overlays/bun.nix`          | Bun runtime override (pinned version)              |

## Maintenance

```bash
sudo nix-collect-garbage -d
nix-store --gc
nix-store --optimize
```

### CI

GitHub Actions runs `nix flake check` on push and pull request events.

## Notes

- Theme/icon tarballs are stored in `files/assets/` and extracted during Home Manager activation.
- Hyprland configs/scripts are sourced from `files/hypr/`.
- Podman is used as a Docker drop-in via shell aliases (`docker` → `podman`).
- This repo may contain local non-tracked folders (backups/projects); they are not required for rebuilds.
