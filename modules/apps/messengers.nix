{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    telegram-desktop
    discord
    teams-for-linux
    thunderbird
  ];
}
