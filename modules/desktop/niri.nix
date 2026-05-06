{ config, lib, pkgs, inputs, ... }:

# niri — tiling Wayland compositor
# noctalia-shell запускается через home-manager (programs.niri.settings.spawn-at-startup)
# в users/alexmcgil-home.nix

{
  # Включить niri через nixosModule из flake-input sodiboo/niri-flake
  programs.niri.enable = true;

  # XDG Desktop Portal настраивается автоматически niri-flake при programs.niri.enable = true:
  # - добавляет xdg-desktop-portal-gnome (screencast) и xdg-desktop-portal-gtk
  # - устанавливает config.niri с правильными маппингами интерфейсов
  # Ручная конфигурация здесь конфликтовала бы с config.niri из флейка.

  # Системные пакеты для niri-сессии
  environment.systemPackages = with pkgs; [
    xwayland-satellite
    qt6.qtwayland
  ];

  # Переменные для Qt-приложений в Wayland
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    XDG_CURRENT_DESKTOP = "niri";
    # Активирует Wayland-режим во всех Electron-приложениях из nixpkgs
    # (teams-for-linux, obsidian и др. проверяют эту переменную и добавляют --ozone-platform=wayland)
    NIXOS_OZONE_WL = "1";
    # Резервный механизм для Electron-приложений вне nixpkgs (AppImage, бинарники с auto-update)
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  # XDG Desktop Portal для niri-сессии
  # xdg-desktop-portal-hyprland — screencast/screenshot для wlroots-based compositors
  # Plasma-сессия использует xdg-desktop-portal-kde (задан в plasma.nix)
  xdg.portal = {
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.niri = {
      default = [ "hyprland" "gtk" ];
      "org.freedesktop.impl.portal.Screencast" = [ "hyprland" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
    };
  };
}
