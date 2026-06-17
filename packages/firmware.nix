{
  python3,
  stdenv,
  cabextract,
  rsync,
  fetchurl,
  fetchzip,
  fetchFromGitHub,
  linux-firmware,
  zstd,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "surface-firmware";
  version = "200.0.32.1";
  commit = "30e823d85c1fb4e410a4afdf9cd2285914ee712d";

  sp12 = fetchFromGitHub {
    owner = "harrisonvanderbyl";
    repo = "surface-pro-12-inch-linux";
    rev = "main";
    hash = "sha256-uEfPZjTuS8T8mYGE8h54A4hcOeu6o7E/v3gAJGcavUo=";
  };

  ath12 = fetchzip {
    url = "https://git.codelinaro.org/clo/ath-firmware/ath12k-firmware/-/archive/main/ath12k-firmware-main.tar.gz";
    sha256 = "sha256-DGyEp4+UGGuJ0qiM+jaHl6xOd02hCk92j28fIlGSoK4=";
  };

  board-2 =
    #"${linux-firmware}/lib/firmware/ath12k/WCN7850/hw2.0/board-2.bin";
    "${finalAttrs.ath12}/WCN7850/hw2.0/board-2.bin";

  bdencoder = fetchurl {
    url = "https://raw.githubusercontent.com/qca/qca-swiss-army-knife/f2164085920540f4ecbfa0b12959918c601724b6/tools/scripts/ath12k/ath12k-bdencoder";
    hash = "sha256-hzn/GVo7nZmuBpuBsEZUcf928w03cgANq+kaUlGmeYA=";
  };

  nativeBuildInputs = [
    cabextract
    rsync
    python3
    zstd
  ];

  buildCommand = ''
    mkdir -p $out/lib/firmware/qcom
    cp -va ${finalAttrs.sp12}/lib/firmware/qcom/* $out/lib/firmware/qcom

    mkdir -p $out/share
    if [ -d "${finalAttrs.sp12}/usr/share/alsa" ]; then
      cp -vr ${finalAttrs.sp12}/usr/share/alsa $out/share
    fi

    mkdir -p $out/lib/firmware/ath12k/WCN7850/hw2.0

    #cp -av ${finalAttrs.ath12}/. $out/lib/firmware/ath12k
    #ls -lah $out/lib/firmware/ath12k

    python3 ${finalAttrs.bdencoder} --extract ${finalAttrs.board-2}
    ls -la
    cat board-2.json
    mv "bus=pci,vendor=17cb,device=1107,subsystem-vendor=17cb,subsystem-device=3378,qmi-chip-id=2,qmi-board-id=255.bin" $out/lib/firmware/ath12k/WCN7850/hw2.0/board.bin

    # Decompress GPU ZAP shader firmware so the initrd builder can find and
    # re-compress it correctly (otherwise it stays as .zst and gets double-compressed)
    if [ -f "$out/lib/firmware/qcom/gen71500_zap.mbn.zst" ]; then
      zstd -d "$out/lib/firmware/qcom/gen71500_zap.mbn.zst" -o "$out/lib/firmware/qcom/gen71500_zap.mbn"
      rm "$out/lib/firmware/qcom/gen71500_zap.mbn.zst"
    fi

    find "$out" -exec touch --date=2000-01-01 {} +
  '';
})
