# NixOS Dual Boot Installation Guide

Complete step-by-step guide for installing NixOS alongside Windows 11.

## Pre-Installation Checklist

### Critical Steps (DO NOT SKIP!)

- [ ] **BACKUP YOUR ENTIRE WINDOWS INSTALLATION**
  - Use Windows Backup or third-party tools (Macrium Reflect, Acronis, etc.)
  - Backup to external drive or cloud storage
  - Verify backup is complete and can be restored

- [ ] **Check your Windows version**
  - Must be Windows 10/11 on UEFI system
  - Open PowerShell: `Get-ComputerInfo | Select-Object BiosMode`
  - Should say "UEFI", not "Legacy" or "BIOS"

- [ ] **Disable BitLocker (if enabled)**
  - Search "BitLocker" in Windows
  - Decrypt your drive before proceeding
  - Can re-enable after NixOS installation

- [ ] **Disable Fast Startup in Windows**
  - Settings → System → Power & sleep → Additional power settings
  - Choose what the power buttons do
  - Uncheck "Turn on fast startup"
  - This prevents filesystem lock issues

- [ ] **Disable Secure Boot (temporarily)**
  - Enter BIOS/UEFI (usually F2, F10, or DEL during boot)
  - Find and disable Secure Boot
  - Can re-enable later with lanzaboote if needed

- [ ] **Check available disk space**
  - Need at least 100GB free for minimal NixOS installation
  - Recommended: 200GB+ for comfortable usage

- [ ] **Download NixOS ISO**
  - Get latest minimal ISO from https://nixos.org/download
  - Current stable: 24.05 (or check for newer)
  - Verify SHA256 checksum

- [ ] **Create bootable USB**
  - Use Rufus (Windows), balenaEtcher, or `dd`
  - Minimum 2GB USB drive required
  - All data on USB will be erased!

- [ ] **Have this repository accessible**
  - Clone it to a USB drive, or
  - Know the git URL to clone during installation

### Recommended Steps

- [ ] Check for BIOS/UEFI firmware updates
- [ ] Run Windows Update completely
- [ ] Defragment Windows partition (if HDD, not SSD)
- [ ] Test your backup by attempting a restore (optional but smart)

## Installation Steps

### Phase 1: Prepare Disk Space in Windows

1. **Open Disk Management**
   - Press `Win + X`, select "Disk Management"
   - Or search "Create and format hard disk partitions"

2. **Shrink Windows Partition**
   - Right-click on your Windows (C:) partition
   - Select "Shrink Volume"
   - Enter amount to shrink (in MB):
     - For 100GB NixOS: enter `102400` MB
     - For 200GB NixOS: enter `204800` MB
   - Click "Shrink"
   - You should now see unallocated space

3. **Leave the unallocated space as-is**
   - Do NOT create a new partition
   - We'll partition it from NixOS installer

4. **Restart to Windows** one more time
   - Make sure everything still works
   - This is your last chance to back out!

### Phase 2: Boot NixOS Installer

1. **Insert USB drive and restart**
   - Enter boot menu (usually F12, F8, or ESC)
   - Select your USB drive
   - Choose "NixOS Installer" from the menu

2. **Wait for installer to load**
   - You'll see a terminal with root access
   - Network might auto-configure via DHCP

3. **Optional: Connect to WiFi**
   ```bash
   # If you need WiFi (skip if using Ethernet)
   sudo systemctl start wpa_supplicant
   wpa_cli
   > add_network
   0
   > set_network 0 ssid "Your-WiFi-Name"
   > set_network 0 psk "your-wifi-password"
   > set_network 0 key_mgmt WPA-PSK
   > enable_network 0
   > quit
   ```

4. **Verify internet connection**
   ```bash
   ping -c 3 nixos.org
   ```

### Phase 3: Partition the Disk

**DANGER ZONE: Triple-check every command!**

1. **List disks**
   ```bash
   lsblk
   ```

   You should see:
   - Your Windows partitions (usually `/dev/nvme0n1p1`, `p2`, etc. or `/dev/sda1`, etc.)
   - EFI System Partition (100-500MB, type "EFI System")
   - Windows partition (large NTFS partition)
   - Unallocated space (no partition)

2. **Identify the correct disk**
   - Usually `/dev/nvme0n1` (NVMe SSD) or `/dev/sda` (SATA)
   - **DO NOT FORMAT THE ENTIRE DISK!**
   - We're only creating partitions in the free space

3. **Use parted or fdisk to partition**

   **Option A: Using fdisk (recommended)**

   ```bash
   sudo fdisk /dev/nvme0n1  # Replace with your disk!
   ```

   Commands in fdisk:
   - `p` - print partition table (verify Windows partitions are there!)
   - `n` - new partition
   - `p` - primary partition
   - Accept default partition number
   - Accept default first sector (should start after Windows)
   - For last sector:
     - For swap: `+16G` (16GB swap)
     - For root: press Enter (use all remaining space)
   - `t` - change partition type
   - Enter partition number
   - `82` for swap, or `83` for Linux filesystem
   - `p` - verify everything looks correct!
   - `w` - write changes (NO GOING BACK AFTER THIS!)

   **Option B: Using parted**

   ```bash
   sudo parted /dev/nvme0n1  # Replace with your disk!
   ```

   Commands:
   ```
   print free              # See free space
   mkpart primary linux-swap <start> <end>   # Create swap
   mkpart primary ext4 <start> <end>         # Create root
   quit
   ```

4. **Example final layout** (your numbers will differ!):
   ```
   /dev/nvme0n1p1  500M   EFI System (Windows)
   /dev/nvme0n1p2  16M    Microsoft Reserved
   /dev/nvme0n1p3  250G   Microsoft Basic Data (Windows C:)
   /dev/nvme0n1p4  16G    Linux swap
   /dev/nvme0n1p5  184G   Linux filesystem (NixOS root)
   ```

### Phase 4: Format and Mount Partitions

1. **Format the new partitions**
   ```bash
   # Format swap (adjust partition number!)
   sudo mkswap /dev/nvme0n1p4
   sudo swapon /dev/nvme0n1p4

   # Format root partition
   sudo mkfs.ext4 -L nixos /dev/nvme0n1p5
   ```

2. **Mount root partition**
   ```bash
   sudo mount /dev/nvme0n1p5 /mnt
   ```

3. **Mount EFI partition**
   ```bash
   # Create boot directory
   sudo mkdir -p /mnt/boot

   # Mount EFI partition (usually p1, but check with lsblk!)
   sudo mount /dev/nvme0n1p1 /mnt/boot
   ```

4. **Verify mounts**
   ```bash
   lsblk
   ```

   Should show:
   - `/dev/nvme0n1p5` mounted at `/mnt`
   - `/dev/nvme0n1p1` mounted at `/mnt/boot`
   - `/dev/nvme0n1p4` as swap

### Phase 5: Generate Initial Configuration

1. **Generate hardware config**
   ```bash
   sudo nixos-generate-config --root /mnt
   ```

   This creates:
   - `/mnt/etc/nixos/configuration.nix` (template)
   - `/mnt/etc/nixos/hardware-configuration.nix` (hardware-specific)

2. **Optional: Review hardware config**
   ```bash
   cat /mnt/etc/nixos/hardware-configuration.nix
   ```

### Phase 6: Create Minimal Bootable Configuration

We'll install with a minimal config first, then apply your full config after booting.

1. **Edit the configuration**
   ```bash
   sudo nano /mnt/etc/nixos/configuration.nix
   ```

2. **Replace with this minimal config:**
   ```nix
   { config, pkgs, ... }:
   {
     imports = [ ./hardware-configuration.nix ];

     boot.loader = {
       systemd-boot.enable = true;
       efi.canTouchEfiVariables = true;
     };

     time.hardwareClockInLocalTime = true; # For dual boot!
     time.timeZone = "America/New_York"; # Change to your timezone

     networking.hostName = "nixos";
     networking.networkmanager.enable = true;

     users.users.nixos = {
       isNormalUser = true;
       extraGroups = [ "wheel" "networkmanager" ];
       initialPassword = "nixos"; # CHANGE AFTER FIRST BOOT!
     };

     environment.systemPackages = with pkgs; [
       vim
       git
       wget
       firefox
     ];

     services.xserver = {
       enable = true;
       displayManager.gdm.enable = true;
       desktopManager.gnome.enable = true;
       xkb.layout = "us";
     };

     nixpkgs.config.allowUnfree = true;
     nix.settings.experimental-features = [ "nix-command" "flakes" ];

     system.stateVersion = "24.05";
   }
   ```

3. **Save and exit** (Ctrl+X, Y, Enter in nano)

### Phase 7: Install NixOS

1. **Run the installation**
   ```bash
   sudo nixos-install
   ```

   This will:
   - Download packages (can take 15-60 minutes)
   - Install the system
   - Ask you to set root password (REMEMBER THIS!)

2. **Wait for completion**
   - If errors occur, check your configuration
   - Common issues: network problems, partition errors

3. **Reboot**
   ```bash
   reboot
   ```

### Phase 8: First Boot

1. **Remove USB drive during reboot**

2. **Boot menu should appear**
   - Should show "NixOS" entries
   - Should also show "Windows Boot Manager"
   - If Windows is missing, see [SYSTEMD_BOOT_WINDOWS.md](SYSTEMD_BOOT_WINDOWS.md)

3. **Boot into NixOS**

4. **Log in**
   - Username: `nixos` (or whatever you set)
   - Password: (what you set in config)

5. **Connect to network**
   - Should auto-connect via Network Manager
   - Or use the GUI network settings

### Phase 9: Apply Your Custom Configuration

1. **Clone this repository**
   ```bash
   cd ~
   git clone https://github.com/yourusername/nixconfig.git
   # Or if you have it on a USB drive, copy it
   ```

2. **Customize the configuration**
   ```bash
   cd nixconfig

   # Edit user configuration
   vim users/default-user.nix
   # Change "yourusername" to your actual username

   # Edit main config - uncomment your desktop choice
   vim configuration.nix
   # Uncomment ONE desktop environment module
   # Uncomment hardware modules as needed
   ```

3. **Copy hardware configuration**
   ```bash
   sudo cp /etc/nixos/hardware-configuration.nix ~/nixconfig/
   ```

4. **Backup old config and link new one**
   ```bash
   sudo mv /etc/nixos /etc/nixos.backup
   sudo ln -s ~/nixconfig /etc/nixos
   ```

5. **Apply the configuration**
   ```bash
   sudo nixos-rebuild switch
   ```

   This will:
   - Download and install all your packages
   - Set up your desktop environment
   - Configure everything according to your modules

6. **Create your actual user account**

   After rebuild completes, your user should exist. Log out and log in with your new username.

7. **Set your password**
   ```bash
   passwd
   ```

8. **Delete the temporary user** (optional)
   ```bash
   sudo userdel -r nixos
   ```

### Phase 10: Verify Everything Works

1. **Test NixOS**
   - [ ] Desktop environment loads correctly
   - [ ] Network connection works
   - [ ] Sound works
   - [ ] Graphics are working (not super slow)

2. **Test Windows**
   - Reboot and select "Windows Boot Manager" from boot menu
   - [ ] Windows boots successfully
   - [ ] Check if time is correct (might be off by timezone)
   - [ ] All files are intact

3. **Fix time if needed**
   - In Windows, you may need to:
   ```powershell
   # Run as Administrator
   reg add "HKLM\System\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /d 1 /t REG_DWORD /f
   ```
   - Or just let NixOS use local time (already configured in our config)

## Post-Installation Tasks

### Update Your Configuration

```bash
cd ~/nixconfig
# Make changes to .nix files
sudo nixos-rebuild switch
```

### Keep System Updated

```bash
sudo nixos-rebuild switch --upgrade
```

### Optimize Boot Time (Optional)

```bash
# List what's slowing boot
systemd-analyze blame
systemd-analyze critical-chain
```

### Set Up Backups

Consider setting up:
- Timeshift (for system snapshots)
- Restic or Borg (for file backups)
- Regular git commits of your nixconfig

### Enable Home Manager (Optional)

For more detailed user configuration:

```bash
nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
nix-channel --update
```

Then uncomment the home-manager section in `users/default-user.nix`.

## Troubleshooting

### Installation Fails

- Check internet connection
- Verify partition layout with `lsblk`
- Check configuration syntax: `sudo nixos-rebuild build`

### System Won't Boot

- Select older generation from boot menu
- Boot from USB and chroot to fix:
  ```bash
  sudo mount /dev/nvme0n1p5 /mnt
  sudo mount /dev/nvme0n1p1 /mnt/boot
  sudo nixos-enter
  # Fix configuration
  nixos-rebuild switch
  ```

### Windows Won't Boot

- Try booting directly from BIOS/UEFI boot menu (F12)
- Check if Windows Boot Manager is still in UEFI variables
- Worst case: Boot Windows recovery USB and run:
  ```
  bootrec /fixboot
  bootrec /fixmbr
  ```

### Graphics Issues

- If screen is black or frozen during install:
  - Add `nomodeset` to boot parameters
  - For NVIDIA: Install with basic drivers, then add nvidia.nix later

### Network Not Working

```bash
# Check status
nmcli device status

# Connect to WiFi
nmcli device wifi connect "SSID" password "password"
```

## Getting Help

- [NixOS Discourse](https://discourse.nixos.org/)
- [NixOS Wiki](https://nixos.wiki/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- IRC: #nixos on Libera.Chat
- Reddit: r/NixOS

## Success!

If you've made it here, congratulations! You now have a working NixOS dual boot setup.

Next steps:
- Customize your configuration
- Install your favorite applications
- Learn about Nix flakes
- Set up home-manager
- Enjoy declarative, reproducible configuration!
