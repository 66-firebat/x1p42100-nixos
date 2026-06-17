{ pkgs, ... }:

let
  surface_12_repo = pkgs.fetchFromGitHub {
    owner = "harrisonvanderbyl";
    repo = "surface-pro-12-inch-linux";
    rev = "main"; 
    # Cache-busting zero-hash to force an absolute fresh download from GitHub
    hash = "sha256-uEfPZjTuS8T8mYGE8h54A4hcOeu6o7E/v3gAJGcavUo="; 
  };

  harrison-firmware = pkgs.runCommand "snapdragon-firmware" {
    # Hard boundary: ensure the output derivation itself contains no outside references
    allowedReferences = [ "out" ]; 
    src = surface_12_repo;
  } ''
    # 1. Create the base target destination tree
    mkdir -p $out/lib

    # 2. Copy the entire firmware folder tree wholesale.
    # This completely eliminates bash wildcard (*) expansion parsing issues.
    cp -R $src/lib/firmware $out/lib/
  '';
in
{
  nixpkgs.config.allowUnfree = true;

  # Load our hand-curated folder layout into the system firmware array
  hardware.firmware = [ harrison-firmware ];

  # Load the core system storage and graphics controllers into Stage 1
  boot.initrd.kernelModules = [ "nvme" "qcom-iris" ];

  # Point the Stage 1 initrd loader directly to our ultra-lean, un-referenced store path
  # boot.initrd.extraFirmwarePaths = [
  #  "${harrison-firmware}/lib/firmware"
  # ];

  # Standard working systemd-boot setup
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  boot.kernelParams = [
    "earlycon=efifb"
    # "video=efifb:off"
    "clk_ignore_unused"
    "pd_ignore_unused"
    "efi=debug"
    "loglevel=7"
  ];
}
