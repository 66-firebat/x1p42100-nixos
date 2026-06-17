{
  pkgs,
  ...
}: {
  programs = {
    firefox = {
      enable = true;
      package = pkgs.firefox;
    };
  };

  services.xserver = {
    enable = true;
    videoDrivers = [
      "modesetting"
      "fbdev"
    ];
  };

  services.desktopManager = {
    gnome = {
      enable = true;
    };
  };

  services.flatpak = {
    enable = true;
  };

  services.displayManager.gdm = {
    enable = true;
    autoSuspend = false;
  };
}
