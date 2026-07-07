{ config, lib, pkgs, ... }:

{
  # Steam
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;

    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };

  # GameMode — позволяет играм запрашивать повышение приоритета
  programs.gamemode.enable = true;

  # Steam Hardware (контроллеры Steam Deck, udev rules)
  hardware.steam-hardware.enable = true;
}
