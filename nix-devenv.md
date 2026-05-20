# Nix + Devenv + Emacs Workflow Guide

This guide walks through setting up a reproducible development environment using `devenv`, `direnv`, and Emacs on a non-NixOS machine.

## Important

This should be tested in the project: `/home/nathanmcunha/projects/findthecoffee/`
and the emacs configs are located in `/home/nathanmcunha/.config/emacs/` and `/home/nathanmcunha/dotfiles/modules/emacs.nix`

## 1. Install the Nix Package Manager

If you are on macOS or a standard Linux distribution (Ubuntu, Fedora, etc.), use the Determinate Systems installer. It enables flakes by default and is easy to uninstall.

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

*Restart your terminal after the installation completes.*

## 2. Install `direnv` and `devenv`

Next, install `direnv` using your host OS package manager, and `devenv` via Nix.

**Install `direnv`**:

- **macOS:** `brew install direnv`
- **Ubuntu/Debian:** `sudo apt install direnv`
- **Fedora:** `sudo dnf install direnv`

Hook `direnv` into your shell (add to `~/.bashrc` or `~/.zshrc`):

```bash
eval "$(direnv hook bash)"  # for bash
eval "$(direnv hook zsh)"   # for zsh
```

**Install `devenv`**:
```bash
nix profile install --accept-flake-config github:cachix/devenv/latest
```

## 3. Configure Emacs

Emacs needs to know how to read the buffer-local environment variables exposed by `direnv`.

**For Doom Emacs:**
Simply open your `~/.config/doom/init.el`, find the `:tools` section, and uncomment or add:

```elisp
direnv
```

Run `doom sync` and restart Emacs.

**For Standard Emacs:**
Install and configure the `envrc` package in your configuration file:

```elisp
(use-package envrc
  :ensure t
  :hook (after-init . envrc-global-mode))
```

## 4. Initialize Your Project

Navigate to your project directory and initialize the `devenv` environment.

```bash
cd my-project
devenv init
```

This creates three files: `devenv.nix`, `devenv.yaml`, and `.envrc`.

### Example: FindTheCoffee Project

For this project (Python backend + TypeScript frontend + PostgreSQL):

```nix
{ pkgs, ... }: {
  # Enable Python 3.12 with common packages
  languages.python = {
    enable = true;
    package = pkgs.python312;
  };

  # Background services
  services.postgres = {
    enable = true;
    initialDatabases = [{ name = "coffeedb"; }];
  };

  # Add common packages
  packages = with pkgs; [
    git
    jq
    mise
    nodejs_22
    npm
  ];

  # Pre-commit hooks
  pre-commit-check.enable = true;
}
```

## 5. The Daily Emacs Workflow

1. **Open the project:** Open any file in your project directory using Emacs (`C-x C-f`).
2. **Allow the environment:** The first time you open the project (or whenever you change `devenv.nix`), Emacs will warn you that the `direnv` environment is blocked.
   - Run `M-x envrc-allow` (or `M-x direnv-allow` in Doom).
3. **Write Code:** Your LSP server will automatically boot up using the exact binaries defined in your `devenv.nix`. Completion tools like Corfu will pick up the correct language server context.
4. **Run Services:** Open an integrated terminal (like `vterm` or `eshell`) inside Emacs and run:
   ```bash
   devenv up
   ```
   This spins up PostgreSQL and any other background services defined in your environment, completely isolated to this project.

## 6. Common Tasks

### Viewing Environment Variables

direnv exposes variables defined in `devenv.nix` to Emacs. You can view them:

```elisp
M-x envrc-show
```

### Updating the Environment

When you modify `devenv.nix`:

```bash
devenv update
```

### Running Tests

```bash
devenv shell python -m pytest
```

### Running the Backend

```bash
devenv shell python backend/main.py
```

### Running the Frontend

```bash
devenv shell npm --prefix frontend run dev
```

### Migrating from mise to devenv

If your project currently uses `mise`, you can migrate to `devenv`:

1. Remove the `.mise.toml` file
2. Run `devenv init` to create new config files
3. Copy environment variables from `.env` to `devenv.nix`
4. Update `.envrc` to use devenv instead of mise:
   ```bash
   eval "$(devenv shell)"
   ```

## Troubleshooting

### "direnv: command not found"

Make sure you've added the direnv hook to your shell and restarted your terminal.

### "envrc mode is not enabled"

Ensure `envrc-global-mode` is enabled in your Emacs config:

```elisp
(envrc-global-mode 1)
```

### LSP server not starting

Restart the LSP session after direnv activates:

```elisp
(add-hook 'envrc-after-update-hook
          (lambda ()
            (when-let (ws (car (lsp-workspaces)))
              (lsp-workspace-restart ws))))
```