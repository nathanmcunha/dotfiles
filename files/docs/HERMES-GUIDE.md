# Hermes Agent Multi-Provider Setup

This guide covers using Hermes Agent with multiple AI providers on your Fedora + Home Manager setup.

## Provider Configuration

Your Hermes setup supports 3 providers:

### 1. Anthropic Claude (Primary)
- **Models:** claude-sonnet-4, claude-3-haiku, claude-3-opus
- **Endpoint:** `https://api.anthropic.com/v1`
- **Auth:** API key or Claude Pro/Max subscription
- **Use case:** General development, code review, complex reasoning

### 2. MiniMax International
- **Models:** MiniMax-M2.7 and variants
- **Endpoint:** International endpoint with custom base URL
- **Auth:** MINIMAX_API_KEY
- **Use case:** Alternative provider, international access

### 3. OpenCode Go
- **Models:** Open models via subscription
- **Cost:** $10/month subscription
- **Auth:** OPENCODE_GO_API_KEY
- **Use case:** Budget-friendly open models

---

## Quick Setup

### 1. Add API Keys

Run the setup script:
```bash
setup-hermes-keys
```

Or manually:
```bash
# Anthropic (required)
pass insert anthropic/api-key
# Paste: sk-ant-api03-...

# MiniMax (already exists, verify)
pass show minimax/api-key

# OpenCode Go (optional)
pass insert opencode/api-key
# Paste: sk-opencode-...
```

### 2. Apply Configuration

```bash
home-manager switch --flake .#nathanmcunha
```

### 3. Start Hermes

```bash
# Start the gateway service
hermes-start

# Or manually
systemctl --user start hermes-agent

# Check status
hermes-status

# View logs
hermes-logs
```

### 4. Chat

```bash
hermes chat
```

---

## Switching Providers

### Default Provider

Your default is set to Anthropic Claude in `config.yaml`:
```yaml
model:
  default: "anthropic/claude-sonnet-4"
  base_url: "https://api.anthropic.com/v1"
```

To switch to MiniMax:
```nix
# In modules/hermes-agent.nix, change:
model:
  default: "MiniMax-M2.7"
  base_url: "https://api.minimax.world/v1"
```

To switch to OpenCode Go:
```yaml
model:
  default: "opencode-default"
  base_url: "https://api.opencode.ai/v1"
```

### Temporary Switch

You can override the default for specific sessions:
```bash
# Use MiniMax for this conversation
HERMES_MODEL=MiniMax-M2.7 hermes chat

# Use Anthropic with different model
HERMES_MODEL=anthropic/claude-3-opus hermes chat
```

---

## Environment Variables

### Hermes recognizes these:

```bash
ANTHROPIC_API_KEY         # Anthropic Claude
MINIMAX_API_KEY            # MiniMax International
OPENCODE_GO_API_KEY        # OpenCode Go
OPENROUTER_API_KEY         # OpenRouter aggregator

HERMES_MODEL               # Override default model
HERMES_FALLBACK_MODEL      # Fallback for errors
HERMES_MEMORY_ENABLED      # Enable memory (true/false)
```

### How they're loaded

In your `hermes-agent.nix`:
```nix
systemd.user.services.hermes-agent.Service.Environment = [
  "ANTHROPIC_API_KEY=$(${pkgs.pass}/bin/pass show anthropic/api-key)"
  "MINIMAX_API_KEY=$(${pkgs.pass}/bin/pass show minimax/api-key)"
];
```

---

## Usage Examples

### Chat with Default Model

```bash
hermes chat
# Uses: anthropic/claude-sonnet-4
```

### Specify Model Inline

```bash
hermes chat --model MiniMax-M2.7
hermes chat --model anthropic/claude-3-opus
```

### Gateway Mode (Background Service)

```bash
# Start gateway
hermes gateway run

# From another terminal
hermes send "What's the status of my Nix setup?"

# Stop gateway
hermes gateway stop
```

### Programming Assistance

```bash
hermes chat <<EOF
Generate a Home Manager module for Docker with:
- Rootless mode
- Default network configuration
- Common aliases
EOF
```

---

## Configuration Files

### Main Config

`~/.config/hermes/config.yaml`:
```yaml
model:
  default: "anthropic/claude-sonnet-4"
  base_url: "https://api.anthropic.com/v1"
  
toolsets: ["all"]

terminal:
  backend: "local"
  timeout: 180
  
max_turns: 100

memory:
  memory_enabled: true
  user_profile_enabled: true
```

### Personality

`~/.hermes/SOUL.md`:
- Defines Hermes' personality and behavior
- Currently: concise, technical, Nix-focused

### User Profile

`~/.hermes/USER.md`:
- Your preferences and context
- Loaded for personalized responses

### Environment

`~/.hermes/.env`:
- Loaded at startup
- Contains API keys from pass

---

## Aliases

Your setup includes these convenience aliases:

```bash
hermes-start      # Start gateway service
hermes-stop       # Stop gateway service
hermes-logs       # Tail logs
hermes-status     # Check status
```

---

## Troubleshooting

### "API key not found"

```bash
# Check keys exist
pass show anthropic/api-key
pass show minimax/api-key

# Verify in systemd
systemctl --user show hermes-agent | grep Environment
```

### "Model not available"

```bash
# Check available models
hermes models

# Or via API
curl https://api.anthropic.com/v1/models \
  -H "x-api-key: $(pass show anthropic/api-key)"
```

### "GPG passphrase required repeatedly"

```bash
# Start GPG agent
gpg-agent --daemon

# Or increase timeout
# In ~/.gnupg/gpg-agent.conf:
default-cache-ttl 3600
max-cache-ttl 7200
```

### "Hermes gateway won't start"

```bash
# Check logs
journalctl --user -u hermes-agent -n 50

# Verify config
hermes config show

# Test manual run
HERMES_HOME=~/.hermes hermes gateway run --verbose
```

### "Config changes not taking effect"

```bash
# Apply Home Manager
home-manager switch --flake .#nathanmcunha

# Restart Hermes
systemctl --user restart hermes-agent

# Verify
hermes config show
```

---

## Costs & Quotas

### Anthropic
- **Free tier:** $5 credit
- **Claude Pro:** $20/month
- **Claude Max:** Higher limits
- **API:** Pay per token

### MiniMax
- Check your dashboard at provider's site

### OpenCode Go
- **Subscription:** $10/month
- **Includes:** Various open models

---

## Security

### API Keys

- **Never** commit plain text keys
- **Always** use `pass` to manage them
- Keys are decrypted at `home-manager switch` time
- Injected into systemd environment, not logs

### GPG Security

- Your GPG key encrypts all pass entries
- Key expires 2029-03-30
- Backup your `~/.gnupg/` and `~/.password-store/`

### Systemd Hardening

Your service has security hardening:
```nix
NoNewPrivileges = true;
ProtectSystem = "strict";
ProtectHome = "read-only";
ReadWritePaths = [ "%h/.hermes" ];
```

---

## Advanced Usage

### Multiple Configurations

Create environment-specific configs:
```bash
# Work config
ln -s ~/.config/hermes/config-work.yaml ~/.config/hermes/config.yaml

# Personal config
ln -s ~/.config/hermes/config-personal.yaml ~/.config/hermes/config.yaml
```

### Custom Model per Task

```bash
# Quick tasks → Haiku (fast, cheap)
alias hermes-quick='HERMES_MODEL=anthropic/claude-3-haiku-20240307 hermes chat'

# Complex reasoning → Opus (best)
alias hermes-smart='HERMES_MODEL=anthropic/claude-3-opus hermes chat'

# Usage
hermes-quick "Format this JSON file"
hermes-smart "Design a distributed caching strategy"
```

### Integration with Emacs

```elisp
;; In your Emacs config
(defun hermes-chat ()
  "Start Hermes chat in shell."
  (interactive)
  (ansi-term "/bin/bash")
  (term-send-string "hermes chat\n"))
```

### Integration with Zsh

```bash
# Already in your aliases.zsh
# Add custom functions:

hermes-nix() {
    hermes chat <<EOF
Help me with this Nix Flake issue:
$@
EOF
}
```

---

## Logs & Monitoring

### View Real-time Logs

```bash
hermes-logs
# Or
journalctl --user -u hermes-agent -f
```

### Check Service Status

```bash
systemctl --user status hermes-agent
```

### Debug Mode

```bash
# Run with verbose output
HERMES_DEBUG=true hermes chat
```

---

## Updates

### Update Hermes

```bash
# Update flake input
nix flake update hermes-agent

# Apply
home-manager switch --flake .#nathanmcunha
```

### Update API Keys

```bash
# Edit existing key
pass edit anthropic/api-key

# Restart Hermes
hermes-stop
hermes-start
```

---

## Related Documentation

- [PASS-GUIDE.md](PASS-GUIDE.md) - Managing API keys with pass
- [Hermes Docs](https://hermes-agent.nousresearch.com) - Official documentation
- [Anthropic API](https://docs.anthropic.com) - Claude API reference

---

## Quick Reference

```bash
# Setup
setup-hermes-keys

# Start/stop
hermes-start
hermes-stop
hermes-status

# Chat
hermes chat
hermes chat --model MiniMax-M2.7

# Config
hermes config show
hermes config edit

# Logs
hermes-logs

# Apply changes
home-manager switch --flake .#nathanmcunha
systemctl --user restart hermes-agent
```