{
  lib,
  fetchFromGitHub,
  buildLinux,
  linuxPackagesFor,
  ccacheStdenv,
  fetchpatch,
  stdenv,
  withCcache ? false,
  ...
}: let
  versions = {
    linux_6_19 = {
      version = "6.19.14";
      rev = "jg/ubuntu-qcom-x1e-6.19.y";
      sha256 = "sha256-+geHPb+Y2RxH4Yt/OyBgsQg0iG7RFoXEYcK0C29k4GI=";
    };
    linux_7_1 = {
      version = "7.1.0-rc7";
      rev = "jg/ubuntu-qcom-x1e-7.1rc";
      sha256 = "sha256-vii+q1JIJGytEvcUQKjtTC0VMsoqv/b8h8RB9Y1M4+U=";
    };
  };

  selected = versions.linux_7_1;
in
  linuxPackagesFor (
    (buildLinux {
      version = selected.version;

      src = fetchFromGitHub {
        owner = "jglathe";
        repo = "linux_ms_dev_kit";
        inherit (selected) rev sha256;
      };

      kernelPatches = [
        # Previously, we needed a mac-address patch to fix the devicetree (dts) file to hardcode the mac address the devicetree. It was no longer needed in the 7.1 kernels
        # {
        #   name = "mac-address";
        #   patch = ./mac-address.patch;
        # }
      ];

      structuredExtraConfig = with lib.kernel; {
        CLK_X1E80100_CAMCC = yes;
        CLK_X1P42100_GPUCC = yes;
        HZ_1000 = yes;
        MFD_QCOM_RPM = yes;
        PCIE_QCOM = yes;
        PHY_QCOM_QMP = yes;
        PHY_QCOM_QMP_PCIE = yes;
        QCOM_CLK_RPM = yes;
        REGULATOR_QCOM_RPM = yes;
        SCHED_CLUSTER = yes;
        TYPEC = yes;
        VIRTUALIZATION = yes;
        KVM = yes;
        MAGIC_SYSRQ = yes;
        FW_LOADER_COMPRESS = yes;
        FW_LOADER_COMPRESS_ZSTD = yes;
        CRYPTO_ZSTD = yes;
      };

      #   # Stuff to reduce compile times.
      #   ACPI = no;

      #   HOTPLUG_PCI = no;

      #   PREEMPT_LAZY = yes;
      #   PREEMPT_VOLUNTARY = yes;

      #   ARCH_ACTIONS = no;
      #   ARCH_AIROHA = no;
      #   ARCH_SUNXI = no;
      #   ARCH_ALPINE = no;
      #   ARCH_APPLE = no;
      #   ARCH_AXIADO = no;
      #   ARCH_BCM = no;
      #   ARCH_BCM2835 = no;
      #   ARCH_BCM_IPROC = no;
      #   ARCH_BCMBCA = no;
      #   ARCH_BRCMSTB = no;
      #   ARCH_BERLIN = no;
      #   ARCH_BLAIZE = no;
      #   ARCH_CIX = no;
      #   ARCH_EXYNOS = no;
      #   ARCH_SPARX5 = no;
      #   ARCH_K3 = no;
      #   ARCH_LG1K = no;
      #   ARCH_HISI = no;
      #   ARCH_KEEMBAY = no;
      #   ARCH_MEDIATEK = no;
      #   ARCH_MESON = no;
      #   ARCH_MVEBU = no;
      #   ARCH_NXP = no;
      #   ARCH_LAYERSCAPE = no;
      #   ARCH_MXC = no;
      #   ARCH_S32 = no;
      #   ARCH_MA35 = no;
      #   ARCH_NPCM = no;
      #   ARCH_REALTEK = no;
      #   ARCH_RENESAS = no;
      #   ARCH_ROCKCHIP = no;
      #   ARCH_SEATTLE = no;
      #   ARCH_INTEL_SOCFPGA = no;
      #   ARCH_SOPHGO = no;
      #   ARCH_STM32 = no;
      #   ARCH_SYNQUACER = no;
      #   ARCH_TEGRA = no;
      #   ARCH_TESLA_FSD = no;
      #   ARCH_SPRD = no;
      #   ARCH_THUNDER = no;
      #   ARCH_THUNDER2 = no;
      #   ARCH_UNIPHIER = no;
      #   ARCH_VEXPRESS = no;
      #   ARCH_VISCONTI = no;
      #   ARCH_XGENE = no;
      #   ARCH_ZYNQMP = no;

      #   DRM_NOUVEAU = no;
      #   DRM_ETNAVIV = no;
      #   DRM_HISI_HIBMC = no;
      #   DRM_HISI_KIRIN = no;
      #   DRM_LIMA = no;
      #   DRM_PANFROST = no;
      #   DRM_PANTHOR = no;
      #   DRM_TIDSS = no;
      #   DRM_POWERVR = no;

      #   WLAN_VENDOR_ADMTEK = no;
      #   WLAN_VENDOR_ATMEL = no;
      #   WLAN_VENDOR_BROADCOM = no;
      #   WLAN_VENDOR_INTEL = no;
      #   WLAN_VENDOR_INTERSIL = no;
      #   WLAN_VENDOR_MARVELL = no;
      #   WLAN_VENDOR_MEDIATEK = no;
      #   WLAN_VENDOR_MICROCHIP = no;
      #   WLAN_VENDOR_PURELIFI = no;
      #   WLAN_VENDOR_RALINK = no;
      #   WLAN_VENDOR_REALTEK = no;
      #   WLAN_VENDOR_RSI = no;
      #   WLAN_VENDOR_SILABS = no;
      #   WLAN_VENDOR_ST = no;
      #   WLAN_VENDOR_TI = no;
      #   WLAN_VENDOR_ZYDAS = no;
      #   WLAN_VENDOR_QUANTENNA = no;
      #   SND_DRIVERS = no;
      #   SND_PCI = no;
      # };
    })
    .override {stdenv = if withCcache then ccacheStdenv else stdenv;}
  )
