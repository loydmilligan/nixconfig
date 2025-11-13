# NixOS Quick Reference Cheat Sheet

## System Management

### Apply Configuration Changes
```bash
# Apply changes and make them default
sudo nixos-rebuild switch

# Test changes without making them default
sudo nixos-rebuild test

# Build but don't activate
sudo nixos-rebuild build

# Apply changes and update all packages
sudo nixos-rebuild switch --upgrade
```

### Rollback and Generations
```bash
# List all generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Switch to specific generation
sudo nix-env --switch-generation 42 --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Boot into older generation (temporary)
# Select it from the boot menu
```

### Garbage Collection
```bash
# Remove old generations and unused packages
sudo nix-collect-garbage

# Remove old generations older than 30 days
sudo nix-collect-garbage --delete-older-than 30d

# Aggressive cleanup (removes everything not currently used)
sudo nix-collect-garbage -d

# Optimize nix store (deduplication)
sudo nix-store --optimize
```

### System Information
```bash
# Show current NixOS version
nixos-version

# Show system configuration
nixos-option system.stateVersion

# Show all system packages
nix-env -qa

# Show installed packages
nix-env -q
```

## Package Management

### Search for Packages
```bash
# Search online (recommended)
# Visit: https://search.nixos.org/packages

# Search locally (requires channel update)
nix search nixpkgs <package-name>

# Search with nix-env (older method)
nix-env -qaP | grep <package-name>
```

### Install Packages (Ad-hoc, not recommended)
```bash
# Install package temporarily (not in config)
nix-env -iA nixpkgs.packagename

# Uninstall package
nix-env -e packagename

# List installed user packages
nix-env -q
```

### Install Packages (Recommended: via configuration.nix)
```nix
# Add to configuration.nix or users/default-user.nix
environment.systemPackages = with pkgs; [
  packagename
];
# Then run: sudo nixos-rebuild switch
```

## Channels (Package Sources)

### Manage Channels
```bash
# List channels
sudo nix-channel --list

# Add channel
sudo nix-channel --add https://nixos.org/channels/nixos-24.05 nixos

# Update channels
sudo nix-channel --update

# Update specific channel
sudo nix-channel --update nixos
```

### Popular Channels
```bash
# Stable
https://nixos.org/channels/nixos-24.05

# Unstable (bleeding edge)
https://nixos.org/channels/nixos-unstable

# Home Manager (stable)
https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz
```

## Configuration Management

### Edit Configuration
```bash
# Edit main configuration
sudo vim /etc/nixos/configuration.nix

# Check configuration for syntax errors
sudo nixos-rebuild build

# Show current configuration file location
readlink -f /etc/nixos
```

### Common Configuration Tasks

**Add a user:**
```nix
users.users.newuser = {
  isNormalUser = true;
  extraGroups = [ "wheel" "networkmanager" ];
  packages = with pkgs; [ firefox vim ];
};
```

**Enable a service:**
```nix
services.servicename.enable = true;
```

**Install system package:**
```nix
environment.systemPackages = with pkgs; [
  packagename
];
```

## Networking

### Network Manager (GUI/CLI)
```bash
# List networks
nmcli device wifi list

# Connect to WiFi
nmcli device wifi connect "SSID" password "password"

# Show connection status
nmcli device status

# Show connection details
nmcli connection show
```

### Basic Network Commands
```bash
# Check IP address
ip addr show

# Check routing
ip route

# Test connectivity
ping -c 3 google.com

# DNS lookup
nslookup google.com
```

## Services

### Systemd Service Management
```bash
# Start a service
sudo systemctl start servicename

# Stop a service
sudo systemctl stop servicename

# Restart a service
sudo systemctl restart servicename

# Enable service at boot
sudo systemctl enable servicename

# Disable service at boot
sudo systemctl disable servicename

# Check service status
sudo systemctl status servicename

# View service logs
sudo journalctl -u servicename

# Follow service logs (live)
sudo journalctl -u servicename -f
```

## Boot and Bootloader

### systemd-boot
```bash
# List boot entries
sudo bootctl list

# Show boot status
sudo bootctl status

# Reinstall bootloader
sudo bootctl install

# Set default entry
sudo bootctl set-default nixos-generation-1.conf
```

### Boot Issues
```bash
# Boot into recovery (single user mode)
# Add to kernel parameters: systemd.unit=rescue.target

# Boot into emergency mode
# Add to kernel parameters: systemd.unit=emergency.target
```

## Disk and Filesystems

### Check Disk Usage
```bash
# Disk usage by filesystem
df -h

# Disk usage by directory
du -sh /home/*

# NixOS store size
du -sh /nix/store

# Show largest packages
nix path-info -S -r /run/current-system | sort -nk2
```

### Mount Partitions
```bash
# List partitions
lsblk

# Mount partition
sudo mount /dev/sdXY /mnt/mountpoint

# Mount in configuration.nix (persistent)
fileSystems."/mnt/data" = {
  device = "/dev/disk/by-uuid/XXXXX";
  fsType = "ext4";
};
```

## Development

### Nix Shell (Temporary Environments)
```bash
# Enter shell with specific packages
nix-shell -p python3 nodejs

# Use shell.nix file
nix-shell

# Run command in nix-shell
nix-shell -p python3 --run "python --version"
```

### Nix Develop (Flakes)
```bash
# Enter development environment
nix develop

# Run command in dev environment
nix develop -c make
```

## Docker (if enabled)

### Docker Commands
```bash
# List containers
docker ps -a

# List images
docker images

# Remove unused containers/images
docker system prune

# Add user to docker group (requires logout)
sudo usermod -aG docker $USER
```

## User Management

### User Commands
```bash
# Change password
passwd

# Change another user's password (as root)
sudo passwd username

# Add user to group
sudo usermod -aG groupname username

# List all users
cat /etc/passwd

# List all groups
cat /etc/group
```

## Hardware

### Hardware Information
```bash
# List PCI devices (GPU, etc.)
lspci

# List USB devices
lsusb

# CPU information
lscpu

# Memory information
free -h

# Detailed hardware info
sudo lshw

# Disk information
sudo fdisk -l
```

### Graphics
```bash
# Check GPU (NVIDIA)
nvidia-smi

# Check GPU (general)
glxinfo | grep "OpenGL renderer"

# Test graphics performance
glxgears
```

## Troubleshooting

### System Logs
```bash
# View system journal
sudo journalctl

# Last boot logs
sudo journalctl -b

# Follow logs (live)
sudo journalctl -f

# Logs since yesterday
sudo journalctl --since yesterday

# Logs for specific service
sudo journalctl -u servicename
```

### Boot Analysis
```bash
# Show boot time
systemd-analyze

# Show what's slowing boot
systemd-analyze blame

# Show boot chain
systemd-analyze critical-chain
```

### Fix Broken System
```bash
# Boot from USB installer
# Then mount and chroot:
sudo mount /dev/sdXY /mnt
sudo mount /dev/sdX1 /mnt/boot  # EFI partition
sudo nixos-enter --root /mnt

# Now you're in your system, fix config and rebuild
sudo nixos-rebuild switch
```

## Useful Aliases

Add these to your shell config (.bashrc, .zshrc, etc.):

```bash
# NixOS
alias nrs='sudo nixos-rebuild switch'
alias nrb='sudo nixos-rebuild build'
alias nrt='sudo nixos-rebuild test'
alias nru='sudo nixos-rebuild switch --upgrade'
alias nrr='sudo nixos-rebuild switch --rollback'

# Nix
alias ngc='sudo nix-collect-garbage -d'
alias nsh='nix-shell'
alias nsp='nix search nixpkgs'

# System
alias syslog='sudo journalctl -f'
alias boottime='systemd-analyze'
```

## Getting More Help

```bash
# NixOS manual
man configuration.nix

# Nix package manager manual
man nix

# List all NixOS man pages
man -k nixos

# NixOS options search
# Visit: https://search.nixos.org/options
```

## Emergency Commands

### System Won't Boot
1. Select older generation from boot menu
2. Or boot from USB and rollback:
   ```bash
   sudo mount /dev/sdXY /mnt
   sudo mount /dev/sdX1 /mnt/boot
   sudo nixos-enter --root /mnt
   sudo nixos-rebuild switch --rollback
   ```

### Out of Disk Space
```bash
# Quick cleanup
sudo nix-collect-garbage -d
sudo nix-store --optimize

# Check what's using space
du -sh /nix/store
nix path-info -S -r /run/current-system | sort -nk2 | tail -20
```

### Network Lost After Update
```bash
# Rollback
sudo nixos-rebuild switch --rollback

# Or restart NetworkManager
sudo systemctl restart NetworkManager
```

## Quick Configuration Examples

### Enable SSH
```nix
services.openssh = {
  enable = true;
  settings.PasswordAuthentication = false;
  settings.PermitRootLogin = "no";
};
```

### Enable Firewall Ports
```nix
networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 22 80 443 ];
  allowedUDPPorts = [ 53 ];
};
```

### Auto-Mount USB Drives
```nix
services.udisks2.enable = true;
```

### Enable Bluetooth
```nix
hardware.bluetooth.enable = true;
services.blueman.enable = true;
```

## Pro Tips

1. **Always test before switching:**
   ```bash
   sudo nixos-rebuild test
   # If it works:
   sudo nixos-rebuild switch
   ```

2. **Keep your config in git:**
   ```bash
   cd /etc/nixos
   git add -A
   git commit -m "Description of changes"
   ```

3. **Don't panic if something breaks:**
   - Boot menu shows all generations
   - Can always rollback
   - System is declarative - easy to reproduce

4. **Use home-manager for user configs:**
   - More control over dotfiles
   - Per-user package management
   - Declarative user environment

5. **Search before installing:**
   - Check https://search.nixos.org first
   - Read package descriptions
   - Check for known issues

## Resources

- **Package Search:** https://search.nixos.org/packages
- **Options Search:** https://search.nixos.org/options
- **Manual:** https://nixos.org/manual/nixos/stable/
- **Wiki:** https://nixos.wiki/
- **Discourse:** https://discourse.nixos.org/
- **Reddit:** https://reddit.com/r/NixOS
