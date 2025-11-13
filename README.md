# NixOS Dual Boot Configuration

This repository contains a modular NixOS configuration designed for dual booting alongside Windows 11.

## Quick Links

- **[Pre-Installation Checklist](INSTALLATION_GUIDE.md#pre-installation-checklist)** - Start here!
- **[Installation Guide](INSTALLATION_GUIDE.md)** - Step-by-step installation
- **[Dual Boot Planning](DUAL_BOOT_PLANNING.md)** - Design decisions and considerations
- **[Bootloader Configuration](SYSTEMD_BOOT_WINDOWS.md)** - Setting up dual boot menu

## Repository Structure

```
nixconfig/
├── configuration.nix              # Main system configuration
├── hardware-configuration.nix     # Auto-generated hardware config (not in git)
├── hosts/
│   └── default/
│       └── configuration.nix      # Host-specific settings
├── modules/
│   ├── desktop/                   # Desktop environments
│   │   ├── gnome.nix             # GNOME desktop
│   │   ├── kde.nix               # KDE Plasma desktop
│   │   └── hyprland.nix          # Hyprland (tiling WM)
│   ├── hardware/                  # Hardware-specific configs
│   │   ├── nvidia.nix            # NVIDIA GPU support
│   │   └── laptop.nix            # Laptop optimizations
│   └── services/                  # Optional services
│       ├── docker.nix            # Docker containers
│       └── virtualization.nix    # KVM/QEMU VMs
└── users/
    └── default-user.nix          # User account and packages
```

## Quick Start

### 1. Before Installation

- **Backup your Windows installation!**
- Read [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) completely
- Check [DUAL_BOOT_PLANNING.md](DUAL_BOOT_PLANNING.md) for planning

### 2. Customize Configuration

Before installation, edit these files:

1. **`users/default-user.nix`** - Set your username and packages
2. **`configuration.nix`** - Uncomment the desktop environment you want
3. **`configuration.nix`** - Set your timezone and hostname

### 3. Choose Desktop Environment

Uncomment ONE of these in `configuration.nix`:

```nix
./modules/desktop/gnome.nix      # For GNOME (recommended for beginners)
./modules/desktop/kde.nix        # For KDE Plasma
./modules/desktop/hyprland.nix   # For Hyprland (advanced)
```

### 4. Optional Hardware Modules

Uncomment as needed in `configuration.nix`:

```nix
./modules/hardware/nvidia.nix    # If you have NVIDIA GPU
./modules/hardware/laptop.nix    # If installing on a laptop
```

### 5. Optional Services

Uncomment as needed in `configuration.nix`:

```nix
./modules/services/docker.nix         # For Docker
./modules/services/virtualization.nix # For VMs
```

## Installation Process

See [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) for detailed instructions.

**Quick overview:**

1. Create NixOS USB installer
2. Shrink Windows partition
3. Boot from USB
4. Partition disk for NixOS
5. Install NixOS with minimal config
6. Clone this repository
7. Apply this configuration
8. Reboot and enjoy!

## Post-Installation

### Apply Configuration Changes

After editing any `.nix` files:

```bash
sudo nixos-rebuild switch
```

### Update System

```bash
sudo nixos-rebuild switch --upgrade
```

### List Generations

```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

### Rollback to Previous Generation

If something breaks:

```bash
sudo nixos-rebuild switch --rollback
```

Or select an older generation from the boot menu.

### Clean Up Old Generations

```bash
# Delete generations older than 30 days
sudo nix-collect-garbage --delete-older-than 30d

# Delete all old generations except current
sudo nix-collect-garbage -d
```

## Customization Tips

### Add More Packages

Edit `users/default-user.nix` and add packages to the `packages` list.

### Change Desktop Environment

1. Comment out current desktop module in `configuration.nix`
2. Uncomment different desktop module
3. Run `sudo nixos-rebuild switch`
4. Log out and log back in

### Enable Home Manager

Home Manager provides more granular user configuration. To enable:

```bash
# Add home-manager channel
nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
nix-channel --update

# Then edit users/default-user.nix and uncomment the home-manager section
```

### Mount Windows Partition

Edit `hardware-configuration.nix` and add:

```nix
fileSystems."/mnt/windows" = {
  device = "/dev/nvme0n1p3"; # Change to your Windows partition
  fsType = "ntfs-3g";
  options = [ "rw" "uid=1000" ];
};
```

## Troubleshooting

### System Won't Boot

1. Boot from NixOS USB
2. Mount your NixOS partitions
3. Check configuration for errors
4. Or, select previous generation from boot menu

### Windows Doesn't Show in Boot Menu

See [SYSTEMD_BOOT_WINDOWS.md](SYSTEMD_BOOT_WINDOWS.md)

### Time is Wrong in Windows or NixOS

This is normal with dual boot. See [DUAL_BOOT_PLANNING.md](DUAL_BOOT_PLANNING.md#time-sync-issues)

The configuration includes `time.hardwareClockInLocalTime = true;` which should fix this.

### Package Not Found

```bash
# Search for packages
nix search nixpkgs package-name

# Or use online search
# https://search.nixos.org/packages
```

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NixOS Wiki](https://nixos.wiki/)
- [Nix Package Search](https://search.nixos.org/packages)
- [NixOS Discourse](https://discourse.nixos.org/)
- [NixOS Reddit](https://www.reddit.com/r/NixOS/)

## Contributing

Feel free to fork this repository and customize it for your needs!

## License

This configuration is provided as-is for educational purposes. Use at your own risk.
