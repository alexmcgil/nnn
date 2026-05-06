{ config, lib, pkgs, ... }:

{
  # Драйвер NVIDIA через xserver
  services.xserver.videoDrivers = [ "nvidia" ];

  # OpenGL / VAAPI
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # NVIDIA-specific
  hardware.nvidia = {
    modesetting.enable = true;
    open = false; # проприетарный драйвер, не open-source ядерный модуль
    nvidiaSettings = true;
    powerManagement.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # KMS параметры для Wayland
  boot.kernelParams = [
    "nvidia_drm.modeset=1"
    "nvidia_drm.fbdev=1"
  ];

  # Переменные среды для Wayland + NVIDIA
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NVD_BACKEND = "direct";
  };

  # NVIDIA Container Toolkit (для Docker с GPU-поддержкой)
  hardware.nvidia-container-toolkit.enable = true;
}
