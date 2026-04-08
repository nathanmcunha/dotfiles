#!/usr/bin/env bash
# Manager for GitHub binary releases
# Supports types: nix (Nix derivation), tarball, single-binary, js
# Usage:
#   update-externals check              → check all tools for updates
#   update-externals nix-update [name]  → update version + hash in derivations.nix
#   update-externals list               → list all managed tools

set -euo pipefail

VERSIONS_FILE="$HOME/dotfiles/files/external/versions.json"
DERIVATIONS_NIX="$HOME/dotfiles/modules/derivations.nix"

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

cmd_check() {
  echo -e "${BLUE}Checking tools for updates...${NC}"
  echo "────────────────────────────────────────"

  python3 << PYEOF
import json, urllib.request

with open('$VERSIONS_FILE') as f:
    data = json.load(f)

has_updates = False

for tool in data['tools']:
    name    = tool['name']
    repo    = tool['repo']
    current = tool['version']
    kind    = tool.get('type', 'tarball')
    label   = f"[{kind}]"

    try:
        url = f"https://api.github.com/repos/{repo}/releases/latest"
        with urllib.request.urlopen(url) as r:
            release = json.load(r)
        latest = release['tag_name'].lstrip('v')

        if latest != current:
            print(f"\033[1;33m⚠  {name}\033[0m {label}: {current} → \033[0;32m{latest}\033[0m")
            if kind == 'nix':
                print(f"   Run: \033[0;34mupdate-externals nix-update {name}\033[0m")
            else:
                print(f"   Run: \033[0;34mupdate-externals update {name} && update-externals install {name}\033[0m")
            has_updates = True
        else:
            print(f"\033[0;32m✅ {name}\033[0m {label}: {current} (up to date)")
    except Exception as e:
        print(f"\033[0;31m❌ {name}\033[0m: ERROR - {e}")

if not has_updates:
    print(f"\n\033[0;32mAll tools are up to date!\033[0m")
PYEOF
}

cmd_nix_update() {
  local target="${1:-}"
  echo -e "${BLUE}Updating Nix derivations...${NC}"
  echo "────────────────────────────────────────"

  python3 << PYEOF
import json, urllib.request, subprocess, re

VERSIONS_FILE   = '$VERSIONS_FILE'
DERIVATIONS_NIX = '$DERIVATIONS_NIX'

with open(VERSIONS_FILE) as f:
    data = json.load(f)

target  = '$target'
updated = []

for tool in data['tools']:
    if tool.get('type') != 'nix':
        continue
    if target and tool['name'] != target:
        continue

    name    = tool['name']
    repo    = tool['repo']
    current = tool['version']
    asset   = tool['asset']

    print(f"\n\033[0;36m{name}\033[0m (pinned: {current})")

    try:
        url = f"https://api.github.com/repos/{repo}/releases/latest"
        with urllib.request.urlopen(url) as r:
            release = json.load(r)
        latest = release['tag_name'].lstrip('v')

        if latest == current:
            print(f"  \033[0;32m✅ Already up to date\033[0m")
            continue

        print(f"  \033[1;33m⬆  {current} → {latest}\033[0m")

        asset_url = f"https://github.com/{repo}/releases/download/v{latest}/{asset}"
        print(f"  Fetching hash: {asset_url}")

        nix32 = subprocess.run(
            ['nix-prefetch-url', asset_url],
            capture_output=True, text=True, check=True
        ).stdout.strip()

        sri = subprocess.run(
            ['nix', 'hash', 'convert', '--hash-algo', 'sha256', '--to', 'sri', nix32],
            capture_output=True, text=True, check=True
        ).stdout.strip()
        print(f"  New hash: {sri}")

        with open(DERIVATIONS_NIX) as f:
            content = f.read()

        # Locate the derivation block by pname
        block_start = content.find(f'pname = "{name}"')
        if block_start == -1:
            print(f"  \033[0;31mERROR\033[0m: pname = \"{name}\" not found in derivations.nix")
            continue

        next_block = content.find('pname = "', block_start + 1)
        block_end  = next_block if next_block != -1 else len(content)
        block      = content[block_start:block_end]

        hash_match = re.search(r'hash = "(sha256-[^"]+)"', block)
        if not hash_match:
            print(f"  \033[0;31mERROR\033[0m: hash not found in block for {name}")
            continue

        old_hash = hash_match.group(1)
        new_block = block \
            .replace(f'version = "{current}"', f'version = "{latest}"', 1) \
            .replace(f'/v{current}/{asset}',   f'/v{latest}/{asset}',   1) \
            .replace(f'hash = "{old_hash}"',   f'hash = "{sri}"',       1)

        content = content[:block_start] + new_block + content[block_end:]

        with open(DERIVATIONS_NIX, 'w') as f:
            f.write(content)

        tool['version'] = latest
        updated.append(f"{name} {current} → {latest}")
        print(f"  \033[0;32m✅ derivations.nix patched\033[0m")

    except subprocess.CalledProcessError as e:
        print(f"  \033[0;31mERROR\033[0m: {e.stderr.strip()}")
    except Exception as e:
        import traceback; traceback.print_exc()
        print(f"  \033[0;31mERROR\033[0m: {e}")

with open(VERSIONS_FILE, 'w') as f:
    json.dump(data, f, indent=2)

if updated:
    print(f"\n\033[0;32mUpdated:\033[0m")
    for u in updated:
        print(f"  {u}")
    print(f"\nApply with:")
    print(f"  \033[0;34msudo nixos-rebuild switch --flake ~/dotfiles#nathanmcunha-nixos\033[0m")
else:
    print(f"\n\033[0;32mAll nix tools are up to date!\033[0m")
PYEOF
}

cmd_list() {
  echo -e "${CYAN}Managed tools:${NC}"
  echo "────────────────────────────────────────"
  python3 -c "
import json
with open('$VERSIONS_FILE') as f:
    data = json.load(f)
for t in data['tools']:
    print(f\"  {t['name']:20} v{t['version']:10} [{t.get('type','tarball')}]  {t['repo']}\")
"
}

case "${1:-check}" in
  check)      cmd_check ;;
  nix-update) cmd_nix_update "${2:-}" ;;
  list)       cmd_list ;;
  *)
    echo "Usage: update-externals [check|nix-update|list] [tool-name]"
    exit 1
    ;;
esac
