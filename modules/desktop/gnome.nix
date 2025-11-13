# GNOME Desktop Environment
# Modern, polished desktop with good touchpad/gesture support

{ config, pkgs, ... }:

{
  # Enable X11 and GNOME
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    # Keyboard layout
    xkb = {
      layout = "us";
      # variant = "";
    };

    # Enable touchpad support
    libinput.enable = true;
  };

  # GNOME-specific packages
  environment.systemPackages = with pkgs; [
    gnome.gnome-tweaks
    gnome.dconf-editor
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.blur-my-shell

    # Useful GNOME apps
    gnome.gnome-terminal
    gnome.nautilus
    gnome.file-roller # Archive manager
    gnome.eog # Image viewer
    gnome.evince # PDF viewer
  ];

  # Exclude some default GNOME apps (optional)
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome.geary # Email client
    gnome.gnome-music
    # gnome.epiphany # Web browser
    # gnome.totem # Video player
  ];
}
