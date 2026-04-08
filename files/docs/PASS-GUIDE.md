# Managing API Keys with Pass

This guide explains how to manage API keys and secrets using `pass` (the standard UNIX password manager) integrated with your Nix/Home Manager setup.

## Overview

**Pass** is a password manager that:
- Encrypts secrets with GPG
- Stores them in `~/.password-store/`
- Integrates with Git for version control
- Can be called from Nix configurations

Your setup uses pass to inject API keys into Hermes Agent and other tools without hardcoding them in your Nix files.

---

## Prerequisites

### 1. GPG Key Setup

You need a GPG key to encrypt passwords. Your current key:

```bash
# List your GPG keys
gpg --list-keys

# Your key (created 2026-03-31)
pub   ed25519 2026-03-31 [SC] [expires: 2029-03-30]
      33B8EA8F30371BAD9171580806A8F8F853803A63
uid           [ultimate] Nathan Cunha <...>
```

If you need to generate a new GPG key:
```bash
gpg --full-generate-key
# Choose: (1) RSA and RSA (default)
# Key size: 4096
# Expiration: 2y (2 years)
# Real name: Nathan Cunha
# Email: your@email.com
```

### 2. Initialize Password Store

If not already initialized:
```bash
# Initialize pass with your GPG key ID
pass init 33B8EA8F30371BAD9171580806A8F8F853803A63

# (Optional) Initialize Git for version control
pass git init
pass git remote add origin git@github.com:yourusername/password-store.git
```

---

## Managing API Keys

### Add a New API Key

```bash
# Method 1: Interactive (prompts for password)
pass insert anthropic/api-key

# Method 2: From stdin (better for automation)
echo "sk-ant-api03-your-key-here" | pass insert -e anthropic/api-key

# Method 3: Generate random password
pass generate anthropic/api-key 32  # 32 character random password
```

**Example for Hermes providers:**

```bash
# Anthropic (Claude)
echo "sk-ant-api03-..." | pass insert -e anthropic/api-key

# MiniMax
echo "sk-minimax-..." | pass insert -e minimax/api-key

# OpenCode Go
echo "sk-opencode-..." | pass insert -e opencode/api-key

# OpenRouter (aggregator)
echo "sk-or-..." | pass insert -e openrouter/api-key
```

### List All Keys

```bash
# Tree view
pass ls

# Or
pass find .
```

### Retrieve API Keys

```bash
# Print to stdout
pass show anthropic/api-key

# Copy to clipboard (clears after 45 seconds)
pass -c anthropic/api-key

# Show with metadata
pass show anthropic/api-key --clip
```

### Update Existing Key

```bash
# Edit interactively
pass edit anthropic/api-key

# Or replace directly
echo "sk-new-api-key" | pass insert -e anthropic/api-key
```

### Delete a Key

```bash
pass rm anthropic/api-key
# Confirm with 'y'
```

---

## Integration with Nix

### How It Works

Your `hermes-agent.nix` configuration loads API keys from pass at activation time:

```nix
systemd.user.services.hermes-agent = {
  Service = {
    Environment = [
      "ANTHROPIC_API_KEY=$(${pkgs.pass}/bin/pass show anthropic/api-key 2>/dev/null)"
      "MINIMAX_API_KEY=$(${pkgs.pass}/bin/pass show minimax/api-key 2>/dev/null)"
    ];
  };
};
```

When you run `home-manager switch`, Nix:
1. Evaluates the expression `${pkgs.pass}/bin/pass show ...`
2. Decrypts your API key with GPG
3. Injects it into the systemd unit environment
4. Hermes can access it as `$ANTHROPIC_API_KEY`

### Multiple Environment Variables

```nix
# .env file approach
home.file.".hermes/.env".text = ''
  ANTHROPIC_API_KEY=$(${pkgs.pass}/bin/pass show anthropic/api-key 2>/dev/null)
  MINIMAX_API_KEY=$(${pkgs.pass}/bin/pass show minimax/api-key 2>/dev/null)
'';

# Or direct environment
systemd.user.services.myservice.Service.Environment = [
  "API_KEY=$(${pkgs.pass}/bin/pass show myservice/api-key)"
];
```

### Fallback Handling

Always include error handling (`2>/dev/null || echo ""`) to prevent build failures if a key doesn't exist:

```nix
Environment = "API_KEY=$(${pkgs.pass}/bin/pass show service/api-key 2>/dev/null || echo '')";
```

---

## Current API Keys Setup

Your current pass structure:

```
~/.password-store/
└── minimax/
    └── api-key.gpg
```

### Required Keys for Hermes

You need to add:

```bash
# 1. Anthropic (Claude Pro/Max or API key)
# Get from: https://console.anthropic.com/settings/keys
pass insert anthropic/api-key
# Enter: sk-ant-api03-...

# 2. MiniMax (already exists ✓)
# Verify:
pass show minimax/api-key

# 3. OpenCode Go (optional)
# Get from: https://opencode.ai
pass insert opencode/api-key
# Enter: sk-opencode-...
```

---

## Best Practices

### 1. Organize by Service

```
.password-store/
├── anthropic/
│   └── api-key.gpg
├── minimax/
│   └── api-key.gpg
├── opencode/
│   └── api-key.gpg
├── github/
│   ├── personal-token.gpg
│   └── deploy-key.gpg
└── cloudflare/
    └── api-token.gpg
```

### 2. Use Multi-line Secrets

For keys with additional metadata:

```bash
pass insert anthropic/api-key
# Enter:
# sk-ant-api03-xxxxx
# created: 2026-04-07
# expires: never
# tier: claude-pro

# Retrieve with:
pass show anthropic/api-key | head -1
```

### 3. Backup Your Password Store

```bash
# Git backup (recommended)
pass git push origin master

# Or tarball backup
tar czf password-store-backup.tar.gz ~/.password-store ~/.gnupg
```

### 4. Never Commit Plain Text Keys

```bash
# ❌ Wrong
home.file.".config/service/key".text = "sk-plaintext-key";

# ✓ Right
systemd.user.services.myapp.Service.Environment = 
  "API_KEY=$(${pkgs.pass}/bin/pass show service/api-key)";
```

---

## Common Operations

### Rotate an API Key

```bash
# 1. Generate new key in service's web UI
# 2. Update in pass
pass edit anthropic/api-key
# Replace old key with new one

# 3. Restart affected services
systemctl --user restart hermes-agent

# 4. Verify
pass show anthropic/api-key
```

### Share Keys Across Machines

```bash
# On machine A
pass git push origin master

# On machine B
pass git pull origin master
# GPG keys must be synced separately
gpg --export-secret-keys YOUR_KEY_ID > private.key
# Copy private.key to machine B
gpg --import private.key
```

### Use in Shell Scripts

```bash
#!/bin/bash
# Example: Deploy with API key

ANTHROPIC_KEY=$(pass show anthropic/api-key 2>/dev/null)
curl -X POST https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "claude-sonnet-4", "messages": [...]}'
```

---

## Testing Your Setup

### Verify Pass is Working

```bash
# List all keys
pass ls

# Test decryption
pass show minimax/api-key

# Test GPG integration
echo "test-secret" | pass insert -e test/password
pass show test/password
pass rm test/password
```

### Verify Hermes Configuration

```bash
# Check if environment variables are set
systemctl --user show hermes-agent | grep Environment

# Start Hermes
systemctl --user start hermes-agent

# Check logs for API key issues
journalctl --user -u hermes-agent -f
```

---

## Security Considerations

### GPG Agent Timeout

By default, GPG remembers your passphrase. Control this:

```bash
# In ~/.gnupg/gpg-agent.conf
default-cache-ttl 3600      # Remember for 1 hour
max-cache-ttl 7200          # Maximum 2 hours
```

### Passphrase Prompt

If you're prompted for GPG passphrase frequently:

```bash
# Start GPG agent
gpg-agent --daemon

# Or use:
export GPG_TTY=$(tty)
```

### Environment Variable Security

Never echo API keys:
```bash
# ❌ Bad: Shows in terminal history
echo $ANTHROPIC_API_KEY

# ✓ Good: Use directly
curl -H "x-api-key: $(pass show anthropic/api-key)" ...

# ✓ Good: Environment variables in systemd
systemd sets them internally, not in logs
```

---

## Troubleshooting

### "Pass is not initialized"

```bash
# Initialize with your GPG key ID
gpg --list-keys  # Find your key ID
pass init YOUR_KEY_ID
```

### "GPG decryption failed"

```bash
# Check GPG agent is running
gpg-agent --daemon

# Verify key exists
gpg --list-secret-keys

# Test GPG manually
echo "test" | gpg --encrypt --armor -r YOUR_EMAIL | gpg --decrypt
```

### "Environment variable is empty"

```bash
# Verify pass can decrypt
pass show anthropic/api-key

# Check Nix expression syntax
# Must use: $(${pkgs.pass}/bin/pass show ...)
# Not: $(pass show ...)  # Missing path to pass binary
```

---

## Quick Reference

```bash
# Add
pass insert service/api-key

# List
pass ls

# Show
pass show service/api-key

# Edit
pass edit service/api-key

# Delete
pass rm service/api-key

# Copy
pass -c service/api-key

# Generate
pass generate service/api-key 32

# Git operations
pass git status
pass git push origin master
pass git pull origin master
```

---

## Related Files

- `modules/hermes-agent.nix` - Configures Hermes to use pass-managed keys
- `modules/claude.nix` - Another example of pass integration (Claude Code)
- `~/.gnupg/` - GPG key store
- `~/.password-store/` - Encrypted secrets

---

## Next Steps

1. **Add missing API keys:**
   ```bash
   pass insert anthropic/api-key
   pass insert opencode/api-key
   ```

2. **Apply Home Manager configuration:**
   ```bash
   home-manager switch --flake .#nathanmcunha
   ```

3. **Start Hermes:**
   ```bash
   systemctl --user start hermes-agent
   hermes chat
   ```

4. **Verify keys are loaded:**
   ```bash
   systemctl --user show hermes-agent | grep Environment
   ```