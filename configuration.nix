{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./modules/system.nix
    ./modules/packages.nix
    ./modules/audio.nix
    ./modules/networking.nix
    ./modules/desktop.nix
    ./modules/services.nix
    ./modules/filesystems.nix
  ];

  system.stateVersion = "26.05";
}
