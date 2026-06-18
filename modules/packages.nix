{
  pkgs,
  inputs,
  ...
}: let
  readmbn = pkgs.callPackage ../packages/readmbn.nix {};
in {
  environment.systemPackages = with pkgs; [
    inputs.llm-agents.packages.${pkgs.stdenv.system}.pi
    alejandra
    attic-client
    bottles
    bottom
    btop
    btrfs-assistant
    cachix
    calc
    caligula
    chromium
    contact
    darktable
    devcontainer
    devenv
    direnv
    distrobox
    firefoxpwa
    firmware-manager
    firmware-updater
    flatpak-builder
    fractal
    fzf
    gcc
    gdu
    gh
    ghostty
    git
    gnome-firmware
    gnome-tweaks
    gnumake
    gparted-full
    htop
    hw-probe
    kitty
    lazygit
    lm_sensors
    lshw
    minicom
    mission-center
    ncdu
    neovim
    nil
    nix-index
    nix-init
    nix-search
    nix-search-cli
    nix-search-tv
    nixd
    nom
    nrfconnect
    pciutils
    pv
    pwvucontrol
    readmbn
    sshfs
    refine
    resilio-sync
    ripgrep
    rsync
    squashfs-tools-ng
    squashfsTools
    starship
    systemctl-tui
    telegram-desktop
    television
    tio
    tv
    usbutils
    uxplay
    waypipe
    wget2
    wike
    wikiman
    wofi
    yazi
    zsh
  ];

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.adwaita-mono
      adwaita-fonts
    ];
  };

  services.kmscon = {
    enable = true;
    fonts = [
      {
        name = "AdwaitaMono-Regular";
        package = pkgs.adwaita-fonts;
      }
    ];
  };
}
