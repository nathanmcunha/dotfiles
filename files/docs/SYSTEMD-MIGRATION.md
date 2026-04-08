# Hyprland Services Migration Guide

## Migration Summary

This document shows which services were migrated from `exec-once` to systemd user services, and the benefits gained.

---

## Migration Mapping

| Old exec-once Command | New Systemd Service | Status |
|-----------------------|---------------------|--------|
| `swww-daemon` | `swww-daemon.service` | ✅ Migrated |
| `quickshell -p Main.qml` | `quickshell-main.service` | ✅ Migrated |
| `quickshell -p TopBar.qml` | `quickshell-topbar.service` | ✅ Migrated |
| `wl-paste --type text --watch cliphist store` | `cliphist-text.service` | ✅ Migrated |
| `wl-paste --type image --watch cliphist store` | `cliphist-image.service` | ✅ Migrated |
| `playerctld` | `playerctld.service` | ✅ Migrated |
| `~/.config/hypr/scripts/volume_listener.sh` | `volume-listener.service` | ✅ Migrated |
| **Already in systemd:** | | |
| `hypridle` | `hypridle.service` | ✅ Already managed |
| `hyprpolkitagent` | `hyprpolkitagent.service` | ✅ Already managed |
| `copyq` | `copyq.service` | ✅ Already managed |
| `elephant` | `elephant.service` | ✅ Already managed |
| `wallpaper_rotate.sh` | `wallpaper-rotate.service` | ✅ Already managed |

---

## Services That Stayed as exec-once

| Command | Reason |
|---------|--------|
| `systemctl --user import-environment` | Must run before any systemd service |
| `/home/nathanmcunha/.local/bin/hyprctl setcursor Adwaita 24` | One-shot command, no daemon |
| `blueman-applet` | GUI app needs direct display access |

---

## Benefits of Systemd Migration

### 1. **Automatic Restart on Failure**
```bash
# If a service crashes, systemd restarts it automatically
Restart = "on-failure";
RestartSec = "2-5";  # Wait2-5 seconds before restarting
```

**Example:** If `swww-daemon` crashes, it restarts in 2 seconds instead of staying deaduntil you manually restartit.

### 2. **Proper Logging**
```bash
# View logs for any service
journalctl --user -u swww-daemon -f
journalctl --user -u quickshell-main -n 50
journalctl --user -u cliphist-text --since "1 hour ago"
```

**No more hunting for logs!** Everything is captured by journald.

### 3. **Dependency Ordering**
```nix
After = [ "graphical-session.target" ];
```

Services wait for Wayland to be ready before starting, preventing race conditions.

### 4. **Status Visibility**
```bash
# Check status of all Hyprland services
systemctl --user status swww-daemon
systemctl --user status quickshell-main
systemctl --user status cliphist-text

# List all Hyprland services
systemctl --user list-units | grep -E "(swww|quickshell|cliphist)"
```

### 5. **Resource Management**
Systemd tracks memory, CPU, and process state:
```bash
systemctl --user show quickshell-main --property=MemoryCurrent
systemctl --user show cliphist-text --property=CPUUsageNSec
```

---

## How to Control Services

### Start/Stop Services
```bash
# Start a specific service
systemctl --user start swww-daemon

# Stop a service
systemctl --user stop quickshell-main

# Restart a service
systemctl --user restart cliphist-text

# Restart all migrated services
systemctl --user restart swww-daemon quickshell-main quickshell-topbar \
                   cliphist-text cliphist-image playerctld volume-listener
```

### Enable/Disable Auto-start
```bash
# Enable auto-start on login
systemctl --user enable swww-daemon

# Disable auto-start
systemctl --user disable quickshell-main

# Note: These services are started by hyprland.conf via:
# exec-once = systemctl --user restart <service-name>
# So enabling/disabling only matters if you want them to start without Hyprland.
```

### View Logs
```bash
# Follow logs in real-time
journalctl --user -u swww-daemon -f

# Show last 100 lines
journalctl --user -u quickshell-main -n 100

# Show logs since boot
journalctl --user -u cliphist-text -b

# Show logs from today
journalctl --user -u playerctld --since today

# Grep specific errors
journalctl --user -u volume-listener | grep -i error
```

### Debug Failed Services
```bash
# Check why a service failed
systemctl --user status swww-daemon
journalctl --user -u swww-daemon -n 50

# Test service manually
systemd-run --user /usr/local/bin/swww-daemon

# Check service definition
systemctl --user cat swww-daemon
```

---

## Service Files Location

All service definitions are in your Home Manager configuration:
```bash
# View service files
ls ~/.config/systemd/user/
# Output:
# cliphist-image.service
# cliphist-text.service
# playerctld.service
# quickshell-main.service
# quickshell-topbar.service
# swww-daemon.service
# volume-listener.service
```

Services are defined in: `~/.config/home-manager/modules/hyprland.nix`

---

## How Hyprland Starts Services

### Old Way (exec-once only)
```bash
# In hyprland.conf
exec-once = swww-daemon
exec-once = wl-paste --type text --watch cliphist store
exec-once = playerctld
```

**Problem:** If a service crashes, it stays dead. No logs, no restart.

### New Way (systemd)
```bash
# In hyprland.conf
exec-once = systemctl --user restart swww-daemon
exec-once = systemctl --user restart quickshell-main quickshell-topbar
exec-once = systemctl --user restart cliphist-text cliphist-image
exec-once = systemctl --user restart playerctld volume-listener
```

**Benefits:**
- ✅ Services automatically restart on failure
- ✅ Logs captured by journald
- ✅ Status visiblevia `systemctl --user status`
- ✅ Dependency ordering respected

---

## Comparison: Before vs After

### Before (exec-once)
```bash
# All services start at once, no control
exec-once = swww-daemon
exec-once = wl-paste --type text --watch cliphist store
exec-once = playerctld

# If swww-daemon crashes:
# → No restart
# → No logs (except in hyprland.log which is huge)
# → Can't checkstatus
# → Must manually restart
```

### After (systemd)
```bash
# Services managed by systemd
exec-once = systemctl --user restart swww-daemon
exec-once = systemctl --user restart cliphist-text cliphist-image
exec-once = systemctl --user restart playerctld

# If swww-daemon crashes:
# → Automatic restart in 2 seconds
# → Logs in journalctl --user -u swww-daemon
# → Status: systemctl --user status swww-daemon
# → Can view memory/CPU usage
# → Proper dependency ordering
```

---

## Testing the Migration

### 1. Verify All Services Created
```bash
systemctl --user list-unit-files | grep -E "(swww|quickshell|cliphist|playerctld|volume)"
```

Should show:
```
cliphist-image.service        linked    disabled
cliphist-text.service         linked    disabled
playerctld.service            linked    disabled
quickshell-main.service       linked    disabled
quickshell-topbar.service     linked    disabled
swww-daemon.service           linked    disabled
volume-listener.service       linked    disabled
```

### 2. Restart Hyprland
```bash
# Logout/login or:
hyprctl dispatch exit
```

### 3. Check Services Started
```bash
systemctl --user status swww-daemon quickshell-main cliphist-text playerctld
```

All should show: `Active: active (running)`

### 4. Test Restart on Failure
```bash
# Kill a service
pkill swww-daemon

# Watch it restart automatically
journalctl --user -u swww-daemon -f

# Should see:
# swww-daemon.service: Scheduled restart job...
# Started swww-daemon.service
```

---

## Common Issues

### Service Won't Start
```bash
# Check logs
journalctl --user -u <service-name> -n 50

# Check if executable exists
which swww-daemon
which quickshell
which cliphist
```

### Service KeepsRestarting
```bash
# Check for errors
journalctl --user -u <service-name> -f

# Might be missing dependency
# Check if binary exists:
which <binary-name>
```

### Display Not Found
```bash
# Make sure environment is imported
# In hyprland.conf, first line should be:
exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_RUNTIME_DIR DISPLAY
```

---

## Advanced: Custom service Options

### Add Environment Variables
```nix
# In hyprland.nix
quickshell-main = {
  Unit = {
    Description = "Quickshell Main Panel";
    After = [ "graphical-session.target" ];
  };
  Service = {
    ExecStart = "/usr/local/bin/quickshell -p %h/.config/hypr/scripts/quickshell/Main.qml";
    Environment = "QT_QPA_PLATFORM=wayland";  # Add env vars
    Restart = "on-failure";
    RestartSec = "3";
  };
};
```

### Limit Resources
```nix
playerctld = {
  Service = {
    ExecStart = "/usr/bin/playerctld";
    MemoryMax = "100M";  # Limit memory
    CPUQuota = "25%";    # Limit CPU
    Restart = "on-failure";
  };
};
```

### Add Dependencies
```nix
quickshell-main = {
  Unit = {
    Description = "Quickshell Main Panel";
    After = [ "graphical-session.target" ];
    Requires = [ "swww-daemon.service" ];  # Requires wallpaper daemon
  };
  # ...
};
```

---

## Summary

✅ **Migrated 7 services** from exec-once to systemd  
✅ **All services auto-restart** on failure  
✅ **All logs captured** by journald  
✅ **Dependency ordering** prevents race conditions  
✅ **Status visibility** via systemctl  

Your Hyprland setup is now **more robust and maintainable**! 🎉