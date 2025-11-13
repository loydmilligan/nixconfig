# Adding Windows to systemd-boot Menu

If Windows doesn't appear in your boot menu after installation, you can manually add it.

## Option 1: Windows Boot Manager Should Auto-Appear

In most cases, systemd-boot will automatically detect the Windows Boot Manager on the EFI partition. If you don't see it:

1. Reboot and enter the boot menu (usually F12 or ESC during POST)
2. Look for "Windows Boot Manager" in the firmware boot menu
3. If it's there, systemd-boot should also show it

## Option 2: Manually Add Windows Entry

If Windows still doesn't show up, you can create a custom boot entry:

### Step 1: Find Windows EFI Boot File

```bash
sudo ls -la /boot/EFI/
# or if your ESP is mounted at /boot/efi
sudo ls -la /boot/efi/EFI/
```

You should see directories like:
- `Microsoft/` - Windows bootloader
- `systemd/` - NixOS bootloader
- `Boot/` - Default bootloader

### Step 2: Create Custom Entry

Create a file at `/boot/loader/entries/windows.conf`:

```bash
sudo vim /boot/loader/entries/windows.conf
```

Add the following content (adjust paths if needed):

```
title   Windows 11
efi     /EFI/Microsoft/Boot/bootmgfw.efi
```

### Step 3: Verify

Reboot and you should see "Windows 11" in the systemd-boot menu.

## Option 3: Use NixOS Configuration

You can also add Windows entry declaratively in your NixOS config:

```nix
# In your configuration.nix
boot.loader.systemd-boot.extraEntries = {
  "windows.conf" = ''
    title   Windows 11
    efi     /EFI/Microsoft/Boot/bootmgfw.efi
  '';
};
```

Then rebuild:
```bash
sudo nixos-rebuild switch
```

## Troubleshooting

### Windows Entry Doesn't Boot

1. Verify the EFI file exists:
   ```bash
   ls -la /boot/EFI/Microsoft/Boot/bootmgfw.efi
   ```

2. Check your BIOS/UEFI settings:
   - Secure Boot might need to be disabled
   - Boot order might need adjustment

3. Try the full path:
   ```
   efi     /EFI/Microsoft/Boot/bootmgfw.efi
   ```

### Both OSes Show But One Doesn't Work

- **NixOS boots but Windows doesn't:** Windows fast startup might be enabled. Boot into Windows and disable it.
- **Windows boots but NixOS doesn't:** Check that EFI variables are correctly set. You may need to run `sudo bootctl install` from a NixOS live USB.

## Recommended: Set Default Boot Entry

To make NixOS the default (or Windows):

```nix
# In configuration.nix
boot.loader.systemd-boot.default = "nixos-generation-*.conf"; # for NixOS
# or
boot.loader.systemd-boot.default = "windows.conf"; # for Windows
```

Or set it manually:
```bash
sudo bootctl set-default windows.conf
# or
sudo bootctl set-default nixos-generation-1.conf
```

## Check Current Boot Configuration

```bash
sudo bootctl status
sudo bootctl list
```
