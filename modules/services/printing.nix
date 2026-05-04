{ config, lib, pkgs, ... }:

# Печать по умолчанию отключена — раскомментировать при необходимости
{
  # services.printing = {
  #   enable = true;
  #   drivers = with pkgs; [
  #     gutenprint
  #     gutenprintBin
  #   ];
  # };
  # services.avahi = {
  #   enable = true;
  #   nssmdns4 = true;
  #   openFirewall = true;
  # };
}
