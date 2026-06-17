{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  readmbn = pkgs.callPackage ./packages/readmbn.nix {};
  firm = pkgs.callPackage ./packages/firmware.nix {};

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
  imports = [
    ./hardware.nix
    ./firmware.nix
    # ./ccache.nix
  ];
  nixpkgs.config.allowUnfree = true;

  nix = {
    channel.enable = true;
    optimise.automatic = true;

    package = pkgs.nixVersions.latest;

    settings = {
      auto-optimise-store = true;
      cores = 6;
      # extra-sandbox-paths = [
      #   config.programs.ccache.cacheDir
      #   "/var/log/ccache"
      #   "/mnt/cache/ccache"
      # ];

      use-cgroups = true;
      experimental-features = [
        "nix-command"
        "flakes"
        "cgroups"
      ];
      trusted-users = [
        "root"
        "default"
      ];
    };
  };

  services.fwupd.enable = true;

  users.users = {
    # root.initialPassword = "root";

    default = {
      isNormalUser = true;
      initialPassword = "arm";
      extraGroups = [
        "wheel"
        "dialout"
        "networkmanager"
        "docker"
      ];
      shell = pkgs.bash;
      uid = 1000;
    };
  };

  # programs.ssh = {
  #   extraConfig = ''
  #     Host *
  #      IdentityAgent ~/.1password/agent.sock
  #   '';
  # };

  programs.direnv.enable = true;

  programs.geary.enable = true;
  environment.shells = [pkgs.zsh];
  programs.nh.enable = true;
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = ["default"];
  };
  virtualisation.docker.enable = true;

  # services.cachix-watch-store = {
  #   enable = true;
  #   cacheName = "qcom-x1p42100";
  # };

  nixpkgs.config.segger-jlink.acceptLicense = true;
  programs.virt-manager.enable = true;
  environment.systemPackages = with pkgs; [
    alejandra
    apple-cursor
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
    helix
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
    vscode
    waypipe
    wget2
    wike
    wikiman
    wofi
    yazi
    zellij
    zsh
  ];

  services.keyd = {
    enable = true;
    keyboards."default".settings = {
      main = {
        "leftshift+leftmeta" = "layer(control)";
      };
    };
  };

  services.gvfs.enable = true;
  hardware.wooting.enable = true;
  hardware.sensor.iio.enable = true;
  programs.gphoto2.enable = true;
  programs.zsh.enable = true;
  services.pcscd.enable = true;
  services.tailscale = {
    enable = true;
  };

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

  # rtkit (optional, recommended) allows Pipewire to use the realtime scheduler for increased performance.
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true; # if not already enabled
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment the following
    jack.enable = true;

    wireplumber = {
      enable = true;
    };
  };
  services.cachefilesd.enable = true;

  # The modemmanager is used for cellular connections. It potentially may interfere with the Qualcomm wireless hardware because the wireless interfaces may appears as modems and the modem manager tries to communicate with the wireless interface in vain. It is deactivated for the sp12in
  networking.modemmanager.enable = false;

  # Disable standalone wpa_supplicant - NM manages its own instance
  # systemd.services.wpa_supplicant.enable = false;

  # # set up enivronment so that UCM configs are used as well
  environment.variables.ALSA_CONFIG_UCM2 = "${alsa-ucm-conf-firm}/share/alsa/ucm2";
  systemd.user.services.pipewire.environment.ALSA_CONFIG_UCM2 =
    config.environment.variables.ALSA_CONFIG_UCM2;
  systemd.user.services.wireplumber.environment.ALSA_CONFIG_UCM2 =
    config.environment.variables.ALSA_CONFIG_UCM2;
  systemd.services.pipewire.environment.ALSA_CONFIG_UCM2 =
    config.environment.variables.ALSA_CONFIG_UCM2;
  systemd.services.wireplumber.environment.ALSA_CONFIG_UCM2 =
    config.environment.variables.ALSA_CONFIG_UCM2;

  services.kbfs = {
    enable = true;
    # mountPoint = "/keybase";
    # enableRedirector = true;
    extraFlags = [
      "-label kbfs"
      "-mount-type normal"
      # "-debug"
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

  # security.wrappers."keybase-redirector" = {
  #   owner = "root";
  #   group = "root";
  # };
  # services.udev.extraRules = ''
  #   SUBSYSTEM=="net", ACTION=="add", \
  #     ATTRS{subsystem_device}=="0x1414", \
  #     ATTRS{subsystem_vendor}=="0x00ab", \
  #     ATTRS{vendor}=="0x17cb", \
  #     PROGRAM="${pkgs.iproute2}/bin/ip link set %k address 8c:1d:55:0d:50:54"
  # '';


# systemd.network.units."80-iwd.link".enable = lib.mkForce false;

  # The network manager apparently programmatically attempts to set random MAC addresses for the purposes of privacy and security. However, the current kernel from jglathe hardcodes the MAC address with bootmac; there were some observed conflicts with attaching to a network even if it was detected.
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


# Attempt to switch to an iwd backend, tried with the mac fix to prevent wpa_supplicant from occupying the wireless interface before NetworkManager access
networking.networkmanager.wifi.backend = "iwd";
networking.wireless.iwd.enable = true;

# FAILED: Attempt to stop wpa_supplicant from being restarted, as observed in /etc/udev/rules.d/99-local.rules
# networking.wireless.enable = lib.mkForce false;

# FAILED: Attempt to set a dummy interface because wpa_supplicant.nix generates the 99-local.rules text when it has no interfaces configured, and then injects a restart rule into the rules file, which is problematic because it basically undoes the mac address udev script every time that udev process is invoked.
# networking.wireless.interfaces = [ "none" ];

# This is a udev rule that changes a hardcoded mac. In the current state of the kernel, the multicast bit at the start of the MAC address (8d) is problematic because it is a multicast bit. The udev rule activates whenever a new device is "add"ed to the "net" subsystem, and matches the PCI address of the chip in the system (acquired from dmesg logs). In order to be made protable, KERNELS==<value> may be switched with DRIVER=="ath12k_pci", although this presents a problem if there are multiple ath12k_pci devices, which could cause the ip link to be inadvertently set, causing downstream issues. After the condition has been met, the RUN event invokes the mac change for that specific device (by it's kernel name, %k). Indentation matters, and the wrong indentation will break the rule, so ensure that indendtation rules are being followed.

services.udev.extraRules = ''
SUBSYSTEM=="net", ACTION=="add", KERNELS=="0004:01:00.0", RUN+="${pkgs.iproute2}/bin/ip link set %k address 8c:fd:f0:00:5a:ae"
'';


  # networking = {
  #   hostName = "qcom-nixos";
  #
  #   # wireless = {
  #   #   enable = false; # true; # false;
  #   #   iwd = {
  #   #     enable = true;
  #   #     settings = {
  #   #       General.ControlPortOverNL80211 = false;
  #   #       Settings = {
  #   #         AutoConnect = true;
  #   #         # AlwaysRandomizeAddress = true;
  #   #       };
  #   #       Network = {
  #   #         EnableIPv6 = true;
  #   #         RoutePriorityOffset = 300;
  #   #       };
  #   #       # DriverQuirks.DefaultInterface = "wlan0";
  #   #     };
  #   #   };
  #   # };
  #
  #   networkmanager = {
  #     enable = true;
  #
  #     wifi = {
  #       # powersave = true;
  #       # backend = "iwd";
  #     };
  #   };
  # };

  hardware.bluetooth.enable = true;

  programs = {
    firefox = {
      enable = true;
      package = pkgs.firefox;
    };
    # hyprland = {
    #   enable = true;
    #   package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    #   portalPackage =
    #     inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    # };
  };

  services.openssh.enable = true;

  # boot.plymouth.enable = true;

  services.xserver = {
    enable = true;

    videoDrivers = [
      "modesetting"
      "fbdev"
      # "displaylink"
    ];
  };

  services.desktopManager = {
    gnome = {
      enable = true;
    };
  };

  services.flatpak = {
    enable = true;

    # remotes = [
    #   {
    #     name = "flathub";
    #     location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    #   }
    # ];
  };

  services.displayManager.gdm = {
    enable = true;
    # autoSuspend makes the machine automatically suspend after inactivity.
    # It's possible someone could/try to ssh'd into the machine and obviously
    # have issues because it's inactive.
    # See:
    # * https://github.com/NixOS/nixpkgs/pull/63790
    # * https://gitlab.gnome.org/GNOME/gnome-control-center/issues/22
    autoSuspend = false;
  };

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

  boot = {
    supportedFilesystems = {
      nfs = true;
      ntfs = true;
      btrfs = true;
    };
    crashDump.enable = true;

    # loader.systemd-boot.enable = lib.mkForce false;

    # lanzaboote = {
    #   enable = true;
    #   pkiBundle = "/var/lib/sbctl";
    #   autoEnrollKeys.enable = true;
    #   autoGenerateKeys.enable = true;
    # };

    # kernelModules = ["kvm"];
    kernelParams = [
      #"drm.debug=0x100"
    ];

    # blacklistedKernelModules = [
    #   "qcom-iris"
    #   "soundwire-qcom"
    #   "snd-mixer-oss"
    #   "snd-pcm-oss"
    # ];

    initrd = {
      # availableKernelModules = ["kvm"];
      # compressor = "zstd";
      # compressorArgs = ["-19"];
    };
  };

  services.fstrim.enable = true;

  time = {
    hardwareClockInLocalTime = false;
  };

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

    # "/mnt/cache" = {
    #   device = "192.168.1.102:/volume1/cache";
    #   fsType = "nfs";
    #   options = [
    #     "x-systemd.automount"
    #     "noauto"
    #     "x-systemd.idle-timeout=600"
    #   ];
    # };
  };

  # swapDevices = [
  #   {
  #     device = "/dev/disk/by-partlabel/disk-swap";
  #     size = 16 * 1024;
  #     options = ["discard"];
  #   }
  # ];

  # boot.resumeDevice = "/dev/disk/by-partlabel/disk-swap";
  # boot.kernelPackages = pkgs.callPackage ./packages/x1e42100-linux.nix { withCcache = true; };
  boot.kernelPackages = lib.mkForce (pkgs.callPackage ./packages/x1e42100-linux.nix { withCcache = false; });
  zramSwap.enable = true;

  system.stateVersion = "26.05";
}
