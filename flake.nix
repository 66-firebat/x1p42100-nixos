{
  description = "NixOS configuration for Snapdragon X Elite (x1p42100) with Calamares Graphical Installer";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "aarch64-linux"; # Set platform target to ARM64
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # Standard hardware-bound target configs
      nixosConfigurations = {
        x1p42100 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hardware-configuration.nix
            ./configuration.nix
            ./modules/hardware.nix
            ./modules/firmware.nix
          ];
        };

        # New deployment target: Generates a Bootable Graphical Installation ISO 
        iso = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            # Pulls in standard NixOS installer base configurations + Calamares engine
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"

            # Inject the repo's specific Snapdragon device-tree and firmware configurations
            ./modules/hardware.nix
            ./modules/firmware.nix

            # Installer overrides and environmental settings
            ({ pkgs, ... }: {
              nixpkgs.config.allowUnfree = true;

              # Ensures standard non-free Wi-Fi/Bluetooth firmware maps inside the installer environment
              hardware.enableAllFirmware = true;

              # Optional: You can pre-seed specific packages to be available inside the Live CD environment
              environment.systemPackages = with pkgs; [
                git
                neovim
                efibootmgr
              ];
            })
          ];
        };
      };
    };
}
