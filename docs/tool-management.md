# Home Manager Tool Management

## What changed

Previously, tools were installed via imperative scripts (curl-pipe-sh, `update-externals install`). Everything is now declarative and Nix-managed.

---

## Tool registry: `files/external/versions.json`

Single source of truth for all managed tools. Each entry has a `repo`, pinned `version`, `asset` filename, and `type`.

```
rtk       → rtk-ai/rtk         [nix]
qwen-code → QwenLM/qwen-code   [nix]
```

---

## Derivations: `modules/derivations.nix`

Each tool is a proper Nix derivation — hash-pinned, fetched from the Nix store, no network calls at activation time. Added to `home.packages` like any other Nix package.

- `rtk` — fetched as a tarball, binary extracted
- `qwen-code` — fetched as `cli.js`, wrapped with `#!/usr/bin/env node`

Both land in `~/.nix-profile/bin/` instead of `~/.local/bin/`.

---

## Day-to-day commands

**Check for updates** (queries GitHub API):
```bash
update-externals check
```

**Update a specific tool** (patches `derivations.nix` in-place):
```bash
update-externals nix-update          # all nix tools
update-externals nix-update rtk      # one tool
```

**Apply:**
```bash
home-manager switch --flake ~/.config/home-manager#nathanmcunha
```

`nix-update` does three things automatically: fetches the new version from GitHub, runs `nix-prefetch-url` for the new hash, and patches both `derivations.nix` and `versions.json`.

---

## Adding a new tool

1. Add entry to `versions.json` with `"type": "nix"`
2. Add derivation block to `modules/derivations.nix`
3. `home-manager switch`
