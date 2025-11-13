# KDE Plasma Desktop Environment
# Highly customizable, Windows-like experience

{ config, pkgs, ... }:

{
  # Enable X11 and KDE Plasma
  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;

    # Keyboard layout
    xkb = {
      layout = "us";
      # variant = "";
    };

    # Enable touchpad support
    libinput.enable = true;
  };

  # KDE-specific packages
  environment.systemPackages = with pkgs; [
    # KDE Applications
    kdePackages.kate
    kdePackages.kdialog
    kdePackages.kio-extras
    kdePackages.ark # Archive manager
    kdePackages.gwenview # Image viewer
    kdePackages.okular # PDF viewer
    kdePackages.spectacle # Screenshot tool
    kdePackages.dolphin # File manager

    # Plasma addons
    kdePackages.plasma-browser-integration
  ];

  # Enable KDE Connect for phone integration
  programs.kdeconnect.enable = true;
}
