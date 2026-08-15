{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    telegram-desktop
    discord
    vesktop
    teams-for-linux
    thunderbird
    deltachat-desktop
  ];
}
