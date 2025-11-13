# Laptop-specific configuration
# Enable this for laptop-specific optimizations

{ config, pkgs, ... }:

{
  # TLP for better battery life
  services.tlp = {
    enable = true;
    settings = {
      # Battery thresholds (helps preserve battery health)
      # Values work on most ThinkPads and some other laptops
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;

      # CPU scaling
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # Enable audio power saving
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
    };
  };

  # Prevent conflicts with TLP
  services.power-profiles-daemon.enable = false;

  # Enable thermald for Intel CPUs (prevents overheating)
  services.thermald.enable = true;

  # Better touchpad support
  services.xserver.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true; # Reverse scrolling direction (macOS-like)
      tapping = true; # Tap to click
      disableWhileTyping = true;
    };
  };

  # Enable firmware updates via fwupd
  services.fwupd.enable = true;

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
  services.blueman.enable = true;

  # Backlight control
  programs.light.enable = true;

  # Laptop-specific packages
  environment.systemPackages = with pkgs; [
    acpi # Battery status
    powertop # Power usage monitoring
    brightnessctl # Screen brightness control
  ];
}
