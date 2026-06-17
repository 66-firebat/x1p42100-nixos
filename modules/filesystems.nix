{
  lib,
  ...
}: {
  boot = {
    supportedFilesystems = {
      nfs = true;
      ntfs = true;
      btrfs = true;
    };
    crashDump.enable = true;
  };

  services.fstrim.enable = true;

  time.hardwareClockInLocalTime = false;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/root-arm64";
      fsType = "ext4";
      options = [
        "noatime"
      ];
      neededForBoot = true;
    };

    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = [
        "fmask=0177"
        "dmask=0077"
      ];
    };
  };

  zramSwap.enable = true;
}
