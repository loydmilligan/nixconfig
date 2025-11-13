# Hyprland - Modern Wayland Tiling Compositor
# For advanced users who want a tiling window manager
# Requires more manual configuration but very efficient

{ config, pkgs, ... }:

{
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Display manager for login
  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };

    # Keyboard layout
    xkb = {
      layout = "us";
      # variant = "";
    };
  };

  # Essential packages for Hyprland
  environment.systemPackages = with pkgs; [
    # Status bar and app launcher
    waybar
    wofi
    rofi-wayland

    # Terminal emulator
    kitty
    alacritty

    # Notifications
    mako
    libnotify

    # Screen lock
    swaylock

    # Wallpaper
    swaybg
    hyprpaper

    # Screenshots
    grim
    slurp
    wl-clipboard

    # File manager
    xfce.thunar

    # Other essentials
    firefox
    pavucontrol # Audio control
    networkmanagerapplet
  ];

  # XDG portal for screen sharing
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Note: You'll need to create ~/.config/hypr/hyprland.conf
  # See https://wiki.hyprland.org/ for configuration examples
}
