{ config, lib, pkgs, ... }:

{
  # KDE Plasma 6 остаётся запасной сессией; экран входа настраивается
  # отдельно в noctalia-greeter.nix.
  services.desktopManager.plasma6.enable = true;

  # Убрать kwallet, elisa, khelpcenter из Plasma
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    kwallet
    kwallet-pam
    kwalletmanager
    elisa
    khelpcenter
  ];

  # XDG порталы для Plasma
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    config.plasma = {
      default = [ "kde" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "kde" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "kde" ];
    };
  };

  # X11 для совместимости (xwayland)
  services.xserver.enable = true;
}
