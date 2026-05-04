{ config, lib, pkgs, ... }:

{
  # Обновление прошивок через LVFS
  services.fwupd.enable = true;
}
