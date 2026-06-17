{
  config,
  pkgs,
  lib,
  ...
}: let
  firm = pkgs.callPackage ../packages/firmware.nix {};

  alsa-ucm-conf-firm = pkgs.symlinkJoin {
    inherit
      (pkgs.alsa-ucm-conf)
      pname
      version
      src
      passthru
      meta
      ;
    paths = [
      pkgs.alsa-ucm-conf
      pkgs.alsa-ucm-conf-asahi
      firm
    ];
  };
in {
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    wireplumber = {
      enable = true;
    };
  };
  services.cachefilesd.enable = true;

  environment.variables.ALSA_CONFIG_UCM2 = "${alsa-ucm-conf-firm}/share/alsa/ucm2";
  systemd.user.services.pipewire.environment.ALSA_CONFIG_UCM2 =
    config.environment.variables.ALSA_CONFIG_UCM2;
  systemd.user.services.wireplumber.environment.ALSA_CONFIG_UCM2 =
    config.environment.variables.ALSA_CONFIG_UCM2;
  systemd.services.pipewire.environment.ALSA_CONFIG_UCM2 =
    config.environment.variables.ALSA_CONFIG_UCM2;
  systemd.services.wireplumber.environment.ALSA_CONFIG_UCM2 =
    config.environment.variables.ALSA_CONFIG_UCM2;
}
