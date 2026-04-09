# Nathan's NixOS Dotfiles

Personal Nix Flake for a full **NixOS + Home Manager** setup focused on a Hyprland desktop workflow, theming, and developer tooling.

## What this repo configures

- NixOS host: `nathanmcunha-nixos`
- Home Manager user: `nathanmcunha`
- Window manager: Hyprland (Wayland)
- Desktop stack: Waybar, Wofi, Dunst, wlogout
- Theming: Gruvbox GTK/icons + Bibata cursor, Matugen/WPGTK integration
- Tooling: GitHub CLI, Copilot CLI, Claude Code, container/K8s tools, editors, scripts

## Repository layout (important)

- `flake.nix`: inputs and outputs (`nixosConfigurations`, `homeConfigurations`)
- `hosts/nathanmcunha-nixos/configuration.nix`: machine-level NixOS config
- `home.nix`: user-level Home Manager entrypoint
- `modules/`: reusable Home Manager and NixOS modules
- `files/`: dotfiles/assets/scripts linked into `$HOME`

## Apply configuration

### NixOS (system + home, recommended on this machine)

```bash
sudo nixos-rebuild switch --flake ~/dotfiles#nathanmcunha-nixos
```

### Home Manager only

```bash
home-manager switch --flake ~/dotfiles#nathanmcunha
```

## Update workflow

Update flake inputs + external pinned tools and rebuild:

```bash
nix-update
```

The alias is defined in `modules/aliases.nix` and runs:

- `nix flake update ~/dotfiles`
- `update-externals check`
- `sudo nixos-rebuild switch --flake ~/dotfiles#nathanmcunha-nixos`

## External tool manager

`files/scripts/update-externals.sh` manages versions from `files/external/versions.json`.

Useful commands:

```bash
update-externals check
update-externals list
update-externals nix-update <tool-name>
```

## Maintenance

Garbage-collect old builds/generations:

```bash
sudo nix-collect-garbage -d
nix-store --gc
nix-store --optimize
```

## Notes

- Theme/icon tarballs are stored in `files/assets/` and extracted during Home Manager activation.
- Hyprland configs/scripts are sourced from `files/hypr/`.
- This repo may contain local non-tracked folders (backups/projects); they are not required for rebuilds.
