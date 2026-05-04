{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    tdesktop          # Telegram
    discord
    teams-for-linux
    thunderbird
  ];
}
