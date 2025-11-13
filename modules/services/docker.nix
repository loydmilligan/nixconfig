# Docker and Container Support
# Enable this for Docker development

{ config, pkgs, ... }:

{
  # Enable Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;

    # Automatically prune old images and containers
    autoPrune = {
      enable = true;
      dates = "weekly";
    };

    # Use the latest Docker version
    # package = pkgs.docker;
  };

  # Add your user to the docker group (replace "yourusername")
  # users.users.yourusername.extraGroups = [ "docker" ];

  # Docker compose
  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker # TUI for docker management
  ];
}
