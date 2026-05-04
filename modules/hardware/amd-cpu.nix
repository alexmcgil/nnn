{ config, lib, pkgs, ... }:

{
  # AMD CPU-специфичные настройки
  hardware.enableRedistributableFirmware = true;

  # Микрокод AMD
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Планировщик задач — schedutil хорош для Zen-архитектур
  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

  # AMD P-State (для Zen 4+/5+, включая 9950X3D)
  boot.kernelParams = [ "amd_pstate=active" ];
}
