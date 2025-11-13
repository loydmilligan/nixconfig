# Virtualization Support (QEMU/KVM, libvirt, virt-manager)
# Enable this for running virtual machines

{ config, pkgs, ... }:

{
  # Enable libvirt and QEMU
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      ovmf.enable = true; # UEFI support
      ovmf.packages = [ pkgs.OVMFFull.fd ];
      swtpm.enable = true; # TPM emulation
    };
  };

  # Enable virt-manager for GUI management
  programs.virt-manager.enable = true;

  # Add your user to libvirtd group (replace "yourusername")
  # users.users.yourusername.extraGroups = [ "libvirtd" ];

  # Useful packages
  environment.systemPackages = with pkgs; [
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    win-virtio # Windows guest drivers
    win-spice # Windows guest tools
  ];

  # Enable USB redirection
  virtualisation.spiceUSBRedirection.enable = true;
}
