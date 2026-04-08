#!/bin/bash
# Helper script to add API keys for Hermes providers

set -e

echo "🔐 Hermes API Key Setup"
echo "========================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if key exists
check_key() {
    local key=$1
    if pass show "$key" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $key exists"
        return 0
    else
        echo -e "${YELLOW}✗${NC} $key not found"
        return 1
    fi
}

# Function to add key
add_key() {
    local service=$1
    local key_name="${service}/api-key"
    
    echo ""
    echo "Adding $service API key..."
    echo "Get your key from:"
    
    case $service in
        "anthropic")
            echo "  https://console.anthropic.com/settings/keys"
            ;;
        "opencode")
            echo "  https://opencode.ai/dashboard"
            ;;
        *)
            echo "  Check your service's dashboard"
            ;;
    esac
    
    echo ""
    read -p "Paste your $service API key: " -s api_key
    echo ""
    
    if [ -z "$api_key" ]; then
        echo -e "${RED}Error: No key provided${NC}"
        return 1
    fi
    
    echo "$api_key" | pass insert -e "$key_name" 2>/dev/null
    echo -e "${GREEN}✓${NC} Added $key_name"
}

# Check current setup
echo "Current pass setup:"
echo ""
pass ls 2>/dev/null || { echo "Error: pass store not initialized"; exit 1; }
echo ""

# Check existing keys
echo "Checking existing keys:"
echo ""
check_key "minimax/api-key"
has_minimax=$?

check_key "anthropic/api-key"
has_anthropic=$?

check_key "opencode/api-key"
has_opencode=$?

echo ""

# Offer to add missing keys
if [ $has_anthropic -ne 0 ]; then
    read -p "Add Anthropic API key? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        add_key "anthropic"
    fi
fi

if [ $has_opencode -ne 0 ]; then
    echo ""
    read -p "Add OpenCode Go API key? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        add_key "opencode"
    fi
fi

echo ""

# Verify setup
echo "Final verification:"
echo ""
pass ls

echo ""
echo -e "${GREEN}Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Apply Home Manager: home-manager switch --flake .#nathanmcunha"
echo "  2. Start Hermes: systemctl --user start hermes-agent"
echo "  3. Test: hermes chat"
echo ""