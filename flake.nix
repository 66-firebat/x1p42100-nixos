{
  description = "Minimal NixOS installation media";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  nixConfig = {
    extra-trusted-substituters = [
      "http://silver-star.ling-lizard.ts.net:7124"
    ];
    extra-trusted-public-keys = [
      "tomas-nixos-1:attQnEt6Gq99mwz5J/h8EVhCpavuB0/z/u0Bt/Mko7E="
    ];
  };
  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    pkgs-unpatched = nixpkgs.legacyPackages.aarch64-linux;
    nixpkgs-patched =
      (pkgs-unpatched.applyPatches {
        name = "nixpkgs-patched";
        src = nixpkgs;
        patches = [
          (pkgs-unpatched.fetchpatch {
            url = "https://github.com/NixOS/nixpkgs/commit/de1fdb6310af8f70c98746ba4550dc2799a03621.patch";
            hash = "sha256-brqJxblmqWFAk8JgxmxXeHoiaWiQtsCsOzht/WlH5eE=";
          })
        ];
      }).overrideAttrs
      {allowSubstitutes = true;};
  in {
    nixosModules = {
      x1p = ./modules/x1p42100.nix;
    };
    packages."aarch64-linux".stubble = let
      pkgs = import nixpkgs-patched {
        system = "aarch64-linux";
      };
    in
      pkgs.callPackage ./packages/stubble.nix {};
    nixosConfigurations = {
      slim5xISO = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        system = "aarch64-linux";
        modules = [
          "${nixpkgs-patched}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
          #"${nixpkgs-patched}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ./iso.nix
          ./modules/x1p42100.nix
          {
            # nixpkgs.buildPlatform = "x86_64-linux";
            # pkgsCross.<yourtarget>.system
            # nixpkgs.hostPlatform = "aarch64-linux";

            fileSystems = {
              "/" = {
                device = "/dev/disk/by-label/root-arm64";
                fsType = "btrfs";
              };
              "/boot" = {
                device = "/dev/disk/by-label/BOOT";
                fsType = "vfat";
              };
            };
            nix = {
              settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
            };
            networking.networkmanager.enable = true;
          }
        ];
      };
      qcom-nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        system = "aarch64-linux";
        modules = [
          ./modules/x1p42100.nix
          ./configuration.nix
        ];
      };
    };
  };
}
