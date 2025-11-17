{
  description = "mmariani's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";  # ADD THIS
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }:  # ADD nixpkgs-unstable
    let
      system = "x86_64-linux";
      pkgs-unstable = import nixpkgs-unstable {  # ADD THIS
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.nixos-dev = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit pkgs-unstable; };  # ADD THIS
        modules = [
          ./hosts/proxmox-dev/hardware-configuration.nix
          ./hosts/proxmox-dev/configuration.nix
          
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mmariani = import ./home/mmariani/home.nix;
            home-manager.extraSpecialArgs = { inherit pkgs-unstable; };  # ADD THIS
          }
        ];
      };
    };
}
