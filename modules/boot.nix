{ config, lib, pkgs, ... }:

{
  # Ядро — всегда последнее стабильное
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # systemd-boot
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
      editor = false; # безопасность: запретить редактирование cmdline в загрузчике
    };
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };

  # Поддержка NTFS (на случай внешних дисков Windows)
  boot.supportedFilesystems = [ "ntfs" ];
}
