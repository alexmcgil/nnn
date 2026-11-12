{ config, lib, pkgs, ... }:

{
  # WORKAROUND STEAM-UI-STARTUP: клиент Valve 1794424036 зависает при запуске интерфейса.
  # Локальный патч ~/.local/share/Steam/steamui/sp.js и откат: docs/workarounds.md.
  # Удалить после проверки штатного клиента без патча; upstream issue пока не найден.
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
