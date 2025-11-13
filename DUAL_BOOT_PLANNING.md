# NixOS + Windows 11 Dual Boot Setup Planning

## Pre-Installation Considerations

### 1. Disk Partitioning Strategy
- **Windows 11 Requirements:**
  - EFI System Partition (ESP): Already exists, typically 100-500MB
  - Windows partition: Already installed
  - Microsoft Reserved partition: Already exists

- **NixOS Partitions Needed:**
  - Share existing ESP (recommended) OR create separate ESP
  - Root partition (/) - 40GB minimum, 100GB+ recommended
  - Swap partition - Equal to RAM for hibernation, or 8-16GB
  - Optional: Separate /home partition for data persistence
  - Optional: /nix/store on larger partition (grows over time)

### 2. Bootloader Choice
- **systemd-boot (recommended for UEFI):**
  - Simpler, cleaner
  - Better Windows 11 compatibility
  - Easier to configure in NixOS
  - No theme complications

- **GRUB:**
  - More features (themes, advanced options)
  - Can auto-detect Windows
  - Slightly more complex

**Recommendation: systemd-boot** for dual boot simplicity

### 3. Time Sync Issues
- Windows uses local time for hardware clock
- Linux uses UTC by default
- **Solution:** Configure NixOS to use local time OR set Windows to use UTC
  ```nix
  time.hardwareClockInLocalTime = true;
  ```

### 4. Shared Data Access
- Mount Windows NTFS partitions in NixOS (read/write with ntfs-3g)
- Consider a shared FAT32/exFAT data partition
- Be cautious with Windows fast startup (can lock NTFS partitions)

### 5. BitLocker Consideration
- If Windows drive is encrypted with BitLocker, disabling fast startup is crucial
- NixOS modifications to ESP may trigger BitLocker recovery

### 6. Fast Startup & Hibernation
- Disable Windows Fast Startup to prevent filesystem lock issues
- Disable Windows hibernation if sharing partitions

## Disk Space Recommendations

### Minimal Setup (100GB for NixOS)
- ESP: 512MB (shared with Windows)
- Swap: 16GB
- Root (/): 84GB

### Recommended Setup (200GB+ for NixOS)
- ESP: 1GB (shared with Windows)
- Swap: 16-32GB
- Root (/): 50GB
- /home: Remaining space

### Advanced Setup (Separate /nix/store)
- ESP: 1GB
- Swap: 16-32GB
- Root (/): 30GB
- /nix: 100GB+
- /home: Remaining space

## Hardware Considerations

### Graphics
- **NVIDIA:** Requires proprietary drivers
  - Can be challenging, but NixOS handles it well
  - May need nomodeset during installation

- **AMD/Intel:** Better out-of-box support
  - Open-source drivers work well

### WiFi
- Some WiFi cards need proprietary firmware
- NixOS can handle this with `hardware.enableRedistributableFirmware`

### Secure Boot
- Windows 11 requires Secure Boot
- NixOS can work with Secure Boot (using lanzaboote)
- Easier to disable Secure Boot initially, enable later if needed

## NixOS Configuration Strategy

### Modular Structure
```
nixconfig/
├── flake.nix (modern approach) OR configuration.nix (classic)
├── hardware-configuration.nix (auto-generated)
├── hosts/
│   └── your-hostname/
│       ├── configuration.nix
│       └── hardware.nix
├── modules/
│   ├── desktop/
│   │   ├── gnome.nix
│   │   ├── kde.nix
│   │   └── hyprland.nix
│   ├── hardware/
│   │   ├── nvidia.nix
│   │   └── laptop.nix
│   └── services/
│       ├── docker.nix
│       └── virtualization.nix
└── users/
    └── your-username.nix
```

## Desktop Environment Choices

Coming from WSL, consider:
1. **GNOME:** Polished, user-friendly, good touchpad support
2. **KDE Plasma:** Highly customizable, Windows-like
3. **Hyprland/Sway:** Tiling, if you like i3/vim-style workflows
4. **XFCE:** Lightweight, traditional

## Essential Packages for WSL Users

- `git`, `vim/neovim`, `tmux`
- `vscode` or `vscodium`
- `firefox` or `chromium`
- `docker`, `podman`
- Terminal: `alacritty`, `kitty`, or `wezterm`
- Shell: `fish` or `zsh` with oh-my-zsh

## Installation Steps Overview

1. **Backup Windows** (full system backup!)
2. **Shrink Windows partition** (using Windows Disk Management)
3. **Create NixOS USB installer**
4. **Boot from USB**
5. **Partition free space for NixOS**
6. **Install NixOS**
7. **Configure bootloader to show both OSes**
8. **Boot into NixOS and apply this configuration**
9. **Verify Windows still boots**

## Post-Installation Tasks

- [ ] Verify both OSes boot correctly
- [ ] Configure time sync (set NixOS to local time)
- [ ] Mount Windows partition (if needed)
- [ ] Disable Windows fast startup
- [ ] Set up home-manager for user dotfiles
- [ ] Configure automatic system updates
- [ ] Set up backups (timeshift, restic, etc.)

## Useful NixOS Commands

```bash
# Apply configuration changes
sudo nixos-rebuild switch

# Test configuration without switching
sudo nixos-rebuild test

# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Garbage collect old generations
sudo nix-collect-garbage -d

# Update channels
sudo nix-channel --update
sudo nixos-rebuild switch --upgrade
```

## Troubleshooting

### Windows doesn't show in boot menu
- Check if os-prober is enabled (for GRUB)
- Manually add Windows entry to systemd-boot
- Verify ESP is properly mounted

### NixOS doesn't boot
- Boot from USB, mount partitions, chroot, fix config
- Use previous generation from boot menu

### Time shows wrong in Windows/NixOS
- Set `time.hardwareClockInLocalTime = true;` in NixOS

### Cannot mount Windows partition
- Disable Windows fast startup
- Boot into Windows, shut down properly (not restart)
