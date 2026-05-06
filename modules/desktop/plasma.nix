{ config, lib, pkgs, ... }:

{
  # KDE Plasma 6 с SDDM на Wayland
  services.desktopManager.plasma6.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

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
