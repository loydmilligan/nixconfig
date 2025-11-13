# User Configuration
# Edit this file to configure your user account and packages

{ config, pkgs, ... }:

{
  # Define your user account
  users.users.yourusername = {  # CHANGE THIS to your desired username
    isNormalUser = true;
    description = "Your Full Name";  # CHANGE THIS

    # User groups - these grant various permissions
    extraGroups = [
      "wheel"          # sudo access
      "networkmanager" # network management
      "audio"          # audio devices
      "video"          # video devices
      # "docker"       # docker (uncomment if using docker module)
      # "libvirtd"     # virtualization (uncomment if using virtualization module)
    ];

    # Set initial password (change this after first login!)
    # Generate a hashed password with: mkpasswd -m sha-512
    # Or set it manually after installation with: passwd yourusername
    # initialPassword = "changeme";

    # User-specific packages
    packages = with pkgs; [
      # Development tools
      git
      neovim
      vscode # or vscodium for fully open-source version

      # Terminal tools
      tmux
      zsh
      fish
      ripgrep
      fd
      bat
      eza # modern ls replacement
      fzf

      # Browsers
      firefox
      chromium

      # Communication
      # discord
      # slack
      # teams

      # Media
      vlc
      spotify
      # mpv

      # Utilities
      libreoffice
      gimp
      # inkscape

      # System monitoring
      btop
      htop

      # Archive tools
      unzip
      zip
      p7zip

      # Note-taking
      # obsidian
      # notion
    ];
  };

  # Configure shell
  programs.zsh.enable = true;
  # programs.fish.enable = true;

  # Set default shell for your user (uncomment to use zsh or fish)
  # users.users.yourusername.shell = pkgs.zsh;
  # users.users.yourusername.shell = pkgs.fish;

  # Git configuration (system-wide)
  programs.git = {
    enable = true;
    config = {
      # user = {
      #   name = "Your Name";
      #   email = "your.email@example.com";
      # };
      init.defaultBranch = "main";
    };
  };

  # Enable home-manager for advanced user configuration
  # Uncomment after installing home-manager
  # home-manager.users.yourusername = { pkgs, ... }: {
  #   home.stateVersion = "24.05";
  #
  #   programs.git = {
  #     enable = true;
  #     userName = "Your Name";
  #     userEmail = "your.email@example.com";
  #   };
  #
  #   programs.vscode = {
  #     enable = true;
  #     extensions = with pkgs.vscode-extensions; [
  #       bbenoist.nix
  #       ms-python.python
  #     ];
  #   };
  # };
}
