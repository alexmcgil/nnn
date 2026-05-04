{ config, lib, pkgs, ... }:

{
  # OpenRGB — управление RGB-подсветкой
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd"; # для desktop-amd; для laptop-intel поменять на "intel"
  };
}
