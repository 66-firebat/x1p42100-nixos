{
  pkgs,
  lib,
  ...
}: {
  networking.modemmanager.enable = false;

  networking.networkmanager = {
    enable = true;
    settings = {
      device = {
        "wifi.scan-rand-mac-address" = "no";
      };
      connection = {
        "wifi.cloned-mac-address" = "permanent";
        "ethernet.cloned-mac-address" = "permanent";
      };
    };
  };

  # Fix invalid multicast bit in hardcoded bootmac for wcn7850 WiFi chip
  systemd.network.links."10-wlP4p1s0" = {
    matchConfig.PermanentMACAddress = "8d:fd:f0:00:5a:ae";
    linkConfig.MACAddress = "8c:fd:f0:00:5a:ae";
  };

  hardware.bluetooth.enable = true;

  services.tailscale = {
    enable = true;
  };
}
