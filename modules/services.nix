{
  pkgs,
  lib,
  config,
  ...
}: {

  services.keyd = {
    enable = true;
    settings = {
      main = {
        # Maps capslock to the overload function
        # overload(layer, action_on_tap)
        # 'control' is a built-in layer in keyd
        capslock = "overload(control, esc)";
      };
    };
  };

  services.gvfs.enable = true;
  hardware.wooting.enable = true;
  hardware.sensor.iio.enable = true;
  programs.gphoto2.enable = true;
  programs.zsh.enable = true;
  services.pcscd.enable = true;
  programs.geary.enable = true;

  services.kbfs = {
    enable = true;
    extraFlags = [
      "-label kbfs"
      "-mount-type normal"
    ];
  };

  systemd.user.services.kbfs = {
    environment = {
      PATH = lib.mkForce "/run/wrappers/bin";
      KEYBASE_SYSTEMD = "1";
    };
    serviceConfig = {
      ExecStartPre = lib.mkForce [
        "${pkgs.coreutils}/bin/mkdir -p \"${config.services.kbfs.mountPoint}\""
      ];
      PrivateTmp = lib.mkForce null;
    };
  };

  virtualisation.docker.enable = true;
  programs.virt-manager.enable = true;

  services.openssh.enable = true;
  services.hardware.bolt.enable = true;
  hardware.flipperzero.enable = true;

  services.avahi = {
    enable = true;
    openFirewall = true;
    publish = {
      workstation = true;
      userServices = true;
    };
  };

  services.rpcbind.enable = true;
  services.fstrim.enable = true;
}
