{ lib, pkgs, ... }:

let
  emacsConfigPull = pkgs.writeShellApplication {
    name = "emacs-config-pull";
    runtimeInputs = [
      pkgs.bash
      pkgs.coreutils
      pkgs.findutils
      pkgs.git
      pkgs.gnugrep
      pkgs.gnused
    ];
    text = ''
      set -eu

      config_dir="$HOME/.config/emacs"

      if [ ! -d "$config_dir/.git" ]; then
        echo "Missing git checkout at $config_dir; run home-manager switch first." >&2
        exit 1
      fi

      git -C "$config_dir" pull --ff-only origin feat/lsp-mode-migration

      if [ -d "$config_dir/bin" ]; then
        find "$config_dir/bin" -maxdepth 1 -type f | while IFS= read -r script; do
          if head -n1 "$script" | grep -q '^#!/bin/bash$'; then
            sed -i '1 s|^#!/bin/bash$|#!/usr/bin/env bash|' "$script"
          fi
        done
      fi
    '';
  };
in

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
  };

  services.emacs = {
    enable = true;
    startWithUserSession = true;
  };

  systemd.user.services.emacs = {
    Service = {
      Environment = [
        "LD_LIBRARY_PATH=${pkgs.enchant_2}/lib"
        "PKG_CONFIG_PATH=${pkgs.enchant_2}/lib/pkgconfig"
      ];
      PassEnvironment = "WAYLAND_DISPLAY DISPLAY XDG_RUNTIME_DIR";
    };
  };

  home.activation.emacsConfigCheckout = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -eu

    config_dir="$HOME/.config/emacs"
    if [ ! -d "$config_dir/.git" ]; then
      if [ -e "$config_dir" ]; then
        backup_dir="$HOME/.config/emacs.hm-backup-$(date +%Y%m%d-%H%M%S)"
        ${pkgs.coreutils}/bin/mv "$config_dir" "$backup_dir"
        echo "Moved existing Emacs config to $backup_dir"
      fi

      ${pkgs.coreutils}/bin/mkdir -p "$HOME/.config"
      ${pkgs.git}/bin/git clone --branch feat/lsp-mode-migration \
        https://github.com/nathanmcunha/emacs-config.git "$config_dir"
    fi

    if [ -d "$config_dir/bin" ]; then
      ${pkgs.findutils}/bin/find "$config_dir/bin" -maxdepth 1 -type f | while IFS= read -r script; do
        if ${pkgs.coreutils}/bin/head -n1 "$script" | ${pkgs.gnugrep}/bin/grep -q '^#!/bin/bash$'; then
          ${pkgs.gnused}/bin/sed -i '1 s|^#!/bin/bash$|#!/usr/bin/env bash|' "$script"
        fi
      done
    fi
  '';

  home.packages = with pkgs; [
    # Runtimes
    go
    gradle
    temurin-bin-21
    maven
    nodejs_24
    python312
    gnumake
    libtool
    pkg-config

    # Python tools
    basedpyright
    ruff

    # Node tools
    prettier
    typescript-language-server

    # Rust
    rustup

    # LSP servers
    sqls # SQL
    yaml-language-server # YAML
    vscode-langservers-extracted # HTML + CSS + JSON
    dockerfile-language-server # Dockerfile
    nixd
    qt6.qtbase.dev
    # Required by jinx
    enchant_2
    emacsConfigPull
  ];
}
