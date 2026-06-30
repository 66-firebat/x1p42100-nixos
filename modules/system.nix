{
  pkgs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  nix = {
    channel.enable = true;
    optimise.automatic = true;

    package = pkgs.nixVersions.latest;

    settings = {
      auto-optimise-store = true;
      cores = 6;
      use-cgroups = true;
      experimental-features = [
        "nix-command"
        "flakes"
        "cgroups"
      ];
      trusted-users = [
        "root"
	"firebat"
      ];
    };
  };

  services.fwupd.enable = true;

  users.users = {
    firebat = {
      isNormalUser = true;
      initialPassword = "arm";
      extraGroups = [
        "wheel"
        "dialout"
        "networkmanager"
        "docker"
	"plugdev"
	"storage"
	"video"
	"audio"
	"input"
      ];
      shell = pkgs.bash;
      uid = 1000;
    };
  };

  programs.direnv.enable = true;
  environment.shells = [pkgs.bash];
  programs.nh.enable = true;
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = ["firebat"];
  };
  nixpkgs.config.segger-jlink.acceptLicense = true;
}
