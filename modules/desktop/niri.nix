{ config, lib, pkgs, inputs, ... }:

# niri — tiling Wayland compositor
# noctalia запускается через home-manager (programs.niri.settings.spawn-at-startup)
# в users/alexmcgil-home.nix

{
  # Включить niri через nixosModule из flake-input sodiboo/niri-flake
  programs.niri.enable = true;

  # niri-flake пока собирает свой пакет с удалённым из unstable
  # libdisplay-info_0_2. Используем актуальный пакет из nixpkgs, который уже
  # переведён на libdisplay-info_0_3, сохраняя модуль конфигурации niri-flake.
  # WORKAROUND NIRI-PACKAGE: niri-flake rev 9ee3e13 требует удалённый libdisplay-info_0_2.
  # Upstream issue/PR: неизвестен. Удалить, когда пакет niri-flake перейдёт на актуальную библиотеку.
  programs.niri.package = lib.warnIf (inputs.niri.rev != "9ee3e13b60643448228353097880521658b2fe0e")
    "WORKAROUND NIRI-PACKAGE: niri-flake обновился; проверьте необходимость подмены пакета"
    pkgs.niri;

  # Системные пакеты для niri-сессии
  environment.systemPackages = with pkgs; [
    xwayland-satellite
    qt6.qtwayland
  ];

  # Переменные для Qt-приложений в Wayland
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    # WORKAROUND NIRI-QT: Qt Quick приложения падают при навязанном стиле Breeze.
    # Upstream issue/PR: неизвестен. Пересмотреть, когда Qt Quick работает с KDE platform theme.
    # NB: QT_QPA_PLATFORMTHEME=kde НЕ задаём — он навязывает QtQuick-стиль
    # org.kde.breeze (требует org.kde.kirigami) всем Qt-Quick приложениям и
    # ломает часть Qt Quick-приложений. dolphin и так берёт иконки/стиль
    # из kdeglobals (KConfig), platform theme для этого не нужен.
    XDG_CURRENT_DESKTOP = "niri";
    # KDE-приложения (Dolphin/Ark/Gwenview) под не-Plasma сессией: KIO строит
    # список приложений и дефолты не из mimeapps.list, а из бинарного кэша KDE
    # ksycoca. Наполняет его kbuildsycoca6, перечисляя .desktop через XDG-меню
    # ${XDG_MENU_PREFIX}applications.menu. Без префикса ищется applications.menu,
    # которого в системе НЕТ (есть только plasma-applications.menu из plasma6) —
    # тогда фабрика приложений в ksycoca собирается ПУСТОЙ, и в Dolphin
    # "Открыть с помощью" пуст + не работают дефолты для всех типов.
    # Явный plasma- чинит это (в чистой Plasma-сессии его выставляет сам Plasma).
    XDG_MENU_PREFIX = "plasma-";
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_DISABLE_RDD_SANDBOX = "1";
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
      # WORKAROUND NIRI-FILECHOOSER: GNOME portal не активирует FileChooser без GNOME Shell.
      # Upstream issue/PR: неизвестен. Удалить, когда GNOME portal сможет открыть диалог здесь.
      # gtk первым — он умеет FileChooser сам, без GNOME Shell
      # gnome первым вызывало: "Delegated FileChooser call failed: The name is not activatable"
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
    };
  };

  # WORKAROUND NIRI-PORTAL: GTK4/Vulkan с NVIDIA выдаёт VK_ERROR_OUT_OF_DATE_KHR.
  # Upstream issue/PR: неизвестен. Удалить, когда gnome-portal работает с Vulkan/NVIDIA.
  # GTK4/Vulkan + GBM_BACKEND=nvidia-drm = VK_ERROR_OUT_OF_DATE_KHR при показе диалога выбора экрана.
  # Для gnome-portal переключаем на GL рендерер и убираем NVIDIA-специфичный GBM/GLX бэкенд.
  systemd.user.services.xdg-desktop-portal-gnome = {
    environment = {
      GSK_RENDERER = "gl";
      __GLX_VENDOR_LIBRARY_NAME = "";
    };
  };
}
