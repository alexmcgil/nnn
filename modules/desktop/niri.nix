{ config, lib, pkgs, inputs, ... }:

# niri — tiling Wayland compositor
# noctalia-shell запускается через home-manager (programs.niri.settings.spawn-at-startup)
# в users/alexmcgil-home.nix

{
  # Включить niri через nixosModule из flake-input sodiboo/niri-flake
  programs.niri.enable = true;

  programs.niri.settings.environment = {
    GBM_BACKEND = "nvidia-drm";
  };

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
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_DISABLE_RDD_SANDBOX = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    # Активирует Wayland-режим во всех Electron-приложениях из nixpkgs
    # (teams-for-linux, obsidian и др. проверяют эту переменную и добавляют --ozone-platform=wayland)
    NIXOS_OZONE_WL = "1";
    # Резервный механизм для Electron-приложений вне nixpkgs (AppImage, бинарники с auto-update)
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  xdg.portal.config = {
    common = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
    };
    niri = {
      default = [ "gnome" "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
    };
  };

  # GTK4/Vulkan + GBM_BACKEND=nvidia-drm = VK_ERROR_OUT_OF_DATE_KHR при показе диалога выбора экрана.
  # Для gnome-portal переключаем на GL рендерер и убираем NVIDIA-специфичный GBM/GLX бэкенд.
  systemd.user.services.xdg-desktop-portal-gnome = {
    environment = {
      GSK_RENDERER = "gl";
      GBM_BACKEND = "";
      __GLX_VENDOR_LIBRARY_NAME = "";
    };
  };
}
