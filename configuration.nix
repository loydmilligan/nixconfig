# NixOS System Configuration
# Main configuration file - edit this to customize your system

{ config, pkgs, ... }:

{
  imports =
    [
      # Include hardware configuration (generated during installation)
      ./hardware-configuration.nix

      # Host-specific configuration
      ./hosts/default/configuration.nix

      # Desktop environment (uncomment one)
      # ./modules/desktop/gnome.nix
      # ./modules/desktop/kde.nix
      # ./modules/desktop/hyprland.nix

      # Hardware-specific modules (uncomment as needed)
      # ./modules/hardware/nvidia.nix
      # ./modules/hardware/laptop.nix

      # Services (uncomment as needed)
      # ./modules/services/docker.nix
      # ./modules/services/virtualization.nix

      # User configuration
      ./users/default-user.nix
    ];

  # System-wide settings that apply regardless of desktop choice

  # Bootloader - systemd-boot (recommended for dual boot)
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10; # Keep last 10 generations
      editor = false; # Disable editor for security
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot"; # or "/boot/efi" depending on your setup
    };
    timeout = 5; # Seconds to show boot menu
  };

  # Networking
  networking = {
    hostName = "nixos"; # Change this to your preferred hostname
    networkmanager.enable = true; # Easy network management

    # Firewall
    firewall = {
      enable = true;
      # allowedTCPPorts = [ 22 80 443 ];
      # allowedUDPPorts = [ ];
    };
  };

  # Time zone and localization
  time.timeZone = "America/New_York"; # Change to your timezone

  # IMPORTANT for dual boot with Windows!
  # Windows uses local time, Linux uses UTC by default
  time.hardwareClockInLocalTime = true;

  # Internationalization
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us"; # or "dvorak", "uk", etc.
  };

  # Enable sound
  sound.enable = true;
  hardware.pulseaudio.enable = false; # Use pipewire instead
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable CUPS for printing
  services.printing.enable = true;

  # Enable firmware updates
  hardware.enableRedistributableFirmware = true;

  # System-wide packages (GUI apps should go in desktop modules)
  environment.systemPackages = with pkgs; [
    # Essential command-line tools
    vim
    wget
    curl
    git
    htop
    btop
    tree
    unzip
    zip
    p7zip

    # File systems
    ntfs3g # For mounting Windows partitions
    exfat # For external drives

    # Network tools
    networkmanagerapplet

    # System info
    neofetch
    pciutils
    usbutils
  ];

  # Enable Nix Flakes (modern Nix features)
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Allow unfree packages (needed for some software like Steam, Discord, etc.)
  nixpkgs.config.allowUnfree = true;

  # SSH server (optional, uncomment if needed)
  # services.openssh = {
  #   enable = true;
  #   settings.PasswordAuthentication = false;
  #   settings.PermitRootLogin = "no";
  # };

  # This value determines the NixOS release with which your system is compatible
  # Don't change this unless you know what you're doing
  system.stateVersion = "24.05"; # Check https://nixos.org/manual/nixos/stable/ for latest
}
