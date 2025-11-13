# NVIDIA GPU Configuration
# Enable this if you have an NVIDIA graphics card

{ config, pkgs, ... }:

{
  # Enable NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Modesetting is required for Wayland
    modesetting.enable = true;

    # Use the open source version of the kernel module (for RTX 20 series and newer)
    # Comment this out if you have an older GPU
    # open = true;

    # Enable power management (experimental, may cause issues)
    powerManagement.enable = false;

    # Fine-grained power management (turns off GPU when not in use)
    # Experimental and only works on modern Nvidia GPUs (Turing or newer)
    powerManagement.finegrained = false;

    # Use the NVidia settings menu
    nvidiaSettings = true;

    # Select the appropriate driver version
    # For latest GPUs, use "stable" or "beta"
    # For older GPUs, you may need "legacy_470" or "legacy_390"
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # For laptop with hybrid graphics (Intel + NVIDIA)
  # Uncomment this section if you have Optimus/hybrid graphics
  # hardware.nvidia.prime = {
  #   sync.enable = true;
  #   # OR use offload mode (better battery life)
  #   # offload = {
  #   #   enable = true;
  #   #   enableOffloadCmd = true;
  #   # };
  #
  #   # Bus IDs of your GPUs - find with: lspci | grep -E "VGA|3D"
  #   intelBusId = "PCI:0:2:0";
  #   nvidiaBusId = "PCI:1:0:0";
  # };

  # Additional packages
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia # GPU monitoring
  ];
}
