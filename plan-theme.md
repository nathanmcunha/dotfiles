## Task: Implement Squirrelsong Theme Across NixOS Setup

Theme: https://sapegin.me/squirrelsong/
Source: https://github.com/sapegin/squirrelsong

### Changes Made

1. **`modules/noctalia.nix`** — 2 edits:
   - `colorSchemes`: `generationMethod = "manual"`, `useWallpaperColors = false`, `predefinedScheme = "Squirrelsong"`
   - `colors`: Mapped to Squirrelsong Light palette (M3 slots)

2. **`~/.config/emacs/themes/squirrelsong-dark-theme.el`** — New file:
   - Custom Emacs theme using Squirrelsong Dark palette
   - Full face coverage: base UI, font-lock, treesit, vertico, corfu, org, doom-modeline, flymake, diff, magit, rainbow-delimiters, nerd-icons, ANSI colors

3. **`~/.config/emacs/theme.org`** — Replaced `base16-rose-pine-moon` with `(load-theme 'squirrelsong-dark t)`

### Apps Themed (no changes needed)
- **Alacritty** — Noctalia template `alacritty-colors.toml` generates from M3 colors
- **Zen Browser** — Built-in Noctalia template (already in `activeTemplates`)
- **Hyprland** — Template `hyprland-colors.conf`
- **Dunst** — Template `dunstrc`
- **Wofi** — Template `wofi-style.css`
- **OMP (Oh My Posh)** — Template `omp-theme.json`
- **OpenCode** — Template `opencode-theme.json`
- **Hyprlock** — Template `hyprlock.conf`
- **Starship** — Built-in Noctalia template

### Color Mapping (Squirrelsong Light → M3)
| M3 Slot | Squirrelsong | Value |
|---------|-------------|-------|
| mPrimary | blue | #80a4be |
| mOnPrimary | gray010 | #000000 |
| mSecondary | greenContrast | #657d38 |
| mOnSecondary | gray180 | #fdfdfe |
| mTertiary | magentaContrast | #806f9b |
| mOnTertiary | gray180 | #fdfdfe |
| mError | redContrast | #c06159 |
| mOnError | gray180 | #fdfdfe |
| mSurface | gray180 | #fdfdfe |
| mOnSurface | gray050 | #3e3d40 |
| mSurfaceVariant | gray170 | #f7f6f9 |
| mOnSurfaceVariant | gray090 | #78737d |
| mOutline | gray110 | #9c96a2 |
| mShadow | gray150 | #dbd7e0 |
| mHover | blue | #80a4be |
| mOnHover | gray010 | #000000 |

### Verification
- `home-manager build` to verify config evaluates
- `nixos-rebuild switch` or `home-manager switch` to apply
- Visually verify Squirrelsong colors in terminal, Emacs, bar, and all themed apps
