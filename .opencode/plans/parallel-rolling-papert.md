# Noctalia Theme Organization Plan

## Problem Summary

| Tool | Issue | Root Cause |
|------|-------|------------|
| **Starship** | Errors / broken prompt | Dual config: user-template + built-in template conflict; `settings` block in nix gets overwritten |
| **Emacs** | Theme never changes | Hardcoded `modus-operandi` in custom.el + `frame-background-mode 'light` in early-init; zero noctalia integration |
| **Pi** | Stuck on light theme | Static `theme = "light"` in nix; no connection to noctalia dark/light switching |
| **Hyprlock** | Hardcoded colors | Ignores theme variables from colors.conf |
| **agy / omp** | No theming API | Binary tools with no theme support — skipped |

---

## Step 1: Fix Starship — Remove user-template, keep built-in

**Files:**
- `modules/noctalia.nix` — remove starship from `user-templates` and `home.file`
- `modules/starship.nix` — remove `configPath` and `settings` block
- `files/noctalia/templates/starship.toml` — delete

`modules/starship.nix` becomes:
```nix
{ ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
}
```

---

## Step 2: Fix Emacs — modus-operandi/vivendi toggle via noctalia hook

**Files:**
- `files/emacs/nix-early-init.el` — dynamic `frame-background-mode`
- `files/emacs/custom.el` — toggle function instead of hardcoded theme
- `files/noctalia/settings.json` — enable hooks, add `darkModeChange` hook

`files/emacs/custom.el` — replace `(load-theme 'modus-operandi t)` with:
```elisp
(defun nm/apply-noctalia-theme ()
  "Load modus theme matching current noctalia dark/light mode."
  (let ((darkp (and (file-exists-p (expand-file-name "~/.config/noctalia/.darkmode"))
                    (string= "1" (string-trim
                                   (with-temp-buffer
                                     (insert-file-contents
                                       (expand-file-name "~/.config/noctalia/.darkmode"))
                                     (buffer-string)))))))
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme (if darkp 'modus-vivendi 'modus-operandi) t)
    (setq-default frame-background-mode (if darkp 'dark 'light))
    (mapc (lambda (f) (set-frame-parameter f 'background-mode (if darkp 'dark 'light)))
          (frame-list))))
(nm/apply-noctalia-theme)
```

`files/emacs/nix-early-init.el` — replace hardcoded `'light` with state file detection.

`settings.json` hooks:
```json
"hooks": {
    "enabled": true,
    "darkModeChange": "echo $([ \"$NOCTALIA_DARK_MODE\" = \"true\" ] && echo 1 || echo 0) > ~/.config/noctalia/.darkmode && emacsclient -e '(nm/apply-noctalia-theme)' 2>/dev/null || true",
    ...
}
```

> **Note:** The exact env variable name needs verification from noctalia-shell hook docs.

---

## Step 3: Fix Pi — Update theme on dark/light change

Append to `darkModeChange` hook:
```
jq '.theme = if $dark then "dark" else "light" end' \
  --argjson dark "$([ \"$NOCTALIA_DARK_MODE\" = \"true\" ] && echo true || echo false)" \
  ~/.pi/agent/settings.json > ~/.pi/agent/settings.json.tmp \
  && mv ~/.pi/agent/settings.json.tmp ~/.pi/agent/settings.json
```

---

## Step 4: Fix Hyprlock — Template with noctalia colors

**Files:**
- Create `files/noctalia/templates/hyprlock.conf` with `{{colors.*}}` tokens
- Add hyprlock user-template to `modules/noctalia.nix`
- Delete `files/hypr/hyprlock.conf` (replaced by template output)

---

## Step 5: Clean up orphaned files

**Delete:**
- `files/hypr/macchiato.conf`
- `files/wofi/themes/catppuccin-macchiato.rasi`
- `files/hypr/scripts/wallpaper_rotate.sh`
- `files/assets/gtk-theme-gruvbox-light.tar.gz`
- `files/assets/gtk-theme-gruvbox-dark.tar.gz`
- `noctalia-themes.md~`

---

## Step 6: Verify

1. `nix flake check` — validate nix changes
2. Rebuild and test:
   - Starship renders without errors
   - Emacs loads modus-operandi (light)
   - Toggle dark mode → Emacs switches to modus-vivendi, pi updates to "dark"
   - Hyprlock uses themed colors

---

## All file changes

| Action | File |
|--------|------|
| Modify | `modules/noctalia.nix` |
| Modify | `modules/starship.nix` |
| Modify | `files/noctalia/settings.json` |
| Modify | `files/emacs/custom.el` |
| Modify | `files/emacs/nix-early-init.el` |
| Create | `files/noctalia/templates/hyprlock.conf` |
| Delete | `files/noctalia/templates/starship.toml` |
| Delete | `files/hypr/hyprlock.conf` |
| Delete | `files/hypr/macchiato.conf` |
| Delete | `files/wofi/themes/catppuccin-macchiato.rasi` |
| Delete | `files/hypr/scripts/wallpaper_rotate.sh` |
| Delete | `files/assets/gtk-theme-gruvbox-light.tar.gz` |
| Delete | `files/assets/gtk-theme-gruvbox-dark.tar.gz` |
| Delete | `noctalia-themes.md~` |
