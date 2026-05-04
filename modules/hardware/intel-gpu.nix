{ config, lib, pkgs, ... }:

{
  # Intel iGPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver   # VAAPI для современных Intel (Broadwell+)
      intel-vaapi-driver   # Старые Intel (до Broadwell)
      libva-vdpau-driver   # VDPAU через VAAPI (бывший vaapiVdpau)
      libvdpau-va-gl
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # intel-media-driver
  };
}
