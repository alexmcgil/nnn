{ config, lib, pkgs, ... }:

{
  # Intel CPU-специфичные настройки
  hardware.enableRedistributableFirmware = true;

  # Микрокод Intel
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Планировщик для Intel
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # Intel P-State
  boot.kernelParams = [ "intel_pstate=active" ];
}
