{
  config,
  pkgs,
  lib,
  ...
}: let
  slbounce = pkgs.callPackage ../packages/slbounce.nix {};
  qebspil = pkgs.callPackage ../packages/qebspil.nix {};
  firm = pkgs.callPackage ../packages/firmware.nix {};

  dtbloader-new = pkgs.dtbloader.overrideAttrs (finalAttrs: {
    pname = "dtbloader";
    version = "1.5.4";

    src = pkgs.fetchFromGitHub {
      owner = "TravMurav";
      repo = "dtbloader";
      tag = "1.5.4";
      hash = "sha256-2M1S8cBsP/wX8ODAIR3iL7tRBhtpruWRIpBjK7bDku8=";
      fetchSubmodules = true;
    };
  });
  qcom-firmware-paths = [
    "qcom/x1p42100/Microsoft/Surface12/adsp_dtbs.elf"
    "qcom/x1p42100/Microsoft/Surface12/adspr.jsn"
    "qcom/x1p42100/Microsoft/Surface12/adsps.jsn"
    "qcom/x1p42100/Microsoft/Surface12/adspua.jsn"
    "qcom/x1p42100/Microsoft/Surface12/battmgr.jsn"
    "qcom/x1p42100/Microsoft/Surface12/cdsp_dtbs.elf"
    "qcom/x1p42100/Microsoft/Surface12/cdspr.jsn"
    "qcom/x1p42100/Microsoft/Surface12/qcadsp8380.mbn"
    "qcom/x1p42100/Microsoft/Surface12/qcadsprpc8380.cat"
    "qcom/x1p42100/Microsoft/Surface12/qccdsp8380.mbn"
    "qcom/x1p42100/Microsoft/Surface12/qcdxkmbase8380.bin"
    "qcom/x1p42100/Microsoft/Surface12/qcdxkmbase8380_pa_111.bin"
    "qcom/x1p42100/Microsoft/Surface12/qcdxkmsuc8380.mbn"
    "qcom/x1p42100/Microsoft/Surface12/qcdxkmsucpurwa.mbn"
    ];
  boot-firmware = builtins.listToAttrs (map (v: {
      name = "firmware/${v}";
      value = builtins.unsafeDiscardStringContext "${firm}/lib/firmware/${v}";
    })
    qcom-firmware-paths);
in {
  hardware = {
    deviceTree = {
      enable = true;
      name = lib.mkDefault "qcom/x1p42100-microsoft-sp12in.dtb";
    };
    # enableAllFirmware = true; # lib.mkForce false; # true;;
    # enableRedistributableFirmware = true; # lib.mkForce false; # true;;

    firmware = [
      pkgs.linux-firmware
      pkgs.wireless-regdb
      firm
    ];

    enableRedistributableFirmware = true;
  };

  specialisation.el2.configuration = {
    hardware.deviceTree.name = lib.replaceString ".dtb" "-el2.dtb" config.hardware.deviceTree.name;
    boot.kernelParams = ["id_aa64mmfr0.ecv=1"];
  };

  systemd.tpm2.enable = false;

  environment = {
    systemPackages = [ firm ];
    pathsToLink = ["/share/alsa"];
  };

  boot = {
    growPartition = false;
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
        netbootxyz.enable = true;
        edk2-uefi-shell.enable = true;
        consoleMode = "max";
        extraFiles =
          {
            "EFI/systemd/drivers/slbounceaa64.efi" = "${slbounce}/slbounce.efi";
            "EFI/systemd/drivers/qebspilaa64.efi" = "${qebspil}/qebspilaa64.efi";
            "EFI/systemd/drivers/dtbloaderaa64.efi" = "${dtbloader-new}/share/dtbloader/efi/dtbloader.efi";
          }
          // boot-firmware;
      };
    };

    hardwareScan = true;
    initrd = {
      systemd.enable = true;
      systemd.tpm2.enable = false;
      availableKernelModules = [
        # Definitely needed for USB:
        "usb_storage"
        "phy_qcom_qmp_combo"
        "phy_snps_eusb2"
        "phy_qcom_eusb2_repeater"
        "tcsrcc_kaanapali"
        "ext4"
        "btrfs"
        "i2c_hid_of"
        "i2c_qcom_geni"
        "dispcc-x1e80100"
        "gpucc-x1e80100"
        "phy_qcom_edp"
        "panel_edp"
        "nvme"
        "phy_qcom_qmp_pcie"
        "uas"
        # Needed with the DP altmode patches
        "ps883x"
        "pmic_glink_altmode"
        "qrtr"
        "ufs_qcom"
        "phy_qcom_qmp_ufs"
        "uas"
        "typec"
        "cdc_ether"
        "r8152"
      ];
      kernelModules = [
        #"ufshcd_qcom"
        "nvme"
        "f2fs"
        "usb_storage"
        "phy_qcom_qmp_combo"
        "phy_snps_eusb2"
        "phy_qcom_eusb2_repeater"
        "uas"
        "dispcc_x1e80100"
        "gpucc_x1e80100"
        "i2c_hid_of"
        "i2c_qcom_geni"
        "typec"
        "r8152"
      ];

      extraFirmwarePaths =
        [
          "qcom/gen71500_sqe.fw"
          "qcom/gen71500_gmu.bin"
          "qcom/gen71500_zap.mbn"

          "qcom/x1p42100/qcadsp8380.mbn"
          "qcom/x1p42100/qccdsp8380.mbn"
          "qcom/x1p42100/qcdxkmsuc8380.mbn"
          "qcom/x1p42100/qcdxkmsucpurwa.mbn"
          # "qcom/x1p42100/qcvss8380.mbn"
        ]
        ++ qcom-firmware-paths;
    };

    kernelParams = [
      "earlycon=efifb"
      "pd_ignore_unused"
      "clk_ignore_unused"
      "efi=noruntime"
      "efi=debug"
      "pcie_aspm=off"
      "regulator_ignore_unused"
      "console=tty0"
      "loglevel=7"
      # "cma=128MB"
      # "snd-soc-x1e80100.i_accept_the_danger=1"
    ];

    kernelPackages = pkgs.callPackage ../packages/x1e42100-linux.nix {};
  };
}
