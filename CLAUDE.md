# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Apply Changes

```bash
# Apply configuration (first time or after changes)
home-manager switch --flake .#nathanmcunha

# Update all flake inputs, then apply
nix flake update && home-manager switch --flake .#nathanmcunha

# Format Nix files
nixfmt <file>.nix
```

## Architecture

This is a Nix flake–based Home Manager dotfiles repo for an `x86_64-linux` Fedora/Hyprland workstation.

**Entry point**: `flake.nix` → `home.nix` → `modules/*.nix`

**Two-layer pattern**: Every tool follows the same split:
- `modules/<tool>.nix` — Home Manager options, package declarations, and `home.file` symlinks
- `files/<tool>/` — Raw static config files (used when HM has no native options for a tool, e.g. Hyprland)

**Key modules**:
- `packages.nix` — All `home.packages`, plus an activation script that installs `rtk` on first run
- `claude.nix` — Declaratively manages `~/.claude/settings.json` (plugins, hooks, statusline) and deploys hook scripts from `files/claude/`
- `hyprland.nix` — Only symlinks files; does not use `wayland.windowManager.hyprland` HM options
- `emacs.nix` — `pgtk` Emacs as a systemd user service + all LSP runtimes

**Important constraint on `settings.json`**: `~/.claude/settings.json` is Nix-managed (read-only symlink). Claude Code cannot write to it while managed. To temporarily allow edits:
```bash
home-manager unmanage ~/.claude/settings.json
```
Re-applying `home-manager switch` will restore Nix management.

**RTK hook** (`files/claude/hooks/rtk-rewrite.sh`): A `PreToolUse` hook that transparently rewrites Bash commands through `rtk rewrite` for token savings. All rewrite logic lives in the `rtk` Rust binary — do not add rewrite rules to the shell script itself.
