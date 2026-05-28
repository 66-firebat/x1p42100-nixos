{ runCommand, fetchFromGitHub, lib, ... }: let
  #slim5x = ../firmware;
  # CHANGED: Updated the file list brace expansion to precisely match the files 
  # present in the harrisonvanderbyl/surface-pro-12-inch-linux repository image.
  # Removed 4 obsolete/missing firmware blobs and added 3 new ones present in the repo.
  surface_12 = fetchFromGitHub {
    owner = "harrisonvanderbyl";
    repo = "surface-pro-12-inch-linux";
    rev = "0ce39c52a0a53787b1eebc209ff3bb86f1e517d0";
    hash = "sha256-kIAdIJUrvFn4cpcLG6aAsm00l/WnHn4Knz9vnTen1as=";
  };
in runCommand "harrison-qcom-laptops-firmware" {} ''
  mkdir -p $out/lib/firmware/qcom/x1p42100/Microsoft/Surface12
cp ${surface_12}/lib/firmware/qcom/x1p42100/Microsoft/Surface12/{adsp_dtbs.elf,adspr.jsn,adsps.jsn,adspua.jsn,battmgr.jsn,cdsp_dtbs.elf,cdspr.jsn,qcadsp8380.mbn,qcadsprpc8380.cat,qccdsp8380.mbn,qcdxkmbase8380.bin,qcdxkmbase8380_pa_111.bin,qcdxkmsuc8380.mbn,qcdxkmsucpurwa.mbn} $out/lib/firmware/qcom/x1p42100/Microsoft/Surface12/
''

